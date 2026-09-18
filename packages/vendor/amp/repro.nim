## Vendor realization of the ``amp`` interface — a wrapper plus exactly one
## platform's native binary.
##
## ## What upstream actually publishes
##
## ``@ampcode/cli`` is a 2.3 KB package containing ``cli-wrapper.cjs``, a
## ``package.json``, and a 141-byte ``bin/amp.exe`` which is NOT a program:
## it is a shell stub that prints "Amp native binary not installed" and
## exits 1. The real binary lives in one of five sibling packages —
## ``@ampcode/cli-{darwin-arm64,darwin-x64,linux-arm64,linux-x64,win32-x64}``
## — which npm installs through OPTIONAL dependencies, keeping only the one
## whose ``os``/``cpu`` constraints match the host.
##
## ``cli-wrapper.cjs`` then resolves that package at RUN time with
## ``require.resolve('@ampcode/cli-<platform>/package.json')`` and spawns
## the binary beside it. So the entry point is the wrapper script, not the
## stub, and the closure is what makes the wrapper's resolution succeed.
##
## ## How that maps onto a package
##
## npm's optional-dependency selection and reprobuild's per-platform
## provisioning slices are the same idea, so the mapping is direct: one
## ``tarball`` entry per platform, each naming the SAME wrapper archive and
## a closure manifest carrying exactly that platform's binary package.
## ``cli-wrapper.cjs`` finds it under ``node_modules/`` in the realized
## prefix, which is where node's own resolution looks.
##
##   win32-x64     -> windows / x86_64
##   darwin-arm64  -> macos   / aarch64
##   darwin-x64    -> macos   / x86_64
##   linux-x64     -> linux   / x86_64
##   linux-arm64   -> linux   / aarch64
##
## The manifests are generated — ``just closure-manifest ... platform=<npm
## os>-<npm cpu>`` — so the platform filter is applied by the same rule npm
## applies, rather than by a human deciding which package belongs to which
## slice.
##
## ## The declared executable, and why it is the script
##
## ``executablePath`` is ``cli-wrapper.cjs`` with ``launcher = "node"`` and
## ``executableAlias = "amp"``, so realize writes ``amp`` and ``amp.cmd``
## beside the wrapper. Declaring ``bin/amp.exe`` instead would name the
## 141-byte stub, and the realized command would be a program whose whole
## behaviour is to tell the user to reinstall.
##
## ``node`` is therefore a requirement this package cannot express: the
## launcher resolves its interpreter from PATH, so a recipe using ``amp``
## must declare node as well.
##
## ## Non-redistributable
##
## The native binary is a closed-source vendor artifact. Fetching one on a
## developer's behalf is ordinary; re-serving it from a shared cache other
## people pull from is a different act, so every slice refuses publication —
## the same rule this catalog applies to every vendor-binary payload.

import repro_project_dsl

const
  AmpVersion = "0.0.1782120930-g64087b"
  AmpWrapperSha256 =
    "b5f10bbe6a56e4d5828042310181d0c095d5e9d677898786ff3683b8fd66717b"
  AmpWrapperUrl =
    "https://registry.npmjs.org/@ampcode/cli/-/cli-" & AmpVersion & ".tgz"

provisioningFor "amp":
  interfaceFingerprint "3e39e906554c2d829e320950837132bc0768fafb30c7e186517ce68890ff384f"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = AmpWrapperUrl,
    sha256 = AmpWrapperSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "cli-wrapper.cjs",
    executableAlias = "amp",
    launcher = "node",
    closureManifest = "closures/amp-win32-x64.manifest",
    nonRedistributable = true,
    packageId = "amp@" & AmpVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-npm:amp@" & AmpVersion &
      ":windows-x86_64:sha256:" & AmpWrapperSha256

  tarball url = AmpWrapperUrl,
    sha256 = AmpWrapperSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "cli-wrapper.cjs",
    executableAlias = "amp",
    launcher = "node",
    closureManifest = "closures/amp-darwin-arm64.manifest",
    nonRedistributable = true,
    packageId = "amp@" & AmpVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-npm:amp@" & AmpVersion &
      ":macos-aarch64:sha256:" & AmpWrapperSha256

  tarball url = AmpWrapperUrl,
    sha256 = AmpWrapperSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "cli-wrapper.cjs",
    executableAlias = "amp",
    launcher = "node",
    closureManifest = "closures/amp-darwin-x64.manifest",
    nonRedistributable = true,
    packageId = "amp@" & AmpVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-npm:amp@" & AmpVersion &
      ":macos-x86_64:sha256:" & AmpWrapperSha256

  tarball url = AmpWrapperUrl,
    sha256 = AmpWrapperSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "cli-wrapper.cjs",
    executableAlias = "amp",
    launcher = "node",
    closureManifest = "closures/amp-linux-x64.manifest",
    nonRedistributable = true,
    packageId = "amp@" & AmpVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-npm:amp@" & AmpVersion &
      ":linux-x86_64:sha256:" & AmpWrapperSha256

  tarball url = AmpWrapperUrl,
    sha256 = AmpWrapperSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "cli-wrapper.cjs",
    executableAlias = "amp",
    launcher = "node",
    closureManifest = "closures/amp-linux-arm64.manifest",
    nonRedistributable = true,
    packageId = "amp@" & AmpVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-npm:amp@" & AmpVersion &
      ":linux-aarch64:sha256:" & AmpWrapperSha256
