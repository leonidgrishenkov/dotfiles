---
description: Review and commit staged git changes
---

Review the staged changes (`git diff --cached`) and summarize them.

After that, commit changes with picked commit message.

# Message Style

For commit message use Conventional Commits Message style. Keep it short, do not dive too deep into details when
describing. If there are a few good variants for the message, ask the user to pick one, use Questionnaire tool
when questioning.

# GPG Signing

If GPG signing failed, stop operation and warn user about it.
