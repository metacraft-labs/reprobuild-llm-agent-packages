## Vendor-binary realization of the ``codex-acp`` interface.
##
## Flat archive: ``codex-acp.exe`` at the root.
##
## Upstream is source-available, so a from-source realization belongs under
## ``packages/source/codex-acp/`` and this pinned-binary entry sits alongside
## it rather than standing in for it.
##
## The digest matches the ``CODEX_ACP_SHA256_X86_64_PC_WINDOWS_MSVC`` pin its
## consumer harvested independently.
##
## x86_64 only: upstream publishes an aarch64-windows asset for this release
## too, but its digest was not re-verified here, and pinning an unverified
## one would put an unchecked claim in the catalog.

import repro_project_dsl

const CodexAcpVersion = "0.14.0"

provisioningFor "codex-acp":
  interfaceFingerprint "bebd1dcb96e756936e2afd040b31448a80603979bd036b7f7ee7e1a91cc2a5b5"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = "https://github.com/zed-industries/codex-acp/releases/download/v" &
      CodexAcpVersion & "/codex-acp-" & CodexAcpVersion &
      "-x86_64-pc-windows-msvc.zip",
    sha256 = "267f577d6d87c403d541420507f7b8f28fa56f6ff432d97eb2eb196c39cf268a",
    archiveType = "zip",
    executablePath = "codex-acp.exe",
    packageId = "codex-acp@" & CodexAcpVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:codex-acp@" & CodexAcpVersion &
      ":windows-x86_64:sha256:267f577d6d87c403d541420507f7b8f28fa56f6ff432d97eb2eb196c39cf268a"
