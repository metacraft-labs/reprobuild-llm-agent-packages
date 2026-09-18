## Vendor-binary realization of the ``claude-code`` interface.
##
## **Why this is a vendor binary and not a source build.** Anthropic ships
## Claude Code as a single bare native executable per (cpu, os) and publishes
## no corresponding source. The catalog's rule is that such a package may
## carry a vendor-binary realization, must never be described as built from
## source, and must say so in its provenance rather than leaving a reader to
## infer it from the absence of a ``packages/source/`` entry.
##
## **Distribution shape.** One file per platform under a stable per-release
## prefix, with a sibling ``manifest.json`` carrying
## ``.platforms.<platform>.checksum``:
##
##   https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/<VERSION>/<PLATFORM>/<binary>
##
## ``archiveType = "raw"`` because there is no archive: the download IS the
## executable, and the realize step copies it into the prefix under the
## declared name rather than extracting anything.
##
## The ``linux-*-musl`` slices upstream also publishes are deliberately
## omitted: the realization schema has no libc dimension, so declaring them
## would mean two entries that differ in a way the selector cannot express.
## The glibc build covers the Linux axis, matching how the rest of this
## catalog's Linux slices are pinned.
##
## **Digests** are upstream's own, from the 2.1.272 manifest. Bumping the
## version means re-reading that manifest; do not carry a digest forward.
##
## **Cache policy.** This realization is marked vendor-binary provenance and
## its payload is fetched on the user's behalf. It must not be republished
## into a shared binary cache — redistributing it is not a right the licence
## grants us, and a cache is redistribution. The interface it satisfies is
## published; the bytes are not.
##
## Every slice below carries `nonRedistributable = true`, which is what makes
## that paragraph load-bearing rather than aspirational: `publishToolPrefix`
## refuses the upload before it looks at whether credentials exist, so the
## policy holds on a machine configured to publish rather than only on one
## that happens not to be.

import repro_project_dsl

const
  ClaudeCodeVersion = "2.1.272"
  ClaudeCodeBase =
    "https://storage.googleapis.com/" &
    "claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/" &
    "claude-code-releases/" & ClaudeCodeVersion & "/"

provisioningFor "claude-code":
  # Pinned to the fingerprint `tools/package_interface_fingerprints.nim`
  # prints for the interface in `packages/interfaces/claude-code/`. If that
  # interface changes, this contribution is REJECTED rather than applied to
  # a contract it was never checked against.
  interfaceFingerprint "f002b7ee0b2abf023c47367651319e4673dfeecce99bd7c65b9f5f0eb9f3aee8"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = ClaudeCodeBase & "win32-x64/claude.exe",
    sha256 = "cd8d8d33e549ba5973428bcf18310164227d68ca756925242c47d3b0d48bf4dc",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "claude.exe",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":windows-x86_64:sha256:cd8d8d33e549ba5973428bcf18310164227d68ca756925242c47d3b0d48bf4dc"

  tarball url = ClaudeCodeBase & "win32-arm64/claude.exe",
    sha256 = "e8fbdb138cb3b438929286f234663f98fe0a914d77d6c8589a51f3ecf8915462",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "claude.exe",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":windows-aarch64:sha256:e8fbdb138cb3b438929286f234663f98fe0a914d77d6c8589a51f3ecf8915462"

  tarball url = ClaudeCodeBase & "linux-x64/claude",
    sha256 = "d81396a668eb76fbddb49a2a5841f1b5d7af96b4c1f6500ced92f2c988f5bcd4",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":linux-x86_64:sha256:d81396a668eb76fbddb49a2a5841f1b5d7af96b4c1f6500ced92f2c988f5bcd4"

  tarball url = ClaudeCodeBase & "linux-arm64/claude",
    sha256 = "214a90efdd16ee0ea81132ffecced588dba394d178cc494f285ba04b5288c8de",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":linux-aarch64:sha256:214a90efdd16ee0ea81132ffecced588dba394d178cc494f285ba04b5288c8de"

  tarball url = ClaudeCodeBase & "darwin-x64/claude",
    sha256 = "6377b8e95ecbf90fd6b91e543b3c23e1b23c9c968b2acb7ad460ce5573d3e41c",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":macos-x86_64:sha256:6377b8e95ecbf90fd6b91e543b3c23e1b23c9c968b2acb7ad460ce5573d3e41c"

  tarball url = ClaudeCodeBase & "darwin-arm64/claude",
    sha256 = "195e24e8e1f9bf46f1eaee72d434a33e18f9f5796f29a6348a00d16c5f8aee75",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":macos-aarch64:sha256:195e24e8e1f9bf46f1eaee72d434a33e18f9f5796f29a6348a00d16c5f8aee75"
