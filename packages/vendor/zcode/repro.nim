## Vendor-binary realization of the ``zcode`` interface (Z.ai ZCode desktop).
##
## ## Provenance and licence
##
## **Provenance class: vendor-binary.** ZCode is a closed-source Electron
## application (a 400 MB ``app.asar``); Z.ai publishes no source, so this is
## the only realization shape and it must never be described as built from
## source. Licence evidence: ZCode Terms of Service, version effective June 15,
## 2026, https://zcode.z.ai/en/terms (fetched 2026-11-17), which prohibits
## "reverse-engineering any algorithms, source code, or mechanisms of ZCode".
## The package metadata inside upstream's own Linux package says
## ``license = unknown`` (``.PKGINFO``), so the terms page is the only
## evidence. The Chromium/Electron components inside carry their own licences
## (``LICENSE.electron.txt``, ``LICENSES.chromium.html`` in the tree); those do
## not make ZCode itself open source.
##
## Homepage https://zcode.z.ai ; changelog https://zcode.z.ai/en/changelog ;
## source location: none.
##
## ## Version and channel
##
## 3.18.2, released 2026-11-12 (``releaseDate`` in upstream's ``latest.yml``).
## The channel is the download page https://zcode.z.ai/en, whose embedded
## data names the newest version just before its ``pluginDownload`` key
## (that was 3.18.2 on 2026-11-17; the same page lists every older version).
## Artifacts are version-addressed under
## ``https://cdn-zcode.z.ai/zcode/electron/releases/<v>/<platform>/``.
##
## ## What upstream ships, and what is realized
##
## Per platform upstream publishes an electron-builder ``latest.yml`` and
## installers: Linux AppImage, ``.deb``, ``.rpm`` and ``.pkg.tar.zst``;
## macOS ``.zip`` and ``.dmg``; Windows NSIS ``.exe``.
##
## * **Linux** uses the ``.pkg.tar.zst`` (pacman) package, because it is the
##   only Linux payload this tarball codec can unpack to a runnable tree:
##   ``.deb`` / ``.rpm`` / AppImage have no ``archiveType``. FILE-NAME TRAP:
##   despite the ``.zst`` suffix the file is XZ-compressed (``zstd -d``
##   rejects it as an xz file; ``tar -tJf`` lists it), so the record says
##   ``archiveType = "tar.xz"``, not ``pkg.tar.zst``. Listing: ``.MTREE``,
##   ``.PKGINFO``, ``.INSTALL`` at the root, then ``opt/ZCode/...`` (the
##   Electron tree) and ``usr/share/...``. The program is
##   ``opt/ZCode/zcode`` (ELF), so ``executablePath = "opt/ZCode/zcode"``,
##   ``stripComponents = 0`` (the tree must stay together: ``libffmpeg.so``,
##   ``resources.pak`` and ``app.asar`` are found next to the binary).
##   ``chrome-sandbox`` in that tree normally needs the setuid bit, which an
##   unprivileged store prefix cannot give; the record kinds have no field
##   for it, so on hosts without unprivileged user namespaces the app must be
##   started with ``--no-sandbox`` (not verified here; I did not run it).
##   The Electron binary also dlopen()s system GTK/NSS/etc. (the ``.PKGINFO``
##   dependency list: gtk3, nss, libxss, libxtst, libnotify, alsa-lib, mesa,
##   xdg-utils); the record kinds cannot express those, and on NixOS they
##   would have to come from elsewhere (numtide patches RUNPATHs; this
##   realization does not).
## * **macOS** uses the ``.zip`` as an ``app-bundle`` (the shape
##   claude-desktop uses): ``ZCode.app``, bundle id ``dev.zcode.app``
##   (read from ``Contents/Info.plist`` in both archives),
##   ``CFBundleShortVersionString`` 3.18.2, team id 8A5X4JJ39T. The team id
##   appears in the code signature embedded in both ``ZCode`` Mach-O files
##   (string present, 4 hits each) and matches the numtide lead; I could
##   NOT run ``codesign`` / ``spctl`` here (Linux host), so signature and
##   notarization are unverified, and realization re-checks them on a Mac.
##   ``executablePath`` is ``ZCode.app/Contents/MacOS/ZCode``. An application
##   package's home launcher is named after the package and runs
##   ``executablePath`` (Store-And-Installation-Layout.md § macOS Application
##   Bundles, "Command line"), so the command ``zcode`` exists on macOS without
##   an ``executableAlias`` (a copy out of the bundle would break the app). Not
##   run here: no home apply was made on a Mac.
## * **Windows** is NOT realized: upstream ships only an NSIS installer
##   (``ZCode-<v>-win-<cpu>.exe``) and I did not verify an installer-nsis
##   realization. That is a gap, not a decision that none is possible.
##
## ## Digests
##
## Upstream publishes electron-builder's ``sha512`` (base64) per artifact in
## ``latest.yml``, NOT a sha256. The sha256 values below are therefore
## SELF-COMPUTED: I downloaded each artifact and ran ``sha256sum``. I also
## computed sha512 of each download and compared it to ``latest.yml``: all
## four match upstream's published value exactly. Upstream's sha512 (base64):
##
##   linux-x64   pkg.tar.zst  18H8pcAqr1cHAweMXGaafpzdhkVUnPIbCkJ+4gGZGQ4yVgkGJbUXV9kz4O9rzKx9FltOmJdGvNBp/Wc8narqOg==
##   linux-arm64 pkg.tar.zst  WLUvWG3QpE26HBDPLKzp789So3NGybj+JA9tJkoP2yEpj91lHpo1dYs8t3KYLMtqh+HP1W03cGBu5tGNk70E7Q==
##   mac-x64     zip          gtHHaI3c7jsA490XAG4dSMd+sleKKUpPZTJlIxYYm6y/Qjx/CVha6Xs9cW9CG5+tlg3iQYecqOV1ii/UcGO6hw==
##   mac-arm64   zip          KD7Z6GjYQWAX2tvgIE35XA4iLU5jn41tx5Wz2ZJEs+ivWu56cQY3yqsusuh88MvgCrtOykRjfhOyHhA1S2Q2gA==
##
## ## Credentials, endpoints
##
## Sign-in is by Z.ai account (OAuth via https://chat.z.ai and
## https://zcode.z.ai/api/v1/oauth/token) or a provider API key configured
## in the app; ``ZCODE_HOME`` selects the data directory and
## ``ZCODE_CREDENTIAL_SECRET`` / ``ZCODE_CREDENTIAL_SECRET_FILE`` feed the
## credential store (names read from strings in ``app.asar``; semantics not
## verified). Endpoints seen: https://api.z.ai (``/api/paas/v4``,
## ``/api/coding/paas/v4``), https://open.bigmodel.cn, https://bigmodel.cn,
## https://zcode.z.ai (``/api/v1/event/report`` telemetry),
## https://cdn-zcode.z.ai (updates, official plugin assets).
##
## ## Self-update
##
## The app embeds electron-updater: ``resources/app-update.yml`` declares
## ``provider: generic`` with a placeholder ``url: http://localhost:8081``
## (the real feed, ``cdn-zcode.z.ai/.../releases``, appears to be set at run
## time; inferred, not observed), and the app calls ``checkForUpdates``.
## Its user setting ``autoDownloadAndInstallUpdates`` defaults to false and
## the 3.18.2 release notes say updates now need manual confirmation, but the
## check itself still runs. This realization CANNOT disable it: the tarball
## record has no field for a wrapper, a settings file seed or a flag, and I
## found no environment variable that turns the updater off. On Linux an
## in-place update of a read-only store prefix fails rather than rewriting
## it; on macOS the bundle is sealed and re-verified by realization.
##
## ## Cache policy
##
## Every slice carries ``nonRedistributable = true``: fetched on the user's
## behalf, never republished into a shared binary cache.

import repro_project_dsl

const
  ZCodeVersion = "3.18.2"
  ZCodeBase =
    "https://cdn-zcode.z.ai/zcode/electron/releases/" & ZCodeVersion & "/"

provisioningFor "zcode":
  interfaceFingerprint "287aaf5ca65eb0794ef76dd8ab6ef71b2d057925a442f3b5d78230208aea413b"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = ZCodeBase & "linux-x64/ZCode-" & ZCodeVersion &
      "-linux-x64.pkg.tar.zst",
    sha256 = "bdd82def4966de3999a82d3b9562db1e6f99d031173e2e06d4523c493c973e38",
    archiveType = "tar.xz",
    stripComponents = 0,
    executablePath = "opt/ZCode/zcode",
    nonRedistributable = true,
    packageId = "zcode@" & ZCodeVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:zcode@" & ZCodeVersion &
      ":linux-x86_64:sha256:bdd82def4966de3999a82d3b9562db1e6f99d031173e2e06d4523c493c973e38"

  tarball url = ZCodeBase & "linux-arm64/ZCode-" & ZCodeVersion &
      "-linux-arm64.pkg.tar.zst",
    sha256 = "4f0e0f1b1656fa915204aec8a6e6bd1e4e5e6d53223e50f6731ddaa67f74c825",
    archiveType = "tar.xz",
    stripComponents = 0,
    executablePath = "opt/ZCode/zcode",
    nonRedistributable = true,
    packageId = "zcode@" & ZCodeVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:zcode@" & ZCodeVersion &
      ":linux-aarch64:sha256:4f0e0f1b1656fa915204aec8a6e6bd1e4e5e6d53223e50f6731ddaa67f74c825"

  tarball url = ZCodeBase & "macos-x64/ZCode-" & ZCodeVersion & "-mac-x64.zip",
    sha256 = "a0250c58672742dfbda55b41841d237cac6fb14f8d01c3cdaaa64625cac29ab9",
    archiveType = "zip",
    installMethod = "app-bundle",
    appBundle = "ZCode.app",
    bundleId = "dev.zcode.app",
    teamId = "8A5X4JJ39T",
    version = ZCodeVersion,
    executablePath = "ZCode.app/Contents/MacOS/ZCode",
    nonRedistributable = true,
    packageId = "zcode@" & ZCodeVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:zcode@" & ZCodeVersion &
      ":macos-x86_64:sha256:a0250c58672742dfbda55b41841d237cac6fb14f8d01c3cdaaa64625cac29ab9"

  tarball url = ZCodeBase & "macos-arm64/ZCode-" & ZCodeVersion & "-mac-arm64.zip",
    sha256 = "b5af46c37aa423d3c7d435f41ec4997d50e4148f662117b6980e586be7172dd8",
    archiveType = "zip",
    installMethod = "app-bundle",
    appBundle = "ZCode.app",
    bundleId = "dev.zcode.app",
    teamId = "8A5X4JJ39T",
    version = ZCodeVersion,
    executablePath = "ZCode.app/Contents/MacOS/ZCode",
    nonRedistributable = true,
    packageId = "zcode@" & ZCodeVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:zcode@" & ZCodeVersion &
      ":macos-aarch64:sha256:b5af46c37aa423d3c7d435f41ec4997d50e4148f662117b6980e586be7172dd8"

# Every provider module of a catalog is extracted on its own by
# `repro catalog publish` and lifted into the artifact of ONE package, named
# by this block; the realizations above are the contributions it carries.
package zcodeRealizations:
  discard
