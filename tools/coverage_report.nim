## The generated coverage report for this catalog.
##
## `inventory/upstream.toml` records what upstream agents exist and what this
## catalog ships for each. This renders that into a table, and — more
## importantly — cross-checks it against the packages that are actually
## registered, because an inventory nobody checks drifts from the catalog it
## describes and then reads as a status report while being a wish list.
##
## ## The distinction the report exists to make
##
## "Not covered" has three causes here, and they need different answers:
##
##   * no interface at all — nobody has decided what the package exports.
##     These are the `[[uncovered]]` rows.
##   * an interface, and no realization, because upstream's distribution is
##     a channel this catalog cannot provision yet. npm is the whole of it
##     today: gemini-cli, qwen-code, amp and claude-code-acp all publish an
##     npm package and no release binaries. These carry
##     `realization_blocked` on their `[[agent]]` row.
##   * an interface and a realization. Covered.
##
## Lumping the first two together is the failure mode. The first is a design
## decision nobody has taken; the second is a provisioning channel nobody
## has built, and building it would close four agents at once.
##
## ## Usage
##
##   nim c -r tools/coverage_report.nim            # the table
##   nim c -r tools/coverage_report.nim --check    # cross-checks only
##
## `--check` exits non-zero when the inventory and the catalog disagree. The
## conformance test runs the same checks, so CI catches it either way; the
## flag is for an author who wants the answer without the table.

import std/[algorithm, os, sequtils, sets, strutils, tables]

import toml_serialization

import repro_project_dsl

import "../packages/interfaces/claude-code/repro" as claudeCodeInterface
import "../packages/interfaces/codex/repro" as codexInterface
import "../packages/interfaces/codex-acp/repro" as codexAcpInterface
import "../packages/interfaces/copilot/repro" as copilotInterface
import "../packages/interfaces/gemini-cli/repro" as geminiCliInterface
import "../packages/interfaces/goose/repro" as gooseInterface
import "../packages/interfaces/opencode/repro" as opencodeInterface
import "../packages/interfaces/qwen-code/repro" as qwenCodeInterface

import "../packages/vendor/claude-code/repro" as claudeCodeVendor
import "../packages/vendor/codex/repro" as codexVendor
import "../packages/vendor/codex-acp/repro" as codexAcpVendor
import "../packages/vendor/copilot/repro" as copilotVendor
import "../packages/vendor/goose/repro" as gooseVendor
import "../packages/vendor/opencode/repro" as opencodeVendor

const
  InventoryPath* = "inventory" / "upstream.toml"
  ExpectedSchema* = "reprobuild.llm-agent-catalog.inventory.v1"

type
  AgentEntry* = object
    name*: string
    homepage*: string
    provenance_class*: string
    source_available*: bool
    main_programs*: seq[string]
    release_channel*: string
    observed_pin*: string
    packaged*: seq[string]
    packaged_version*: string
    realization_blocked*: string
    notes*: string

  UncoveredEntry* = object
    name*: string
    homepage*: string
    observed_pin*: string
    reason*: string

  Inventory* = object
    schema*: string
    agent*: seq[AgentEntry]
    uncovered*: seq[UncoveredEntry]

proc inventoryPath*(): string =
  currentSourcePath.parentDir.parentDir / InventoryPath

proc loadInventory*(text: string): Inventory =
  result = Toml.decode(text, Inventory)
  if result.schema != ExpectedSchema:
    raise newException(ValueError,
      InventoryPath & ": schema is `" & result.schema & "`, expected `" &
      ExpectedSchema & "`. A schema this tool does not know may spell the " &
      "coverage fields differently, and reading it anyway would report " &
      "coverage nobody stated.")

proc loadInventoryFile*(): Inventory =
  loadInventory(readFile(inventoryPath()))

proc registeredPackageNames*(): HashSet[string] =
  for pkg in registeredPackages():
    result.incl(pkg.packageName)

proc hasRealization*(entry: AgentEntry): bool =
  "vendor" in entry.packaged or "source" in entry.packaged

proc coverageLabel*(entry: AgentEntry): string =
  if "source" in entry.packaged and "vendor" in entry.packaged:
    "source+vendor"
  elif "source" in entry.packaged:
    "source"
  elif "vendor" in entry.packaged:
    "vendor"
  elif "interface" in entry.packaged:
    "interface only"
  else:
    "nothing"

proc problems*(inv: Inventory; registered: HashSet[string]): seq[string] =
  ## Everywhere the inventory and the catalog can disagree.
  var agentNames = initHashSet[string]()
  for entry in inv.agent:
    if entry.name in agentNames:
      result.add("duplicate [[agent]] row: " & entry.name)
    agentNames.incl(entry.name)
    if entry.name.len == 0:
      result.add("an [[agent]] row has no name")
      continue
    if "interface" notin entry.packaged:
      # Every row in this section is an agent this catalog has taken a
      # position on. One with no interface belongs in [[uncovered]].
      result.add(entry.name & ": an [[agent]] row must declare " &
        "`packaged = [\"interface\", ...]`; an upstream with no interface " &
        "belongs in [[uncovered]]")
    elif entry.name notin registered:
      result.add(entry.name & ": the inventory says its interface is " &
        "packaged, but no package by that name is registered")
    if entry.main_programs.len == 0:
      result.add(entry.name & ": no main_programs, so the inventory does " &
        "not say what the package is for")
    if hasRealization(entry):
      if entry.packaged_version.len == 0:
        result.add(entry.name & ": claims a realization but records no " &
          "packaged_version, so the report cannot say WHAT is covered")
      if entry.realization_blocked.len > 0:
        result.add(entry.name & ": carries realization_blocked AND a " &
          "realization; one of the two is out of date")
    else:
      if entry.realization_blocked.len == 0:
        result.add(entry.name & ": interface only, and no " &
          "realization_blocked reason -- the report cannot tell a channel " &
          "this catalog cannot provision from work nobody has done")
      if entry.packaged_version.len > 0:
        result.add(entry.name & ": records a packaged_version but ships no " &
          "realization")
    if "source" in entry.packaged and not entry.source_available:
      result.add(entry.name & ": a source realization is packaged but " &
        "source_available is false")

  var uncoveredNames = initHashSet[string]()
  for entry in inv.uncovered:
    if entry.name in uncoveredNames:
      result.add("duplicate [[uncovered]] row: " & entry.name)
    uncoveredNames.incl(entry.name)
    if entry.name in agentNames:
      # The contradiction this section's comment warns about: one row says
      # packaged, the other says uncovered, and whichever is read first
      # wins while the other stays as a plausible note nobody rechecks.
      result.add(entry.name & ": appears as both [[agent]] and " &
        "[[uncovered]]; an agent with an interface but no realization " &
        "carries realization_blocked instead")
    if entry.name in registered:
      result.add(entry.name & ": listed as [[uncovered]], but a package by " &
        "that name is registered")
    if entry.reason.strip().len == 0:
      result.add(entry.name & ": an [[uncovered]] row with no reason is an " &
        "unexplained gap, which is what this file exists to replace")

  # Every registered INTERFACE has to be in the inventory. Without this the
  # inventory can be complete about what it mentions and silent about a
  # package somebody added.
  for name in registered.items.toSeq.sorted:
    if name notin agentNames:
      result.add(name & ": registered as a package, and the inventory does " &
        "not mention it")

proc renderReport*(inv: Inventory): string =
  var rows: seq[AgentEntry] = inv.agent
  rows.sort(proc (a, b: AgentEntry): int = cmp(a.name, b.name))

  var nameWidth = len("agent")
  var coverWidth = len("coverage")
  var versionWidth = len("packaged")
  var pinWidth = len("observed")
  for entry in rows:
    nameWidth = max(nameWidth, entry.name.len)
    coverWidth = max(coverWidth, entry.coverageLabel.len)
    versionWidth = max(versionWidth, max(entry.packaged_version.len, 1))
    pinWidth = max(pinWidth, max(entry.observed_pin.len, 1))

  result.add("| " & "agent".alignLeft(nameWidth) & " | " &
    "coverage".alignLeft(coverWidth) & " | " &
    "packaged".alignLeft(versionWidth) & " | " &
    "observed".alignLeft(pinWidth) & " |\n")
  result.add("|-" & repeat('-', nameWidth) & "-+-" &
    repeat('-', coverWidth) & "-+-" & repeat('-', versionWidth) & "-+-" &
    repeat('-', pinWidth) & "-|\n")
  for entry in rows:
    let version = if entry.packaged_version.len > 0: entry.packaged_version
                  else: "-"
    let pin = if entry.observed_pin.len > 0: entry.observed_pin else: "-"
    result.add("| " & entry.name.alignLeft(nameWidth) & " | " &
      entry.coverageLabel.alignLeft(coverWidth) & " | " &
      version.alignLeft(versionWidth) & " | " &
      pin.alignLeft(pinWidth) & " |\n")

  var blocked = rows.filterIt(not it.hasRealization())
  if blocked.len > 0:
    result.add("\nInterface defined, no realization -- and why:\n")
    for entry in blocked:
      result.add("  - " & entry.name & ": " &
        entry.realization_blocked.strip().splitLines().join(" ") & "\n")

  if inv.uncovered.len > 0:
    var uncovered = inv.uncovered
    uncovered.sort(proc (a, b: UncoveredEntry): int = cmp(a.name, b.name))
    result.add("\nNo interface in this catalog -- and why:\n")
    for entry in uncovered:
      result.add("  - " & entry.name & ": " &
        entry.reason.strip().splitLines().join(" ") & "\n")

  var counts = initTable[string, int]()
  for entry in rows:
    counts.mgetOrPut(entry.coverageLabel, 0) += 1
  result.add("\n" & $rows.len & " agents with an interface")
  var parts: seq[string] = @[]
  for label in ["source+vendor", "source", "vendor", "interface only"]:
    let n = counts.getOrDefault(label, 0)
    if n > 0:
      parts.add($n & " " & label)
  if parts.len > 0:
    result.add(" (" & parts.join(", ") & ")")
  result.add(", " & $inv.uncovered.len & " known upstreams with none.\n")

when isMainModule:
  var checkOnly = false
  for i in 1 .. paramCount():
    let arg = paramStr(i)
    if arg == "--check":
      checkOnly = true
    else:
      quit("unknown argument: " & arg &
        "\nusage: coverage_report [--check]", 2)

  let inv = loadInventoryFile()
  let found = problems(inv, registeredPackageNames())
  if not checkOnly:
    stdout.write(renderReport(inv))
  if found.len > 0:
    stderr.write("\n")
    for problem in found:
      stderr.write("error: " & problem & "\n")
    quit(1)
  if checkOnly:
    echo "inventory and catalog agree"
