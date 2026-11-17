## Vendor-binary realization of the ``muse-code`` interface (Meta Muse Code).
##
## ## Provenance and licence
##
## **Provenance class: vendor-binary.** Meta publishes Muse Code only as
## prebuilt native executables and no source, so this is the only realization
## shape and it must never be described as built from source.
## Licence evidence: the Meta Model API Terms of Service, last updated
## October 9, 2026 (https://dev.meta.ai/legal/terms-of-service; fetched
## 2026-11-17), whose "Downloadable Materials" clause forbids selling,
## leasing, redistributing, sublicensing, making available to third parties
## or modifying the downloaded materials. I read that clause; I did not
## find a separate Muse-Code-specific EULA, so whether another document
## governs the CLI is unverified. Not open source.
##
## Homepage: https://dev.meta.ai/ (changelog
## https://dev.meta.ai/docs/muse-code/changelog). Source location: none.
##
## ## Version and channel
##
## Channel ``muse-stable``. The channel document
## https://api.meta.ai/muse-code/channels/muse-stable read version
## ``1.4.23-R8977.1`` (state ``public``) on 2026-11-17 and points at the
## per-version manifest
## ``https://lookaside.facebook.com/lookaside/muse/download/?channel=muse&version=<v>&file=manifest.json``.
## The version string has the shape ``X.Y.Z-R<build>[.<n>]`` (the launcher's
## own ``version_pattern``).
##
## ## What upstream ships, and the declared executable
##
## Each ``file=muse-<arch>-<os>`` URL is ONE bare executable, not an archive,
## so ``archiveType = "raw"``: realize copies the download into the prefix
## under the name ``executablePath`` gives. Magic bytes and machine type
## checked per slice: ELF x86-64 / AArch64, Mach-O x86-64 / arm64, PE32+
## x64 / arm64. The upstream names say ``x86``; they are x86-64 binaries,
## hence cpu = "x86_64". Slices: all six in the manifest. The manifest also
## lists a ``universal_macos_pkg`` (``muse.pkg``, sha256
## 061e3c78...); it is deliberately not used: the two per-arch Mach-O files
## already cover macOS, and a flat installer package is the ``pkg-install``
## shape the tarball record only declares.
##
## ## Digests
##
## UPSTREAM-PUBLISHED: every digest below is the ``checksum`` (sha256) field
## of that artifact in the version's manifest.json. I also downloaded all
## six artifacts and ran ``sha256sum``; all six computed values are equal to
## the manifest's, and the sizes match the manifest's ``size``.
##
## ## Credentials, endpoints
##
## Needs a Meta account or key: ``META_API_KEY`` in the environment, or a
## device-code login (https://auth.meta.com) whose token is stored at
## ``$XDG_CONFIG_HOME/muse/auth.json`` / ``~/.config/muse/auth.json``
## (``MUSE_AUTH_PATH`` overrides). The binary also reads other providers' keys
## (``ANTHROPIC_API_KEY``, ``OPENAI_API_KEY``, ``OPENROUTER_API_KEY``) and
## ``MUSE_MODEL``. Endpoints: https://api.meta.ai (``/v1``, the channel
## document, ``muse-code/telemetry``, ``muse-code/feedback``),
## https://auth.meta.com, https://lookaside.facebook.com (downloads),
## https://dev.meta.ai. Downloads from lookaside were served without
## authentication on 2026-11-17.
##
## ## Self-update
##
## The bare binary is what this realization installs. Upstream's update logic
## is in the LAUNCHER script (https://api.meta.ai/muse-launcher.sh, installed
## by https://dev.meta.ai/install.sh as ``~/.local/bin/muse``), which checks
## the channel every ``MUSE_UPDATE_INTERVAL_SECONDS`` (default 3600) and swaps
## the binary in place unless ``MUSE_NO_AUTO_UPDATE=1`` (read from the script).
## The launcher is not part of this payload, so I could not establish
## whether the bare binary has an update path of its own (it mentions
## "auto-update" in strings; unverified). Each slice sets
## ``env = "MUSE_NO_AUTO_UPDATE=1"``, exported as an environment binding of
## the activated home environment: it covers the launcher if a user runs one
## from that environment, and is harmless otherwise. The record kinds have no
## wrapper or argv field to do more.
##
## ## Cache policy
##
## Every slice carries ``nonRedistributable = true``: fetched on the user's
## behalf, never republished into a shared binary cache.

import repro_project_dsl

const
  MuseCodeVersion = "1.4.23-R8977.1"
  MuseCodeBase =
    "https://lookaside.facebook.com/lookaside/muse/download/?channel=muse&version=" &
    MuseCodeVersion & "&file="

provisioningFor "muse-code":
  interfaceFingerprint "e16d215598b94c3852b0c6e892c343696c705a7d9190ad50bc52270ff37eb205"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = MuseCodeBase & "muse-x86-linux",
    sha256 = "7ca9e16659f759eab3ae6c4b61c6f1e70f5f3fea1ca961ebd49044a1146956f4",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "muse",
    env = "MUSE_NO_AUTO_UPDATE=1",
    packageId = "muse-code@" & MuseCodeVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:muse-code@" & MuseCodeVersion &
      ":linux-x86_64:sha256:7ca9e16659f759eab3ae6c4b61c6f1e70f5f3fea1ca961ebd49044a1146956f4"

  tarball url = MuseCodeBase & "muse-aarch64-linux",
    sha256 = "e06646f5e59bac21c1ae44c14bd361ed5375df6ac1f0637f03004a713fb85a33",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "muse",
    env = "MUSE_NO_AUTO_UPDATE=1",
    packageId = "muse-code@" & MuseCodeVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:muse-code@" & MuseCodeVersion &
      ":linux-aarch64:sha256:e06646f5e59bac21c1ae44c14bd361ed5375df6ac1f0637f03004a713fb85a33"

  tarball url = MuseCodeBase & "muse-x86-macos",
    sha256 = "d8a29bc2b5c44ac00372d4151bad9aec7f7e3f0985455530b6abd7807b4a6e40",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "muse",
    env = "MUSE_NO_AUTO_UPDATE=1",
    packageId = "muse-code@" & MuseCodeVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:muse-code@" & MuseCodeVersion &
      ":macos-x86_64:sha256:d8a29bc2b5c44ac00372d4151bad9aec7f7e3f0985455530b6abd7807b4a6e40"

  tarball url = MuseCodeBase & "muse-aarch64-macos",
    sha256 = "215a6eaac150f5855edc5a1df3b14ddfa504eb03690a4d65449887b396522fa8",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "muse",
    env = "MUSE_NO_AUTO_UPDATE=1",
    packageId = "muse-code@" & MuseCodeVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:muse-code@" & MuseCodeVersion &
      ":macos-aarch64:sha256:215a6eaac150f5855edc5a1df3b14ddfa504eb03690a4d65449887b396522fa8"

  tarball url = MuseCodeBase & "muse-x86-windows.exe",
    sha256 = "9ff96e49e2c623f35ea002a4aab08c29b08878636cbe218be388f8e0d5f33de1",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "muse.exe",
    env = "MUSE_NO_AUTO_UPDATE=1",
    packageId = "muse-code@" & MuseCodeVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:muse-code@" & MuseCodeVersion &
      ":windows-x86_64:sha256:9ff96e49e2c623f35ea002a4aab08c29b08878636cbe218be388f8e0d5f33de1"

  tarball url = MuseCodeBase & "muse-aarch64-windows.exe",
    sha256 = "9ba30ff829ab43cf990f948bb2a36c4fd082cc481fe5ebb642df36e0e567cf84",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "muse.exe",
    env = "MUSE_NO_AUTO_UPDATE=1",
    packageId = "muse-code@" & MuseCodeVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:muse-code@" & MuseCodeVersion &
      ":windows-aarch64:sha256:9ba30ff829ab43cf990f948bb2a36c4fd082cc481fe5ebb642df36e0e567cf84"
