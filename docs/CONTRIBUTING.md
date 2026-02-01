# Contributing to Nudge

## Core rules (non-negotiable)
1. Local-only MVP: no backend, no accounts, no AI, no social integrations.
2. Privacy-first: NEVER log or send PII (names, notes, birthdays, phone numbers, contact ids).
3. Ask permissions only when needed (Contacts on import, Notifications on enable reminders).
4. Keep changes small and focused. Avoid sweeping refactors unless explicitly requested.

## Project structure
- App/                 App entry, environment, routing
- Features/            Feature folders (People, Deck, Settings)
- Models/              Domain models + enums
- Persistence/         Core Data stack + repositories
- Services/            Deck, Notifications, Export, Contact Import
- UIComponents/        Reusable SwiftUI components
- Utilities/           Small cross-cutting helpers only

## Coding standards
- Prefer clarity over cleverness.
- Views render UI. Business logic belongs in Services or ViewModels.
- No force unwraps in app code.
- Comments are for "why" and gotchas, not for narrating code.
- New feature work should include basic tests for non-trivial logic.

## Commit discipline
- One ticket per PR.
- One feature per PR.
- Use conventional commits:
  - feat: ...
  - fix: ...
  - chore: ...
  - docs: ...
  - test: ...

## Definition of done
- Builds cleanly.
- No PII logging.
- Tests pass (where applicable).
- Feature matches ticket acceptance criteria.
- docs/HANDOFF.md updated only if a milestone-level change occurred.
