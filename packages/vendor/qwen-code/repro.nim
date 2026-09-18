## Vendor-tarball realization of the ``qwen-code`` interface.
##
## The sibling of ``packages/vendor/gemini-cli/``, and for the same reasons:
## the npm registry tarball is already a self-contained build output, the
## package declares ZERO dependencies, and the published entry point is a
## SCRIPT rather than a program. See that module for why ``launcher``
## exists and why ``node`` is a requirement this package cannot express.
##
## Two differences worth naming.
##
## **The entry point sits at the package root**, not under a ``bundle/``
## directory — ``bin`` is ``qwen`` -> ``cli-entry.js`` — so the launcher
## pair is written at the prefix root and the prefix root is what goes on
## PATH.
##
## **The tarball vendors ripgrep for four platforms** under
## ``vendor/ripgrep/{arm64,x64}-{darwin,linux}/``. That is upstream's own
## layout and it is left alone: the entry carries no ``cpu``/``os``
## because the JavaScript is platform-independent, and pruning the
## unused ripgrep builds would make the realized prefix differ from the
## published artifact for a saving that is not the reason this package
## exists. A later version that ships a Windows ripgrep would not change
## any of that.
##
## The digest was taken from the registry artifact on 2026-09-18 and the
## ``bin`` entry read out of the tarball's own ``package.json``.

import repro_project_dsl

const
  QwenCodeVersion = "0.23.4"
  QwenCodeSha256 =
    "d590c8e27fdd112cac4b0ce5ee98febdb91cf660c01db86ae431870f8ee41a9d"

provisioningFor "qwen-code":
  interfaceFingerprint "05178cec761286d9df7e0ac74aad6a90fcf9fc24dbc68b9b6055266b2720a7be"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url =
      "https://registry.npmjs.org/@qwen-code/qwen-code/-/qwen-code-" &
      QwenCodeVersion & ".tgz",
    sha256 = QwenCodeSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "cli-entry.js",
    executableAlias = "qwen",
    launcher = "node",
    packageId = "qwen-code@" & QwenCodeVersion,
    lockIdentity = "vendor-npm:qwen-code@" & QwenCodeVersion &
      ":sha256:" & QwenCodeSha256
