---
type: commit
---

# Lifecycle: Commit

## Goal

Create safe, reviewable commits and keep AI Native memory updated.

## Rules

- Do not commit secrets.
- Do not commit generated build artifacts.
- Keep commits focused.

## Steps

1. Ensure the task passed the confirmation gate and required checks.
2. Draft a message describing **why** the change exists (not just what changed).
3. Commit.
4. Immediately run `.ai/commands/update-indexers.md` to sync:
   - `.ai/indexers/file-index.md`
   - `.ai/indexers/pattern-index.md`
   - `.ai/context/domain-map.md` (if affected)

## Notes

This repository may or may not be initialized as a git repo. If not, initialize git only if explicitly requested by the user.
