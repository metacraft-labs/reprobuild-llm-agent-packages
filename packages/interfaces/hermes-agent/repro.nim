## ``hermes-agent`` — Nous Research's Hermes Agent, a terminal AI agent.
##
## Interface only: there is NO realization of this package in this catalog,
## and the reason is a gap in the record kinds, not a missing recipe (below).
##
## **Provenance class: source-available.** The source is published at
## https://github.com/NousResearch/hermes-agent under the MIT licence.
## Verified at the version this interface was written against (the v0.23.2
## release, 2026-11-16): the repository's ``LICENSE`` is the MIT text
## ("Copyright (c) 2025 Nous Research",
## https://github.com/NousResearch/hermes-agent/blob/v0.23.2/LICENSE) and
## ``pyproject.toml`` at that tag declares ``license = "MIT"``. Homepage:
## https://hermes-agent.nousresearch.com/.
##
## The member is ``hermes``, the program the consuming workspace invokes
## (``[project.scripts] hermes = "hermes_cli.main:main"``). Upstream's wheel
## also installs ``hermes-agent`` (a legacy entry point) and ``hermes-acp``
## (an Agent Client Protocol adapter); neither is declared, because nothing
## consumes them yet and an interface member no realization can provide is
## an unsatisfiable contract. Add them here, and republish the fingerprint,
## when a consumer needs one.
##
## ## Why there is no realization
##
## What upstream distributes, checked 2026-11-17:
##
## * GitHub releases carry NO program archives. The only assets ever
##   attached are the Python sdist and wheel, or their sigstore bundles, and
##   none are attached to any release after v2026.7.20 (v0.23.2 has none).
## * PyPI (``hermes-agent``) is MIT and carries a wheel and an sdist, but it
##   is stale: its newest version is 0.19.0 (2026-07-20) while upstream is
##   at 0.23.2.
## * The program is Python (``requires-python >=3.11,<3.15``, with its
##   dependency pins gated to ``python_version >= '3.14'``). Its closure is
##   a ``uv.lock`` of exact-pinned PyPI packages, including native
##   extensions, with environment markers. Realizing it means resolving that
##   closure per (cpu, os) and installing wheels, which is a resolver
##   problem. The ``tarball`` record kind unpacks archives into a prefix;
##   its ``closureManifest`` is an npm-shaped list of ``.tgz`` archives
##   (see ``packages/vendor/amp/``). Neither can select, order or unpack a
##   wheel closure, and a source tarball of the repository would be a
##   program that cannot start. A recipe claiming otherwise would be faked.
## * The only prebuilt, self-contained form is the macOS desktop bundle,
##   which carries its own CPython and dependency tree. That is the
##   ``hermes-desktop`` package (macOS arm64 only); it is the desktop
##   application, not this package's CLI, and is not offered as a
##   realization of ``hermes``.
##
## Because the package is source-available, the catalog rule is that its
## primary realization be a from-source build under ``packages/source/``.
## That tier currently holds only a build-closure manifest for gemini-cli
## and no recipe, so there is nothing to put here either.
##
## ## Run-time facts for a future realization (never the secrets)
##
## * Credentials: provider API keys, as ``UPPER_SNAKE`` variables such as
##   ``OPENROUTER_API_KEY`` stored in ``~/.hermes/.env``; OAuth credentials
##   for the Nous Portal in ``~/.hermes/auth.json``; settings in
##   ``~/.hermes/config.yaml``. ``HERMES_HOME`` relocates the whole
##   directory.
## * Network: the configured model provider, the Nous Portal
##   (``portal.nousresearch.com``, ``inference-api.nousresearch.com``), the
##   Skills Hub on GitHub, and whatever tool gateways the user enables.
## * Self-update: ``hermes update`` updates in place. Upstream refuses it
##   for image-managed installs (docker, nix, apt, desktop app) and prints
##   the right command instead (``hermes_cli/update_contract.py``). A
##   realization must therefore be installed as a sealed tree upstream's
##   steward markers recognise, or the update command isolated; which of
##   the two upstream supports for a store prefix is NOT verified here.

import repro_project_dsl

package `hermes-agent`:
  executable hermes:
    discard
