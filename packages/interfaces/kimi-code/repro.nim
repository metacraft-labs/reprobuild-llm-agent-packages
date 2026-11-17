## ``kimi-code`` — Moonshot AI's Kimi Code terminal coding agent.
##
## One executable, ``kimi``: the name upstream's release archives ship
## (``kimi`` on Unix, ``kimi.exe`` on Windows) and the name every consumer
## invokes, even though the project and the npm scope are called
## ``kimi-code``. That mismatch between package name and program name is why
## this note exists — a consumer looking for ``kimi-code`` on PATH finds
## nothing.
##
## **Provenance class: source-available.** The source is public at
## https://github.com/MoonshotAI/kimi-code under the MIT licence; the LICENSE
## file at tag ``@moonshot-ai/kimi-code@2.6.3`` reads "MIT License /
## Copyright (c) 2026 Moonshot AI". By this catalog's rules the PRIMARY
## realization should therefore be a from-source build under
## ``packages/source/kimi-code/``. None exists yet: the project is a pnpm
## workspace whose build produces a standalone binary, and nothing in this
## catalog's record kinds expresses a pnpm install plus build (the only
## ``packages/source/`` entry, for gemini-cli, is a closure manifest with no
## recipe). The pinned-binary realization under ``packages/vendor/kimi-code/``
## is the only one that exists and must not be presented as equivalent
## provenance.
##
## This is the CLI only. The helpers ``fd`` and ``rg`` that the agent uses for
## file search are looked up on PATH at run time and are not members of this
## interface.

import repro_project_dsl

package `kimi-code`:
  executable kimi:
    discard
