## Conformance for the catalog's from-source realizations.
##
## These are compiled apart from `test_llm_agent_catalog.nim` on purpose: a
## source recipe imports reprobuild's DSL stdlib (`constructors`), which
## registers every stdlib package, and the catalog test's "each registered
## package is an inventoried agent" rule would then fail for `zlib`.
##
## What is asserted, and why:
##
##   * the realization adds, removes and renames no member of the interface
##     (AGENTS.md "Interface ownership"): its `gemini` executable is exactly
##     the interface's;
##   * the realization's package is NOT named like the interface. A package
##     defined twice resolves to whichever module was imported last, and the
##     `Realizations` suffix is what `repro catalog publish` and
##     `tools/coverage_report.nim` treat as "not an agent";
##   * the closure manifest and the corrected lock the recipe consumes sit
##     beside it, are well formed, and cover every lock entry that carries a
##     `resolved` archive (a stale manifest is what turns an offline build
##     into a registry-dependent one).

import std/[json, os, sequtils, sets, strutils, unittest]

import repro_project_dsl

import "../packages/interfaces/gemini-cli/repro" as geminiCliInterface
import "../packages/source/gemini-cli/repro" as geminiCliSource

const repoRoot = parentDir(parentDir(currentSourcePath()))

suite "gemini-cli from source":
  test "the realization carries exactly the interface's members":
    let packages = registeredPackages()
    let iface = packages.filterIt(it.packageName == "gemini-cli")
    check iface.len == 1
    let real = packages.filterIt(
      it.packageName == "geminiCliSourceRealizations")
    check real.len == 1
    check real[0].executables.mapIt(it.exportName).toHashSet ==
      iface[0].executables.mapIt(it.exportName).toHashSet

  test "the closure manifest matches the corrected lock":
    let dir = repoRoot / "packages" / "source" / "gemini-cli"
    let lock = parseFile(dir / "npm-build-closure.package-lock.json")
    var wanted = initHashSet[string]()
    for key, entry in lock["packages"]:
      if "node_modules/" in key and entry.hasKey("resolved") and
          not entry.hasKey("link"):
        wanted.incl(key)
    var listed = initHashSet[string]()
    for line in lines(dir / "npm-build-closure.manifest"):
      if line.len == 0 or line.startsWith("#"):
        continue
      let fields = line.split(' ')
      check fields.len == 3
      check fields[1].len == 64
      check fields[2].startsWith("https://registry.npmjs.org/")
      listed.incl(fields[0])
    check listed.len > 1000
    check listed == wanted
