test:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-catalog --out:build/test-catalog tests/test_llm_agent_catalog.nim

# Print the canonical interface fingerprints external catalogs pin.
fingerprints:
  nim c -r --hints:off --warnings:off --nimcache:build/nimcache-fp --out:build/fingerprints tools/package_interface_fingerprints.nim
