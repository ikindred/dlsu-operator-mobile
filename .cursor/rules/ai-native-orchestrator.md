---
description: "AI Native v4: always enter via orchestrator (no manual mentions)."
alwaysApply: true
---

## AI Native v4 (Cursor) — Mandatory Entry

You must follow the AI-Native Development System v4 for **every** user request in this repository.

### Non-negotiable rule

Before responding to the user (even for read-only questions), you must:

1. Read `.cursor/orchestrator.md`
2. Execute its steps in order
3. Only then produce your response

The user must **never** need to mention `.cursor/orchestrator.md`, `.ai/orchestrator.md`, or any system file to make you comply.

### Enforcement behavior

- If any required system file is missing or cannot be read, stop and ask for permission to create/read it (do not proceed with partial compliance).
- Never silently assume unspecified requirements; use structured selectable questions.
- Never begin coding or editing until the orchestrator’s **confirmation gate** is satisfied.
