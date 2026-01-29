---
description: "Entry point shim. Delegates to AI Native v4 orchestrator."
---

## Cursor Orchestrator (Shim)

This repository uses the AI-Native Development System v4.

### Mandatory behavior

1. Immediately load and follow: `.ai/orchestrator.md`
2. Execute the orchestrator steps **in order** for every user prompt
3. Do not ask the user to reference any `.cursor/` or `.ai/` files to enforce this behavior

If `.ai/orchestrator.md` does not exist, you must create it from the AI-Native spec in `AI_Native_Dev_System_v4_FINAL.md` before continuing.
