test:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-catalog --out:build/test-catalog tests/test_llm_agent_catalog.nim

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
