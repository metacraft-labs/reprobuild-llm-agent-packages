## The two closures `tools/npm_closure_manifest` writes.
##
## `closureOf` walks ONE package's runtime dependencies the way npm resolves
## a `require`; its suite is at the end. A from-source agent build needs the
## opposite, `installClosure`: the whole
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

suite "npm runtime closure of one package (closureOf)":
  ## The `--root` form. Its contract (reprobuild-pm
  ## spec/From-Source-Build-Recipes.md, "npm runtime closures") is the closure
  ## `npm install --omit=dev` would install for the root, at the positions npm
  ## would use. These cases are shaped on the `openclaw` lock that the first
  ## version of this walk could not take (reprobuild-pm issue
  ## 2026-11-17-npm-closure-manifest-tool-cannot-take-a-root-with-bundled-
  ## dependencies-and-ignores-libc): a root with `bundleDependencies`, and a
  ## dependency whose required version is nested under its dependent because
  ## a different one is hoisted.

  proc agentLock(bundled = true): JsonNode =
    ## `bundled = false` drops the bundled member, so a case about nesting
    ## or platforms does not also depend on bundle handling.
    result = parseJson("""
    {
      "": {"name": "scratch", "dependencies": {"agent": "1"}},
      "node_modules/agent": {
        "version": "1.0.0", "resolved": "https://r/agent-1.tgz",
        "integrity": "sha512-a",
        "bundleDependencies": ["playwright-core"],
        "dependencies": {"playwright-core": "1", "express": "4",
                         "content-type": "2"},
        "optionalDependencies": {"@n/bin-linux-x64-gnu": "1",
                                 "@n/bin-linux-x64-musl": "1",
                                 "@n/bin-darwin-arm64": "1"}
      },
      "node_modules/agent/node_modules/playwright-core": {
        "version": "1.56.1", "inBundle": true},
      "node_modules/express": {
        "version": "4.0.0", "resolved": "https://r/express-4.tgz",
        "integrity": "sha512-e", "dependencies": {"content-type": "1"}},
      "node_modules/express/node_modules/content-type": {
        "version": "1.0.5", "resolved": "https://r/content-type-1.tgz",
        "integrity": "sha512-c1"},
      "node_modules/content-type": {
        "version": "2.0.0", "resolved": "https://r/content-type-2.tgz",
        "integrity": "sha512-c2"},
      "node_modules/@n/bin-linux-x64-gnu": {
        "version": "1.0.0", "resolved": "https://r/bin-gnu.tgz",
        "integrity": "sha512-g", "optional": true,
        "os": ["linux"], "cpu": ["x64"], "libc": ["glibc"]},
      "node_modules/@n/bin-linux-x64-musl": {
        "version": "1.0.0", "resolved": "https://r/bin-musl.tgz",
        "integrity": "sha512-m", "optional": true,
        "os": ["linux"], "cpu": ["x64"], "libc": ["musl"]},
      "node_modules/@n/bin-darwin-arm64": {
        "version": "1.0.0", "resolved": "https://r/bin-darwin.tgz",
        "integrity": "sha512-d", "optional": true,
        "os": ["darwin"], "cpu": ["arm64"]}
    }""")
    if not bundled:
      result["node_modules/agent"].delete("bundleDependencies")
      result["node_modules/agent"]["dependencies"].delete("playwright-core")
      result.delete("node_modules/agent/node_modules/playwright-core")

  test "a root with bundleDependencies: the bundled member is not an entry":
    # The first walk looked every name up at the top-level node_modules and
    # stopped with "not in the lock file: playwright-core".
    let paths = closureOf(agentLock(), "agent", "linux-x64").mapIt(it.path)
    check "node_modules/playwright-core" notin paths
    check "node_modules/agent/node_modules/playwright-core" notin paths
    check "node_modules/express" in paths

  test "a version nested under its dependent stays nested, beside the hoisted one":
    # express needs content-type 1, nested under it; the root needs the
    # hoisted 2. A flat walk took the hoisted one for both, silently.
    let entries = closureOf(agentLock(bundled = false), "agent", "linux-x64")
    var urls: seq[(string, string)] = @[]
    for e in entries: urls.add((e.path, e.url))
    check ("node_modules/content-type", "https://r/content-type-2.tgz") in urls
    check ("node_modules/express/node_modules/content-type",
      "https://r/content-type-1.tgz") in urls

  test "a linux slice drops other platforms and (for now) keeps every libc variant":
    # Current behaviour, not yet a decided rule: whether libc should filter
    # is an open owner decision in the reprobuild-pm issue named above.
    let paths = closureOf(agentLock(bundled = false), "agent", "linux-x64").mapIt(it.path)
    check "node_modules/@n/bin-linux-x64-gnu" in paths
    check "node_modules/@n/bin-linux-x64-musl" in paths
    check "node_modules/@n/bin-darwin-arm64" notin paths

  test "a member nested under the root moves up into the prefix":
    # A member npm nested under the root lands beside the root's archive.
    var lock = agentLock(bundled = false)
    lock["node_modules/agent"]["dependencies"]["ms"] = %"2"
    lock["node_modules/agent/node_modules/ms"] = %*{
      "version": "2.1.3", "resolved": "https://r/ms-2.tgz",
      "integrity": "sha512-ms"}
    let paths = closureOf(lock, "agent", "linux-x64").mapIt(it.path)
    check "node_modules/ms" in paths
    check "node_modules/agent/node_modules/ms" notin paths

  test "two members landing on one prefix path are refused, not overwritten":
    var lock = agentLock(bundled = false)
    lock["node_modules/agent"]["dependencies"]["content-type"] = %"3"
    lock["node_modules/agent/node_modules/content-type"] = %*{
      "version": "3.0.0", "resolved": "https://r/content-type-3.tgz",
      "integrity": "sha512-c3"}
    # The root's nested 3 lands on node_modules/content-type, and so does
    # the hoisted 2 that `body` (hoisted) requires.
    lock["node_modules/agent"]["dependencies"]["body"] = %"1"
    lock["node_modules/body"] = %*{
      "version": "1.0.0", "resolved": "https://r/body-1.tgz",
      "integrity": "sha512-b", "dependencies": {"content-type": "2"}}
    expect ClosureError:
      discard closureOf(lock, "agent", "linux-x64")

  test "a platform-specific closure without --platform is refused":
    expect ClosureError:
      discard closureOf(agentLock(bundled = false), "agent", "")

  test "a required dependency the lock does not carry is refused":
    var lock = agentLock(bundled = false)
    lock["node_modules/agent"]["dependencies"]["ghost"] = %"1"
    expect ClosureError:
      discard closureOf(lock, "agent", "linux-x64")

  test "the header names the root and the lock's source, not a scratch path":
    let packages = agentLock()
    check rootLabel(packages, "agent") == "agent@1.0.0"
    let header = manifestHeader(rootLabel(packages, "agent"),
      "npm install agent@1.0.0 --package-lock-only (npm 10.9.3)",
      "linux-x64", buildClosure = false)
    check header[0] == "# Runtime dependency closure of agent@1.0.0."
    check "#   npm install agent@1.0.0 --package-lock-only (npm 10.9.3)" in header

  test "a bundled member's own non-bundled dependency is in the closure":
    var lock = agentLock()
    lock["node_modules/agent/node_modules/playwright-core"]["dependencies"] =
      %*{"outside": "1"}
    lock["node_modules/outside"] = %*{
      "version": "1.0.0", "resolved": "https://r/outside-1.tgz",
      "integrity": "sha512-o"}
    let paths = closureOf(lock, "agent", "linux-x64").mapIt(it.path)
    check "node_modules/outside" in paths

  test "a platform-constrained bundled member does not force --platform":
    let lock = parseJson("""{
      "node_modules/r": {"version": "1.0.0", "resolved": "https://r/r.tgz",
        "bundleDependencies": ["bb"], "dependencies": {"bb": "1", "d": "1"}},
      "node_modules/r/node_modules/bb": {"inBundle": true, "os": ["linux"]},
      "node_modules/d": {"version": "1", "resolved": "https://r/d.tgz"}}""")
    check closureOf(lock, "r", "").mapIt(it.path) == @["node_modules/d"]

  test "a deep root with a member in a scope between it and the top is refused":
    # In the prefix the root sits at the top, so node_modules/a/node_modules/x
    # has no position b would find it at.
    let lock = parseJson("""{
      "node_modules/a": {"version": "1", "resolved": "https://r/a.tgz"},
      "node_modules/a/node_modules/b": {"version": "1",
        "resolved": "https://r/b.tgz", "dependencies": {"x": "1"}},
      "node_modules/a/node_modules/x": {"version": "1",
        "resolved": "https://r/x-1.tgz"},
      "node_modules/x": {"version": "2", "resolved": "https://r/x-2.tgz"}}""")
    expect ClosureError:
      discard closureOf(lock, "node_modules/a/node_modules/b", "")
    check rootLabel(lock, "node_modules/a/node_modules/b") == "b@1"

  test "a hoisted member on the root's bundled path at another version is refused":
    # The root's bundled node_modules/x unpacks at prefix/node_modules/x,
    # exactly where the hoisted x@2 that y needs would go.
    let lock = parseJson("""{
      "node_modules/a": {"version": "1", "resolved": "https://r/a.tgz",
        "bundleDependencies": ["x"], "dependencies": {"x": "1", "y": "1"}},
      "node_modules/a/node_modules/x": {"version": "1.0.0", "inBundle": true},
      "node_modules/y": {"version": "1", "resolved": "https://r/y.tgz",
        "dependencies": {"x": "2"}},
      "node_modules/x": {"version": "2.0.0", "resolved": "https://r/x-2.tgz"}}""")
    expect ClosureError:
      discard closureOf(lock, "a", "")
    # The same version on both paths unpacks identical contents (openclaw's
    # bundled debug, fast-deep-equal and ms): kept.
    var same = lock.copy()
    same["node_modules/x"]["version"] = %"1.0.0"
    check closureOf(same, "a", "").mapIt(it.path) ==
      @["node_modules/x", "node_modules/y"]

  test "a member that requires the root by name is refused":
    # Nothing sits at node_modules/<root> in the prefix, so the plugin's
    # require of its host (or a cycle back to the root) would fail.
    let peer = parseJson("""{
      "node_modules/a": {"version": "1", "resolved": "https://r/a.tgz",
        "dependencies": {"plug": "1"}},
      "node_modules/plug": {"version": "1", "resolved": "https://r/p.tgz",
        "peerDependencies": {"a": "1"}}}""")
    expect ClosureError:
      discard closureOf(peer, "a", "")
    let cycle = parseJson("""{
      "node_modules/a": {"version": "1", "resolved": "https://r/a.tgz",
        "dependencies": {"b": "1"}},
      "node_modules/b": {"version": "1", "resolved": "https://r/b.tgz",
        "dependencies": {"a": "1"}}}""")
    expect ClosureError:
      discard closureOf(cycle, "a", "")

  test "a platform-constrained bundled member is kept for any --platform":
    let lock = parseJson("""{
      "node_modules/r": {"version": "1.0.0", "resolved": "https://r/r.tgz",
        "bundleDependencies": ["bb"], "dependencies": {"bb": "1", "d": "1"}},
      "node_modules/r/node_modules/bb": {"inBundle": true, "os": ["linux"]},
      "node_modules/d": {"version": "1", "resolved": "https://r/d.tgz"}}""")
    check closureOf(lock, "r", "darwin-arm64").mapIt(it.path) ==
      @["node_modules/d"]
