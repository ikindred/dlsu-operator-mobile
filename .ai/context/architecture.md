---
last_updated: 2026-01-28
---

# Architecture

This file documents the evolving architecture for this Flutter app.
The AI must **read this before proposing structural changes** and must update it when architecture changes are introduced and committed.

## Current state (detected)

- App is currently the default Flutter template (`MaterialApp` + counter demo).
- No feature modules, routing, or state management setup is present yet.

## Target architecture (GetX-oriented)

When you begin implementing real screens/features, prefer a simple, scalable GetX structure:

```
lib/
  app/
    routes/
      app_pages.dart
      app_routes.dart
    bindings/
    controllers/
    services/
    models/
    ui/
      pages/
      widgets/
  main.dart
```

### Responsibilities

- `routes/`: GetX route tables and named routes
- `bindings/`: per-feature dependency bindings (DI setup)
- `controllers/`: presentation/application state + orchestration
- `services/`: API clients, storage, device services
- `models/`: immutable domain/data models
- `ui/`: pages/screens + reusable widgets

### State management conventions (GetX)

- Prefer **Controller-driven** logic; keep Widgets mostly declarative.
- Prefer `Rx<T>` / `.obs` for reactive state and `Obx` for UI binding.
- Use `GetBuilder` when you need explicit `update()` cycles (avoid mixing without reason).

## Routing conventions (GetX)

- Prefer `GetMaterialApp` when adopting GetX routing.
- Centralize routes in `app_pages.dart` to keep navigation consistent.

## Persistence / side effects

- Keep side effects in `services/` and orchestrate via controllers.
- Avoid direct IO calls in Widgets.

## Known decisions (locked per repository)

- The AI must use the orchestrator flow for every prompt.
- Clarification + confirmation gates are mandatory before any code changes.
