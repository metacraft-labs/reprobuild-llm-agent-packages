## ``goose`` — Block's Goose agent.
##
## Interface only. **Provenance class: source-available** (Apache-2.0 Rust
## upstream). Goose ships two programs and both are part of the contract: the
## CLI a consumer drives, and the desktop/daemon-side ``goosed`` the CLI
## talks to. A realization that provides only one does not satisfy this
## interface.

import repro_project_dsl

package goose:
  executable goose:
    discard

  executable goosed:
    discard
