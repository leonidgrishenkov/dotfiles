---
name: anki
description: Inspect, query, and manipulate a local Anki flashcard collection using the Anki Python library. Use when the user asks about their Anki decks, cards, notes, review stats, or wants to programmatically add/update/delete flashcards.
---

# Anki Python Library

## Running scripts

Always use `uv` to run scripts — it handles the `anki` dependency automatically:

```sh
uv run --with anki python -c << 'PYEOF'
from anki.collection import Collection
...
PYEOF
```

Or:

```sh
uv run --with anki ./your_script.py
```

## Opening the collection

**macOS path:**
```
~/Library/Application Support/Anki2/User 1/collection.anki2
```

```python
from anki.collection import Collection
from pathlib import Path

path = Path.home() / "Library/Application Support/Anki2/User 1/collection.anki2"

col = Collection(path)
```

## Key API patterns

```python
# Decks
for d in col.decks.all_names_and_ids():
    count = col.decks.card_count(d.id, include_subdecks=True)

# Counts
col.card_count()   # total cards
col.note_count()   # total notes

# Search notes (Anki query syntax)
note_ids = col.find_notes("deck:English is:new")
note = col.get_note(note_id)
print(note.fields)            # list of field values
print(note.note_type()["name"])  # e.g. "Basic", "Cloze"

# Direct SQL via col.db
col.db.scalar("SELECT count() FROM cards WHERE queue = 0")  # new cards
col.db.all("SELECT id, flds FROM notes LIMIT 10")
```

For full API reference — tables, card states, search syntax, and more examples — see [REFERENCE.md](REFERENCE.md).
