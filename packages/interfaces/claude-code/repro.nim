## ``claude-code`` — Anthropic's coding-agent CLI.
##
## Interface only. This module says WHAT the package exports and nothing
## about where a realization comes from; the realizations live under
## ``packages/vendor/`` (pinned vendor binaries) and ``packages/source/``
## (built from upstream source), and external catalogs may contribute more
## through ``provisioningFor`` without touching this file.
##
## **Provenance class: vendor-binary.** Anthropic distributes Claude Code as
## a bare native executable per (cpu, os) and publishes no buildable source
## for it. Per the catalog's provenance rules it therefore may carry only a
## ``vendor-binary`` realization, must never be described as built from
## source, and its payload is fetched on the user's behalf rather than
## republished into a shared cache.
##
## The executable is spelled ``claude``, not ``claude-code``: the package
## name is the project's name and the member is the program it installs.
## Consumers that shell out to the agent name the member.

import repro_project_dsl

package `claude-code`:
  executable claude:
    discard
