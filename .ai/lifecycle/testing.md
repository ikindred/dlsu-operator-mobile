---
type: testing
---

# Lifecycle: Testing

## Goal

Introduce or improve tests in alignment with the project’s testing strategy.

## Steps

1. **Classify**: usually refactor (if only tests) or behavior-changing (if code changes are required).
2. **Clarify**:
   - what risk the test mitigates
   - which layer(s): unit / widget / integration
3. **Confirm gate** before writes.
4. **Implement tests** per `.ai/indexers/test-strategy.md`.
5. **Run tests** relevant to the change.
