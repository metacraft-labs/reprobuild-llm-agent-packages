## Vendor-binary realization of the ``opencode`` interface.
##
## Source-available upstream, so a from-source realization belongs under
## ``packages/source/opencode/`` and this pinned-binary entry sits alongside
## it rather than standing in for it.
##
## The release zip carries ``opencode.exe`` flat at the archive root.
##
## Per the catalog's metadata rules, the licence must be re-verified AT THIS
## VERSION rather than inherited: OpenCode's licence and its published build
## have diverged before, which is why the interface module says so too.
##
## Digests are the ``OPENCODE_SHA256_1_18_31_*`` values the consuming project
## harvested independently; both were re-verified against the artifacts.

import repro_project_dsl

const
  OpencodeVersion = "1.18.31"
  OpencodeBase = "https://github.com/sst/opencode/releases/download/v" &
    OpencodeVersion & "/opencode-windows-"

provisioningFor "opencode":
  interfaceFingerprint "c3febd17d26ee16b06d4420469c559b8b9ea01599c2a14f2bed97d19b6a90fb0"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = OpencodeBase & "x64.zip",
    sha256 = "0ecd7ffc7f26390ce7799e7bcd409e4f11c410144308a6a5b0fcdce63d871006",
    archiveType = "zip",
    executablePath = "opencode.exe",
    packageId = "opencode@" & OpencodeVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:opencode@" & OpencodeVersion &
      ":windows-x86_64:sha256:0ecd7ffc7f26390ce7799e7bcd409e4f11c410144308a6a5b0fcdce63d871006"

  tarball url = OpencodeBase & "arm64.zip",
    sha256 = "1b20c559ac53e342046a0080bacb89cb3d40997943ecf18a2bc4d1b0398e33b2",
    archiveType = "zip",
    executablePath = "opencode.exe",
    packageId = "opencode@" & OpencodeVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:opencode@" & OpencodeVersion &
      ":windows-aarch64:sha256:1b20c559ac53e342046a0080bacb89cb3d40997943ecf18a2bc4d1b0398e33b2"
