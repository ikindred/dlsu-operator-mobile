---
tool: "Cursor"
overlay: true
---

# Cursor Overlay (AI-Native v4)

This overlay modifies the orchestrator execution behavior specifically for **Cursor**.

## Bias

- **Minimal correct change** over “complete” change.
- Prefer surgical edits to a small set of files.
- Clarify early; do not start editing if success criteria are unclear.

## Hard stops (Cursor behavior)

- If any command/build/test fails: **stop**, explain the failing layer, propose a reduced scope fix.
- If the diff budget will likely be exceeded: **stop and ask** to split work.
- Never perform broad refactors unless explicitly requested and classified as **refactor**.

## Diff budget enforcement

Default budgets (from system spec):

- Bugfix: ≤ 50 LOC
- Feature: ≤ 300 LOC
- Refactor: ≤ 1 module (and no behavior change)

If a request exceeds these limits, propose a staged plan and wait for user approval.

## Tooling expectations

- Prefer repository-local evidence: read existing files before deciding.
- Avoid adding dependencies unless the user task requires them; if required, ask and document impact.
- Keep changes deterministic: avoid “maybe”, “should”, or speculative edits.

## Clarification format (enforced)

Only ask structured questions with selectable options:

```
QUESTION: <clear, scoped question>

OPTIONS:
A) <option>
B) <option>
C) <option>

SELECT ONE OR MORE OPTIONS
```

## Confirmation gate (enforced)

Before any writes:

```
CONFIRMATION SUMMARY:
- Task type:
- Scope:
- Affected layers:
- Expected behavior:
- Tests required:

CONFIRM?
A) Yes, proceed
B) No, revise
```
