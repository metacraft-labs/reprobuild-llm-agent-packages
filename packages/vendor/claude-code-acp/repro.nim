## Vendor-tarball realization of the ``claude-code-acp`` interface, with its
## dependency closure.
##
## The entry that needed a reprobuild feature more than the other npm ones.
## ``gemini-cli`` and ``qwen-code`` publish self-contained esbuild bundles
## with zero dependencies, so they needed only a way to be INVOKED
## (``launcher``). This package is 174 KB and does not run without its
## dependencies: five direct, 97 transitive.
##
## ## What the alternative would have been
##
## A build step that runs ``npm install`` into the prefix. That is a
## version-range resolution at build time and a network fetch inside a
## build — the two things this provisioning system exists to remove, and
## the reason the closure is a COMMITTED manifest of pinned archives
## instead. Every entry goes through the same verified download the root
## archive does: checksum-checked, shared with every other consumer of the
## same bytes through the store's download cache, and offline after the
## first time.
##
## ``closures/claude-code-acp.manifest`` is generated, not hand-written —
## the transitive closure npm recorded in Agent Harbor's
## ``scripts/agent-tools/package-lock.json``, with the sha256 of the
## archives those ``resolved`` URLs actually serve. npm pins by sha512
## ``integrity``; reprobuild verifies sha256, so each archive was fetched
## once and hashed. The file diffs like a lock file, which is what makes a
## dependency change reviewable.
##
## ## The launcher, and the name
##
## ``dist/index.js`` is a script, so the same ``launcher`` /
## ``executableAlias`` pair the other npm agents use applies: realize
## writes ``claude-code-acp`` and ``claude-code-acp.cmd`` beside it, under
## the name npm's own ``bin`` publishes and an editor's agent configuration
## spawns. ``node`` is therefore a requirement this package cannot express
## — the launcher resolves its interpreter from PATH, so a recipe using
## this package must declare node as well.
##
## ## A note for whoever bumps it
##
## Bumping the version means regenerating the manifest, not just changing
## the digest here: the closure moves with the dependency graph. The
## realizer keys its cache entry on the manifest's CONTENT, so a stale
## manifest beside a new root archive is a different prefix and will not
## collide with anyone else's.
##
## No ``cpu``/``os``: the adapter is JavaScript and the same bytes are
## correct on every host. The per-platform part is the interpreter.

import repro_project_dsl

const
  ClaudeCodeAcpVersion = "0.16.2"
  ClaudeCodeAcpSha256 =
    "4713b3bba04650850929e4db1e680073d03bf55dcdf8bfcb3bb1cbd82bcfa99e"

provisioningFor "claude-code-acp":
  interfaceFingerprint "7ca396bad2119735e7f2e906216c795b447c863ac1e43b0364e0c045cfea5496"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url =
      "https://registry.npmjs.org/@zed-industries/claude-code-acp/-/" &
      "claude-code-acp-" & ClaudeCodeAcpVersion & ".tgz",
    sha256 = ClaudeCodeAcpSha256,
    archiveType = "tar.gz",
    stripComponents = 1,
    executablePath = "dist/index.js",
    executableAlias = "claude-code-acp",
    launcher = "node",
    closureManifest = "closures/claude-code-acp.manifest",
    packageId = "claude-code-acp@" & ClaudeCodeAcpVersion,
    lockIdentity = "vendor-npm:claude-code-acp@" & ClaudeCodeAcpVersion &
      ":sha256:" & ClaudeCodeAcpSha256
