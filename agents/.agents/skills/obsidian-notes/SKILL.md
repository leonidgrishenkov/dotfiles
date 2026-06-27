---
name: obsidian-notes
description: >
  Search, create, and manage notes in the Obsidian vault. Use when user wants to find, create, or organize their
  personal notes in Obsidian.
---

# Obsidian

## Vault

- **Location:** `~/Filen/Obsidian/main-vault`
- **Base/** — all knowledge notes (primary location for new notes)
- **Daily/** — daily journal and log notes
- **Template/** — note templates (do not edit)
- **Attachments/** — images and binary files (do not edit). Legacy images may be in `Base/Attachments/`; do not place new ones there.
- **Excalidraw/** — Excalidraw diagram files (do not edit)

## Obsidian CLI

Use the `obsidian` CLI as the **primary tool** for all vault operations. Prefer it over raw file tools (`fd`, `rg`, `cat`). Run `obsidian help <command>` for details on any command.

### Quick reference

| Task | Command |
|---|---|
| Search content | `obsidian search query="<text>"` |
| Search with context | `obsidian search:context query="<text>"` |
| List files | `obsidian files [folder=<path>] [ext=<ext>]` |
| Read a note | `obsidian read file="<name>"` / `obsidian read path="<path>"` |
| Create a note | `obsidian create name="<title>" path="Base/<title>.md" content="<text>"` |
| Append / prepend | `obsidian append file="<name>" content="<text>"` |
| Rename / move | `obsidian rename file="<name>" name="<new>"` / `obsidian move file="<name>" to="<folder>"` |
| Delete | `obsidian delete file="<name>"` |
| Links / backlinks | `obsidian links file="<name>"` / `obsidian backlinks file="<name>"` |
| Properties (list) | `obsidian properties file="<name>"` |
| Set a property | `obsidian property:set name="<p>" value="<v>" file="<n>"` |
| Tags | `obsidian tags [counts] [sort=count]` |
| Daily note | `obsidian daily:read` / `obsidian daily:append content="<text>"` |
| Tasks | `obsidian tasks [done\|todo]` |
| Vault info | `obsidian vault` |

- `file=` resolves by name (like wikilinks); `path=` is vault-relative (e.g. `Base/My Note.md`).
- Quote values with spaces: `file="My Note"`. Use `\n` for newlines, `\t` for tabs in `content=`.
- Add `format=json` to `search`/`search:context` for clean, parseable output; add `total` for just a count.
- `files` supports `folder=` / `ext=` / `total` but **not** `limit=` — filter with `folder` instead.

Full command list → [REFERENCE.md](REFERENCE.md#cli-reference)

### Fallback to raw file tools

Use `fd` / `rg` only when the CLI can't help (regex patterns, non-indexed files):

```bash
rg -i "pattern" --no-ignore -l ~/Filen/Obsidian/main-vault
fd -i "substring" -e md --no-ignore ~/Filen/Obsidian/main-vault
```

## Workflows

### Search for notes

```bash
obsidian search query="git worktree"
obsidian search:context query="git worktree"   # with matching line context
obsidian search query="keyword" path="Base"     # limit to a folder
obsidian search query="keyword" total           # just the match count
obsidian files folder="Base" ext="md"          # list markdown files in Base
```

### Create new notes

1. Deduplicate — `obsidian search query="<topic>"`
2. Create in `Base/` unless a different folder is clearly appropriate
3. Follow [Note format](REFERENCE.md#note-format) rules (frontmatter, headings, linking, etc.)
4. Never modify files in `Template/`, `Attachments/`, or `Excalidraw/`

### Manage notes

1. Always read before editing: `obsidian read file="<name>"`
2. Use `obsidian append` / `obsidian prepend` for additions; use `edit` tool for targeted replacements
3. Use `obsidian property:set` to update frontmatter properties; use `obsidian properties file="<name>"` to read them back
4. Ask user approval before deleting or replacing substantial content

### After creating a note

1. Search for related notes and add `[[wikilinks]]` where relevant
2. Verify wikilink targets exist: `obsidian read file="<target>"` (fails cleanly if missing)
3. Notify the user of the created note path
