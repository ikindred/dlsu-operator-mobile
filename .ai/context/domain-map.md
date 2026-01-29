---
last_updated: 2026-01-28
---

# Domain Map

This file maps product domains → modules/owners in the codebase.

## Current state

No business domains have been defined yet (new Flutter template).

## How to use this file (rule)

When a feature is introduced, add a section:

- **Domain**: <name>
- **User intent**: <one-liner>
- **Primary UI**: <pages/screens>
- **Controllers**: <GetX controllers>
- **Services**: <APIs/storage/device>
- **Models**: <key models>
- **Routes**: <named routes>
- **Tests**: <unit/widget/integration locations>

## Seeded conventions (GetX)

- Domains should own their controllers and bindings.
- Shared widgets go into `ui/widgets/`.
- Cross-domain services go into `services/` and must be well-documented.
