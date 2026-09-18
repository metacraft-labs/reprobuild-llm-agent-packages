## Catalog conformance for the agent interfaces and their realizations.
##
## What this asserts, and why each one is worth a test:
##
##   * every published interface registers exactly once — a package defined
##     twice resolves to whichever module was imported, which is the
##     import-order dependence the contribution model exists to rule out;
##   * every contribution's ``interfaceFingerprint`` equals the canonical
##     fingerprint of the interface it names — a stale pin must FAIL rather
##     than be applied to a contract it was never checked against;
##   * the interface artifact round-trips through encode/decode with its
##     contributions intact, because that artifact is what an external
##     consumer reads without executing a provider;
##   * a vendor-binary realization covers every platform it claims, with a
##     distinct digest per slice. A copy-pasted digest across two platforms
##     is the specific authoring mistake that yields a package which
##     resolves everywhere and runs on one machine.

import std/[os, sequtils, sets, strutils, unittest]

import repro_interface_artifacts
import repro_project_dsl

import "../packages/interfaces/claude-code/repro" as claudeCodeInterface
import "../packages/interfaces/codex/repro" as codexInterface
import "../packages/interfaces/gemini-cli/repro" as geminiCliInterface
import "../packages/interfaces/goose/repro" as gooseInterface
import "../packages/interfaces/opencode/repro" as opencodeInterface
import "../packages/interfaces/qwen-code/repro" as qwenCodeInterface
import "../packages/interfaces/copilot/repro" as copilotInterface
import "../packages/interfaces/codex-acp/repro" as codexAcpInterface
import "../packages/interfaces/claude-code-acp/repro" as claudeCodeAcpInterface

import "../packages/vendor/claude-code/repro" as claudeCodeVendor
import "../packages/vendor/codex/repro" as codexVendor
import "../packages/vendor/goose/repro" as gooseVendor
import "../packages/vendor/opencode/repro" as opencodeVendor
import "../packages/vendor/copilot/repro" as copilotVendor
import "../packages/vendor/codex-acp/repro" as codexAcpVendor
import "../packages/vendor/gemini-cli/repro" as geminiCliVendor
import "../packages/vendor/qwen-code/repro" as qwenCodeVendor
import "../packages/vendor/claude-code-acp/repro" as claudeCodeAcpVendor

import ../tools/coverage_report as coverage

const PublishedInterfaces = [
  "claude-code", "claude-code-acp", "codex", "codex-acp", "copilot",
  "gemini-cli", "goose", "opencode", "qwen-code"]

suite "LLM agent catalog":
  test "each published interface is registered exactly once":
    let packages = registeredPackages()
    for name in PublishedInterfaces:
      let matches = packages.filterIt(it.packageName == name)
      check matches.len == 1

  test "every interface exports at least one executable member":
    let packages = registeredPackages()
    for name in PublishedInterfaces:
      let target = packages.filterIt(it.packageName == name)[0]
      check target.executables.len >= 1

  test "goose declares only the program its release archive ships":
    # Regression guard for a correction: an earlier draft of this interface
    # also declared `goosed`, reasoning from Goose's architecture rather than
    # from its artifacts. `goosed` ships in the Desktop application, not in
    # the CLI release archive, so that member was unsatisfiable and every
    # realization would have failed conformance for it.
    let packages = registeredPackages()
    let goosePkg = packages.filterIt(it.packageName == "goose")[0]
    let members = goosePkg.executables.mapIt(it.exportName).toHashSet()
    check "goose" in members
    check "goosed" notin members

  test "contributions pin the canonical fingerprint of their target":
    let packages = registeredPackages()
    let contributions = registeredProvisioningContributions()
    check contributions.len >= 1
    for contribution in contributions:
      let targets = packages.filterIt(
        it.packageName == contribution.targetPackage)
      check targets.len == 1
      check contribution.targetInterfaceFingerprint ==
        canonicalPackageInterfaceFingerprint(targets[0], packages)

  test "codex reconciles its triple-suffixed binary to the invoked name":
    # Upstream ships `codex-<triple>.exe`; every consumer invokes `codex`. A
    # realized prefix goes on PATH as a directory, so without an alias the
    # plain name never resolves - which is why the environment this catalog
    # replaces had to synthesise a codex.exe shim outside any store.
    let codexSlices = registeredProvisioningContributions()
      .filterIt(it.targetPackage == "codex")[0].tarballProvisioning
    check codexSlices.len == 2
    for slice in codexSlices:
      check slice.executablePath.startsWith("codex-")
      check slice.executableAlias == "codex.exe"

  test "the two npm agents are launched, not executed":
    # Both publish a self-contained esbuild bundle with ZERO dependencies,
    # so neither needs a closure resolver -- what they needed was a way to
    # be INVOKED. A realized prefix goes on PATH as a directory, so a
    # command's name there is a file's own name, and `bundle/gemini.js` is
    # not a program on any host.
    #
    # `launcher` is what closes that: realize writes the launcher pair npm
    # would have generated, taking its name from `executableAlias`. This
    # case pins all three fields together, because any one of them alone is
    # a prefix whose declared command cannot run.
    for (pkg, script, alias) in [
      ("gemini-cli", "bundle/gemini.js", "gemini"),
      ("qwen-code", "cli-entry.js", "qwen"),
    ]:
      let contributions = registeredProvisioningContributions().filterIt(
        it.targetPackage == pkg)
      check contributions.len == 1
      let slices = contributions[0].tarballProvisioning
      check slices.len == 1
      let slice = slices[0]
      checkpoint(pkg & " -> " & slice.url)
      check slice.executablePath == script
      check slice.executableAlias == alias
      check slice.launcher == "node"
      # npm tarballs are rooted at `package/`, a wrapper rather than part
      # of the layout. Without the strip the declared path never resolves.
      check slice.stripComponents == 1
      check slice.archiveType == "tar.gz"
      check slice.url.startsWith("https://registry.npmjs.org/")
      # The bundle is JavaScript: the same bytes are correct on every host,
      # and a stray platform constraint would make it unresolvable
      # everywhere else. The per-platform part is the interpreter, which is
      # a different package.
      check slice.cpu.len == 0
      check slice.os.len == 0

  test "the ACP adapter carries its dependency closure, not a build step":
    # The npm agent a self-contained bundle does not cover: 174 KB with
    # five direct dependencies and 97 transitive. Declared as one tarball
    # it would realize a prefix whose command cannot start; resolved with
    # `npm install` at build time it would be a version-range resolution
    # and a network fetch inside a build.
    let contributions = registeredProvisioningContributions().filterIt(
      it.targetPackage == "claude-code-acp")
    check contributions.len == 1
    let slices = contributions[0].tarballProvisioning
    check slices.len == 1
    let slice = slices[0]
    check slice.closureManifest == "closures/claude-code-acp.manifest"
    # The same launcher shape the other npm agents use: `dist/index.js` is
    # a script, and the alias is the name npm's own `bin` publishes.
    check slice.executablePath == "dist/index.js"
    check slice.executableAlias == "claude-code-acp"
    check slice.launcher == "node"
    check slice.stripComponents == 1
    check slice.cpu.len == 0
    check slice.os.len == 0

  test "the committed closure manifest is well formed and pinned":
    # Read as DATA rather than trusted: every line must carry a
    # prefix-relative path, a 64-char sha256 and a registry URL, because a
    # malformed line is only discovered at realize time otherwise -- on
    # whatever machine first tries to install the adapter.
    # Anchored to this source file rather than to the working directory,
    # which differs between `nim c -r` from the root and a built binary
    # invoked from anywhere.
    let repoRoot = parentDir(parentDir(currentSourcePath()))
    let manifest = repoRoot /
      "packages" / "vendor" / "claude-code-acp" / "closures" /
      "claude-code-acp.manifest"
    check fileExists(manifest)
    var entries = 0
    var paths = initHashSet[string]()
    for rawLine in readFile(manifest).splitLines():
      let line = rawLine.strip()
      if line.len == 0 or line.startsWith("#"):
        continue
      let parts = line.splitWhitespace()
      checkpoint(line)
      check parts.len == 3
      check parts[0].startsWith("node_modules/")
      check (not parts[0].contains(".."))
      check parts[1].len == 64
      check parts[2].startsWith("https://registry.npmjs.org/")
      # A path repeated across two entries means one dependency is
      # overwriting another's tree, and the last one written would win
      # silently.
      check parts[0] notin paths
      paths.incl(parts[0])
      inc entries
    # The closure npm recorded, minus the root archive itself.
    check entries == 97

  test "the claude-code vendor realization covers six distinct platforms":
    let contributions = registeredProvisioningContributions().filterIt(
      it.targetPackage == "claude-code")
    check contributions.len == 1
    let slices = contributions[0].tarballProvisioning
    check slices.len == 6
    # A digest repeated across two slices means one platform is serving the
    # other's bytes. Distinctness is the cheap check that catches it.
    var digests = initHashSet[string]()
    var platforms = initHashSet[string]()
    for slice in slices:
      digests.incl(slice.sha256)
      platforms.incl(slice.cpu & "-" & slice.os)
    check digests.len == 6
    check platforms.len == 6

  test "the interface artifact round-trips with its contributions":
    let artifact = artifactFromRegisteredDsl(
      parentDir(getCurrentDir()) / "repro.nim")
    let expected = registeredProvisioningContributions().len
    check artifact.projectInterface.provisioningContributions.len == expected
    let roundTrip = decodeProjectInterfaceArtifact(
      encodeProjectInterfaceArtifact(artifact))
    check roundTrip.projectInterface.provisioningContributions.len == expected

suite "the upstream inventory and the catalog agree":
  ## `inventory/upstream.toml` is what the coverage report is generated
  ## from, and an inventory nobody checks drifts from the catalog it
  ## describes and then reads as a status report while being a wish list.
  ## It had drifted: `codex-acp` was listed as packaged AND as uncovered,
  ## and `amp` and `claude-code-acp` each appeared twice with different
  ## reasons.
  let inv = coverage.loadInventoryFile()

  test "the inventory makes no claim the catalog contradicts":
    # THE GATE. Every disagreement `tools/coverage_report.nim` knows how to
    # find, reported by name: a duplicate row, a name in both sections, a
    # claimed interface with no registered package, a registered package
    # the inventory does not mention, a realization with no version, an
    # interface-only row with no reason.
    let found = coverage.problems(inv, coverage.registeredPackageNames())
    for problem in found:
      checkpoint(problem)
    check found.len == 0

  test "every published interface is in the inventory, and vice versa":
    # The two lists are maintained in different files by different edits,
    # so they are exactly the kind of pair that comes apart silently.
    var inventoried = initHashSet[string]()
    for entry in inv.agent:
      inventoried.incl(entry.name)
    for name in PublishedInterfaces:
      check name in inventoried
    check inventoried.len == PublishedInterfaces.len

  test "an interface with no realization says why, and it is not silence":
    # The distinction the report exists for: "nobody built the recipe" and
    # "upstream's only channel is one this catalog cannot provision" need
    # different answers, and today every uncovered agent is the second.
    for entry in inv.agent:
      if coverage.hasRealization(entry):
        continue
      checkpoint(entry.name)
      check entry.realization_blocked.strip().len > 0
      check entry.realization_blocked.contains("npm")

  test "the report renders every row it was given":
    let report = coverage.renderReport(inv)
    for entry in inv.agent:
      check report.contains(entry.name)
    for entry in inv.uncovered:
      check report.contains(entry.name)
    check report.contains("No interface in this catalog")

  test "the report still has a section for an unrealized interface":
    # Asserted against a SYNTHETIC entry rather than against the live
    # inventory. It used to read the real one, which quietly made this a
    # test that the catalog stays INCOMPLETE: the day the last unrealized
    # interface got a realization -- gemini-cli and qwen-code, once
    # `launcher` existed -- the section disappeared and a renderer test
    # failed for a reason that was good news.
    var synthetic = Inventory(agent: @[AgentEntry(
      name: "fixture-agent",
      provenance_class: "source-available",
      main_programs: @["fixture"],
      release_channel: "npm",
      observed_pin: "1.0.0",
      packaged: @["interface"],
      realization_blocked: "npm-only, and nothing provisions it yet.")])
    let syntheticReport = coverage.renderReport(synthetic)
    check syntheticReport.contains("Interface defined, no realization")
    check syntheticReport.contains("fixture-agent")
    check syntheticReport.contains("npm-only")

suite "non-redistributable payloads cannot reach a shared cache":
  ## The catalog's AGENTS.md has said since it was seeded that a
  ## vendor-binary payload is fetched on the user's behalf and must not be
  ## republished, because a cache is redistribution and redistribution is not
  ## a right these licences grant. Until `nonRedistributable` landed in
  ## reprobuild that sentence was documentation: `publishToolPrefix` uploaded
  ## every realized prefix, and the only things stopping it were a global env
  ## var and the absence of credentials. A developer who configured publish
  ## credentials re-served Anthropic's and GitHub's binaries to everyone
  ## pulling from that cache, and nothing in the recipe could object.
  ##
  ## These cases are what turn the sentence into a property. They are
  ## deliberately keyed off the INVENTORY's `provenance_class` rather than a
  ## hand-written list, so an agent added as vendor-binary tomorrow fails
  ## here until its realization carries the flag.
  let inv = coverage.loadInventoryFile()

  proc vendorBinaryNames(): HashSet[string] =
    for entry in inv.agent:
      if entry.provenance_class == "vendor-binary":
        result.incl(entry.name)

  test "the inventory still knows of vendor-binary agents":
    # Guards the cases below against becoming vacuous: if the classification
    # ever disappears they would pass by having nothing to check.
    check vendorBinaryNames().len > 0

  test "every vendor-binary slice refuses republication":
    let restricted = vendorBinaryNames()
    var checkedSlices = 0
    for contribution in registeredProvisioningContributions():
      if contribution.targetPackage notin restricted:
        continue
      check contribution.tarballProvisioning.len > 0
      for slice in contribution.tarballProvisioning:
        checkpoint(contribution.targetPackage & " " & slice.os & "-" &
          slice.cpu)
        check slice.nonRedistributable
        inc checkedSlices
    # claude-code ships six platform slices and copilot two; a count that
    # collapsed would mean the loop stopped finding them rather than that
    # they all passed.
    check checkedSlices >= 8

  test "source-available agents are left publishable":
    # The other half of the policy, and the reason the flag is per-entry
    # rather than catalog-wide: publishing what we ARE entitled to publish is
    # the point of a shared cache, and a blanket refusal would cost every
    # other consumer the substitution.
    var publishable = initHashSet[string]()
    for entry in inv.agent:
      if entry.provenance_class == "source-available":
        publishable.incl(entry.name)
    for contribution in registeredProvisioningContributions():
      if contribution.targetPackage notin publishable:
        continue
      for slice in contribution.tarballProvisioning:
        checkpoint(contribution.targetPackage & " " & slice.os & "-" &
          slice.cpu)
        check not slice.nonRedistributable

  test "the flag survives the artifact a consumer actually reads":
    # A consumer sees a contributed provisioning only through the interface
    # artifact and the stub emitted from it. A flag that stopped at the
    # recipe would be enforced here and nowhere else.
    let artifact = artifactFromRegisteredDsl(
      parentDir(getCurrentDir()) / "repro.nim")
    let roundTrip = decodeProjectInterfaceArtifact(
      encodeProjectInterfaceArtifact(artifact))
    let restricted = vendorBinaryNames()
    var seen = 0
    for contribution in roundTrip.projectInterface.provisioningContributions:
      if contribution.targetPackage notin restricted:
        continue
      for slice in contribution.tarballProvisioning:
        check slice.nonRedistributable
        inc seen
    check seen >= 8

  test "the launcher survives the artifact a consumer actually reads":
    # Same argument as the flag above, for the field that makes the two npm
    # agents invocable at all. A launcher that stopped at the recipe would
    # give a consumer a prefix whose declared command is a script nothing
    # can execute -- and the failure would appear at RUN time, on the
    # consumer's machine, not here.
    #
    # Worth its own case because the round-trip test nearby checks only
    # that the CONTRIBUTION COUNT survives, which a dropped field does not
    # change.
    let artifact = artifactFromRegisteredDsl(
      parentDir(getCurrentDir()) / "repro.nim")
    let roundTrip = decodeProjectInterfaceArtifact(
      encodeProjectInterfaceArtifact(artifact))
    var launched: seq[string] = @[]
    for contribution in roundTrip.projectInterface.provisioningContributions:
      for slice in contribution.tarballProvisioning:
        if slice.launcher.len == 0:
          continue
        launched.add(contribution.targetPackage)
        check slice.launcher == "node"
        # The name the launcher takes travels with it; without the alias
        # there is nothing to write the pair under.
        check slice.executableAlias.len > 0
    check launched.len == 3
    check "gemini-cli" in launched
    check "qwen-code" in launched
    check "claude-code-acp" in launched
