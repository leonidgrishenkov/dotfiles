/**
 * Modal Editor - vim-like modal editing extension
 *
 * Usage: pi --extension ./pi/.pi/agent/extensions/modal-editor.ts
 *
 * Modes:
 *   Escape:       insert → normal (in normal mode, aborts agent)
 *   i / I:        normal → insert (I inserts at line start)
 *   a / A:        normal → insert after cursor (A appends at line end)
 *   o / O:        open line below / above, enter insert mode
 *
 * Navigation (normal mode):
 *   h / j / k / l:  left / down / up / right
 *   w:              word forward
 *   b:              word backward
 *   0:              beginning of line
 *   ^:              first non-whitespace (beginning-of-line)
 *   $:              end of line
 *   gg:             top of buffer
 *   G:              bottom of buffer
 *
 * Editing (normal mode):
 *   x:              delete char under cursor
 *   r<char>:        replace char under cursor
 *   J:              join current line with next
 *
 *   dd:             delete (cut) line
 *   yy / Y:         yank (copy) line
 *   p / P:          paste after / before cursor
 *
 *   dw / cw:        delete / change word forward
 *   db / cb:        delete / change word backward
 *   D / C:          delete / change to end of line
 *
 *   u:              undo
 *   Ctrl+R:         (passes through to readline)
 *
 * The editor is built on readline-compatible escape sequences, so
 * behaviour for advanced operators may vary across terminal emulators.
 */

import { CustomEditor, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { matchesKey, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

/* ── Escape sequence constants ─────────────────────────────── */

const KEY = {
	up: "\x1b[A",
	down: "\x1b[B",
	right: "\x1b[C",
	left: "\x1b[D",
	wordFwd: "\x1bf", // Alt+F  (forward-word)
	wordBwd: "\x1bb", // Alt+B  (backward-word)
	home: "\x01", // Ctrl+A (beginning-of-line)
	end: "\x05", // Ctrl+E (end-of-line)
	bufEnd: "\x1b>", // Alt+> (end-of-buffer)
	del: "\x1b[3~", // Delete key (forward delete)
	bs: "\x7f", // Backspace (backward delete)
	kill: "\x0b", // Ctrl+K (kill to end of line)
	discard: "\x15", // Ctrl+U (kill to beginning of line)
	wordKill: "\x17", // Ctrl+W (kill word backward)
	yank: "\x19", // Ctrl+Y (yank from kill ring)
	undo: "\x1a", // Ctrl+Z (undo)
	undoAlt: "\x18\x15", // Ctrl+X Ctrl+U (alternative undo)
} as const;

/* ── Single-key mappings (direct pass-through or mode switch) ── */

const SIMPLE_KEYS: Record<string, string> = {
	h: KEY.left,
	j: KEY.down,
	k: KEY.up,
	l: KEY.right,
	w: KEY.wordFwd,
	b: KEY.wordBwd,
	"0": KEY.home,
	"^": KEY.home,
	$: KEY.end,
	x: KEY.del,
};

/**
 * Pending operator + motion pairs.
 * `op` — action to perform:
 *   "d" = delete (cut), "y" = yank (copy), "c" = change (delete + insert)
 * `motion` — what the second key targets:
 *   "d"/"g" = line, "w"/"b" = word
 */
const PENDING_PAIRS: Record<string, Record<string, { op: "d" | "y" | "c"; motion: "line" | "word" }>> = {
	d: {
		d: { op: "d", motion: "line" },
		w: { op: "d", motion: "word" },
		b: { op: "d", motion: "word" },
	},
	y: {
		y: { op: "y", motion: "line" },
		w: { op: "y", motion: "word" },
		b: { op: "y", motion: "word" },
	},
	c: {
		c: { op: "c", motion: "line" },
		w: { op: "c", motion: "word" },
		b: { op: "c", motion: "word" },
	},
};

/* ── Editor class ──────────────────────────────────────────── */

class ModalEditor extends CustomEditor {
	private mode: "normal" | "insert" = "insert";
	private pendingKey: string | null = null;
	private inputQueue: string[] = [];
	private clipboard = "";

	handleInput(data: string): void {
		// Drain queued inputs first (from multi-step commands like J, r)
		if (this.inputQueue.length > 0) {
			super.handleInput(this.inputQueue.shift()!);
			return;
		}

		// Escape always cancels pending state, else toggles / aborts
		if (matchesKey(data, "escape")) {
			if (this.pendingKey) {
				this.pendingKey = null;
				return;
			}
			if (this.mode === "insert") {
				this.mode = "normal";
			} else {
				super.handleInput(data);
			}
			return;
		}

		// ── Insert mode: pass everything through ──────────────
		if (this.mode === "insert") {
			super.handleInput(data);
			return;
		}

		// ── Normal mode ───────────────────────────────────────

		// Replace-char state: consume next printable char as replacement
		if (this.pendingKey === "r") {
			this.pendingKey = null;
			if (data.length === 1 && data.charCodeAt(0) >= 32) {
				this.queue(KEY.del, data);
			}
			return;
		}

		// Pending operator (d/y/c/g): consume motion key
		if (this.pendingKey) {
			const prev = this.pendingKey;
			this.pendingKey = null;

			// Two-key motions
			if (prev === "g" && data === "g") {
				super.handleInput(KEY.home); // top of buffer
				return;
			}

			const pair = PENDING_PAIRS[prev!]?.[data];
			if (pair) {
				if (pair.motion === "line") {
					this.doLine(pair.op);
				} else {
					this.doWord(pair.op, data as "w" | "b");
				}
			}
			return;
		}

		// Simple navigation / delete mappings
		if (data in SIMPLE_KEYS) {
			super.handleInput(SIMPLE_KEYS[data]!);
			return;
		}

		// Mode-switch and single-key edit commands
		switch (data) {
			// Insert at cursor / line start
			case "i":
				this.mode = "insert";
				break;
			case "I":
				this.mode = "insert";
				super.handleInput(KEY.home);
				break;

			// Append after cursor / line end
			case "a":
				this.mode = "insert";
				super.handleInput(KEY.right);
				break;
			case "A":
				this.mode = "insert";
				super.handleInput(KEY.end);
				break;

			// Open line below / above
			case "o":
				this.mode = "insert";
				this.queue(KEY.end, "\n");
				break;
			case "O":
				this.mode = "insert";
				this.queue(KEY.home, "\n", KEY.up);
				break;

			// Yank line (Y ≡ yy)
			case "Y":
				this.doLine("y");
				break;

			// Delete to end of line (D ≡ d$)
			case "D":
				this.clipboard = "";
				super.handleInput(KEY.kill);
				break;

			// Change to end of line (C ≡ c$)
			case "C":
				this.clipboard = "";
				super.handleInput(KEY.kill);
				this.mode = "insert";
				break;

			// Join lines (J)
			case "J":
				this.queue(KEY.end, KEY.del);
				break;

			// Go to bottom of buffer (G)
			case "G":
				super.handleInput(KEY.bufEnd);
				break;

			// Replace character (r)
			case "r":
				this.pendingKey = "r";
				break;

			// Paste after cursor (p)
			case "p":
				super.handleInput(KEY.right);
				super.handleInput(KEY.yank);
				break;

			// Paste before cursor (P)
			case "P":
				super.handleInput(KEY.yank);
				break;

			// Undo (u)
			case "u":
				super.handleInput(KEY.undo);
				break;

			// Pending operators: dd, dw, db, yy, yw, yb, cc, cw, cb, gg
			case "d":
			case "y":
			case "c":
			case "g":
				this.pendingKey = data;
				break;

			default:
				// Consume printable chars without passing through
				if (data.length > 0 && data.charCodeAt(0) < 32) {
					super.handleInput(data);
				}
				break;
		}
	}

	render(width: number): string[] {
		const lines = super.render(width);
		if (lines.length === 0) return lines;

		// Mode label — show pending state when waiting for a motion
		let label: string;
		if (this.pendingKey) {
			label = ` -- ${this.pendingKey.toUpperCase()}-- `;
		} else {
			label = this.mode === "normal" ? " NORMAL " : " INSERT ";
		}

		const last = lines.length - 1;
		if (visibleWidth(lines[last]!) >= label.length) {
			lines[last] = truncateToWidth(lines[last]!, width - label.length, "") + label;
		}
		return lines;
	}

	/* ── Private helpers ─────────────────────────────────── */

	/** Enqueue key sequences to be dispatched on subsequent input events. */
	private queue(...seqs: string[]): void {
		this.inputQueue.push(...seqs);
	}

	/**
	 * Execute a line-level operator (dd / yy / cc).
	 * Uses Ctrl+K (kill to end) + Backspace to remove the empty remainder,
	 * which is the most portable readline-compatible approach.
	 */
	private doLine(op: "d" | "y" | "c"): void {
		if (op === "y") {
			// Select all → copy to kill ring → deselect
			// Fallback: Ctrl+A, Ctrl+K (kills line into kill ring), Ctrl+Y (restore)
			this.queue(KEY.home, KEY.kill, KEY.yank);
		} else {
			// Delete: home, kill to end, delete empty line remnant
			this.queue(KEY.home, KEY.kill, KEY.bs);
			if (op === "c") {
				this.mode = "insert";
			}
		}
	}

	/**
	 * Execute a word-level operator (dw / db / cw / cb).
	 *
	 * Forward (dw/cw): navigate forward to skip the target word, then delete
	 * backward with Ctrl+W to remove the word in one step.
	 *
	 * Backward (db/cb): delete backward one word with Ctrl+W directly.
	 *
	 * This is the most reliable readline-compatible approach since readline
	 * has no built-in forward-word-delete binding across all terminals.
	 */
	private doWord(op: "d" | "y" | "c", motion: "w" | "b"): void {
		if (motion === "w") {
			if (op === "y") {
				// Yank word: select forward word, kill, restore
				this.queue(KEY.wordFwd, KEY.wordKill);
			} else {
				// Delete/change word forward: jump ahead then kill word backward
				this.queue(KEY.wordFwd, KEY.wordKill);
				if (op === "c") this.mode = "insert";
			}
		} else {
			// motion === "b": delete/change/yank word backward
			if (op === "y") {
				// Copy word backward (less common; approximate with wordKill)
				this.queue(KEY.wordBwd, KEY.wordFwd, KEY.wordKill);
			} else {
				super.handleInput(KEY.wordKill);
				if (op === "c") this.mode = "insert";
			}
		}
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("session_start", (_event, ctx) => {
		ctx.ui.setEditorComponent((tui, theme, kb) => new ModalEditor(tui, theme, kb));
	});
}
