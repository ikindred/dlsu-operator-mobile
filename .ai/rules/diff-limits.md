---
locked: true
---

# Diff Limits (Budget Enforcement)

Default maximum diffs:

- **Bugfix**: ≤ 50 LOC
- **Feature**: ≤ 300 LOC
- **Refactor**: ≤ 1 module (no behavior change)

## If the budget will be exceeded

- Cursor behavior: **STOP** and ask the user to approve either:
  - A) split into multiple staged changes
  - B) increase the budget for this task (explicitly)

## Counting guidance

- Count only meaningful code/logic lines (not whitespace), but be conservative.
- Large renames and formatting-only changes still count as “diff risk”; prefer smaller PR-sized steps.
