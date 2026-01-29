---
command: update-indexers
---

# Command: Update Indexers (Post-Commit Knowledge Sync)

Run this after a commit that changes structure, patterns, domains, or testing.

## What to update

1. `.ai/indexers/file-index.md`
   - new folders/files with ownership
   - new entry points
   - new sources-of-truth

2. `.ai/indexers/pattern-index.md`
   - new architectural patterns or conventions
   - new GetX patterns (controllers/bindings/routes) if introduced

3. `.ai/context/domain-map.md`
   - add/update domains touched by the change

4. `.ai/context/architecture.md`
   - record any structural decisions made

## Rules

- Do not dump raw source code.
- Keep entries concise and navigable.
- If nothing changed structurally, write “No structural changes” with date.
