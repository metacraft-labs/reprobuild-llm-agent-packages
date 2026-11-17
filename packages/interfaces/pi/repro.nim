## ``pi`` — Earendil's terminal coding agent (npm ``@earendil-works/pi-coding-agent``).
##
## One executable, ``pi``: upstream's release archives ship ``pi`` (Unix) and
## ``pi.exe`` (Windows), and it is also the name npm's ``bin`` publishes.
##
## **Provenance class: source-available.** The source is public at
## https://github.com/earendil-works/pi under the MIT licence; the LICENSE
## file at tag ``v1.5.2`` reads "MIT License / Copyright (c) 2025 Mario
## Zechner". By this catalog's rules the PRIMARY realization should be a
## from-source build under ``packages/source/pi/``. None exists yet: the
## project is an npm workspace whose standalone binary is produced by
## ``bun build --compile`` over the compiled workspace packages, and nothing
## in this catalog's record kinds expresses that build (a bun toolchain, the
## workspace-wide ``npm ci`` closure, then the compile step). The
## pinned-binary realization under ``packages/vendor/pi/`` is the only one
## that exists and must not be presented as equivalent provenance.
##
## The member list is ``pi`` alone. ``fd`` and ``rg`` are used by the agent
## for file search and are looked up on PATH at run time; they are not
## shipped by upstream's archive and are not members of this interface.

import repro_project_dsl

package pi:
  executable pi:
    discard
