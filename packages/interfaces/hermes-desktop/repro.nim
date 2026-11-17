## ``hermes-desktop`` — the official Electron desktop shell for Nous
## Research's Hermes Agent.
##
## One executable, ``hermes-desktop``: the name the consuming workspace
## invokes. Upstream's macOS bundle is ``Hermes Agent.app`` whose
## ``CFBundleExecutable`` is ``Hermes Agent``, so the name is the package's,
## not the file's; a realization's package launcher supplies it (an
## ``app-bundle`` record's launcher is named after the package and runs
## ``executablePath``, Store-And-Installation-Layout.md § macOS Application
## Bundles, "Command line").
##
## **Provenance class: source-available.** The application's source is
## ``apps/desktop`` in https://github.com/NousResearch/hermes-agent under the
## MIT licence, verified at v0.22.0 (the version the stable channel serves):
## https://github.com/NousResearch/hermes-agent/blob/v0.22.0/LICENSE is the
## MIT text, "Copyright (c) 2025 Nous Research". The artifact upstream
## ships, though, is a signed, notarized binary bundle that upstream's CI
## assembles from that source plus a pinned CPython, uv, Node and a prebuilt
## Python dependency tree (``apps/desktop/BUILDING.md``, "Payload
## contents"). A from-source realization would have to reproduce that
## bundle build (npm workspace, electron-builder, a Python dependency
## closure, Developer ID signing and notarization), none of which the record
## kinds express, so ``packages/source/`` has no entry. The realization in
## ``packages/vendor/hermes-desktop/`` repacks upstream's binary and must
## not be presented as equivalent provenance.
##
## What upstream publishes per platform (2026-11-17):
##
## * macOS arm64: ``Hermes Agent.app`` in a ZIP and a DMG on
##   ``hermes-assets.nousresearch.com``. Realized.
## * macOS x86_64: none. "The current workflow builds the bundled variant on
##   ARM64 runners only" (``website/docs/developer-guide/macos-bundle-updates.md``).
## * Windows x64 / arm64: a 4.3 GB signed ``.msixbundle`` and a
##   ``.appinstaller``. The ``tarball`` record kind has no MSIX install
##   method (its archive types are tar.gz, zip, dmg, pkg, ... and its
##   Windows installer methods are msi, nsis and inno-setup), so it cannot
##   be expressed.
## * Linux: none. "Linux desktop release legs are disabled"
##   (``apps/desktop/BUILDING.md``); a local build can produce an AppImage,
##   but upstream publishes none.

import repro_project_dsl

package `hermes-desktop`:
  executable `hermes-desktop`:
    discard
