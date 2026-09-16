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

import std/[os, sequtils, sets, unittest]

import repro_interface_artifacts
import repro_project_dsl

import "../packages/interfaces/claude-code/repro" as claudeCodeInterface
import "../packages/interfaces/codex/repro" as codexInterface
import "../packages/interfaces/gemini-cli/repro" as geminiCliInterface
import "../packages/interfaces/goose/repro" as gooseInterface
import "../packages/interfaces/opencode/repro" as opencodeInterface
import "../packages/interfaces/qwen-code/repro" as qwenCodeInterface

import "../packages/vendor/claude-code/repro" as claudeCodeVendor

const PublishedInterfaces = [
  "claude-code", "codex", "gemini-cli", "goose", "opencode", "qwen-code"]

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

  test "goose exports both of the programs its contract names":
    let packages = registeredPackages()
    let goosePkg = packages.filterIt(it.packageName == "goose")[0]
    let members = goosePkg.executables.mapIt(it.exportName).toHashSet()
    check "goose" in members
    check "goosed" in members

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
