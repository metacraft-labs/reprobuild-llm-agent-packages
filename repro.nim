## Reprobuild LLM agent packages — catalog root.
##
## This repository owns the coding-agent package INTERFACES and their
## realizations. It is the federation unit described in
## ``reprobuild-specs/Provisioning-Contributions.md`` §"Repository
## Composition", and the first deliverable of
## ``Reprobuild-LLM-Agent-Packages.milestones.org`` M0.
##
## The root recipe deliberately does NOT import the per-package modules.
## Each package under ``packages/`` is independently addressable, and an
## aggregate import here would make every package part of every provider
## compile — the same rule ``reprobuild-packages`` states in its AGENTS.md,
## and for the same reason: a catalog that grows to a hundred agents must
## not cost a hundred compiles to resolve one of them.

import repro_project_dsl

package reprobuildLlmAgentPackages:
  devEnv:
    task("test",
      "nim c -r --nimcache:build/nimcache-catalog tests/test_llm_agent_catalog.nim",
      description = "Validate the agent interfaces and their contributions")
