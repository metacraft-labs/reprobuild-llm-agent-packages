## Vendor-binary realization of the ``codex-acp`` interface.
##
## Upstream is source-available, so a from-source realization belongs under
## ``packages/source/codex-acp/`` and this pinned-binary entry sits alongside
## it rather than standing in for it.
##
## **Platforms.** One slice per (cpu, os) upstream publishes for the release:
## Windows, Linux and macOS, each on x86_64 and aarch64. Upstream also ships
## ``*-unknown-linux-gnu`` archives; the Linux slices use the ``*-musl`` ones
## instead because they are statically linked, so the same binary runs on a
## glibc distribution and on NixOS without a loader shim. The realization
## schema has no libc dimension, so declaring both would be two entries the
## selector cannot tell apart.
##
## **Archive layout**, read from each listing rather than assumed: every
## archive is flat, with the executable at the root. The Linux archives also
## carry ``codex-resources/bwrap``, a sandbox helper; the whole archive is
## realized rather than the one file, so pruning does not change what
## upstream shipped.
##
## **Digests** are upstream's own, as the release lists them for each asset,
## and each matched the sha256 of the archive downloaded here. The
## windows-x86_64 one also matches the
## ``CODEX_ACP_SHA256_X86_64_PC_WINDOWS_MSVC`` pin its consumer harvested
## independently. Run check: the linux-x86_64 binary was started on NixOS
## directly. The other slices were checksummed and listed, not executed.
## Bumping the version means re-reading the release; do not carry a digest
## forward.

import repro_project_dsl

const
  CodexAcpVersion = "0.14.0"
  CodexAcpBase = "https://github.com/zed-industries/codex-acp/releases/download/v" &
    CodexAcpVersion & "/codex-acp-" & CodexAcpVersion & "-"

provisioningFor "codex-acp":
  interfaceFingerprint "bebd1dcb96e756936e2afd040b31448a80603979bd036b7f7ee7e1a91cc2a5b5"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = CodexAcpBase & "x86_64-pc-windows-msvc.zip",
    sha256 = "267f577d6d87c403d541420507f7b8f28fa56f6ff432d97eb2eb196c39cf268a",
    archiveType = "zip",
    executablePath = "codex-acp.exe",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":windows-x86_64:sha256:267f577d6d87c403d541420507f7b8f28fa56f6ff432d97eb2eb196c39cf268a"

  tarball url = CodexAcpBase & "aarch64-pc-windows-msvc.zip",
    sha256 = "409e9b114fff9451c73a27f620a087ad73649a44396415ef1c3bf217fb23c093",
    archiveType = "zip",
    executablePath = "codex-acp.exe",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":windows-aarch64:sha256:409e9b114fff9451c73a27f620a087ad73649a44396415ef1c3bf217fb23c093"

  tarball url = CodexAcpBase & "x86_64-unknown-linux-musl.tar.gz",
    sha256 = "dddc0dc7a6cf0fe98279a2eadfeeedca4e6e482c5fa71d468fd4cf8d89a6f53e",
    archiveType = "tar.gz",
    executablePath = "codex-acp",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":linux-x86_64:sha256:dddc0dc7a6cf0fe98279a2eadfeeedca4e6e482c5fa71d468fd4cf8d89a6f53e"

  tarball url = CodexAcpBase & "aarch64-unknown-linux-musl.tar.gz",
    sha256 = "18908961d97993458cb616bb39f8956dbb1bc327932493f0da068a2f23d617c3",
    archiveType = "tar.gz",
    executablePath = "codex-acp",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":linux-aarch64:sha256:18908961d97993458cb616bb39f8956dbb1bc327932493f0da068a2f23d617c3"

  tarball url = CodexAcpBase & "x86_64-apple-darwin.tar.gz",
    sha256 = "57f5c265473fc2b4c29cf574496d0f97c7a2474a2ea353662d0289885e529f36",
    archiveType = "tar.gz",
    executablePath = "codex-acp",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":macos-x86_64:sha256:57f5c265473fc2b4c29cf574496d0f97c7a2474a2ea353662d0289885e529f36"

  tarball url = CodexAcpBase & "aarch64-apple-darwin.tar.gz",
    sha256 = "01009b98cf3cfe83280f6aad060001cfa02694d6a62e6a2c4d17b6c30a3edcb1",
    archiveType = "tar.gz",
    executablePath = "codex-acp",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":macos-aarch64:sha256:01009b98cf3cfe83280f6aad060001cfa02694d6a62e6a2c4d17b6c30a3edcb1"

# Every provider module of a catalog is extracted on its own by
# `repro catalog publish` and lifted into the artifact of ONE package, named
# by this block; the realizations above are the contributions it carries.
package codexAcpRealizations:
  discard
