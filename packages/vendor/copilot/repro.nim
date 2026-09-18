## Vendor-binary realization of the ``copilot`` interface.
##
## Flat archives: ``copilot.exe`` at the root, no strip.
##
## Version 1.0.83, matching the pin its consumer carries. That consumer
## installs Copilot from npm rather than from these release archives, so
## unlike the other agents in this catalog there was no independently
## harvested digest to cross-check against; both were computed from the
## upstream assets on 2026-09-17 and are the only source for them here.
##
## **Cache policy.** `copilot` is `provenance_class = "vendor-binary"` in the
## inventory, so its payload is fetched on the user's behalf and must not be
## republished into a shared binary cache — a cache is redistribution, and
## redistribution is not a right the licence grants. Both slices carry
## `nonRedistributable = true`, which is what enforces it:
## `publishToolPrefix` refuses the upload before it checks whether
## credentials exist, so the policy holds on a machine configured to publish
## rather than only on one that happens not to be.

import repro_project_dsl

const
  CopilotVersion = "1.0.83"
  CopilotBase = "https://github.com/github/copilot-cli/releases/download/v" &
    CopilotVersion & "/copilot-win32-"

provisioningFor "copilot":
  interfaceFingerprint "62999373bd6ca7c7e7bef189a0141d4fb402ff93d95f8d87ef2408acbff1a6b5"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = CopilotBase & "x64.zip",
    sha256 = "0e07221a275fdf7e61619c53566e3a421fd646d74d8e9ca491dbbff221f22945",
    archiveType = "zip",
    nonRedistributable = true,
    executablePath = "copilot.exe",
    packageId = "copilot@" & CopilotVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:copilot@" & CopilotVersion &
      ":windows-x86_64:sha256:0e07221a275fdf7e61619c53566e3a421fd646d74d8e9ca491dbbff221f22945"

  tarball url = CopilotBase & "arm64.zip",
    sha256 = "63f35c0ce1a5fdcc6f3e584890d689b1ede8f930933394aaf7b5e139b53d2cc1",
    archiveType = "zip",
    nonRedistributable = true,
    executablePath = "copilot.exe",
    packageId = "copilot@" & CopilotVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:copilot@" & CopilotVersion &
      ":windows-aarch64:sha256:63f35c0ce1a5fdcc6f3e584890d689b1ede8f930933394aaf7b5e139b53d2cc1"
