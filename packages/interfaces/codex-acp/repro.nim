## ``codex-acp`` — the ACP adapter that fronts Codex.
##
## The first entry in this catalog from the ACP-adapter category rather than
## the coding-agent-CLI one. The distinction is real: an adapter speaks the
## Agent Client Protocol to an editor on one side and drives a coding agent
## on the other, so a consumer composes it WITH an agent rather than instead
## of one. Its interface is deliberately the same shape as a CLI's for now —
## one executable — because the protocol members the category will eventually
## declare (negotiated ACP version, transport, capabilities) are not modelled
## yet, and declaring them before they can be verified would put
## unsatisfiable members in a contract.
##
## **Provenance class: source-available** (Rust, on GitHub); the realization
## below is a pinned binary, which is a statement about that realization and
## not about the project.

import repro_project_dsl

package `codex-acp`:
  executable `codex-acp`:
    discard
