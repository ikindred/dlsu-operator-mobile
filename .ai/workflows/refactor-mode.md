---
mode: REFACTOR
---

# Workflow: REFACTOR Mode

Use this mode when task classification is **refactor**.

## Rules

- No behavior change.
- No user-visible changes.
- Keep within refactor diff constraints (≤ 1 module by default).

## Steps

1. Clarify desired refactor outcomes (readability, structure, testability).
2. Confirmation gate before edits.
3. Explain why behavior is unchanged (inputs/outputs preserved).
4. Verify with the smallest relevant checks (tests/build) where feasible.
