## The npm BUILD closure — `installClosure` in `tools/npm_closure_manifest`.
##
## `closureOf` (already covered by use: it generates the committed runtime
## closures of the vendored npm agents) walks ONE package's runtime
## dependencies. A from-source agent build needs the opposite: the whole
## `npm ci` install — dev dependencies that do the building, and every
## workspace's dependencies — which a lockfileVersion 2/3 lock has already
## resolved into its `packages` map. `installClosure` is every installed
## entry there (any key with a `node_modules/` segment, hoisted or nested
## under a workspace). These cases pin that it takes the build tools and
## workspace-nested versions, skips workspace symlinks and un-resolved
## entries, and is order-stable.

import std/[json, sequtils, unittest]

import "../tools/npm_closure_manifest"

suite "npm build closure (installClosure)":

  proc lockPackages(): JsonNode =
    ## A lock shaped like a workspace monorepo's: a root with a devDependency,
    ## a hoisted build tool and a hoisted runtime dep, a workspace source
    ## entry and its `link` in node_modules, and an entry with no `resolved`.
    parseJson("""
    {
      "": {"name": "agent", "devDependencies": {"esbuild": "1"}},
      "node_modules/esbuild": {"resolved": "https://r/esbuild-1.tgz", "version": "1"},
      "node_modules/typescript": {"resolved": "https://r/typescript-5.tgz"},
      "node_modules/react": {"resolved": "https://r/react-18.tgz"},
      "packages/cli": {"name": "@agent/cli"},
      "packages/cli/node_modules/tar": {"resolved": "https://r/tar-7.tgz"},
      "node_modules/@agent/cli": {"link": true, "resolved": "packages/cli"},
      "node_modules/inlined": {"version": "1"}
    }""")

  test "a version nested under a workspace is in the closure":
    # npm keeps a version that conflicts with the hoisted one under the
    # workspace that needs it. It is an archive `npm ci` installs, so an
    # offline mirror without it fails; the old `node_modules/`-prefix filter
    # dropped every such entry (104 of them in gemini-cli v0.59.0).
    let paths = installClosure(lockPackages()).mapIt(it.path)
    check "packages/cli/node_modules/tar" in paths

  test "the build tools (devDependencies) are in the closure":
    let paths = installClosure(lockPackages()).mapIt(it.path)
    check "node_modules/esbuild" in paths      # a devDependency archive
    check "node_modules/typescript" in paths
    check "node_modules/react" in paths        # a runtime dep, also installed

  test "a workspace symlink (link:true) is not an archive and is skipped":
    let paths = installClosure(lockPackages()).mapIt(it.path)
    check "node_modules/@agent/cli" notin paths

  test "an entry with no resolved url has no archive to fetch":
    let paths = installClosure(lockPackages()).mapIt(it.path)
    check "node_modules/inlined" notin paths

  test "the root and non-node_modules keys are never emitted":
    let paths = installClosure(lockPackages()).mapIt(it.path)
    check "" notin paths
    check "packages/cli" notin paths

  test "exactly the four installed archives, sorted":
    let entries = installClosure(lockPackages())
    check entries.mapIt(it.path) == @[
      "node_modules/esbuild",
      "node_modules/react",
      "node_modules/typescript",
      "packages/cli/node_modules/tar"]
    check entries[0].url == "https://r/esbuild-1.tgz"

  test "an empty packages map yields an empty closure, not an error":
    check installClosure(parseJson("{}")).len == 0
