---
name: modern-cli
description: Preferred modern CLI alternatives for shell commands. Use whenever running file search, text search, or code refactoring. Prefer ripgrep over grep, fd over find, and ast-grep (sg) for structural code edits.
---

# Modern CLI Tools

When running shell commands, prefer these modern alternatives over legacy Unix tools. They are faster, more ergonomic, and produce better output.

| Instead of | Use | Why |
|---|---|---|
| `grep` / `grep -r` | `rg` (ripgrep) | Faster, respects `.gitignore`, recursive by default |
| `find` | `fd` | Simpler syntax, respects `.gitignore`, colorized output |
| `sed` | `sg run --rewrite` | AST-aware rewrites that don't break on comments or strings |
| Text-based code search | `rg` for strings/text | Fast and reliable |
| Structural code search | `sg` for syntax patterns | Understands code structure via AST |

## ripgrep (`rg`)

Text search in files. Recursive by default — no `-r` flag or `find | xargs grep` pipeline needed.

```bash
rg "pattern"                          # recursive search, respects .gitignore
rg "pattern" --type js                # filter by file type
rg "pattern" -g '*.ts'                # glob filter
rg "pattern" --hidden                 # include hidden files
rg "pattern" --json                   # machine-readable output
rg -l "pattern"                       # files with matches only
rg -c "pattern"                       # count matches per file
```

## fd

File search replacement for `find`. Simpler syntax, faster, respects `.gitignore`.

```bash
fd 'pattern'                          # find by name (substring match, not regex)
fd -e ts                              # filter by extension
fd -t f                               # files only (-t d for directories)
fd -g '*.test.ts'                     # glob pattern
fd --hidden                           # include hidden files
fd 'pattern' . --type f --exec wc -l  # pipe to other commands
```

`fd` uses substring matching by default. Pass `-E` / `--regex` for regular expressions.

## ast-grep (`sg`)

Structural code search and rewrite. Parses language AST, so searches understand syntax rather than matching raw text. Always prefer over `sed`, `awk`, or `grep` for code refactoring tasks.

### Search

```bash
sg run -p 'console.log($$$A)'                         # find all console.log calls
sg run -p 'console.log($$$A)' --lang js               # force language
sg run -p 'function $NAME($$$ARGS) { $$$BODY }'       # match function declarations
sg run -p 'if ($COND) { $$$BODY }' -p -A 2            # with surrounding context
sg run -p 'console.log($$$A)' --json                  # machine-readable output
```

### Rewrite (dry run — shows diff without modifying files)

```bash
sg run -p 'console.log($$$A)' --rewrite 'logger.info($$$A)'
sg run -p 'var $NAME = $INIT' --rewrite 'const $NAME = $INIT'
sg run -p 'let $NAME = $INIT' --rewrite 'const $NAME = $INIT'
sg run -p '$LIST.forEach($FUNC)' --rewrite 'for (const $VAR of $LIST) { $FUNC }'
```

### Rewrite (apply changes to files)

```bash
sg run -p 'console.log($$$A)' --rewrite 'logger.info($$$A)' --update-all
```

### Metavariable Patterns

| Pattern | Meaning |
|---------|---------|
| `$VAR` | Single AST node (identifier, expression, statement) |
| `$$VAR` | List of nodes at the same level (e.g., function arguments) |
| `$$$VAR` | List of nodes across levels (e.g., multiple statements in a block) |

`sg` auto-detects language from file extensions, so `--lang` is rarely needed.

## General Guidelines

- Prefer piping modern tools: `fd -e ts | xargs rg "pattern"` is fine.
- When refactoring code (rename, restructure, migration patterns), always prefer `sg run --rewrite` over `sed` — AST-aware rewrites won't silently corrupt comments, strings, or partial matches.
- Use `rg` for text search, `fd` for file search, and `sg` when the edit requires understanding code structure.
- All of these tools are faster and produce cleaner output than their legacy equivalents.
