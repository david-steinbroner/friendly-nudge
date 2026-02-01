# Handoff (read this first)

## What Nudge is
A private, local-only friendship companion. No accounts, no cloud sync, no AI, no social integrations.

## Current status
- Milestone: 0 (Setup)
- Implemented:
  - (none yet)

## Repo rules (must follow)
- No PII logging. Ever.
- Local-only storage for MVP.
- Small PRs, one ticket per PR.
- Keep logic out of SwiftUI view bodies when possible.

## Next tickets
1) Scaffold project structure + Core Data entities
2) People list CRUD
3) Person detail edit
4) Interaction logging
5) Daily deck selection logic + tests
6) Local notifications
7) Privacy controls: app lock + hide notes
8) Export + delete flows
9) Contacts import
10) Accessibility pass

## File map (update as it grows)
- App/
- Features/
- Services/
- Persistence/
- docs/

## Known landmines
- Avoid permission requests at launch. Ask only on user action.
- Avoid any analytics payloads that include user-entered text.
- Avoid "tracker" wording in UI and marketing copy.

## Open questions
- Final app name (Nudge is working title).
- MVP deck size default (likely 7).
