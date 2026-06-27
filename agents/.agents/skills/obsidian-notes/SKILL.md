---
name: obsidian-notes
description: >
  Search, create, and manage notes in the Obsidian vault. Use when user wants to find, create, or organize their
  personal notes in Obsidian.
---

# Obsidian

## Vault

### Location

Placed here: `~/Filen/Obsidian/main-vault`.

### Structure

Vault consists of these folders:

- `Base/` — all knowledge notes (primary location for new notes)
- `Daily/` — daily journal and log notes
- `Template/` — note templates (do not edit)
- `Attachments/` — images and binary files (do not edit). Some legacy images are located in `Base/Attachments/`, do not
  place new images there.
- `Excalidraw/` — Excalidraw diagram files (do not edit)

## Obsidian CLI

The `obsidian` CLI is the **primary tool** for all vault operations. Prefer it over raw file tools (`fd`, `rg`, `cat`)
for searching, reading, creating, and managing notes. Run `obsidian help <command>` for details on any command.

### Key commands reference

| Task                              | Command                                                                                                                  |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Search vault content              | `obsidian search query="<text>"`                                                                                         |
| Search with context               | `obsidian search:context query="<text>"`                                                                                 |
| List files (optionally by folder) | `obsidian files [folder=<path>]`                                                                                         |
| Read a note by name               | `obsidian read file="<name>"`                                                                                            |
| Read a note by path               | `obsidian read path="<path>"`                                                                                            |
| Create a note                     | `obsidian create name="<title>" path="Base/<title>.md" content="<text>"`                                                 |
| Append to a note                  | `obsidian append file="<name>" content="<text>"`                                                                         |
| Prepend to a note                 | `obsidian prepend file="<name>" content="<text>"`                                                                        |
| Rename / move                     | `obsidian rename file="<name>" name="<new>"` / `obsidian move file="<name>" to="<folder>"`                               |
| Delete a note                     | `obsidian delete file="<name>"`                                                                                          |
| Show outgoing links               | `obsidian links file="<name>"`                                                                                           |
| Show backlinks                    | `obsidian backlinks file="<name>"`                                                                                       |
| List / query tags                 | `obsidian tags [counts] [sort=count]`                                                                                    |
| Read / set properties             | `obsidian property:read name="<prop>" file="<name>"` / `obsidian property:set name="<prop>" value="<val>" file="<name>"` |
| Outline (headings)                | `obsidian outline file="<name>"`                                                                                         |
| Word count                        | `obsidian wordcount file="<name>"`                                                                                       |
| Find orphans (no backlinks)       | `obsidian orphans`                                                                                                       |
| Find dead ends (no outlinks)      | `obsidian deadends`                                                                                                      |
| List unresolved links             | `obsidian unresolved`                                                                                                    |
| Read daily note                   | `obsidian daily:read`                                                                                                    |
| Append to daily note              | `obsidian daily:append content="<text>"`                                                                                 |
| List tasks                        | `obsidian tasks [done\|todo]`                                                                                            |
| Vault info                        | `obsidian vault`                                                                                                         |

**Notes on CLI usage:**

- `file=` resolves by name (like wikilinks); `path=` is the exact vault-relative path (e.g. `Base/My Note.md`).
- Quote values containing spaces: `file="My Note"`.
- Use `\n` for newlines and `\t` for tabs inside `content=` values.
- Add `format=json` where available for machine-readable output.

### Fallback to raw file tools

Use `fd` / `rg` only when the CLI lacks the needed capability:

- Regex or complex pattern matching (the CLI search is plain-text only)
- Searching inside Excalidraw or other non-indexed files

```bash
# Fallback: regex search
rg -i "pattern" --no-ignore -l ~/Filen/Obsidian/main-vault

# Fallback: filename glob
fd -i "substring" -e md --no-ignore ~/Filen/Obsidian/main-vault
```

## Workflows

### Search for notes

```bash
# Search by content — returns matching file names
obsidian search query="git worktree"

# Search with surrounding context lines
obsidian search:context query="git worktree"

# Limit search to a specific folder
obsidian search query="keyword" path="Base"

# List files in a folder
obsidian files folder="Base"
```

### Create new notes

1. Search first: `obsidian search query="<topic>"` to check whether a note already exists
2. Create in `Base/` unless a different folder is clearly appropriate:
   ```bash
   obsidian create name="<Title>" path="Base/<Title>.md" content="<full note content>"
   ```
3. Keep filenames concise and descriptive
4. Follow Note Format rules for note content (frontmatter, headings, linking, etc.)
5. Never modify files in `Template/`, `Attachments/`, or `Excalidraw/`

### Managing notes

1. Always read the note before editing: `obsidian read file="<name>"`
2. Use `obsidian append` / `obsidian prepend` for adding content; use the `edit` tool for targeted replacements
3. Use `obsidian property:set` to update frontmatter properties
4. If you plan to delete/replace an existing note or substantial content — ask for user approval first

### After creating a note

1. Search for related notes: `obsidian search query="<keywords>"` and add `[[wikilinks]]` where relevant
2. Verify the target of every wikilink exists: `obsidian read file="<target>"` (will fail if missing)
3. Notify the user of the created note path

## Note format

### Title

- Use title case for all note names and filenames:
  - Capitalize major words: **Running Pi Coding Agent with Extensions**
  - Lowercase articles, prepositions, conjunctions: _a, an, the, in, with, of, on, for_
- No folders for notes organization — use links.

### Frontmatter

Every note uses this YAML frontmatter structure:

```yaml
---
title:
created-at: YYYY-MM-DDTHH:mm:ss±HH:mm
modified-at: YYYY-MM-DDTHH:mm:ss±HH:mm
aliases: [] # DO NOT FILL — reserved
parent: [] # DO NOT FILL — reserved
categories: [] # DO NOT FILL — reserved
description: # DO NOT FILL — use only when explicitly requested
---
```

Field rules:

- `title` — the note's human-readable title (matches the file name)
- `created-at` / `modified-at` — date and time in ISO 8601 with timezone offset, e.g. `2026-04-18T14:30:00+03:00`
  - Prefer computing the timestamp from the agent's current date context
  - If uncertain of timezone, run `date -Iseconds` as fallback
- `aliases`, `parent`, `categories` — DO NOT FILL; reserved fields
- `description` — leave empty unless the user explicitly requests it

When creating a new note, always fill `created-at` and `modified-at` with the current date and time. When editing an
existing note, always update `modified-at` to the current date/time.

### Headings

- All notes should start with H1 that contains the note title
- Do not add numbers to headings

### Linking

- Use Obsidian `[[wikilinks]]` syntax: `[[Note Title]]`
- Before adding a wikilink, confirm the target file exists in the vault

### Tags

- Do not use inline `#tags`. Use the vault structure and wikilinks for organization instead.

### Content and style

- Notes may be written in Russian or English depending on the topic and user request
- Keep terminology in English when writing in Russian
- Prefer focused, self-contained notes over sprawling ones
- If a topic spans multiple subtopics, consider splitting into separate linked notes

### Code

- Surround inline code with backticks
- For code-blocks use standard markdown syntax, for example:
  ```python
  print("hey there!")
  ```
