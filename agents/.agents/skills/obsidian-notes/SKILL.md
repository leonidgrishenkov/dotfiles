---
name: obsidian-notes
description: Search, create, and manage notes in the Obsidian vault. Use when user wants to find, create, or organize their personal notes in Obsidian.
---

# Obsidian Notes

## Vault

### Location

Placed here: `~/Filen/Obsidian/main-vault`.

### Structure

Vault consists of these folders:

- `Base/` — all knowledge notes (primary location for new notes)
- `Daily/` — daily journal and log notes
- `Template/` — note templates (do not edit)
- `Attachments/` — images and binary files (do not edit). Some legacy images are located in `Base/Attachments/`, do not place new images there.
- `Excalidraw/` — Excalidraw diagram files (do not edit)

## Workflows

### Decision flow

- *"Write a note about X"* → check existing → create in `Base/`
- *"Summarize our discussion as a note"* → extract key points → create note
- *"Find notes about X"* → search vault → present results
- *"Update note X"* → read first → edit with user approval for deletions
- *"Organize / categorize notes"* → read targets → propose actions, confirm before executing

### Search for notes

Before creating or referencing a note, check if one already exists:

1. Search by filename: `fd -e md "<keyword>" ~/Filen/Obsidian/main-vault/`
2. Search by content: `rg "<keyword>" ~/Filen/Obsidian/main-vault/ -l`
3. If a matching note exists, link to it instead of creating a duplicate.

### Create new notes

1. Create the file in `Base/` unless a different folder is clearly appropriate
2. Keep new note filenames concise and descriptive
3. Check whether a note on the topic already exists before creating one
4. Update frontmatter fields
5. Follow Note Format rules for note content
6. Never modify files in `Template/`, `Attachments/`, or `Excalidraw/`

### Managing notes

1. Always read the note before editing it
2. If you plan to delete/replace existing note or content in the note — ask for user approval

### After creating a note

1. Search for existing related notes and add `[[wikilinks]]` where relevant
2. Notify the user of the created note path

## Note format

### Title

- Use title case for all note names and filenames:
  - Capitalize major words: **Running Pi Coding Agent with Extensions**
  - Lowercase articles, prepositions, conjunctions: *a, an, the, in, with, of, on, for*
- No folders for notes organization — use links.

### Frontmatter

Every note uses this YAML frontmatter structure:

```yaml
---
title:
created-at: YYYY-MM-DDTHH:mm:ss±HH:mm
modified-at: YYYY-MM-DDTHH:mm:ss±HH:mm
aliases: []          # DO NOT FILL — reserved
parent: []           # DO NOT FILL — reserved
categories: []       # DO NOT FILL — reserved
description:         # DO NOT FILL — use only when explicitly requested
---
```

Field rules:

- `title` — the note's human-readable title (matches the file name)
- `created-at` / `modified-at` — date and time in ISO 8601 with timezone offset, e.g. `2026-04-18T14:30:00+03:00`
  - Prefer computing the timestamp from the agent's current date context
  - If uncertain of timezone, run `date -Iseconds` as fallback
- `aliases`, `parent`, `categories` — DO NOT FILL; reserved fields
- `description` — leave empty unless the user explicitly requests it

When creating a new note, always fill `created-at` and `modified-at` with the current date and time. When editing an existing note, always update `modified-at` to the current date/time.

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
