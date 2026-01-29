---
system: "AI-Native Development System v4 (FINAL)"
tool: "Cursor"
entrypoint: true
---

# Orchestrator (CORE BRAIN)

This file is the **mandatory entry point** for every user prompt in this repository.

## Operating principle

Ask relentlessly up front → Confirm understanding → Write boring, correct code → Keep memory fresh.

## Hard rules (non-negotiable)

- Never guess silently.
- Clarify using **selectable options** (A/B/C…), unlimited rounds until resolved.
- Block execution until the **confirmation gate** is satisfied.
- Respect task classification constraints (read-only/refactor/behavior-changing/infra-impacting).
- Follow Cursor bias: **minimal correct change**, hard stop on diff overflow.

## Required system files (must exist)

If any are missing, create them first (from `AI_Native_Dev_System_v4_FINAL.md`) before continuing:

- `.ai/tools/cursor.md`
- `.ai/context/ai-environment.md`
- `.ai/context/project-profile.md`
- `.ai/context/architecture.md`
- `.ai/context/domain-map.md`
- `.ai/context/task-clarifications.md`
- `.ai/indexers/file-index.md`
- `.ai/indexers/pattern-index.md`
- `.ai/indexers/test-strategy.md`
- `.ai/rules/decision-constraints.md`
- `.ai/rules/change-impact.md`
- `.ai/rules/diff-limits.md`
- `.ai/rules/anti-patterns.md`
- `.ai/rules/prompt-hygiene.md`
- `.ai/workflows/read-mode.md`
- `.ai/workflows/write-mode.md`
- `.ai/workflows/refactor-mode.md`
- `.ai/workflows/failure-recovery.md`
- `.ai/workflows/interactive-clarification.md`
- `.ai/commands/update-indexers.md`
- `.ai/commands/safe-commit.md`

---

## Execution order (must run in this exact order)

### 0) Environment & project discovery (Phase 0)

1. Detect tool environment: **Cursor**.
2. Load or initialize:
   - `.ai/context/ai-environment.md`
   - `.ai/context/project-profile.md`
3. If the user task would be meaningfully affected by architecture/domain assumptions, load:
   - `.ai/context/architecture.md`
   - `.ai/context/domain-map.md`
4. Load memory/indexers:
   - `.ai/indexers/file-index.md`
   - `.ai/indexers/pattern-index.md`
   - `.ai/indexers/test-strategy.md`

### 1) Task classification

Classify the user request as **exactly one** primary type:

- **read-only**: explanation, analysis, “what is…”, no code changes
- **refactor**: code restructuring with **no behavior change**
- **behavior-changing**: new behavior, bugfix, feature work
- **infra-impacting**: toolchain changes, CI/CD, build config, dependency changes, platform-level changes

If multiple apply, choose the **highest risk** type (infra-impacting > behavior-changing > refactor > read-only).

### 2) Load constraints (rules overlay)

Always load:

- `.ai/rules/decision-constraints.md`
- `.ai/rules/diff-limits.md`
- `.ai/rules/prompt-hygiene.md`
- `.ai/tools/cursor.md`

If the task touches architecture, also load:

- `.ai/rules/change-impact.md`
- `.ai/rules/anti-patterns.md`

### 3) Interactive clarification phase (unlimited)

If there is any ambiguity about:

- scope, acceptance criteria, platforms, UX, data models, APIs
- what “done” means, test expectations
- blast radius risks or diff budget risks

…you must ask structured questions in this format (no free text unless explicitly allowed by the user):

```
QUESTION: <clear, scoped question>

OPTIONS:
A) <option>
B) <option>
C) <option>

SELECT ONE OR MORE OPTIONS
```

Persist:

- questions asked
- selected options
- any allowed free-text notes

…into `.ai/context/task-clarifications.md` under a new dated section for the current request.

### 4) Confidence check (MANDATORY gate)

Before editing files or running write operations, present:

```
CONFIRMATION SUMMARY:
- Task type:
- Scope:
- Affected layers:
- Expected behavior:
- Tests required:

CONFIRM?
A) Yes, proceed
B) No, revise
```

Execution is blocked until the user selects **A**.

### 5) Lock execution mode

Lock one of:

- **READ**: inspect/explain only, no file writes
- **WRITE**: implement behavior changes with tests if required
- **REFACTOR**: restructure only, prove no behavior change

### 6) Execute with constraints applied

During execution:

- Compute blast radius using `.ai/rules/change-impact.md` before making edits.
- Stay within diff limits from `.ai/rules/diff-limits.md`. If likely to exceed: **STOP and ask**.
- For behavior-changing tasks: ensure a test plan exists; add/update tests per `.ai/indexers/test-strategy.md` where appropriate.
- If anything fails (build/test/lint): follow `.ai/workflows/failure-recovery.md`. In Cursor mode, stop after failure and reduce scope.

### 7) Post-change knowledge sync (after commits)

If the user performs or requests a commit, run `.ai/commands/update-indexers.md`:

- update `.ai/indexers/file-index.md`
- update `.ai/indexers/pattern-index.md`
- update `.ai/context/domain-map.md` if affected

---

## Cursor-specific enforcement

Cursor bias applies:

- Prefer minimal, correct edits.
- Clarify early.
- Avoid wide refactors.
- If the requested change is large, propose a staged approach under the diff budget.
