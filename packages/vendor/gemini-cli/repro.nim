## Vendor-tarball realization of the ``gemini-cli`` interface.
##
## **This is the npm registry tarball, not a from-source build.** Gemini CLI
## is Apache-2.0 TypeScript, so a from-source realization belongs under
## ``packages/source/gemini-cli/`` and this entry sits alongside it rather
## than standing in for it. What makes the registry tarball worth pinning on
## its own is that it is ALREADY a build output: upstream publishes a
## self-contained esbuild bundle and the package declares ZERO dependencies,
## so there is no closure to resolve and nothing here is repacking somebody
## else's node_modules.
##
## ## Why this needed a reprobuild feature rather than just a digest
##
## A realized prefix reaches PATH as a DIRECTORY, so a command's name there
## is a file's own name. ``bundle/gemini.js`` is not a program: naming it as
## ``executablePath`` yields a prefix whose declared command cannot be
## executed by the OS on any host. npm's answer is to generate a launcher
## pair beside the bundle, and ``launcher = "node"`` asks realize to do the
## same — ``executableAlias`` supplies the name, so ``gemini`` and
## ``gemini.cmd`` are written into ``bundle/`` and that directory is what
## goes on PATH.
##
## ``node`` is therefore a REQUIREMENT of this package that the package
## cannot express: the launcher resolves its interpreter from PATH, so a
## recipe that uses ``gemini-cli`` must declare ``node`` as well. Resolving
## it from PATH rather than baking a store path in is deliberate — it keeps
## the prefix relocatable, and it lets the consuming activation decide which
## node runs.
##
## ## No platform constraint
##
## The bundle is JavaScript and the same bytes are correct everywhere, so
## the entry carries no ``cpu``/``os`` and matches every host. The
## interpreter is the per-platform part, and it is a different package.
##
## The digest was taken from the registry artifact on 2026-09-18 and the
## ``bin`` entry (``gemini`` -> ``bundle/gemini.js``) read out of the
## tarball's own ``package.json`` rather than assumed.

import repro_project_dsl

const
  GeminiCliVersion = "0.59.0"
  GeminiCliSha256 =
    "59dc2cdb098b3000d36e34a185fc873932df4fd9d00900e817f2b19cd349d98b"

provisioningFor "gemini-cli":
  interfaceFingerprint "8e462ed89c3159f13d4628088d92af27675787b1d097165340ecd0e2fd4b84ad"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = "https://registry.npmjs.org/@google/gemini-cli/-/gemini-cli-" &
      GeminiCliVersion & ".tgz",
    sha256 = GeminiCliSha256,
    archiveType = "tar.gz",
    # npm tarballs are rooted at `package/`, which is a wrapper rather than
    # part of the layout.
    stripComponents = 1,
    executablePath = "bundle/gemini.js",
    executableAlias = "gemini",
    launcher = "node",
    packageId = "gemini-cli@" & GeminiCliVersion,
    lockIdentity = "vendor-npm:gemini-cli@" & GeminiCliVersion &
      ":sha256:" & GeminiCliSha256
