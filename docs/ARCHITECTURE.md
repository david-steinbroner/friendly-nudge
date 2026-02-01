# Architecture (MVP)

## Goals
- Local-first, privacy-first, minimal complexity.
- SwiftUI UI with testable logic outside view bodies.
- Keep iteration safe: small changes, predictable structure.

## High-level
SwiftUI + MVVM-ish structure:
- Views: UI only
- ViewModels: presentation logic and state
- Services: business logic (deck selection, exports, notifications)
- Persistence: Core Data stack + repositories

## Data flow
View -> ViewModel -> Service/Repository -> Core Data

## Core modules
### People
- PeopleListView: list + add/import
- PersonDetailView: view/edit profile
- Interaction logging: one tap updates lastConnected + optional note

### Deck
- DailyDeckView: shows selected people for today
- DeckService: deterministic selection logic + snooze rules

### Settings
- Privacy controls:
  - App lock (biometric)
  - Hide notes
  - Export all data
  - Delete person / delete all data

## Persistence
Core Data store on device only.
Entities:
- Person
- Tag
- InteractionLog
Optional:
- SnoozeState (or fields on Person)

## Testing
- DeckService should have unit tests for selection rules and snooze behavior.
- ExportService should have unit tests for CSV/JSON formatting.
