---
last_updated: 2026-01-28
---

# AI Environment

## Active environment

- Tool: **Cursor**
- Bias: precision, minimal correct change, human-in-the-loop

## Enforcement

Cursor must always enter via:

1. `.cursor/rules/ai-native-orchestrator.md` (auto-applied rule)
2. `.cursor/orchestrator.md` (shim)
3. `.ai/orchestrator.md` (core brain)

The user should not need to mention any of these files for compliance.
