# Obsidian CLI — Full Reference

## CLI reference

Run `obsidian help <command>` for details on any command.

### Files and content

| Command       | Description           | Key options                                            |
| ------------- | --------------------- | ------------------------------------------------------ |
| `files`       | List vault files      | `folder=<path>`, `ext=<ext>`, `total`                  |
| `read`        | Read file contents    | `file=<name>`, `path=<path>`                           |
| `create`      | Create a new file     | `name=`, `path=`, `content=`, `template=`, `overwrite` |
| `append`      | Append content        | `file=`, `content=` (required), `inline`               |
| `prepend`     | Prepend content       | `file=`, `content=` (required), `inline`               |
| `delete`      | Delete a file         | `file=`, `permanent`                                   |
| `move`        | Move a file           | `file=`, `to=<path>` (required)                        |
| `rename`      | Rename a file         | `file=`, `name=<new>` (required)                       |
| `open`        | Open a file           | `file=`, `newtab`                                      |
| `file`        | Show file info        | `file=`, `path=`                                       |
| `recents`     | Recently opened files | `total`                                                |
| `random`      | Open a random note    | `folder=`, `newtab`                                    |
| `random:read` | Read a random note    | `folder=`                                              |
| `wordcount`   | Word / char count     | `file=`, `words`, `characters`                         |

### Search

| Command          | Description              | Key options                                                                  |
| ---------------- | ------------------------ | ---------------------------------------------------------------------------- |
| `search`         | Search vault text        | `query=` (required), `path=`, `limit=`, `total`, `case`, `format=text\|json` |
| `search:context` | Search with line context | same as `search`                                                             |
| `search:open`    | Open search view in UI   | `query=`                                                                     |

### Links and graph

| Command      | Description                  | Key options                                         |
| ------------ | ---------------------------- | --------------------------------------------------- |
| `links`      | Outgoing links from a file   | `file=`, `total`                                    |
| `backlinks`  | Incoming links to a file     | `file=`, `counts`, `total`, `format=json\|tsv\|csv` |
| `orphans`    | Files with no backlinks      | `total`, `all`                                      |
| `deadends`   | Files with no outgoing links | `total`, `all`                                      |
| `unresolved` | Broken / unresolved links    | `total`, `counts`, `verbose`                        |
| `aliases`    | List aliases                 | `file=`, `total`, `verbose`                         |

### Properties and tags

| Command           | Description           | Key options                                                                     |
| ----------------- | --------------------- | ------------------------------------------------------------------------------- |
| `properties`      | List vault properties | `file=`, `name=`, `total`, `sort=count`, `counts`                               |
| `property:read`   | Read a property value | `name=` (required), `file=`                                                     |
| `property:set`    | Set a property        | `name=`, `value=`, `type=text\|list\|number\|checkbox\|date\|datetime`, `file=` |
| `property:remove` | Remove a property     | `name=` (required), `file=`                                                     |
| `tags`            | List tags             | `file=`, `total`, `counts`, `sort=count`                                        |
| `tag`             | Tag info              | `name=` (required), `total`, `verbose`                                          |

### Structure and outline

| Command   | Description   | Key options                                     |
| --------- | ------------- | ----------------------------------------------- |
| `outline` | File headings | `file=`, `format=tree\|md\|json`, `total`       |
| `folders` | List folders  | `folder=`, `total`                              |
| `folder`  | Folder info   | `path=` (required), `info=files\|folders\|size` |

### Daily notes

| Command         | Description           | Key options                             |
| --------------- | --------------------- | --------------------------------------- |
| `daily`         | Open daily note       | `paneType=tab\|split\|window`           |
| `daily:read`    | Read daily note       | —                                       |
| `daily:append`  | Append to daily note  | `content=` (required), `inline`, `open` |
| `daily:prepend` | Prepend to daily note | `content=` (required), `inline`, `open` |
| `daily:path`    | Get daily note path   | —                                       |

### Tasks

| Command | Description          | Key options                                                             |
| ------- | -------------------- | ----------------------------------------------------------------------- |
| `tasks` | List tasks           | `file=`, `path=`, `done`, `todo`, `status="<char>"`, `total`, `verbose` |
| `task`  | Show / update a task | `ref=<path:line>`, `toggle`, `done`, `todo`, `status=`                  |

### Templates

| Command           | Description                      | Key options                             |
| ----------------- | -------------------------------- | --------------------------------------- |
| `templates`       | List templates                   | `total`                                 |
| `template:read`   | Read template content            | `name=` (required), `resolve`, `title=` |
| `template:insert` | Insert template into active file | `name=` (required)                      |

### History and diff

| Command           | Description              | Key options                    |
| ----------------- | ------------------------ | ------------------------------ |
| `history`         | List file versions       | `file=`                        |
| `history:read`    | Read a version           | `file=`, `version=<n>`         |
| `history:restore` | Restore a version        | `file=`, `version=` (required) |
| `history:list`    | Files with history       | —                              |
| `diff`            | Diff local/sync versions | `file=`, `from=<n>`, `to=<n>`  |

### Bookmarks, plugins, themes, workspace

| Command                             | Description           | Key options                          |
| ----------------------------------- | --------------------- | ------------------------------------ |
| `bookmark`                          | Add a bookmark        | `file=`, `url=`, `title=`            |
| `bookmarks`                         | List bookmarks        | `total`, `verbose`                   |
| `plugins`                           | List plugins          | `filter=core\|community`, `versions` |
| `plugin:enable` / `plugin:disable`  | Toggle plugin         | `id=` (required)                     |
| `themes`                            | List themes           | `versions`                           |
| `theme:set`                         | Set active theme      | `name=` (required)                   |
| `workspaces`                        | List saved workspaces | `total`                              |
| `workspace:save` / `workspace:load` | Save / load workspace | `name=`                              |

### Vault

| Command   | Description       | Key options                             |
| --------- | ----------------- | --------------------------------------- |
| `vault`   | Vault info        | `info=name\|path\|files\|folders\|size` |
| `vaults`  | List known vaults | `total`, `verbose`                      |
| `version` | Obsidian version  | —                                       |
| `reload`  | Reload vault      | —                                       |
| `restart` | Restart Obsidian  | —                                       |

### CLI usage notes

- `file=` resolves by name (like wikilinks); `path=` is the exact vault-relative path (e.g. `Base/My Note.md`).
- Quote values containing spaces: `file="My Note"`.
- Use `\n` for newlines and `\t` for tabs inside `content=` values.
- Add `format=json` where available for machine-readable output.
- Most commands default to the active file when `file=`/`path=` is omitted.
- `property:set` reliably writes frontmatter, but `property:read` is unreliable for hyphenated names (e.g. `modified-at`). To read properties back, use `obsidian properties file="<name>"` instead.
- `files` does **not** support `limit=`. Filter with `folder=` / `ext=` / `total`.

---

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
- `created-at` / `modified-at` — ISO 8601 with timezone offset, e.g. `2026-04-18T14:30:00+03:00`
  - Prefer computing from the agent's current date context
  - If uncertain of timezone, run `date -Iseconds` as fallback
- `aliases`, `parent`, `categories` — DO NOT FILL; reserved fields
- `description` — leave empty unless the user explicitly requests it

When **creating** a note, always fill `created-at` and `modified-at`. When **editing**, always update `modified-at`.

### Headings

- All notes should start with H1 that contains the note title
- Do not add numbers to headings

### Linking

- Use Obsidian `[[wikilinks]]` syntax: `[[Note Title]]`
- Before adding a wikilink, confirm the target file exists: `obsidian read file="<target>"`

### Tags

- Do not use inline `#tags`. Use the vault structure and wikilinks for organization instead.

### Content and style

- Notes may be written in Russian or English depending on the topic and user request
- Keep terminology in English when writing in Russian
- Prefer focused, self-contained notes over sprawling ones
- If a topic spans multiple subtopics, consider splitting into separate linked notes

### Code

- Surround inline code with backticks
- For code blocks use standard markdown fenced syntax:
  ```python
  print("hey there!")
  ```
