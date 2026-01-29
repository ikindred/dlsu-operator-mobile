---
type: feature
---

# Lifecycle: Feature

## Goal

Deliver a behavior-changing feature under the AI Native v4 process (Cursor bias: minimal correct change).

## Steps (must follow)

1. **Classify**: behavior-changing (unless proven otherwise).
2. **Clarify**: ask structured questions until acceptance criteria are unambiguous.
3. **Confirm**: require the confirmation gate before any code edits.
4. **Plan minimal slice**: keep within diff budget (≤ 300 LOC by default).
5. **Implement**:
   - prefer small, composable units
   - follow architecture conventions in `.ai/context/architecture.md`
   - use GetX patterns from `.ai/indexers/pattern-index.md` when applicable
6. **Tests**:
   - define a test plan (unit/widget/integration as appropriate)
   - update tests if feature changes behavior
7. **Verify**:
   - run the minimal relevant checks (build/test) that validate the change
8. **Sync memory after commit**:
   - update indexers via `.ai/commands/update-indexers.md`

## Deliverable checklist

- Feature meets acceptance criteria
- No undocumented assumptions
- Diff is within budget or staged with approval
- Relevant tests updated/added (if required)
