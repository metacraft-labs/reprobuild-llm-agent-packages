## ``openclaw`` — the OpenClaw assistant gateway, with its web control UI.
##
## One executable, ``openclaw``: the npm ``bin`` (``openclaw`` ->
## ``openclaw.mjs``) and the name every consumer invokes. The gateway, the
## control UI and the ``nodes`` host are all subcommands of it.
##
## **Provenance class: source-available.** The source is published at
## https://github.com/openclaw/openclaw under the MIT licence. Verified at
## the version this interface was written against (v2026.11.5,
## 2026-11-17): the ``LICENSE`` in the published npm tarball is the MIT text,
## "Copyright (c) 2026 OpenClaw Foundation", and is byte-identical to
## https://github.com/openclaw/openclaw/blob/v2026.11.5/LICENSE;
## ``package.json`` declares ``"license": "MIT"``. Homepage:
## https://openclaw.ai.
##
## Per the catalog rule the primary realization of a source-available
## package is a from-source build under ``packages/source/``. That tier has
## no recipe form yet (it holds only gemini-cli's build-closure manifest),
## so the realization in ``packages/vendor/openclaw/`` is the npm registry
## tarball, which is upstream's own build output (a compiled ``dist/``), and
## it must not be presented as a from-source build.

import repro_project_dsl

package openclaw:
  executable openclaw:
    discard
