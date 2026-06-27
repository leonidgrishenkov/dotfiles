# Command Reference

> [!NOTE] Output below is condensed from `<tool> <command> --help`. Run the help command yourself for the authoritative,
> up-to-date flag list.

## Table of contents

- [remindctl](#remindctl)
  - [show](#remindctl-show) · [list](#remindctl-list) · [add](#remindctl-add) · [edit](#remindctl-edit)
  - [complete](#remindctl-complete) · [delete](#remindctl-delete) · [status](#remindctl-status) ·
    [authorize](#remindctl-authorize)
- [ical](#ical)
  - [add](#ical-add) · [calendars](#ical-calendars) · [delete](#ical-delete) · [export](#ical-export)
  - [free](#ical-free) · [import](#ical-import) · [inbox](#ical-inbox) · [join](#ical-join)
  - [list](#ical-list) · [rsvp](#ical-rsvp) · [search](#ical-search) · [show](#ical-show)
  - [today](#ical-today) · [upcoming](#ical-upcoming) · [update](#ical-update)

---

# remindctl

Manage Apple Reminders from the terminal. `remindctl 0.2.0`.

Common options on every subcommand:

```
-j, --json               Emit machine-readable JSON output
    --plain               Emit stable line-based output
-q, --quiet               Only emit minimal output
    --no-color            Disable colored output
    --no-input            Disable interactive prompts
```

### remindctl show

Show reminders. Filter: `today|tomorrow|week|overdue|upcoming|open|completed|all` or a date string.

```
remindctl show [filter] [options]
  -l, --list <value>   Limit to a specific list
```

Examples:

```bash
remindctl
remindctl today
remindctl show overdue
remindctl show 2026-01-04
remindctl show --list Work
```

### remindctl list

List reminder lists, or show contents of one or more named lists.

```
remindctl list [name] [options]
  -r, --rename <value>   Rename the list
  -d, --delete           Delete the list
      --create           Create list if missing
  -f, --force            Skip confirmation prompts
```

Examples:

```bash
remindctl list
remindctl list Work
remindctl list Work Errands
remindctl list Work --rename Office
remindctl list Work --delete
remindctl list Projects --create
```

### remindctl add

Add a reminder. Title as argument or via `--title`.

```
remindctl add [title] [options]
      --title <value>     Reminder title
  -l, --list <value>     List name
  -d, --due <value>      Due date
  -a, --alarm <value>    Alarm date
      --location <value> Location address for geofence trigger
      --radius <value>   Geofence radius in meters (default: 100)
  -n, --notes <value>    Notes
  -r, --repeat <value>   daily|weekly|biweekly|monthly|yearly|every N days/weeks/months/years
  -p, --priority <value> none|low|medium|high
      --leaving          Trigger when leaving location
```

Examples:

```bash
remindctl add "Buy milk"
remindctl add --title "Call mom" --list Personal --due tomorrow
remindctl add "Call mom" --due "2026-01-03 09:00" --alarm "2026-01-03 08:55"
remindctl add "Check mailbox" --location "1 Apple Park Way, Cupertino, CA"
remindctl add "Take vitamins" --due tomorrow --repeat daily
remindctl add "Review docs" --priority high
```

### remindctl edit

Edit a reminder. Use an index or ID prefix from `show` output.

```
remindctl edit <id> [options]
  -t, --title <value>   New title
  -l, --list <value>    Move to list
  -d, --due <value>     Set due date
  -a, --alarm <value>   Set alarm date
  -n, --notes <value>   Set notes
  -r, --repeat <value>  daily|weekly|biweekly|monthly|yearly|every N days/weeks/months/years
  -p, --priority <value> none|low|medium|high
      --clear-due       Clear due date
      --clear-alarm     Clear alarm
      --no-repeat       Remove recurrence
      --complete        Mark completed
      --incomplete      Mark incomplete
```

Examples:

```bash
remindctl edit 1 --title "New title"
remindctl edit 4A83 --due tomorrow
remindctl edit 4A83 --alarm "2026-01-03 08:55"
remindctl edit 4A83 --repeat weekly
remindctl edit 2 --priority high --notes "Call before noon"
remindctl edit 3 --clear-due --clear-alarm --no-repeat
```

### remindctl complete

Mark reminders complete. Use indexes or ID prefixes from `show`.

```
remindctl complete [ids] [options]
  -n, --dry-run   Preview without changes
```

Examples:

```bash
remindctl complete 1
remindctl complete 1 2 3
remindctl complete 4A83
```

### remindctl delete

Delete reminders. Use indexes or ID prefixes from `show`.

```
remindctl delete [ids] [options]
  -n, --dry-run   Preview without changes
  -f, --force      Skip confirmation
```

Examples:

```bash
remindctl delete 1
remindctl delete 4A83
remindctl delete 1 2 3 --force
```

### remindctl status

Show Reminders authorization status (no prompt).

```bash
remindctl status
remindctl status --json
remindctl status --plain
```

### remindctl authorize

Request Reminders access; triggers the permission prompt when available.

```bash
remindctl authorize
remindctl authorize --json
remindctl authorize --quiet
```

---

# ical

A fast, native macOS Calendar CLI built on EventKit. Full CRUD for calendar events, natural language dates, recurrence
support, import/export, and multiple output formats.

Global flags:

```
      --no-color        Disable color output
  -o, --output string   Output format: table, json, plain (default "table")
```

### ical add

Create a new calendar event (aliases: `create`, `new`). Title as argument or via `--title`. Use `-i` for interactive
mode.

```
ical add [title] [flags]
      --alert stringArray     Alert before event (e.g., 15m, 1h, 1d) — repeatable
  -a, --all-day               Create as all-day event
  -c, --calendar string       Calendar name
  -e, --end string            End date/time (default: start + 1h)
  -i, --interactive           Interactive mode with guided prompts
      --invite stringArray    Invite an attendee by email or "Name <email>" — repeatable
  -l, --location string       Location string
      --no-alert              Create with zero alerts (overrides calendar default alerts)
  -n, --notes string          Notes/description
  -r, --repeat string         Recurrence: daily, weekly, monthly, yearly
      --repeat-count int      Recurrence occurrence count
      --repeat-days string    Days for weekly recurrence (e.g., mon,wed,fri)
      --repeat-interval int   Recurrence interval (default 1)
      --repeat-until string   Recurrence end date
  -s, --start string          Start date/time (required)
      --timezone string       IANA timezone (e.g., America/New_York)
  -T, --title string          Event title
      --travel string         Travel time before the event (e.g., 30m, 1h)
  -u, --url string            URL to attach
```

Examples:

```bash
ical add "Sync with Sam" -s "tomorrow 10:00" -e "tomorrow 10:30" -c Work
ical add "Lunch" -s "noon" -a                              # all-day
ical add "Sprint planning" --start "2026-01-06 10:00" --repeat weekly --repeat-days mon,wed,fri
ical add "All-hands" -s "2026-01-06 17:00" --invite "sam@example.com" --invite "dee@example.com"
ical add "Flight" -s "2026-01-10 08:00" -e "2026-01-10 11:00" --travel 2h --alert 3h
```

### ical calendars

List, create, update, and delete calendars (alias: `cals`). Without a subcommand, lists all calendars. Subcommands:
`create`, `delete`, `list`, `update`.

```
ical calendars create [title]        # aliases: add, new
  -s, --source string   Account source (e.g., "iCloud", "Gmail")  [required]
  -T, --title string    Calendar title
      --color string     Calendar color (hex, e.g., '#FF6961')
  -i, --interactive      Interactive mode with guided prompts

ical calendars update [calendar name]   # aliases: edit, rename
  -T, --title string   New calendar title
      --color string    New calendar color (hex, e.g., '#FF6961')
  -i, --interactive     Interactive mode with guided prompts

ical calendars delete [calendar name]   # aliases: rm, remove
  -f, --force   Skip confirmation prompt

ical calendars list                     # aliases: ls
```

Examples:

```bash
ical calendars
ical calendars list -o json
ical calendars create "Side projects" --source iCloud --color '#FF6961'
ical calendars update "Old" --title "Personal"
ical calendars delete "Old" --force
```

### ical delete

Delete one or more events (aliases: `rm`, `remove`). Confirms by default.

- No args → interactive picker (`--from`/`--to`/`--days` control the range).
- One/multiple args → row number(s) from last listing, or full/partial event IDs.
- `--id` → exact full event ID, single event only.

```
ical delete [number or id...] [flags]
  -d, --days int      Number of days to show in picker (default 7)
  -f, --force         Skip confirmation prompt
      --from string   Start date for event picker
      --id string     Full event ID (exact match, no prefix search)
      --span string   For recurring events: this, future, or all (default "this")
      --to string     End date for event picker
```

Examples:

```bash
ical delete 1
ical delete 1 2 3 --force
ical delete 4A83 --span all      # delete whole recurring series
ical delete --id  ABC123DEF --span future
```

### ical export

Export events to JSON, CSV, or ICS format.

```
ical export [flags]
  -c, --calendar stringArray   Filter by calendar name (repeatable)
      --format string          Format: json, csv, ics (default "json")
  -f, --from string            Start date (default: 30 days ago)
      --output-file string     Write to file instead of stdout
  -t, --to string              End date (default: 30 days ahead)
```

Examples:

```bash
ical export --format ics --from "2026-01-01" --to "2026-12-31" --output-file year.ics
ical export --format csv -c Work -c Personal -o json
```

### ical free

Free/busy availability for one or more emails over a time range. Requires Exchange or Google Workspace (iCloud does not
support free/busy). Defaults to the next 24 hours.

```
ical free <email> [email...] [flags]
  -f, --from string   Start of the window (default: now)
  -t, --to string     End of the window (default: +24h)
```

Examples:

```bash
ical free sam@example.com
ical free sam@example.com dee@example.com --from "tomorrow 09:00" --to "tomorrow 17:00"
```

### ical import

Import events from JSON, CSV, or ICS files.

```
ical import [file] [flags]
  -c, --calendar string   Override target calendar for all events
      --dry-run           Preview without creating
  -f, --force             Skip confirmation prompt
```

Examples:

```bash
ical import year.ics --calendar Personal
ical import events.json --dry-run
```

### ical inbox

List pending event invitations (Calendar.app notification inbox).

```bash
ical inbox
```

### ical join

Open the video-conference link (Zoom, Meet, Teams, FaceTime, …) of an event.

- No args → pick the meeting happening now, else the next upcoming event with a conference link (searched over the next
  `--days` days).
- With an argument → row number from last listing, or full/partial event ID.

```
ical join [number or id] [flags]
  -d, --days int   How many days ahead to look for the next meeting (default 7)
  -p, --print      Print the conference link instead of opening it
```

Examples:

```bash
ical join                # join the current/next meeting
ical join 2              # join event at row 2 of last listing
ical join -p             # print the link instead of opening it
```

### ical list

List events within a date range (aliases: `ls`, `events`). Defaults to today if no range set. Dates accept natural
language or ISO 8601.

```
ical list [flags]
      --all-day                        Show only all-day events
  -a, --attendee string                Filter by attendee or organizer name/email
  -c, --calendar stringArray           Filter by calendar name (repeatable)
      --calendar-id string             Filter by calendar ID
      --exclude-calendar stringArray   Exclude calendars by name (repeatable)
  -f, --from string                    Start date (natural language or ISO 8601)
  -n, --limit int                      Max events to display
      --no-recurring                   Hide recurring events
  -s, --search string                  Search title, location, notes
      --sort string                    Sort by: start, end, title, calendar (default "start")
  -t, --to string                      End date (natural language or ISO 8601)
```

Examples:

```bash
ical list
ical list --from today --to "in 3 days"
ical list -c Work -c Personal --sort start
ical list -a sam@example.com --no-recurring -n 20
```

### ical rsvp

Set your RSVP status on an event invitation. First arg: `accepted|declined|tentative` (aliases `yes|no|maybe`). Second
arg: row number from last listing or full/partial event ID. No event arg → interactive picker. Sends your reply to the
organizer on server-backed calendars.

```
ical rsvp <accepted|declined|tentative> [number or id] [flags]
```

Examples:

```bash
ical inbox
ical rsvp accepted 3
ical rsvp declined 4A83
```

### ical search

Search events by title, location, and notes within a date range (aliases: `find`). Defaults: 30 days back to 30 days
ahead.

```
ical search [query] [flags]
  -a, --attendee string        Filter by attendee or organizer name/email
  -c, --calendar stringArray   Filter by calendar name (repeatable)
  -f, --from string            Start of search range (default: 30 days ago)
  -n, --limit int              Max results
      --no-recurring           Hide recurring events
  -t, --to string              End of search range (default: 30 days ahead)
```

Examples:

```bash
ical search "dentist"
ical search "standup" -c Work --from "2026-01-01"
```

### ical show

Display full details for a single event (aliases: `get`, `info`).

- No args → interactive picker (`--from`/`--to`/`--days` control the range).
- With an argument → row number from last listing, or full/partial event ID.
- `--id` → exact full event ID, no prefix search.

```
ical show [number or id] [flags]
  -d, --days int      Number of days to show in picker (default 7)
  -f, --from string   Start date for event picker (natural language or ISO 8601)
      --id string     Full event ID (exact match, no prefix search)
  -t, --to string     End date for event picker
```

Examples:

```bash
ical show 2
ical show 4A83
ical show --id ABC123DEF
```

### ical today

Shortcut for `ical list --from today --to tomorrow`. Same flags as `list` (no range flags).

```bash
ical today
ical today -c Work
ical today --all-day
```

### ical upcoming

Shortcut for `ical list --from today --to "in N days"` (aliases: `next`, `soon`).

```
ical upcoming [flags]
  -d, --days int   Number of days to look ahead (default 7)
  ... (same listing filters as `list`)
```

Examples:

```bash
ical upcoming
ical upcoming -d 14 -c Work
ical next -n 5
```

### ical update

Update an existing event (aliases: `edit`). Only specified fields change.

- No args → interactive picker to select the event.
- With an argument → row number from last listing, or full/partial event ID.
- `--id` → exact full event ID, no prefix search.
- `-i` → interactive mode with guided prompts.

```
ical update [number or id] [flags]
      --alert stringArray     Replace alerts (repeatable, 'none' to clear)
  -a, --all-day string        Set all-day (true/false)
  -c, --calendar string       Move to calendar (by name)
  -e, --end string            New end date/time
      --id string             Full event ID (exact match, no prefix search)
  -i, --interactive           Interactive mode with guided prompts
  -l, --location string       New location (empty to clear)
  -n, --notes string          New notes (empty to clear)
  -r, --repeat string         Set/change recurrence (none to remove)
      --repeat-count int      Change recurrence count
      --repeat-days string    Change recurrence days
      --repeat-interval int   Change recurrence interval (default 1)
      --repeat-until string   Change recurrence end date
      --span string           For recurring events: this or future (default "this")
  -s, --start string          New start date/time
      --timezone string       New timezone
  -T, --title string          New title
  -u, --url string            New URL (empty to clear)
```

Examples:

```bash
ical update 2 --title "Renamed event"
ical update 4A83 --start "tomorrow 14:00" --end "tomorrow 15:00"
ical update 4A83 --location "Conf room B" --alert 15m
ical update 4A83 --repeat weekly --repeat-days mon,wed,fri
ical update 4A83 --calendar Work --span future
ical update 4A83 --notes ""     # clear notes
```
