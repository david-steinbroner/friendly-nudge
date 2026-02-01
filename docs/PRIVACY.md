# Privacy posture (MVP)

## Promise
Nudge stores your data on your device. No accounts. No cloud sync. No AI. No social integrations.

## What we store (on device)
- Person name, optional photo, optional birthday
- Tags/groups
- Notes you write
- Interaction logs (date + type + optional note)
- Reminder settings and snooze state

## What we do NOT do
- No server-side storage for MVP.
- No reading SMS, iMessage, call history, email, or social DMs.
- No uploading contacts to a server.
- No tracking users across apps.
- No PII in analytics or crash reports.

## Logging rules (hard rule)
Never log:
- names
- notes
- birthdays
- phone numbers
- contact identifiers
- any freeform user text

If logging is required for debugging, log only event types (e.g. "export_started") without payload.

## Permissions
- Contacts: requested only when user taps Import.
- Notifications: requested only when user enables reminders.
- Photos: requested only if user chooses to add a custom photo.

## User controls
- Export all data (CSV/JSON)
- Delete person
- Delete all data
- App lock and hide-notes options
