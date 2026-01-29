---
last_updated: 2026-01-28
---

# Test Strategy (Index)

Goal: document **how testing works**, not list all tests.

## Default tools (detected)

- Flutter test runner: `flutter test`
- Test package: `flutter_test` (from `pubspec.yaml`)

## Test types

### Unit tests

Scope:

- pure functions (formatters, validators)
- controller logic (where possible)
- service logic with mocks

Guidelines:

- avoid Widget rendering unless needed
- mock IO boundaries

### Widget tests

Scope:

- UI components and pages
- interaction flows within a widget tree
- verifying controller-driven state is rendered correctly (with test doubles)

Guidelines:

- keep widget tests focused on a single page/widget
- avoid network calls; inject fakes/mocks

### Integration tests

Scope:

- end-to-end user flows
- navigation, platform interactions

Guidelines:

- use when multiple layers interact and widget tests are insufficient

## When tests are required

- For **behavior-changing** work, tests are required unless the user explicitly waives them and accepts risk.

## Naming / location

- Place tests in `test/` mirroring `lib/` structure as the app grows.
