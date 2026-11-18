## Vendor-binary realization of the ``grok`` interface (xAI Grok Build CLI).
##
## ## Provenance and licence
##
## **Provenance class: vendor-binary.** xAI publishes the CLI only as
## prebuilt native executables and no source for it, so this is the only
## realization shape and it must never be described as built from source.
## There is no LICENSE file for the artifact: it is governed by xAI's terms
## of service, https://x.ai/legal/terms-of-service (the URL the binary and
## its installer refer to). Measured 2026-11-17: that page returns a
## Cloudflare 403 to a non-browser client, so its text was NOT read here and
## no licence clause is quoted; "proprietary, terms-governed, no source" is
## inferred from the absence of any published source or open licence, not from
## reading the terms. A reviewer with a browser should read them before this
## pin is relied on.
##
## Homepage: https://x.ai/cli (docs https://docs.x.ai/build/overview).
## Source location: none published.
##
## ## Version and channel
##
## Release channel ``stable``. The channel pointer is the one-line text file
## https://storage.googleapis.com/grok-build-public-artifacts/cli/stable,
## which read ``1.0.88`` on 2026-11-17 (the installer also knows ``alpha``
## and ``enterprise``). Artifacts are version-addressed:
## ``cli/grok-<version>-<os>-<cpu>[.exe]``.
##
## ## What upstream ships, and the declared executable
##
## Each URL is ONE bare executable, not an archive, so ``archiveType =
## "raw"``: realize copies the download into the prefix under the name
## ``executablePath`` gives (there is no stripComponents to speak of). I
## confirmed the magic bytes per slice: ELF (linux), Mach-O 64-bit
## ``cffaedfe`` (macos), ``MZ`` (windows). Upstream's installer links the same
## binary as BOTH ``grok`` and ``agent``; ``executableAlias`` places a second
## copy under ``agent`` (``agent.exe`` on Windows), which is what the
## interface's second member needs.
##
## Slices: linux/macos/windows x x86_64/aarch64 — all six upstream
## publishes. No musl build exists (404 measured), so there is no libc axis
## to omit.
##
## ## Digests
##
## Upstream publishes NO checksum for these artifacts (``<url>.sha256``,
## ``manifest.json`` and a per-version manifest all 404, 2026-11-17), so every
## digest below is SELF-COMPUTED: each artifact was downloaded and run through
## ``sha256sum``. Cross-check available for another version only: the
## numtide/llm-agents.nix hashes for 1.0.77 (a lead, not authority) decode to
## the same sha256 I computed for the 1.0.77 linux-x86_64 artifact
## (b702950a...), which shows the bucket serves immutable bytes per version.
## Bumping the version means re-downloading and recomputing; do not carry a
## digest forward.
##
## ## Credentials, endpoints
##
## Needs an xAI account or key: ``XAI_API_KEY`` in the environment, or
## ``grok login`` which writes ``~/.grok/auth.json`` (OIDC against
## https://auth.x.ai / https://accounts.x.ai); ``GROK_DEPLOYMENT_KEY``
## (enterprise) and ``GROK_AUTH_PROVIDER_COMMAND`` also feed auth; config
## lives under ``~/.grok`` (``GROK_HOME``). Endpoints seen in the binary's
## strings: https://api.x.ai/v1, https://auth.x.ai, https://accounts.x.ai,
## https://console.x.ai, https://docs.x.ai, the update bucket
## storage.googleapis.com/grok-build-public-artifacts, and x.ai install
## scripts. Telemetry is controlled by ``GROK_TELEMETRY_ENABLED`` (default not
## verified).
##
## ## Self-update
##
## The CLI updates itself in place. Upstream documents ``--no-auto-update``
## and the binary contains the literal ``GROK_DISABLE_AUTOUPDATER`` (string
## inspection only; I did not run it). Each slice below sets
## ``env = "GROK_DISABLE_AUTOUPDATER=1"``, which the tarball record exports as
## a binding written by ``repro home apply`` as a persistent user environment variable (a managed block in the shell rc file on POSIX, the user registry on Windows). LIMITS the
## record kinds impose: that is a variable, not a wrapper, and only home apply
## writes it, so a ``grok`` started by something that does not read that rc
## file (a GUI launcher, cron) or from a ``uses:`` dev environment is not
## covered; and there is no field to inject ``--no-auto-update`` into
## argv. Whether the variable alone suppresses every update path is
## unverified (I did not execute the binary).
##
## ## Cache policy
##
## Every slice carries ``nonRedistributable = true``: the bytes are fetched on
## the user's behalf and must not be republished into a shared binary cache.

import repro_project_dsl

const
  GrokVersion = "1.0.88"
  GrokBase =
    "https://storage.googleapis.com/grok-build-public-artifacts/cli/"

provisioningFor "grok":
  interfaceFingerprint "1f43056f5e553e6a7939af23b9cc8cb89ab6bcf4e33e108a1ab1a0778157c0fd"
  contributor "github:metacraft-labs/reprobuild-llm-agent-packages"

  tarball url = GrokBase & "grok-" & GrokVersion & "-linux-x86_64",
    sha256 = "a33013fe73ea63d2f18df636f90f84060a88712f9932b77cda0447dd83b4bfe5",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "grok",
    executableAlias = "agent",
    env = "GROK_DISABLE_AUTOUPDATER=1",
    packageId = "grok@" & GrokVersion,
    cpu = "x86_64",
    os = "linux",
    lockIdentity = "vendor-binary:grok@" & GrokVersion &
      ":linux-x86_64:sha256:a33013fe73ea63d2f18df636f90f84060a88712f9932b77cda0447dd83b4bfe5"

  tarball url = GrokBase & "grok-" & GrokVersion & "-linux-aarch64",
    sha256 = "55f285af4b68fe53cc2f45b00a4392c8c4871509671e0185e0237804194ccf29",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "grok",
    executableAlias = "agent",
    env = "GROK_DISABLE_AUTOUPDATER=1",
    packageId = "grok@" & GrokVersion,
    cpu = "aarch64",
    os = "linux",
    lockIdentity = "vendor-binary:grok@" & GrokVersion &
      ":linux-aarch64:sha256:55f285af4b68fe53cc2f45b00a4392c8c4871509671e0185e0237804194ccf29"

  tarball url = GrokBase & "grok-" & GrokVersion & "-macos-x86_64",
    sha256 = "4ec4d61a50d1aff49139bc0c84878d0b37e9b62949eb45c561fd57ed52305739",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "grok",
    executableAlias = "agent",
    env = "GROK_DISABLE_AUTOUPDATER=1",
    packageId = "grok@" & GrokVersion,
    cpu = "x86_64",
    os = "macos",
    lockIdentity = "vendor-binary:grok@" & GrokVersion &
      ":macos-x86_64:sha256:4ec4d61a50d1aff49139bc0c84878d0b37e9b62949eb45c561fd57ed52305739"

  tarball url = GrokBase & "grok-" & GrokVersion & "-macos-aarch64",
    sha256 = "b0185133b3362c406069653e40c9864876342fd6d667555e0438f7f26a1f785e",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "grok",
    executableAlias = "agent",
    env = "GROK_DISABLE_AUTOUPDATER=1",
    packageId = "grok@" & GrokVersion,
    cpu = "aarch64",
    os = "macos",
    lockIdentity = "vendor-binary:grok@" & GrokVersion &
      ":macos-aarch64:sha256:b0185133b3362c406069653e40c9864876342fd6d667555e0438f7f26a1f785e"

  tarball url = GrokBase & "grok-" & GrokVersion & "-windows-x86_64.exe",
    sha256 = "1bbfc010cc38f9578157673381b4f6efb7664c48b9c8031a833b49d078d2b560",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "grok.exe",
    executableAlias = "agent.exe",
    env = "GROK_DISABLE_AUTOUPDATER=1",
    packageId = "grok@" & GrokVersion,
    cpu = "x86_64",
    os = "windows",
    lockIdentity = "vendor-binary:grok@" & GrokVersion &
      ":windows-x86_64:sha256:1bbfc010cc38f9578157673381b4f6efb7664c48b9c8031a833b49d078d2b560"

  tarball url = GrokBase & "grok-" & GrokVersion & "-windows-aarch64.exe",
    sha256 = "73fb2c790db7ef6749e82d7b2553ddd1ae3fb7d5ba9c710151c7e7355f69eb89",
    archiveType = "raw",
    nonRedistributable = true,
    executablePath = "grok.exe",
    executableAlias = "agent.exe",
    env = "GROK_DISABLE_AUTOUPDATER=1",
    packageId = "grok@" & GrokVersion,
    cpu = "aarch64",
    os = "windows",
    lockIdentity = "vendor-binary:grok@" & GrokVersion &
      ":windows-aarch64:sha256:73fb2c790db7ef6749e82d7b2553ddd1ae3fb7d5ba9c710151c7e7355f69eb89"

# Every provider module of a catalog is extracted on its own by
# `repro catalog publish` and lifted into the artifact of ONE package, named
# by this block; the realizations above are the contributions it carries.
package grokRealizations:
  discard
