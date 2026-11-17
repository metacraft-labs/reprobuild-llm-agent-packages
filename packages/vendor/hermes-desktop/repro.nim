## Vendor-binary realization of the ``hermes-desktop`` interface: Nous
## Research's signed, notarized ``Hermes Agent.app`` for macOS arm64.
##
## ## Provenance, in words
##
## The project is source-available (MIT, ``apps/desktop`` in
## https://github.com/NousResearch/hermes-agent; licence verified at the
## pinned tag: https://github.com/NousResearch/hermes-agent/blob/v0.22.0/LICENSE).
## This realization is NOT a from-source build. It repacks the binary bundle
## upstream's release CI built from that source, and must not be presented
## as equivalent provenance. A from-source realization is not expressible:
## the bundle is an Electron app plus a pinned CPython, uv, Node and a
## prebuilt Python dependency tree, built by electron-builder and signed
## with a Developer ID the catalog does not hold (see the interface header).
##
## ## Version and channel
##
## 0.22.0, the version served by upstream's ``stable`` channel
## (``releases/channels/stable.json`` -> build ``e1734abd5c61...``, release
## tag v0.22.0, commit ``e06df9c2eae6901f4c88f464e0ae6e753c0428b8``,
## published 2026-10-14). The stable channel LAGS the GitHub releases: the
## newest tag, v0.23.2 (2026-11-16), has no desktop artifacts yet. The
## consuming workspace's current source build is 0.23.0, so this pin is
## older than what it runs today.
##
## ## Where the bytes live
##
## ``https://hermes-assets.nousresearch.com/releases/tag/rc.3-v0.22.0/``.
## ``releases/tag/<tag>/<file>`` is immutable upstream ("Same-tag macOS
## artifacts cannot be overwritten with different bytes",
## ``website/docs/developer-guide/macos-bundle-updates.md``); the URLs under
## ``releases/darwin/stable/`` and ``Hermes-Setup.dmg`` are MUTABLE and are
## deliberately not used.
##
## ## Digest
##
## The sha256 is UPSTREAM-PUBLISHED: it is the ``artifact.sha256`` of the
## darwin/arm64 package in the stable build manifest
## (``releases/channel-builds/<buildId>/build.json``). It was also computed
## independently on 2026-11-17 by downloading the 1,583,117,114-byte file
## and running ``sha256sum``: the two are equal. The feed's own sha512
## (``stable-mac.yml``) was recomputed and matched as well.
##
## ## What was read out of the archive
##
## The ZIP holds one top-level directory entry, ``Hermes Agent.app``;
## ``Contents/MacOS/Hermes Agent`` exists (53,488 bytes, mode 0755) and
## ``Info.plist`` gives ``CFBundleIdentifier`` ``com.nousresearch.hermes-bundled``,
## ``CFBundleShortVersionString`` ``0.22.0``, ``CFBundleExecutable``
## ``Hermes Agent``. ``stripComponents`` is 0 (an app-bundle record keeps the
## bundle at the prefix root). The team id, ``763K57MW7Z``, is taken from
## upstream's build manifest (``teamId``). It was NOT verified with
## ``codesign`` here (this was a Linux host); realization checks it, and a
## wrong value fails realization rather than installing.
##
## ## Slices
##
## macOS arm64 only. Upstream publishes no macOS x86_64 bundle, no Linux
## desktop build, and a Windows MSIX the record kinds cannot install (see
## the interface header); those are upstream gaps and a record-kind gap,
## not missing entries.
##
## ## Runtime facts
##
## * Credentials: none held by the app itself. The bundled agent reads
##   provider keys from ``~/.hermes/.env`` and OAuth tokens from
##   ``~/.hermes/auth.json``; ``HERMES_HOME`` relocates them. The desktop
##   update check also honours ``GITHUB_TOKEN`` / ``GH_TOKEN``.
## * Network: ``hermes-assets.nousresearch.com`` (update feed),
##   ``api.github.com`` (the in-app update check), the Nous Portal
##   (``portal.nousresearch.com``, ``inference-api.nousresearch.com``) and
##   whichever model providers the user configures. Honours
##   ``HTTPS_PROXY`` / ``HTTP_PROXY`` / ``NO_PROXY``.
## * Self-update: the bundle embeds electron-updater with Squirrel.Mac. Its
##   ``Contents/Resources/app-update.yml`` is
##   ``provider: generic, url: https://hermes-assets.nousresearch.com/releases/darwin/stable/``.
##   Upstream's docs say checks never download automatically and an update
##   is applied only on the user's request, but there is a user-facing apply
##   path. The record kinds have no flag or environment field for a
##   realization to disable it with (the ``env`` argument belongs to
##   installers), and the sealed bundle cannot be edited without breaking
##   its signature, so the update path is NOT disabled by this recipe. A
##   store-placed bundle that an in-app update replaced would diverge from
##   its content-addressed identity. Treat that as an open gap; the fix
##   belongs in upstream (a no-update channel/identity) or in the
##   realizer (read-only placement).
##
## ## Non-redistributable
##
## The payload is a 1.5 GB aggregate of upstream's code and third-party
## components (Electron/Chromium, CPython, Node, Python wheels) whose
## licence notices were not audited at this version. Until they are, the
## slice refuses publication to a shared cache; the bytes stay upstream.

import repro_project_dsl

const
  HermesDesktopVersion = "0.22.0"
  HermesDesktopArm64Sha256 =
    "8a3b64b4e2b10b88912937f883a2c616ea902f3b5c683d3cdffc459de7fa8f73"

provisioningFor "hermes-desktop":
  interfaceFingerprint "7ce7183c7f5c99f4e837a3abd5975f86da2198b2d1cbe38f330c34fda6029b0f"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url =
      "https://hermes-assets.nousresearch.com/releases/tag/rc.3-v0.22.0/" &
      "HermesBundled-" & HermesDesktopVersion & "-mac-arm64.zip",
    sha256 = HermesDesktopArm64Sha256,
    archiveType = "zip",
    installMethod = "app-bundle",
    appBundle = "Hermes Agent.app",
    bundleId = "com.nousresearch.hermes-bundled",
    teamId = "763K57MW7Z",
    version = HermesDesktopVersion,
    executablePath = "Hermes Agent.app/Contents/MacOS/Hermes Agent",
    nonRedistributable = true,
    packageId = "hermes-desktop@" & HermesDesktopVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:hermes-desktop@" & HermesDesktopVersion &
      ":macos-aarch64:sha256:" & HermesDesktopArm64Sha256
