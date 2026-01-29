---
workflow: failure-recovery
---

# Workflow: Failure Recovery

Cursor rule: stop immediately after a failure and reduce scope.

## On failure (build/test/lint/runtime)

1. Identify failing layer:
   - UI/widget
   - controller/state
   - service/IO boundary
   - build/tooling
2. Revert or minimize the most recent risky change (keep the smallest working set).
3. Explain likely root cause using evidence (logs/errors).
4. Reduce scope:
   - smallest fix that addresses failure
   - stage additional improvements for later
5. Retry only if the reduced scope is clearly defined.

## Never do

- Do not chain multiple speculative fixes.
- Do not expand scope mid-recovery.
- Do not “try random changes” until it passes.
