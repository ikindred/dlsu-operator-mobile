---
last_updated: 2026-01-28
---

# Pattern Index (Memory Layer)

Purpose: capture **architectural patterns and conventions**. No raw source dumping.

## Flutter baseline conventions

- Keep widgets declarative; put orchestration/state in controllers/services.
- Prefer small widgets + composition over large monolithic build methods.
- Avoid side effects inside `build()`.

## GetX (comprehensive)

### Controllers

- Location (target): `lib/app/controllers/` (or feature-local equivalents)
- Responsibilities:
  - screen state
  - orchestration of services
  - derived view-model fields
- Conventions:
  - expose `Rx<T>` fields using `.obs`
  - keep controller API small and explicit
  - dispose resources in `onClose()`

Example patterns:

- **Reactive state**:
  - `final count = 0.obs;`
  - UI uses `Obx(() => Text('${controller.count.value}'))`
- **Non-reactive**:
  - `GetBuilder` + `update()` when needed (avoid mixing randomly with `Obx`)

### Bindings (Dependency Injection)

- Location (target): `lib/app/bindings/`
- Use `Bindings` to register dependencies for a route:
  - `Get.lazyPut<SomeController>(() => SomeController())`
  - register services once (app-level) when appropriate

### Navigation & Routes

- Prefer `GetMaterialApp` when adopting GetX routing.
- Maintain named routes centrally:
  - `app_routes.dart`: route name constants
  - `app_pages.dart`: `GetPage` list with bindings and middlewares

### Dependency access

- Prefer constructor injection when reasonable (testability).
- Use `Get.find<T>()` sparingly and consistently; avoid hidden globals.

### Services

- Location (target): `lib/app/services/`
- Encapsulate IO:
  - API clients
  - storage (secure storage / shared prefs)
  - device integrations

### Middleware (route guards)

- Use `GetMiddleware` for:
  - auth guards
  - onboarding checks
  - role-based routing

### Error handling

- Prefer explicit error states in controllers:
  - `Rxn<String> errorMessage = Rxn<String>();`
  - `RxBool isLoading = false.obs;`
- In UI, surface errors through consistent patterns (snackbar/dialog/banner) decided in `architecture.md`.

## Naming conventions (recommended)

- Controller: `XController`
- Binding: `XBinding`
- Page/Screen: `XPage` or `XView`
- Service: `XService`
- Route constants: `Routes.x` or `AppRoutes.x`
