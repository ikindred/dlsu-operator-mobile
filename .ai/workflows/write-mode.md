---
mode: WRITE
---

# Workflow: WRITE Mode

Use this mode when task classification is **behavior-changing**.

## Before writing

1. Ensure clarification is complete (structured options).
2. Present the **confirmation summary** gate and wait for approval.
3. Compute blast radius via `.ai/rules/change-impact.md`.
4. Check diff budget via `.ai/rules/diff-limits.md`. If exceeded: stop and stage.

## While writing

- Apply Cursor bias: minimal correct change.
- Prefer narrow file edits and incremental commits (when user requests commits).
- Keep structure aligned with `.ai/context/architecture.md`.

## After writing

- Provide a test plan and the exact commands to run (or run them if requested).
- If committing, sync memory via `.ai/commands/update-indexers.md`.
