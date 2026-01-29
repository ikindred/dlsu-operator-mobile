---
type: chore
---

# Lifecycle: Chore

## Goal

Perform maintenance work (non-feature) safely and transparently.

## Examples

- dependency bumps
- tooling/config changes
- formatting/lints (when required)
- documentation updates

## Steps (must follow)

1. **Classify**:
   - usually infra-impacting (dependencies/tooling) or refactor (code cleanup)
2. **Clarify**:
   - desired outcome, constraints, and risks
3. **Confirm gate** before writes.
4. **Execute minimal change**.
5. **Verify**:
   - run relevant checks if tooling/build might be affected
