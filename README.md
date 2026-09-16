# reprobuild-llm-agent-packages

Reprobuild package interfaces for LLM coding agents, and the realizations
that satisfy them.

This is a federated catalog in the sense of
[`Provisioning-Contributions.md`](https://github.com/metacraft-labs/reprobuild-specs/blob/latest/Provisioning-Contributions.md):
it owns a set of package *interfaces*, and separately owns *realizations* of
them. Other repositories may publish further realizations of the same
interfaces without modifying anything here, provided they pin the interface
fingerprint they were checked against.

## Layout

```
packages/interfaces/<name>/repro.nim   the public interface — what the package exports
packages/source/<name>/repro.nim       built from upstream source
packages/vendor/<name>/repro.nim       pinned vendor binaries, for agents that publish no source
inventory/upstream.toml                machine-readable upstream inventory and coverage
tools/                                 the published interface fingerprints
tests/                                 catalog conformance
```

The directory name IS the public package name, hyphens included. Nim cannot
take a hyphenated path segment as a bare import, so modules here are imported
with a quoted path — that is deliberate, and preferable to renaming
`claude-code/` to `claude_code/` and leaving the selector a developer types
different from the directory it resolves to.

Each package is independently addressable. There is no aggregate import, so
resolving one agent does not compile the catalog.

## Using a package

Name it in your project's `uses:`:

```nim
package myProject:
  uses:
    "claude-code >=2.1"
```

## Publishing a realization from another repository

Read the interface fingerprint, then pin it:

```console
just fingerprints
```

```nim
provisioningFor "claude-code":
  interfaceFingerprint "f002b7ee…"
  contributor "github:your-org/your-catalog"
  scoopApp bucket = "main", app = "…", executablePath = "…"
```

A contribution whose pin no longer matches the interface is rejected rather
than applied to a contract it was never checked against.

## Contributor checks

```console
just test          # interface registration, fingerprint pins, artifact round-trip
just fingerprints  # the canonical pins external catalogs use
```

Set `REPROBUILD_SRC` when the sibling `reprobuild` checkout is not at
`../reprobuild`.
