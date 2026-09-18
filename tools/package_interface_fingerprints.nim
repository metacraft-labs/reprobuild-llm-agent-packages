## Print the canonical interface fingerprint of every package this catalog
## owns, in the form an external provisioning catalog pins.
##
## A contribution published from another repository names its target
## interface by fingerprint, and a contribution whose pin no longer matches
## is REJECTED rather than silently applied to a changed interface. So the
## fingerprints are a published artifact of this repo, and this tool is how
## they are read — the same role
## ``reprobuild-packages/tools/package_interface_fingerprints.nim`` plays
## for the interfaces that repo owns.
##
## Run: ``nim c -r tools/package_interface_fingerprints.nim``

import std/[algorithm, sequtils, strutils]

import repro_interface_artifacts
import repro_project_dsl

# Quoted import paths, because the directory name IS the public package
# name and several of those carry a hyphen, which Nim will not accept as a
# bare path segment. Renaming the directories to `claude_code/` would make
# the selector a developer types and the directory it resolves to two
# different strings, which is the drift the layout rule exists to prevent.
import "../packages/interfaces/claude-code/repro" as claudeCodeInterface
import "../packages/interfaces/codex/repro" as codexInterface
import "../packages/interfaces/gemini-cli/repro" as geminiCliInterface
import "../packages/interfaces/goose/repro" as gooseInterface
import "../packages/interfaces/opencode/repro" as opencodeInterface
import "../packages/interfaces/qwen-code/repro" as qwenCodeInterface
import "../packages/interfaces/copilot/repro" as copilotInterface
import "../packages/interfaces/codex-acp/repro" as codexAcpInterface
import "../packages/interfaces/claude-code-acp/repro" as claudeCodeAcpInterface
import "../packages/interfaces/amp/repro" as ampInterface

const PublishedPackages = [
  "amp", "claude-code", "claude-code-acp", "codex", "codex-acp", "copilot",
  "gemini-cli", "goose", "opencode", "qwen-code"]

let packages = registeredPackages()
var selected = packages.filterIt(it.packageName in PublishedPackages)
selected.sort(proc (a, b: PackageDef): int = cmp(a.packageName, b.packageName))

if selected.len != PublishedPackages.len:
  raise newException(ValueError,
    "expected one canonical registration for each of " &
    PublishedPackages.join(", ") & "; got " &
    selected.mapIt(it.packageName).join(", "))
for packageDef in selected:
  echo packageDef.packageName, " ",
    canonicalPackageInterfaceFingerprint(packageDef, packages)
