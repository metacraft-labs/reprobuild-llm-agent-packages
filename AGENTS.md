# Reprobuild LLM Agent Packages

This repository owns coding-agent package interfaces and their realizations.
Read [`README.md`](./README.md) for the layout; this file is the contract a
change has to satisfy.

Changes land on `dev`. Keep public commit messages user-facing, and do not
add assistant-attribution trailers to them.

## Interface ownership

An interface says WHAT a package exports — its executables, and later its
config, credential and protocol members. It says nothing about where bytes
come from.

- A package is defined exactly ONCE. Two definitions of one name resolve to
  whichever module happened to be imported, which is the import-order
  dependence this whole model exists to rule out.
- A realization may not add, remove or rename an interface member. If a
  realization cannot provide a declared member, it does not satisfy the
  interface and must not claim to.
- Changing an interface changes its fingerprint and invalidates every
  external contribution pinned to the old one. That is the intended
  behaviour: a stale pin must fail rather than be applied to a contract
  nobody checked it against. Publish the new fingerprints (`just
  fingerprints`) in the same change.

## Provenance classes

Every package declares one, and it is not a matter of taste:

- **`source-available`** — upstream publishes buildable source under a
  licence that permits it. The PRIMARY realization must be a from-source
  build under `packages/source/`. A vendor-binary realization of the same
  interface is allowed as a convenience, and must not be presented as
  equivalent provenance.
- **`vendor-binary`** — no corresponding source is published, or its licence
  forbids building and redistributing. Only `packages/vendor/` realizations
  are reachable. Such a package must never be described as built from
  source, and the absence of a `packages/source/` entry is not an adequate
  way to say so — the recipe says it in words.

Re-derive the class at every version bump. A project's licence and its
published build have diverged before, and inheriting a judgement made at an
earlier version is how a catalog ends up asserting something untrue.

## Cache policy

A vendor-binary payload is fetched **on the user's behalf** and MUST NOT be
republished into a shared binary cache. A cache is redistribution, and
redistribution is not a right these licences generally grant. What this
catalog publishes is the interface and the pin; the bytes stay upstream.

Source-built outputs of `source-available` packages are publishable, and
should be published — that is the point of building them.

## Required metadata

A realization records, at the pinned version:

- upstream homepage and source location
- version, and the release channel it came from
- licence **verified at that version**
- provenance class
- main programs
- platforms, as explicit (cpu, os) slices
- integrity: a distinct digest per platform slice
- whether the program needs credentials, and which environment variables or
  config paths carry them — never the secrets themselves
- network endpoints the program contacts at run time
- self-update behaviour, and how it was disabled

## Digests

Take each digest from upstream's own published checksum for that exact
artifact, at that exact version. Do not carry a digest across a version bump,
and do not reuse one slice's digest for another platform — a digest repeated
across two slices means one platform is serving the other's bytes, and the
package will resolve everywhere and run on one machine. `just test` checks
slice-digest distinctness for exactly this reason.

## Self-update

Agent CLIs commonly update themselves in place. A realization must disable or
isolate that path, so a version is changed by refreshing the catalog lock
rather than by a program rewriting itself underneath a content-addressed
store. Record how it was disabled.

## Inventory

`inventory/upstream.toml` is a coverage input, not a source of truth. Add an
`[[uncovered]]` entry for an upstream you decided not to package yet, with
the reason — coverage reporting has to distinguish "not packaged" from "not
known about", and an absent row cannot express the difference.
