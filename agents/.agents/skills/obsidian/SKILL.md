---
name: obsidian
description: Search, create, and manage notes in the Obsidian vault. Use when user wants to find, create, or organize notes in Obsidian.
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

## Note Format

### Title

- Title case for all note names
- No folders for organization - use links

### Frontmatter

Every note uses this YAML frontmatter structure:

```yaml
---
title:
aliases: []
created-at: YYYY-MM-DD HH:mm:ssZ
modified-at: YYYY-MM-DD HH:mm:ssZ
parent: []
extras: []
categories: []
description:
---
```

Field rules:

- `title`: the note's human-readable title (matches the file name)
- `aliases`: DO NOT FILL
- `created-at` / `modified-at`: format `2026-04-18 14:30:00+03:00` (in Europe/Moscow timezone)
- `parent`: DO NOT FILL
- `categories`: DO NOT FILL
- `description`: DO NOT FILL

When creating a new note always fill `created-at` and `modified-at` with current date and time. When editing an existing
note, always update `modified-at` to the current date/time.

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

## Workflows

TBD


# Rules

- Create the file in `Base/` unless a different folder is clearly appropriate
- Check whether a note on the topic already exists before creating one (use glob)
- Never delete content without an explicit instruction to do so
- Never modify files in `Template/`, `Attachments/`, or `Excalidraw/`
- Always read the note before editing it
- Keep new note filenames concise and descriptive

NOTE: for inspiration: https://github.com/mattpocock/skills/blob/main/skills/personal/obsidian-vault/SKILL.md
