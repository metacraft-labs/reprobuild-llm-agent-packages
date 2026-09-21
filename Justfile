test:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-catalog --out:build/test-catalog tests/test_llm_agent_catalog.nim
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-npm-closure --out:build/test-npm-closure tests/test_npm_closure_manifest.nim

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
#   just closure-manifest #     lock=../agent-harbor/scripts/agent-tools/package-lock.json #     root=@zed-industries/claude-code-acp #     out=packages/vendor/claude-code-acp/closures/claude-code-acp.manifest
#
# Pass `platform=<npm-os>-<npm-cpu>` for a package whose native binary
# arrives through npm's optional-dependency mechanism; that follows
# optional deps and keeps only the entries the platform admits.
closure-manifest lock root out platform="":
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-closure --out:build/npm-closure-manifest tools/npm_closure_manifest.nim --lock={{lock}} --root={{root}} --out={{out}} {{ if platform == "" { "" } else { "--platform=" + platform } }}
