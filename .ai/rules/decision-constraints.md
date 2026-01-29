---
locked: true
---

# Decision Constraints (Global)

These rules apply to **every** task.

## Task types → allowed actions

- **read-only**
  - Allowed: read files, explain, analyze, propose
  - Forbidden: modify files, run write operations

- **refactor**
  - Allowed: restructure code without changing behavior
  - Required: prove/argue behavior equivalence
  - Forbidden: new features, bugfix behavior changes

- **behavior-changing**
  - Allowed: implement features/bugfixes
  - Required: test plan; tests added/updated when appropriate

- **infra-impacting**
  - Allowed: dependency/build/tooling changes
  - Required: explicit user approval before applying

## Ambiguity rule

If you are unsure, ask structured clarification questions. Never silently assume.
