---
description: Review staged git changes, create a commit message and commit
---

# Git Commit

## Workflow

- Review the staged changes (`git diff --cached`) and create a commit message based on them.
Use Conventional Commits Message style. Keep it short and descriptive.
- Commit changes with picked commit message.

## Rules

- Do not sign commit message with GPG explicitly. It should only happen automatically if configured so.
- When any error occured, stop current operation, describe error to the user and let them decide what to do next.
