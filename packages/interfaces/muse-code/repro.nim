## ``muse-code`` — Meta's Muse Code terminal coding agent.
##
## Interface only. **Provenance class: vendor-binary.** Meta serves Muse
## Code as a bare native executable per (cpu, os) and publishes no source
## for it; its terms (https://dev.meta.ai/legal/terms-of-service, "Downloadable
## Materials") forbid redistributing or modifying the downloaded materials.
## A from-source realization is not available, and the realization under
## ``packages/vendor/muse-code/`` is the only shape there is.
##
## The executable is spelled ``muse``, not ``muse-code``: the package name is
## the product's name and the member is the program it installs (the name
## upstream's installer and launcher script give it).

import repro_project_dsl

package `muse-code`:
  executable muse:
    discard
