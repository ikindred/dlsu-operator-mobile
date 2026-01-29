---
workflow: interactive-clarification
locked: true
---

# Workflow: Interactive Clarification

Clarification is **unlimited until resolved**.

## Question format (mandatory)

```
QUESTION: <clear, scoped question>

OPTIONS:
A) <option>
B) <option>
C) <option>

SELECT ONE OR MORE OPTIONS
```

## Rules

- No silent assumptions.
- Prefer options over free text.
- Only allow free text if the user explicitly permits it for that question.
- Clarifications are per-task and must be recorded in `.ai/context/task-clarifications.md`.

## Completion criteria

Clarification is “resolved” only when:

- acceptance criteria are clear,
- scope boundaries are defined,
- platform targets are stated (if relevant),
- test expectations are stated (if behavior changes).
