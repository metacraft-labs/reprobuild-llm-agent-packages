## ``zcode`` — Z.ai's ZCode agentic development environment.
##
## Interface only. **Provenance class: vendor-binary.** ZCode is an
## Electron DESKTOP application, not a terminal CLI: it ships as an unpacked
## Electron tree (Linux) or a signed ``ZCode.app`` bundle (macOS) with a
## closed-source ``app.asar``. Z.ai publishes no source for it, and its
## terms (https://zcode.z.ai/en/terms) prohibit reverse engineering. A
## from-source realization is not available, and the realization under
## ``packages/vendor/zcode/`` is the only shape there is.
##
## The member is the launcher ``zcode`` that upstream's Linux package puts at
## ``opt/ZCode/zcode`` (and the desktop entry execs as ``zcode``). It is a
## GUI program: it needs a display session and starts the app, it does not
## run headless.

import repro_project_dsl

package zcode:
  executable zcode:
    discard
