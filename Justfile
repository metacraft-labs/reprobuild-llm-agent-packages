test:
  nim c -r --hints:off --warnings:off --out:build/test-nimcache-locality tests/test_nimcache_is_worktree_local.nim
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-catalog --out:build/test-catalog tests/test_llm_agent_catalog.nim
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-npm-closure --out:build/test-npm-closure tests/test_npm_closure_manifest.nim
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-source-realizations --out:build/test-source-realizations tests/test_source_realizations.nim

# Print the canonical interface fingerprints external catalogs pin.
fingerprints:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-fp --out:build/fingerprints tools/package_interface_fingerprints.nim

# The generated coverage report: what this catalog ships for each known
# upstream agent, and for each gap whether there is no interface at all or
# an interface whose upstream distribution is a channel this catalog cannot
# provision yet.
#
# `just coverage-check` runs only the cross-checks against the registered
# packages -- the same ones `just test` runs.
coverage:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-coverage --out:build/coverage-report tools/coverage_report.nim

coverage-check:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-coverage --out:build/coverage-report tools/coverage_report.nim --check

# Regenerate a dependency-closure manifest from an npm lock file.
#
# A closure is derived data -- every entry is a `resolved` URL npm already
# recorded -- so it is generated rather than transcribed, and a dependency
# bump is this command rather than an afternoon of hand-editing.
#
# Arguments are positional (just does not take name=value):
#
#   just closure-manifest <lock> <root> <out> <npm-os>-<npm-cpu> "<source>"
#
# The platform is required for a closure with platform-specific members
# (native binaries through npm's optional dependencies) and may be "" for
# one without. Every libc variant is kept. <source> is required: it is what
# the header says the lock is (an upstream path and commit, or the
# `npm install <pkg>@<version> --package-lock-only` that produced it).
closure-manifest lock root out platform source:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-closure --out:build/npm-closure-manifest tools/npm_closure_manifest.nim --lock={{lock}} --root={{root}} --out={{out}} {{ if platform == "" { "" } else { "--platform=" + platform } }} --lock-source={{ quote(source) }}

# Regenerate a BUILD-closure manifest (every archive `npm ci` installs, for a
# from-source build) from an npm lock file. Same arguments as
# `closure-manifest` minus root and platform.
#
#   just build-closure-manifest <lock> <out> "<source>"
build-closure-manifest lock out source:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-closure --out:build/npm-closure-manifest tools/npm_closure_manifest.nim --build-closure --lock={{lock}} --out={{out}} --lock-source={{ quote(source) }}

# Regenerate `published-interfaces/` from the providers (commit the result);
# `publish-check` is what CI runs: it fails when the directory is stale.
publish:
  repro catalog publish

publish-check:
  repro catalog publish --check
