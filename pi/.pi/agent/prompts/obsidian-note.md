---
description: Create or modify notes in Obsidian
argument-hint: "<TOPIC>"
---

# Task

User request: $@

Create or modify note in Obsidian according to user's request. If user didn't specify any arguments, prompt user
via Questionnaire tool what they want excatly:
1. Summurise and write current discussion as a note
2. Write a topic or task for a note in the next message

# Vault Structure

The vault root is in `~/Filen/Obsidian/main-vault/`.

Folders:

- `Base/` — all knowledge notes (primary location for new notes)
- `Daily/` — daily journal and log notes
- `Template/` — note templates (do not edit)
- `Attachments/` — images and binary files (do not edit)
- `Excalidraw/` — diagram files (do not edit)

# Note Format

## Frontmatter

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

## Headings

Any note should always start with H1 contains title.

## Wikilinks

Use `[[Note Name]]` syntax for internal links. The note name must exactly match the target filename (without `.md`).
Before adding a wikilink, confirm the target file exists in Vault with glob.

## Content and Style

Notes may be written in Russian or English depending on the topic and user request. If using Russian keep terminology in
English.

## Code

Surround inline code with backticks.

For code-blocks use standard markdown syntax. For example:

```python
print('hey there!')
```

# Rules

- Create the file in `Base/` unless a different folder is clearly appropriate
- Check whether a note on the topic already exists before creating one (use glob)
- Never delete content without an explicit instruction to do so
- Never modify files in `Template/`, `Attachments/`, or `Excalidraw/`
- Always read the note before editing it
- Keep new note filenames concise and descriptive
