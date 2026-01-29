---
command: safe-commit
---

# Command: Safe Commit

This is a process guide. Execute only when the user explicitly asks for a commit.

## Preconditions

- The orchestrator confirmation gate was satisfied for the change.
- Relevant checks were run (or the user explicitly accepted risk).
- No secrets are included.

## Steps (git)

1. Review changes:
   - `git status`
   - `git diff`
2. Stage intentionally (avoid committing generated/build outputs).
3. Commit with a message explaining **why** the change exists.
4. Verify commit created successfully:
   - `git status`
5. Run post-commit sync:
   - `.ai/commands/update-indexers.md`

## If repository is not a git repo

- Do not initialize git unless the user requests it.
- If the user requests it, initialize and make the first commit, then run post-commit sync.
