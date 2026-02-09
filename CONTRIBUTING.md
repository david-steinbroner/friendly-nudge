# Contributing to Friendly Nudge

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

## Formatting + linting
We use SwiftFormat and SwiftLint. CI enforces both.

**Install tools locally:**
```bash
brew install swiftformat swiftlint
```

**Run lint check:**
```bash
./scripts/lint.sh
```

**Auto-format code:**
```bash
./scripts/format.sh
```

Configuration files: `.swiftformat`, `.swiftlint.yml`

## Testing
Unit tests live in `FriendlyNudge/FriendlyNudgeTests/`. CI runs tests automatically on all PRs.

**Local workflow (default):**
- Do NOT run `xcodebuild test` locally by default — it's slow and CI handles it.
- Verify behavior by running the app on a physical iPhone (Cmd+R in Xcode).
- Run `./scripts/lint.sh` before committing.
- Open PR once lint passes and device verification is done.
- Let CI (required check: `build`) run simulator build + unit tests.

**Run tests locally only if:**
- CI fails and you need to debug locally, OR
- The user explicitly requests local test runs.

**Command to run tests locally (when needed):**
```bash
xcodebuild test \
  -project FriendlyNudge/FriendlyNudge.xcodeproj \
  -scheme FriendlyNudge \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO
```

When adding new features with non-trivial logic, include unit tests.

## PR-first workflow (required for Linear automation)
- Never commit directly to main.
- One branch per Linear issue; branch name must include SKU-### (e.g., `SKU-123-feature-slug`).
- PR title must include SKU-### (e.g., `SKU-123 Add feature X`).
- PR description must start with `Fixes SKU-###` on its own line.
- Merge PR to auto-close the Linear ticket.
- Use GitHub CLI: `gh pr create --title "SKU-### Title" --body "Fixes SKU-###" --base main`
- Helper script: `./scripts/fn_pr.sh SKU-### "slug" "PR title"`

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
- Lint passes (`./scripts/lint.sh`).
- No PII logging.
- Verified on physical device (Cmd+R).
- Feature matches ticket acceptance criteria.
- docs/HANDOFF.md updated only if a milestone-level change occurred.
- CI build check green (CI runs build + tests on simulator).
