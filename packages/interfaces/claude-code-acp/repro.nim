## ``claude-code-acp`` — the ACP adapter that fronts Claude Code.
##
## The second entry in the ACP-adapter category, after ``codex-acp``, and
## the same shape for the same reason: an adapter speaks the Agent Client
## Protocol to an editor on one side and drives a coding agent on the
## other, so a consumer composes it WITH an agent rather than instead of
## one. Its interface declares one executable, because the protocol members
## the category will eventually carry (negotiated ACP version, transport,
## capabilities) are not modelled yet and declaring them before they can be
## verified would put unsatisfiable members in a contract.
##
## The member name is the one npm's ``bin`` publishes, ``claude-code-acp``,
## which is also what an editor's agent configuration spawns.
##
## This interface waited on its REALIZATION rather than on anything about
## the category. Upstream ships no release binary — npm only — and the
## published package is not self-contained: 174 KB with five runtime
## dependencies. It became declarable when reprobuild grew
## ``closureManifest``; see ``packages/vendor/claude-code-acp/``.

import repro_project_dsl

package `claude-code-acp`:
  executable `claude-code-acp`:
    discard
