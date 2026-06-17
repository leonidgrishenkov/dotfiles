---
name: obsidian-notes
description: Search, create, and manage notes in the Obsidian vault. Use when user wants to find, create, or organize their personal notes in Obsidian.
---

# Obsidian

## Vault

### Localtion

Placed here: `~/Filen/Obsidian/main-vault`.

### Structure

Vault consists of there folders:

- `Base/` — all knowledge notes (primary location for new notes)
- `Daily/` — daily journal and log notes
- `Template/` — note templates (do not edit)
- `Attachments/` — images and binary files (do not edit). Some of images located there `Base/Attachments`, but it's
legacy, do not place new images there.
- `Excalidraw/` — Excalidraw diagram files (do not edit)

## Workflows

### Search for Notes

Or use Grep/Glob tools directly on the vault path.

### Create new Notes

1. Create the file in `Base/` unless a different folder is clearly appropriate
2. Keep new note filenames concise and descriptive
3. Check whether a note on the topic already exists before creating one
4. Update frontmatter fields
Follow Note Format rules for note content
Never modify files in `Template/`, `Attachments/`, or `Excalidraw/`

### Managing Notes

1. Always read the note before editing it
- If you plan to delete/replace existing note or content in the note - ask for user approaval.

## Note Format

### Title

- Title case for all note names
- No folders for notes organization - use links.

### Frontmatter

Every note uses this YAML frontmatter structure:

```yaml
---
title:
aliases: []
created-at: YYYY-MM-DDTHH:mm:ssZ
modified-at: YYYY-MM-DDTHH:mm:ssZ
parent: []
extras: []
categories: []
description:
---
```

Field rules:

- `title`: the note's human-readable title (matches the file name)
- `aliases`: DO NOT FILL
- `created-at` / `modified-at`: current date and time in ISO 8601 format (e.g. `2026-04-18T14:30:00+03:00`).
- `parent`: DO NOT FILL
- `categories`: DO NOT FILL
- `description`: DO NOT FILL

When creating a new note always fill `created-at` and `modified-at` with current date and time. When editing an existing
note, always update `modified-at` to the current date/time.

To get current datetime value run (plaform independent): `date -Iseconds`.

### Headings

- All notes should start with H1, that contains note title
- Do not add number to heading

### Linking

- Use Obsidian `[[wikilinks]]` syntax: `[[Note Title]]`
- Before adding a wikilink, confirm the target file exists in Vault.

### Content and Style

- Notes may be written in Russian or English depending on the topic and user request
- Keep terminology in English when using Russian

### Code

- Surround inline code with backticks.
- For code-blocks use standard markdown syntax. For example:
    ```python
    print('hey there!')
    ```
