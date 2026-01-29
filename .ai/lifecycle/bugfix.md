---
type: bugfix
---

# Lifecycle: Bugfix

## Goal

Fix a defect with minimal, correct change and validated behavior.

## Steps (must follow)

1. **Classify**: behavior-changing (bugfix) unless it’s strictly refactor.
2. **Reproduce / observe**:
   - collect failing behavior (steps, logs, screenshots, error text)
   - identify where it occurs (UI vs controller vs service)
3. **Clarify** (structured options):
   - expected behavior vs current behavior
   - target platforms (Android/iOS/Web/etc.)
   - scope boundaries
4. **Confirm gate**: user must approve the confirmation summary.
5. **Blast radius**:
   - map dependencies (controllers → UI, services → callers)
6. **Fix**:
   - keep within bugfix diff budget (≤ 50 LOC) or stop and stage
7. **Tests**:
   - add/adjust tests to prevent regression when feasible
8. **Verify**:
   - run the smallest set of commands to validate fix

## Deliverable checklist

- Root cause explained
- Fix is minimal and localized
- Regression risk addressed (test or rationale)
