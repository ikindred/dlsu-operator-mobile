---
locked: true
---

# Change Impact Awareness (Blast Radius)

Before coding, compute the likely blast radius of the proposed change.

## Flutter / GetX blast radius heuristics

### UI layer

- Page/Screen widget changes may affect:
  - navigation arguments
  - controller bindings
  - widget tests

### GetX controllers

- Controller changes may affect:
  - any page/widget using `Obx`/`GetBuilder` bindings to its state
  - bindings that instantiate it
  - routing that depends on it
  - unit tests for controller logic

### Bindings / DI

- Binding changes may affect:
  - runtime initialization order
  - integration tests and navigation flows
  - dependency lifetimes (lazy vs eager)

### Routes

- Route table changes may affect:
  - navigation flows
  - middlewares (guards)
  - deep linking and integration tests

### Services / IO boundaries

- API/storage service changes may affect:
  - all controllers and UI relying on responses
  - error handling and loading states
  - integration tests and mocks/fakes

## Enforced behavior

- If the blast radius is unclear: clarify scope first.
- If the blast radius is large: stage changes under diff limits.
