## ``minimax-code`` — MiniMax's terminal coding agent.
##
## Interface only, and no realization exists yet — see "Why there is no
## realization" below. The one member is ``mcode``, the name the npm package's
## ``bin`` publishes (``@minimax-ai/code`` -> ``cli.js``) and the name every
## consumer invokes; the project, the repository and the package are all
## called "minimax-code" or "code", never "mcode", so a consumer looking for
## the package name on PATH finds nothing.
##
## ``@minimax-ai/code`` also publishes a second ``bin``, ``mcode-tools``
## (``mcode-tools.js``). It is the agent's internal tool helper, spawned by
## ``mcode`` itself from ``internal-bin/``, not a program a user is expected
## to run, and a realization can name only one ``executableAlias`` per
## archive, so it is deliberately not a member. Declaring a member that no
## realization can provide would make the interface unsatisfiable (the
## mistake the goose interface records).
##
## **Provenance class: source-available, with a caveat about the pinned
## artifact.** https://github.com/MiniMax-AI/minimax-code is public under the
## MIT licence (root LICENSE: "MIT License / Copyright (c) 2026 MiniMax Code";
## LICENSE-STATUS.md records that third_party/sandbox-runtime stays
## Apache-2.0 and that Pi-derived terminal code and bundled assets keep their
## own declarations, so the root licence is explicitly NOT a statement about
## every bundled file). But the repository's newest tag and ``package.json``
## are 0.7.2 while the npm package is already 0.7.7: the source of the
## published artifact is not published at that version, and the npm tarball is
## bundled, minified output (``cli.js`` plus ``chunks/``) with no LICENSE file
## in it, only ``"license": "MIT"`` in its ``package.json``.
##
## ## Why there is no realization
##
## The npm package is not runnable from an unpacked archive plus its
## dependency closure. It imports ``better-sqlite3`` unconditionally (its
## session store), and that package's native addon
## (``build/Release/better_sqlite3.node``) exists only after an install
## script has either downloaded a prebuild for the user's exact Node ABI or
## compiled it. ``tarball`` + ``closureManifest`` unpack pinned archives and
## run no lifecycle scripts, and the Node ABI is the user's, not the
## recipe's. Measured against ``@minimax-ai/code@0.7.7`` installed with
## ``--ignore-scripts``: ``mcode --version`` prints ``0.7.7``, ``mcode exec``
## fails with "Could not locate the bindings file" for better-sqlite3. A
## realization that resolves, unpacks and then fails on first use would be a
## false statement that the interface is satisfied, so none is written until
## reprobuild can supply a Node-ABI-matched native addon or upstream ships a
## self-contained build.

import repro_project_dsl

package `minimax-code`:
  executable mcode:
    discard
