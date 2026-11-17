## ``grok`` — xAI's Grok Build coding agent (the Grok CLI).
##
## Interface only. **Provenance class: vendor-binary.** xAI distributes the
## CLI as a bare native executable per (cpu, os) from a public storage
## bucket and publishes no source for it (the only public xai-org
## repository found that mentions it, ``grok-build-plugin-cc``, is a plugin
## FOR the tool, not the tool). A from-source realization is therefore not
## available, and the realization under ``packages/vendor/grok/`` is the
## only shape there is.
##
## Two members, both read from upstream's own installer
## (https://x.ai/cli/install.sh): it downloads ONE binary and links it to
## BOTH ``grok`` and ``agent`` in the install directory (``ln -sf`` on
## POSIX, a second ``agent.exe`` copy on Windows). ``agent`` is the same
## program invoked under another name (the binary documents an ``agent``
## entrypoint alongside ``headless``), and consumers such as editor
## integrations call it by that name, so it is an interface member rather
## than an implementation detail.

import repro_project_dsl

package grok:
  executable grok:
    discard
  executable agent:
    discard
