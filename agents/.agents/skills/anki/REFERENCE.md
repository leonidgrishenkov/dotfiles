# Anki Python API Reference

## Database schema (SQLite — access via `col.db`)

### `cards` table

| Column | Meaning                                    |
| ------ | ------------------------------------------ |
| id     | Card ID (epoch ms timestamp)               |
| nid    | Note ID (foreign key)                      |
| did    | Deck ID                                    |
| ord    | Card ordinal (template index)              |
| type   | 0=new, 1=learning, 2=review, 3=relearning  |
| queue  | See "Card states" below                    |
| due    | Due value (queue-dependent interpretation) |
| ivl    | Interval in days (review cards)            |
| factor | Ease factor × 1000 (e.g. 2500 = 250%)      |
| reps   | Number of reviews                          |
| lapses | Number of lapses                           |

### `notes` table

| Column | Meaning                                          |
| ------ | ------------------------------------------------ |
| id     | Note ID                                          |
| mid    | Model (note type) ID                             |
| flds   | Field values separated by `\x1f`                 |
| tags   | Space-separated tags with leading/trailing space |

### Card states (`cards.queue`)

| Value | State                                     |
| ----- | ----------------------------------------- |
| -3    | Buried manually (pre-scheduler)           |
| -2    | Suspended                                 |
| -1    | Buried by sibling                         |
| 0     | New                                       |
| 1     | Learning                                  |
| 2     | Review                                    |
| 3     | Day-learn (learning with day-based steps) |
| 4     | Preview                                   |

## Search syntax (pass to `col.find_notes()` or `col.find_cards()`)

```python
col.find_notes("deck:English")              # cards in a deck
col.find_notes("deck:English is:new")       # new cards
col.find_notes("deck:English is:due")       # due cards
col.find_notes("tag:vocabulary")            # by tag
col.find_notes('"some text"')               # full-text search
col.find_notes("added:7")                   # added in last 7 days
col.find_notes("rated:1:hard")              # rated Hard in last 1 day
col.find_notes("prop:ivl>=21")             # interval ≥ 21 days
col.find_notes("prop:ease<2")              # ease < 200%
col.find_notes("-is:suspended -is:buried")  # exclude suspended/buried
```

Combine freely: `"deck:English is:review -is:due"`

## Practical query recipes

### Cards due today

```python
due = col.db.scalar(
    "SELECT count() FROM cards WHERE due <= ? AND queue > 0",
    col.sched.today
)
```

### Card state breakdown

```python
from collections import Counter
states = Counter()
for c in col.find_cards(""):
    card = col.get_card(c)
    # card.type: 0=new, 1=learning, 2=review, 3=relearning
    # card.queue: see table above
```

### Ease & interval stats

```python
avg_ease = col.db.scalar("SELECT avg(factor)/10.0 FROM cards WHERE factor > 0")
avg_ivl  = col.db.scalar("SELECT avg(ivl) FROM cards WHERE ivl > 0 AND type = 2")
max_ivl  = col.db.scalar("SELECT max(ivl) FROM cards")
```

### Cards reviewed today

```python
import time
day_start_ms = int(time.time() - time.time() % 86400) * 1000
reviews_today = col.db.scalar(
    "SELECT count() FROM revlog WHERE id > ?", day_start_ms
)
```

### Cards added recently

```python
import time
thirty_days_ago_ms = (int(time.time()) - 30 * 86400) * 1000
recent = col.db.scalar("SELECT count() FROM cards WHERE id > ?", thirty_days_ago_ms)
```

### Iterate notes with fields

```python
for nid in col.find_notes("deck:English"):
    note = col.get_note(nid)
    fields = note.fields            # list of strings
    tags   = note.tags              # list of strings
    ntype  = note.note_type()["name"]
    print(f"[{ntype}] {fields}")
```

## Writing (requires Anki to be closed)

```python
col = Collection(path)  # Anki must NOT be running

# Add a basic note
note = col.new_note(col.models.by_name("Basic"))
note.fields[0] = "What is X?"   # Front
note.fields[1] = "Y"            # Back
note.tags = ["vocabulary"]
col.add_note(note, deck_id=col.decks.id("English"))

# Add a cloze note
note = col.new_note(col.models.by_name("Cloze"))
note.fields[0] = "She {{c1::went}} to the store."
col.add_note(note, deck_id=col.decks.id("English"))

col.close()
```

## Important notes

- `col.close()` must be called when done (or use `try/finally`).
- Card/note IDs are epoch-millisecond timestamps (e.g. `1700000000000`).
- The `anki` package bundles a Rust backend (`anki._backend`) — no extra install needed.
- Deck IDs are integers; use `col.decks.id("DeckName")` to resolve by name.
- For read-only inspection while Anki runs, always copy the `.anki2` file first.
