## Vendor-binary realization of the ``kimi-code`` interface.
##
## ## Provenance
##
## **Provenance class: source-available upstream, vendor-binary realization.**
## Upstream publishes its source under the MIT licence, so the catalog's
## primary realization would be a from-source build under
## ``packages/source/kimi-code/``; none exists (see the interface for why), and
## this entry repacks the prebuilt binaries upstream's release workflow
## attaches to each GitHub release. It must not be presented as built from
## source or as equivalent provenance.
##
## - Homepage: https://www.kimi.com/code/docs/
## - Source: https://github.com/MoonshotAI/kimi-code (pnpm workspace; the CLI
##   is ``apps/kimi-code``)
## - Release channel: GitHub releases of the repository, tag
##   ``@moonshot-ai/kimi-code@<version>``, stable (non-prerelease) only;
##   upstream also publishes ``-canary.`` prereleases, which are not pinned.
## - Version: 2.6.3 (published 2026-11-17, the newest stable at the time of
##   writing). The numtide/llm-agents.nix pin this was led by is 2.5.3.
## - Licence, verified at this version: the LICENSE file at tag
##   ``@moonshot-ai/kimi-code@2.6.3`` --
##   https://raw.githubusercontent.com/MoonshotAI/kimi-code/%40moonshot-ai%2Fkimi-code%402.6.3/LICENSE
##   -- is the MIT licence, "Copyright (c) 2026 Moonshot AI".
##   The binary bundles third-party dependencies under their own licences
##   that this recipe has not audited.
##   This realization is the CONVENIENCE one: the primary realization of a
##   source-available package is a from-source build, which does not exist
##   yet (reprobuild-pm issue 2026-11-18-nine-agents-source-available-without-from-source-realization).
##   Every slice sets ``nonRedistributable``: what is realized is a prebuilt
##   aggregate whose bundled third-party dependencies this recipe has not
##   audited, and AGENTS.md § Cache policy says a vendor-binary payload is
##   never republished into a shared cache, whatever the upstream licence.
##
## ## What the archives are
##
## Each ``kimi-code-<target>.tar.gz`` holds exactly ONE file at the archive
## root and no wrapper directory -- ``kimi`` (``kimi.exe`` on Windows), a
## 150-190 MB standalone executable -- so ``stripComponents`` stays 0 and
## ``executablePath`` is the bare name. Listing each archive is what fixed
## that; the Windows archives are ``.tar.gz`` too, not zip. Upstream also
## publishes ``.zip`` and ``.zst`` forms of each target; the ``.tar.gz`` is
## pinned because the ``tarball`` record unpacks it natively and upstream
## publishes a checksum for it.
##
## ## Platforms and digests
##
## Six explicit slices, every one distinct. Each sha256 is the value upstream
## itself publishes in the ``kimi-code-<target>.tar.gz.sha256`` release asset
## for that exact archive, and was then compared with the sha256 of the
## archive downloaded here: all six matched. (``manifest.json`` in the release
## carries checksums of the UNCOMPRESSED binaries and of the ``.zst`` files,
## not of the ``.tar.gz``, so it is not the source of these.)
## Run check: the linux-x86_64 binary was started and printed ``2.6.3`` for
## ``kimi --version`` (on NixOS, through an explicit glibc loader, since the
## binary is dynamically linked). The other five slices were checksummed and
## listed but not executed.
##
## ## Credentials, endpoints, config paths
##
## The program needs a model credential, and it is NOT read from the ambient
## environment by default: upstream documents that ``KIMI_API_KEY`` /
## ``ANTHROPIC_API_KEY`` / ``OPENAI_API_KEY`` exported in the shell are not
## picked up. Credentials live in ``$KIMI_CODE_HOME/config.toml``
## (``[providers.<name>]`` or its ``.env`` sub-table; default home
## ``~/.kimi-code``) or in an explicit ``api_key_env`` field naming a shell
## variable, or in OAuth files under ``$KIMI_CODE_HOME/credentials/`` after
## ``kimi`` login. Run-time endpoints seen in upstream's source at this tag:
## ``https://api.kimi.com/coding/v1`` (and ``api.moonshot.ai/v1`` for API-key
## providers; ``.cn``/``.ai`` regional variants exist), sign-in at
## ``https://auth.kimi.com``, telemetry at ``https://telemetry-logs.kimi.com/v1/event``,
## and the update/CDN origin ``https://code.kimi.com/kimi-code`` (``code.kimi.ai``
## for the ``.ai`` region). I did not capture traffic; this list is read from
## source and docs, not observed.
##
## ## Self-update, and what this recipe cannot do about it
##
## Left alone the program checks the CDN for a newer release and, by default
## (``tui.toml`` ``[upgrade].auto_install``, on by default), installs it in the
## background over itself -- the thing a content-addressed store must not
## have happen. Upstream's off switch is the environment variable
## ``KIMI_CODE_NO_AUTO_UPDATE=1`` (legacy alias ``KIMI_CLI_NO_AUTO_UPDATE``),
## which "fully disables the update preflight: no check, background install,
## or prompt"; ``KIMI_DISABLE_TELEMETRY=1`` turns telemetry off.
## Each slice therefore declares ``env = "KIMI_CODE_NO_AUTO_UPDATE=1"``, which the
## ``tarball`` record turns into a binding written by ``repro home apply`` as a persistent user environment variable (a managed block in the shell rc file on POSIX, the user registry on Windows). LIMIT: a variable, not a wrapper, and only home apply
## writes it, so a ``kimi`` started by something that does not read that rc file
## (a GUI launcher, cron) or from a ``uses:`` dev environment still checks for
## updates; ``auto_install = false`` in ``tui.toml`` is the other off switch. The
## realized prefix is a sealed store path, so an in-place self-update would fail
## to write rather than succeed silently. Telemetry (``KIMI_DISABLE_TELEMETRY=1``)
## is a privacy choice, not store integrity, and is left to the consumer.

import repro_project_dsl

const
  KimiCodeVersion = "2.6.3"
  # The release tag contains ``@`` and ``/``, which a download URL needs
  # percent-encoded: ``@moonshot-ai/kimi-code@<version>``.
  KimiCodeBase = "https://github.com/MoonshotAI/kimi-code/releases/download/" &
    "%40moonshot-ai%2Fkimi-code%40" & KimiCodeVersion & "/kimi-code-"

provisioningFor "kimi-code":
  interfaceFingerprint "c66b431bb33f784d7da158a54d59121ff5a3042c68992806d0c21f5abf36f1cc"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = KimiCodeBase & "linux-x64.tar.gz",
    sha256 = "a138b9854236c2b97f8bd6f28f93dd756f720383177e5cf0f95810b2872bab43",
    archiveType = "tar.gz",
    nonRedistributable = true,
    executablePath = "kimi",
    env = "KIMI_CODE_NO_AUTO_UPDATE=1",
    packageId = "kimi-code@" & KimiCodeVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:kimi-code@" & KimiCodeVersion &
      ":linux-x86_64:sha256:a138b9854236c2b97f8bd6f28f93dd756f720383177e5cf0f95810b2872bab43"

  tarball url = KimiCodeBase & "linux-arm64.tar.gz",
    sha256 = "f3da3f2268683260fe39ceaf37aacd973e56b7e42f41858ff113ed06789f493a",
    archiveType = "tar.gz",
    nonRedistributable = true,
    executablePath = "kimi",
    env = "KIMI_CODE_NO_AUTO_UPDATE=1",
    packageId = "kimi-code@" & KimiCodeVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:kimi-code@" & KimiCodeVersion &
      ":linux-aarch64:sha256:f3da3f2268683260fe39ceaf37aacd973e56b7e42f41858ff113ed06789f493a"

  tarball url = KimiCodeBase & "darwin-arm64.tar.gz",
    sha256 = "2f65c94f666b02641a20d305d84a3f5513938bf21d4884c82f9e479ffebccc00",
    archiveType = "tar.gz",
    nonRedistributable = true,
    executablePath = "kimi",
    env = "KIMI_CODE_NO_AUTO_UPDATE=1",
    packageId = "kimi-code@" & KimiCodeVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:kimi-code@" & KimiCodeVersion &
      ":macos-aarch64:sha256:2f65c94f666b02641a20d305d84a3f5513938bf21d4884c82f9e479ffebccc00"

  tarball url = KimiCodeBase & "darwin-x64.tar.gz",
    sha256 = "b8ba43a0bd3e6eded9ef8bfd8f7088f509d076b1da45a75eaa6997c0f1683471",
    archiveType = "tar.gz",
    nonRedistributable = true,
    executablePath = "kimi",
    env = "KIMI_CODE_NO_AUTO_UPDATE=1",
    packageId = "kimi-code@" & KimiCodeVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:kimi-code@" & KimiCodeVersion &
      ":macos-x86_64:sha256:b8ba43a0bd3e6eded9ef8bfd8f7088f509d076b1da45a75eaa6997c0f1683471"

  tarball url = KimiCodeBase & "win32-x64.tar.gz",
    sha256 = "10572ae83bdff33316e9f8ab6fd2a73a9e72b713a5b75764d19c361170879018",
    archiveType = "tar.gz",
    nonRedistributable = true,
    executablePath = "kimi.exe",
    env = "KIMI_CODE_NO_AUTO_UPDATE=1",
    packageId = "kimi-code@" & KimiCodeVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:kimi-code@" & KimiCodeVersion &
      ":windows-x86_64:sha256:10572ae83bdff33316e9f8ab6fd2a73a9e72b713a5b75764d19c361170879018"

  tarball url = KimiCodeBase & "win32-arm64.tar.gz",
    sha256 = "f32426d24320a91a9a649dfbe4829fae52b24b7349ed75285214b39f7884c99a",
    archiveType = "tar.gz",
    nonRedistributable = true,
    executablePath = "kimi.exe",
    env = "KIMI_CODE_NO_AUTO_UPDATE=1",
    packageId = "kimi-code@" & KimiCodeVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:kimi-code@" & KimiCodeVersion &
      ":windows-aarch64:sha256:f32426d24320a91a9a649dfbe4829fae52b24b7349ed75285214b39f7884c99a"
