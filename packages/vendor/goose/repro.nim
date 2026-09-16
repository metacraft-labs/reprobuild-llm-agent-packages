## Vendor-binary realization of the ``goose`` interface.
##
## Source-available upstream (Apache-2.0 Rust), so a from-source realization
## belongs under ``packages/source/goose/``; this pinned-binary entry is the
## alternative, not the primary.
##
## The archive carries a ``goose-package/`` wrapper holding a single program,
## so stripComponents=1 flattens it. Reading that listing is what corrected
## the interface: an earlier draft declared ``goosed`` beside ``goose``,
## reasoning from Goose's architecture rather than from what it ships —
## ``goosed`` lives in the Desktop application, and this archive contains
## exactly one executable.
##
## x86_64 Windows only: upstream publishes no arm64 Windows build, an
## upstream platform gap rather than a missing recipe.
##
## Digest is the ``GOOSE_SHA256_1_50_1_X86_64_PC_WINDOWS_MSVC`` value the
## consuming project harvested independently; re-verified against the
## artifact.

import repro_project_dsl

const GooseVersion = "1.50.1"

provisioningFor "goose":
  interfaceFingerprint "b244dfcfa0303c980d7682a73798e098a311a2b7c6f35a20cb0a35792736aad1"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = "https://github.com/block/goose/releases/download/v" &
      GooseVersion & "/goose-x86_64-pc-windows-msvc.zip",
    sha256 = "defdbf4f905fb913152a1cf5938674a0862f23c7d453251bc27de59814c1c609",
    archiveType = "zip",
    stripComponents = 1,
    executablePath = "goose.exe",
    packageId = "goose@" & GooseVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:goose@" & GooseVersion &
      ":windows-x86_64:sha256:defdbf4f905fb913152a1cf5938674a0862f23c7d453251bc27de59814c1c609"
