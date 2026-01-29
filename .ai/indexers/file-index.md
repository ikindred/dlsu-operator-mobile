---
last_updated: 2026-01-28
---

# File Index (Memory Layer)

Purpose: capture **ownership, entry points, and sources of truth**. Do not dump raw file contents.

## Repository roots

- `lib/`: Dart source (app code)
  - Entry: `lib/main.dart`
- `test/`: Flutter tests
  - Default: `test/widget_test.dart`
- `android/`: Android platform project
- `ios/`: iOS platform project
- `web/`: Web platform project
- `macos/`, `windows/`, `linux/`: desktop platform projects

## Key configuration files

- `pubspec.yaml`: dependencies, assets, metadata
- `analysis_options.yaml`: lint rules
- `.ai/`: AI Native system files (orchestrator, rules, workflows, memory)
- `.cursor/`: Cursor rules and orchestrator shim

## Source-of-truth notes

- App behavior is defined by `lib/` and its architecture conventions in `.ai/context/architecture.md`.
- Routing and state management conventions should be documented in:
  - `.ai/context/architecture.md`
  - `.ai/indexers/pattern-index.md`
