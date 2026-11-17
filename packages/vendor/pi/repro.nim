## Vendor-binary realization of the ``pi`` interface.
##
## ## Provenance
##
## **Provenance class: source-available upstream, vendor-binary realization.**
## Upstream publishes its source under the MIT licence, so the catalog's
## primary realization would be a from-source build under
## ``packages/source/pi/``; none exists (see the interface for why), and this
## entry repacks the prebuilt standalone binaries upstream's release workflow
## attaches to each GitHub release. It must not be presented as built from
## source or as equivalent provenance.
##
## - Homepage / source: https://github.com/earendil-works/pi (the coding agent
##   is ``packages/coding-agent``, npm ``@earendil-works/pi-coding-agent``;
##   upstream documentation and the version-check endpoint are on ``pi.dev``).
##   The repository declares no separate homepage.
## - Release channel: GitHub releases, tag ``v<version>``, stable.
## - Version: 1.5.2 (published 2026-11-10, the newest release at the time of
##   writing). It is also the version of the numtide/llm-agents.nix pin this
##   was led by.
## - Licence, verified at this version: the LICENSE file at tag ``v1.5.2`` --
##   https://raw.githubusercontent.com/earendil-works/pi/v1.5.2/LICENSE -- is
##   the MIT licence, "Copyright (c) 2025 Mario Zechner". The binary embeds
##   its npm dependencies under their own licences, which this recipe has not
##   audited. Because the licence permits redistribution these payloads do NOT
##   set ``nonRedistributable`` (the catalog applies that to closed-source
##   vendor binaries; goose and codex, MIT/Apache upstream builds, do not set
##   it either).
##
## ## What the archives are
##
## A ``bun build --compile`` standalone executable (``pi``, 100-123 MB) plus
## the runtime assets bun cannot embed, laid out the way the program expects:
## ``package.json``, ``theme/``, ``assets/``, ``export-html/``,
## ``photon_rs_bg.wasm``, ``native/<os>/prebuilds/<target>/*.node``, and
## ``docs/`` and ``examples/``. The program finds those beside itself, so the
## WHOLE archive is realized, not the one file; pruning would change what
## upstream tested.
##
## The Unix archives (``.tar.gz``) wrap everything in a ``pi/`` directory, so
## ``stripComponents = 1`` and ``executablePath = "pi"``. The Windows archives
## (``.zip``) have NO wrapper -- ``pi.exe`` is at the root -- so
## ``stripComponents`` is 0 and ``executablePath = "pi.exe"``. Both facts were
## read from the archive listings rather than assumed to match.
##
## ## Platforms and digests
##
## Six explicit slices, every one distinct. Each sha256 is the value upstream
## itself publishes in the release's ``SHA256SUMS`` asset for that exact
## archive, and each was compared with the sha256 of the archive downloaded
## here: all six matched. The release lists no musl and no 32-bit builds; those
## are upstream platform gaps, not missing recipes. Run check: the linux-x86_64 binary was started and printed
## ``1.5.2`` for ``pi --version`` (on NixOS through an explicit glibc loader,
## with ``PI_PACKAGE_DIR`` pointing at the unpacked archive because the
## loader hides the executable's own directory). The other five slices were
## checksummed and listed but not executed.
##
## ## Credentials, endpoints, config paths
##
## The program needs a model-provider credential. It reads the provider's
## standard API-key variable (``ANTHROPIC_API_KEY``, ``OPENAI_API_KEY``,
## ``GEMINI_API_KEY``, ``OPENROUTER_API_KEY``, ... -- the full table is
## ``docs/providers.md`` in the archive) or an OAuth/API-key credential that
## ``/login`` stores in ``auth.json`` under the agent directory (default
## ``~/.pi/agent``, overridden by ``PI_CODING_AGENT_DIR``). Run-time
## endpoints: the chosen model provider's API; ``pi.dev`` for the latest-version
## request; ``radius.pi.dev`` for ``/bug`` uploads; and install/update
## telemetry and a model-catalog refresh whose hosts I did not identify.
## ``PI_OFFLINE=1`` disables automatic network activity including the
## catalog refresh. This list is read from source and docs, not observed
## from traffic.
##
## ## Self-update, and what this recipe cannot do about it
##
## Pi has a version check (a request to ``pi.dev`` that prints a newer-version
## notice) and ``pi update``, which runs a package-manager command to update
## Pi itself. Upstream's switches are ``PI_SKIP_VERSION_CHECK=1`` (no
## version request), ``PI_TELEMETRY=0``, ``PI_OFFLINE=1``, and
## ``PI_SELF_UPDATE_COMMAND`` to redirect what ``pi update`` runs. The
## each slice therefore declares ``env = "PI_SKIP_VERSION_CHECK=1"`` and
## ``env = "PI_TELEMETRY=0"``, exported by the ``tarball`` record as bindings of
## bindings written by ``repro home apply`` as a persistent user environment variable (a managed block in the shell rc file on POSIX, the user registry on Windows). LIMIT: variables, not a wrapper, and only home apply
## writes them, so a ``pi`` started by something that does not read that rc file
## (a GUI launcher, cron) or from a ``uses:`` dev environment is not covered. Per upstream's changelog the
## check disables "new version notifications", and ``pi update`` runs only when
## the user invokes it, so no unprompted rewrite of the prefix was found; a user
## who runs ``pi update`` would still try.

import repro_project_dsl

const
  PiVersion = "1.5.2"
  PiBase = "https://github.com/earendil-works/pi/releases/download/v" &
    PiVersion & "/"

provisioningFor "pi":
  interfaceFingerprint "bde25f0c3bb13380fd83a3e559f135307408e65e40cf99bafc5c1a15b0abb4cf"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = PiBase & "pi-linux-x64.tar.gz",
    sha256 = "811c6f2c9e7aaee252b5404252e556fb713aa209c1f7f924226aa77d4ef70cb5",
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "pi",
    env = "PI_SKIP_VERSION_CHECK=1",
    env = "PI_TELEMETRY=0",
    packageId = "pi@" & PiVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:pi@" & PiVersion &
      ":linux-x86_64:sha256:811c6f2c9e7aaee252b5404252e556fb713aa209c1f7f924226aa77d4ef70cb5"

  tarball url = PiBase & "pi-linux-arm64.tar.gz",
    sha256 = "42805cd5615952fcbbfc9c56b04f8feb84395134952e169a6cdc8d7676975666",
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "pi",
    env = "PI_SKIP_VERSION_CHECK=1",
    env = "PI_TELEMETRY=0",
    packageId = "pi@" & PiVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:pi@" & PiVersion &
      ":linux-aarch64:sha256:42805cd5615952fcbbfc9c56b04f8feb84395134952e169a6cdc8d7676975666"

  tarball url = PiBase & "pi-darwin-arm64.tar.gz",
    sha256 = "56b5e194d485ced555667b8ba3276157a8272e9ecde9e001e428af80985bdd9b",
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "pi",
    env = "PI_SKIP_VERSION_CHECK=1",
    env = "PI_TELEMETRY=0",
    packageId = "pi@" & PiVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:pi@" & PiVersion &
      ":macos-aarch64:sha256:56b5e194d485ced555667b8ba3276157a8272e9ecde9e001e428af80985bdd9b"

  tarball url = PiBase & "pi-darwin-x64.tar.gz",
    sha256 = "f997a088613514ac97d913aeea7642094d84fe6d46854ff7e64e2c12e536dc50",
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "pi",
    env = "PI_SKIP_VERSION_CHECK=1",
    env = "PI_TELEMETRY=0",
    packageId = "pi@" & PiVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:pi@" & PiVersion &
      ":macos-x86_64:sha256:f997a088613514ac97d913aeea7642094d84fe6d46854ff7e64e2c12e536dc50"

  tarball url = PiBase & "pi-windows-x64.zip",
    sha256 = "e6adb8cb8c84eca14391ad24b363de9d2be98a89ca3ba3fdee1fa4de32b7f2e8",
    archiveType = "zip",
    executablePath = "pi.exe",
    env = "PI_SKIP_VERSION_CHECK=1",
    env = "PI_TELEMETRY=0",
    packageId = "pi@" & PiVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:pi@" & PiVersion &
      ":windows-x86_64:sha256:e6adb8cb8c84eca14391ad24b363de9d2be98a89ca3ba3fdee1fa4de32b7f2e8"

  tarball url = PiBase & "pi-windows-arm64.zip",
    sha256 = "e83404bc5a6003ac950683edd9b6cf499dac91ec890d8439a8c32528de534a77",
    archiveType = "zip",
    executablePath = "pi.exe",
    env = "PI_SKIP_VERSION_CHECK=1",
    env = "PI_TELEMETRY=0",
    packageId = "pi@" & PiVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:pi@" & PiVersion &
      ":windows-aarch64:sha256:e83404bc5a6003ac950683edd9b6cf499dac91ec890d8439a8c32528de534a77"
