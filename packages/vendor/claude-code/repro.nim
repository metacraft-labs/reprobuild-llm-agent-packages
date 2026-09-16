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
## **Digests** are upstream's own, from the 2.1.170 manifest. Bumping the
## version means re-reading that manifest; do not carry a digest forward.
##
## **Cache policy.** This realization is marked vendor-binary provenance and
## its payload is fetched on the user's behalf. It must not be republished
## into a shared binary cache — redistributing it is not a right the licence
## grants us, and a cache is redistribution. The interface it satisfies is
## published; the bytes are not.

import repro_project_dsl

const
  ClaudeCodeVersion = "2.1.170"
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
    sha256 = "193061508fe619abf534b2c9d48151f26971d1d5b8460ad75c0af4be3d3525fb",
    archiveType = "raw",
    executablePath = "claude.exe",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":windows-x86_64:sha256:193061508fe619abf534b2c9d48151f26971d1d5b8460ad75c0af4be3d3525fb"

  tarball url = ClaudeCodeBase & "win32-arm64/claude.exe",
    sha256 = "9abd330bcc191aecc877a8ee9da2b448852cfe3bda15e5e4608385ea1d9d1709",
    archiveType = "raw",
    executablePath = "claude.exe",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":windows-aarch64:sha256:9abd330bcc191aecc877a8ee9da2b448852cfe3bda15e5e4608385ea1d9d1709"

  tarball url = ClaudeCodeBase & "linux-x64/claude",
    sha256 = "849e007277a0442ab27570d3e3d6d43787507946590e8dd1947e5a39b7081f9e",
    archiveType = "raw",
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":linux-x86_64:sha256:849e007277a0442ab27570d3e3d6d43787507946590e8dd1947e5a39b7081f9e"

  tarball url = ClaudeCodeBase & "linux-arm64/claude",
    sha256 = "1bb9d032440a75532f7dd4cafbc687f220aaf16c63eba17e192dfbec2f04bd25",
    archiveType = "raw",
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":linux-aarch64:sha256:1bb9d032440a75532f7dd4cafbc687f220aaf16c63eba17e192dfbec2f04bd25"

  tarball url = ClaudeCodeBase & "darwin-x64/claude",
    sha256 = "914f23a70bbed5d9ae567e3e04b86206ed9971b371bc9baca3f79c8885bfddb4",
    archiveType = "raw",
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":macos-x86_64:sha256:914f23a70bbed5d9ae567e3e04b86206ed9971b371bc9baca3f79c8885bfddb4"

  tarball url = ClaudeCodeBase & "darwin-arm64/claude",
    sha256 = "e903646d8b7a31882a80ecd27569a27d8ac57b3708745f349709632c84117fdf",
    archiveType = "raw",
    executablePath = "claude",
    packageId = "claude-code@" & ClaudeCodeVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:claude-code@" & ClaudeCodeVersion &
      ":macos-aarch64:sha256:e903646d8b7a31882a80ecd27569a27d8ac57b3708745f349709632c84117fdf"
