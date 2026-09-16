## Vendor-binary realization of the ``codex`` interface.
##
## Codex is source-available (Rust, on GitHub), so the CATALOG's primary
## realization for it should be a from-source build under
## ``packages/source/codex/``. This entry is the pinned-binary realization
## that exists alongside it, and it is labelled vendor-binary for exactly
## that reason: it repacks upstream's release archive rather than building
## the tree, and must not be presented as equivalent provenance.
##
## **The triple-suffixed program name.** Upstream's Windows zip contains
## ``codex-x86_64-pc-windows-msvc.exe`` — named for its target triple —
## alongside two helpers (``codex-command-runner.exe`` and
## ``codex-windows-sandbox-setup.exe``) that the CLI spawns. Every consumer
## invokes it as ``codex``. A realized prefix goes on PATH as a directory, so
## the program's name there is the file's own, and without reconciliation
## ``codex`` simply does not resolve. ``executableAlias`` places a copy under
## the plain name inside the sealed prefix, which is what lets the helpers
## stay adjacent — they are found relative to the executable, so extracting
## the one binary elsewhere would break them.
##
## That gap is why the DIY environment this replaces had to synthesise a
## ``codex.exe`` shim of its own, outside any store.
##
## Digests are the ``CODEX_SHA256_0_154_0_*`` values the consuming project
## harvested independently; both were re-verified against the artifacts.

import repro_project_dsl

const
  CodexVersion = "0.154.0"
  CodexBase = "https://github.com/openai/codex/releases/download/rust-v" &
    CodexVersion & "/codex-"

provisioningFor "codex":
  interfaceFingerprint "5b98987bb4b19640ed86f20cd66df0eaf9a1ca8311e16a27e495cf0f47bc1518"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = CodexBase & "x86_64-pc-windows-msvc.exe.zip",
    sha256 = "53685f9f6bd171d4bd7d6c2be724fc04f6737a4001eb8471ec59824e5adc8042",
    archiveType = "zip",
    executablePath = "codex-x86_64-pc-windows-msvc.exe",
    executableAlias = "codex.exe",
    packageId = "codex@" & CodexVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:codex@" & CodexVersion &
      ":windows-x86_64:sha256:53685f9f6bd171d4bd7d6c2be724fc04f6737a4001eb8471ec59824e5adc8042"

  tarball url = CodexBase & "aarch64-pc-windows-msvc.exe.zip",
    sha256 = "5da0e4b828d125bb72ecefc882bd068443625df32d56269e687afb7026b2a65d",
    archiveType = "zip",
    executablePath = "codex-aarch64-pc-windows-msvc.exe",
    executableAlias = "codex.exe",
    packageId = "codex@" & CodexVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:codex@" & CodexVersion &
      ":windows-aarch64:sha256:5da0e4b828d125bb72ecefc882bd068443625df32d56269e687afb7026b2a65d"
