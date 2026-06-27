---
name: macos-pim
description:
  Manage macOS Calendar and Reminders via CLI. Use when the user asks to
  create, list, edit, delete, or search calendar events or reminders, check free/busy availability, RSVP to invitations,
  or otherwise manipulate their local Calendar.app or Reminders.app data.
---

# macOS Calendar & Reminders

Two native macOS CLIs (both built on EventKit) give full CRUD access to the user's local Calendar.app and Reminders.app
data:

| Tool        | Domain    | Binary      |
| ----------- | --------- | ----------- |
| `ical`      | Calendar  | `ical`      |
| `remindctl` | Reminders | `remindctl` |

Both require a one-time macOS permission grant for "Full Disk Access" / Reminders / Calendar on first use. If a command
fails with a permission error, run `remindctl status` (Reminders) or check System Settings → Privacy & Security for
Calendar access.

## Rules

- **Always prefer these CLIs** over AppleScript, `osascript`, or GUI automation for calendar/reminders work on this
  machine.
- Run `--help` on any subcommand for the authoritative flag list; the reference below is a quick index, not exhaustive.
- When the user gives a relative date ("tomorrow", "next Friday"), pass it verbatim — both tools parse natural-language
  dates. ISO 8601 also works.
- For machine-readable output (parsing, scripting, agent verification), prefer `--json` (`remindctl`) or `-o json`
  (`ical`). Use `--plain` / `-o plain` for line-based output.
- Many `remindctl` and `ical` commands accept a **row number from the previous listing** or a **partial/short ID**. To
  act on an item: list first, then reference by row number or ID prefix. Use `--id` (`ical`) for an exact full-ID match
  with no prefix search.
- Destructive actions (`delete`, calendars `delete`) prompt for confirmation by default; pass `--force`/`-f` only when
  the user has already confirmed.
- This machine only. If the user wants Google Calendar / Todoist / Notion, use a different integration, not
  `ical`/`remindctl`.

## Quick start

### Reminders

```bash
remindctl status                       # check Reminders permission
remindctl list                          # list reminder lists
remindctl show today                    # today's reminders
remindctl add "Buy milk" --due tomorrow --list Personal
remindctl add "Standup" --due "tomorrow 09:00" --repeat weekly --priority high
remindctl complete 1                    # complete by row number from `show`
remindctl edit 4A83 --due "2026-01-03 09:00"
remindctl delete 1 2 3 --force
```

### Calendar

```bash
ical today                              # today's agenda
ical upcoming                           # next 7 days (alias: next, soon)
ical list --from today --to "in 3 days"
ical search "dentist"                   # search title/location/notes
ical add "Sync with Sam" --start "tomorrow 10:00" --end "tomorrow 10:30" --calendar Work
ical add "Lunch" -s "noon" -a --calendar Personal     # all-day event
ical add "Sprint planning" --start "2026-01-06 10:00" --repeat weekly --invite "sam@example.com"
ical show 2                             # show by row number from last listing
ical join                               # open the meeting link of the current/next event
ical rsvp accepted 3                    # accept invitation (row 3 from listing)
ical delete 1 --span all               # delete whole recurring series
```

## Workflows

### Find an item to act on

1. List/search to get a row number or ID:
   - Reminders: `remindctl show [filter]` or `remindctl list <name>`
   - Calendar: `ical today`, `ical upcoming`, `ical list --from .. --to ..`, `ical search "<q>"`
2. Re-run the same listing command before referencing row numbers — row numbers are tied to the most recent listing in
   the same context and can drift if items change.

### Recurring events/reminders

- `ical add --repeat <daily|weekly|monthly|yearly>`; refine with `--repeat-interval`, `--repeat-days mon,wed,fri`,
  `--repeat-count`, `--repeat-until`.
- `remindctl add --repeat <daily|weekly|biweekly|monthly|yearly|every N days/weeks/months/years>`.
- When deleting/updating a recurring `ical` event, set `--span this|future|all`.
- When editing a recurring `remindctl` item, pass `--no-repeat` to remove recurrence.

### Free/busy & invitations

- `ical free <email>...` — availability lookup (requires Exchange/Google Workspace; iCloud does not support free/busy).
- `ical inbox` — pending event invitations.
- `ical rsvp <accepted|declined|tentative> [number or id]` — respond to an invitation.

## Command reference

Full per-command flags, aliases, and examples:

- **Reminders** (`remindctl`): see [REFERENCE.md](REFERENCE.md#remindctl)
- **Calendar** (`ical`): see [REFERENCE.md](REFERENCE.md#ical)
