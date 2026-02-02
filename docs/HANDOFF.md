# Handoff (read this first)

## What Friendly Nudge is
A private, local-only friendship companion. No accounts, no cloud sync, no AI, no social integrations.

## Current status
- Milestone: 1 (Scaffold complete)
- Builds and runs on physical iPhone
- Tracking: Fixes SKU-357 (scaffold complete)

### Implemented
- Xcode project created in-repo (`FriendlyNudge/`)
- SwiftUI tabs: People, Deck, Settings
- Core Data stack + `FriendlyNudge.xcdatamodeld` with Person, Tag, InteractionLog entities
- Placeholder views: PeopleListView, PersonDetailView, DailyDeckView, SettingsView
- Docs renamed to "Friendly Nudge"

## Repo rules (must follow)
- No PII logging. Ever.
- Local-only storage for MVP.
- Small PRs, one ticket per PR.
- Keep logic out of SwiftUI view bodies when possible.

## PR-first workflow (required for Linear automation)
- Never commit directly to main.
- Create a branch per Linear issue; branch name must include the issue key (e.g., `SKU-123-feature-slug`).
- PR title must include the issue key (e.g., `SKU-123 Add feature X`).
- PR description must start with `Fixes SKU-###` on its own line.
- Merge the PR to auto-close the Linear ticket.
- Use `scripts/linear_pr.sh` to scaffold branches and get PR commands.

## Next tickets
1) People list CRUD
2) Person detail edit
3) Interaction logging
4) Daily deck selection logic + tests
5) Local notifications
6) Privacy controls: app lock + hide notes
7) Export + delete flows
8) Contacts import
9) Accessibility pass

## File map (update as it grows)
- FriendlyNudge/App/
- FriendlyNudge/Features/
- FriendlyNudge/Models/
- FriendlyNudge/Persistence/
- docs/

## Known landmines
- Avoid permission requests at launch. Ask only on user action.
- Avoid any analytics payloads that include user-entered text.
- Avoid "tracker" wording in UI and marketing copy.

## Gotchas
- Device signing requires a valid Apple Development certificate; simulator does not require signing.
- Linear auto-close works best via PRs, not direct commits.
- Integration check: PR linking test.

## Open questions
- MVP deck size default (likely 7).
