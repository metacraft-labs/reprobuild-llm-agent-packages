## ``codex`` — OpenAI's Codex CLI coding agent.
##
## Interface only; see ``claude-code/repro.nim`` for why realizations live
## elsewhere.
##
## **Provenance class: source-available.** Upstream publishes a Rust
## workspace under an OSI licence, so this package's primary realization is
## a from-source build under ``packages/source/codex/``. A vendor-binary
## realization of the same interface is permitted as a convenience but must
## not be the only one, and must not be presented as equivalent provenance.

import repro_project_dsl

package codex:
  executable codex:
    discard
