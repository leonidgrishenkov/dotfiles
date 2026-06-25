---
name: python
description:
  Use uv for Python instead of the system interpreter. Use when running Python scripts, creating or managing Python
  projects, installing packages, or managing virtual environments.
---

# Python

## Key Rules

1. **Prefer `uv` over the system `python`/`pip`.** Do not call bare `python` or `pip` against the system interpreter.
   `uv` is faster, self-contained, and manages its own Python builds — no system Python, pyenv, or global venv needed.
2. **Run scripts with `uv run`.** It auto-creates/uses the project venv — no manual `source .venv/bin/activate` needed.
3. **Manage Python versions with `uv python`**, not `pyenv` or system installs.
4. **Manage dependencies with `uv add` / `uv sync`** (writes `pyproject.toml` + `uv.lock`), not `pip install`.

## Quick Command Map

| Instead of                        | Use                                  |
| --------------------------------- | ------------------------------------ |
| `python script.py`                | `uv run python script.py`            |
| `python -m venv .venv`            | `uv venv`                            |
| `pip install pkg`                 | `uv add pkg`                         |
| `pip install -r requirements.txt` | `uv pip install -r requirements.txt` |
| `python -m pytest`                | `uv run pytest`                      |
| `pyenv install 3.12`              | `uv python install 3.12`             |
| `pipx run ruff`                   | `uvx ruff`                           |

## Common Workflows

### Run a one-off script

```bash
uv run python script.py
# With an ephemeral dependency (no project needed):
uv run --with requests python script.py
```

### Create a new project

```bash
uv init my-project
cd my-project
uv python pin 3.12
uv add requests pydantic
uv run python main.py
```

### Work in an existing project

```bash
uv sync                       # install from uv.lock (creates venv automatically)
uv run pytest
uv add new-package
```

### Run a CLI tool without installing it globally

```bash
uvx ruff check .
uvx black .
```

### Scripts bundled in a skill

Run Python scripts shipped inside a skill (e.g. `scripts/`) with `uv run` — the `pdf` skill already follows this
pattern:

```bash
uv run scripts/some_script.py
```

## Notes

- `uv run` isolates execution — prefer it over manually activating virtual environments.
- `uvx` (alias for `uv tool run`) runs a tool in an isolated, temporary environment.
- Keep `uv.lock` committed for reproducible installs; use `uv sync --frozen` in CI.

## Reference

For full uv usage — lockfiles, Docker/CI integration, monorepos, migration from pip/poetry/pip-tools, performance
tuning, troubleshooting, and the complete command reference — see the bundled uv skill:

- [uv-package-manager/SKILL.md](uv-package-manager/SKILL.md) — core concepts, install, venvs, package & Python version
  management, `pyproject.toml` config.
- [uv-package-manager/references/advanced-patterns.md](uv-package-manager/references/advanced-patterns.md) — advanced
  workflows, comparisons, and the full command reference.
