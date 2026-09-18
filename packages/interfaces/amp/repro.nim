## ``amp`` — Sourcegraph's Amp coding agent.
##
## One executable, ``amp``, which is the name npm's ``bin`` publishes and
## the name every consumer invokes.
##
## **Provenance class: vendor-binary**, and the reason is worth stating
## because the npm package looks source-available at a glance. What npm
## serves under ``@ampcode/cli`` is a 2.3 KB wrapper; the program is a
## per-platform NATIVE binary in a separate package the wrapper resolves at
## runtime. There is no published source for that binary, so a from-source
## realization is not merely unbuilt here — it is not available, and the
## realization under ``packages/vendor/amp/`` is the only shape there is.
##
## The interface waited on its realization rather than on anything about
## the agent: selecting one platform's binary out of npm's
## optional-dependency mechanism needs a dependency closure, which
## reprobuild grew as ``closureManifest``.

import repro_project_dsl

package amp:
  executable amp:
    discard
