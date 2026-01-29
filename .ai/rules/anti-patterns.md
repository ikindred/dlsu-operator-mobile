---
locked: true
---

# Anti-Patterns (Flutter / GetX)

Avoid these patterns unless explicitly justified and documented.

## Flutter anti-patterns

- Side effects in `build()` (network calls, state mutations).
- Huge widgets with deeply nested build trees; prefer extraction + composition.
- Global singletons without clear lifetimes or testability strategy.

## GetX anti-patterns

- Overusing `Get.find()` everywhere (hidden global dependency graph).
- Mixing `Obx`, `GetX`, and `GetBuilder` randomly in the same area without a reason.
- Controllers that do IO directly without service boundaries (harder to test).
- Controllers that become “god objects” (too many responsibilities).
- Storing `BuildContext` in controllers.
- Making every field reactive (`.obs`) “just in case” (noise + overhead).

## Routing anti-patterns

- Scattered route definitions across unrelated files.
- Navigation without typed/validated arguments when arguments are required.
- Route guards implemented ad-hoc in UI instead of middleware.

## Enforcement

If a request would introduce an anti-pattern, the AI must:

- surface the risk
- propose the minimal compliant alternative
- ask the user to choose (structured options) if trade-offs exist
