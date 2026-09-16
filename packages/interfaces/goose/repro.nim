## ``goose`` — Block's Goose agent.
##
## Interface only. **Provenance class: source-available** (Apache-2.0 Rust
## upstream).
##
## The interface declares ``goose`` ALONE, corrected from an earlier draft
## that also declared ``goosed``. That draft was written from the project's
## architecture rather than from its artifacts: ``goosed`` is real, but it
## ships in the Goose Desktop application, not in the CLI release archive —
## upstream's ``goose-<triple>.zip`` contains exactly one program. An
## interface naming a member no realization can provide is not a strict
## contract, it is an unsatisfiable one, and every realization would have
## failed conformance for a member the upstream never shipped here.

import repro_project_dsl

package goose:
  executable goose:
    discard
