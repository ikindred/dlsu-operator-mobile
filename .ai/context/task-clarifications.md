---
last_updated: 2026-01-28
---

# Task Clarifications (Per-Task Only)

This file stores structured answers for **the current task only**.
Do not treat prior answers as globally reusable unless the user explicitly promotes them to `architecture.md` / `domain-map.md`.

---

## 2026-01-28 — AI Native system bootstrap (Cursor / Flutter / GetX)

QUESTION: What state management approach does your Flutter project use or plan to use?

OPTIONS:
A) BLoC (Business Logic Component)
B) Provider
C) Riverpod
D) GetX
E) MobX
F) Other or not decided yet

SELECTED:

- D) GetX

QUESTION: The AI Native system supports both Cursor and Cline. Should I configure for:

OPTIONS:
A) Cursor only (precision-focused, minimal changes)
B) Both Cursor and Cline (full flexibility)

SELECTED:

- A) Cursor only

QUESTION: Should the lifecycle workflows be Flutter-specific or keep them generic?

OPTIONS:
A) Flutter-specific
B) Generic
C) Both - generic with Flutter adaptations

SELECTED:

- B) Generic

QUESTION: Where should the orchestrator auto-invocation rule be placed?

OPTIONS:
A) .cursor/rules/
B) .ai/rules/
C) Both

SELECTED:

- A) .cursor/rules/

QUESTION: Should I pre-populate the context files with Flutter project detection?

OPTIONS:
A) Yes - auto-detect and fill
B) Templates only
C) Partial

SELECTED:

- A) Yes - auto-detect and fill

QUESTION: How should the orchestrator be automatically invoked?

OPTIONS:
A) Every request
B) Dev tasks only
C) Smart detection

SELECTED:

- A) Every request

QUESTION: Should I include GetX-specific patterns in indexers and rules?

OPTIONS:
A) Yes - comprehensive
B) Yes - basic
C) No

SELECTED:

- A) Yes - comprehensive

QUESTION: What level of detail should initial files contain?

OPTIONS:
A) Comprehensive
B) Structured
C) Minimal

SELECTED:

- A) Comprehensive

QUESTION: Should I include testing strategy configuration?

OPTIONS:
A) Yes - Flutter testing strategy
B) Yes - generic testing strategy
C) Later

SELECTED:

- B) Yes - generic testing strategy
