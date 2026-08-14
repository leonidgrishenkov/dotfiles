#!/usr/bin/env node
/**
 * Claude Code statusLine — mirrors the pi "starship-footer" extension:
 *   Line 1 — starship prompt (directory, git branch/status, language versions, etc.)
 *   Line 2 — Claude usage info right-aligned (model, thinking effort, tokens, cost)
 *
 * Configured via ~/.claude/settings.json:
 *   "statusLine": { "type": "command", "command": "~/.claude/statusline.mjs" }
 *
 * Prerequisites: starship must be in PATH. Falls back to usage-only line otherwise.
 */

import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";

const ESC = "\x1b";
const reset = `${ESC}[0m`;
const dim = (s) => `${ESC}[2m${s}${reset}`;
const fg = (code, s) => `${ESC}[${code}m${s}${reset}`;
const cyan = (s) => fg(36, s);
const yellow = (s) => fg(33, s);
const green = (s) => fg(32, s);
const gray = (s) => fg(90, s);

function stripAnsi(s) {
	return s.replace(/\x1b\[[0-9;]*m/g, "");
}

function visibleWidth(s) {
	return stripAnsi(s).length;
}

function truncateToWidth(s, width) {
	if (visibleWidth(s) <= width) return s;
	return stripAnsi(s).slice(0, width);
}

function isStarshipAvailable() {
	try {
		execFileSync("starship", ["--version"], { stdio: "ignore" });
		return true;
	} catch {
		return false;
	}
}

function fetchStarshipPrompt(cwd, width) {
	try {
		// Leave STARSHIP_SHELL unset: starship then emits raw ANSI with no
		// shell-specific non-printing markers to strip, and skips the $shell
		// module's icon (some shell icons in this config are Nerd Font glyphs
		// disguised as "" in the TOML, which render as stray blank cells here).
		const env = { ...process.env, PWD: cwd };
		delete env.STARSHIP_SHELL;

		const stdout = execFileSync(
			"starship",
			[
				"prompt",
				`--terminal-width=${width}`,
				"--status=0",
				"--keymap=",
				"--pipestatus=0",
				"--cmd-duration=0",
				"--jobs=0",
			],
			{ cwd, timeout: 3000, env, encoding: "utf-8" },
		);

		const lines = stdout.split("\n");
		const firstLine = lines.find((l) => l.trim().length > 0) ?? "";

		// Strip trailing ANSI reset codes, then trim trailing whitespace
		const clean = firstLine.replace(/(\x1b\[[0-9;]*m)+$/g, "").trimEnd();

		return clean || null;
	} catch {
		return null;
	}
}

function fmt(n) {
	return n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`;
}

function readStdin() {
	try {
		return JSON.parse(readFileSync(0, "utf-8"));
	} catch {
		return {};
	}
}

// Claude Code reserves some columns around the statusLine content in ways it
// doesn't document (border/gutter/mode-indicator area), so COLUMNS overstates
// the usable width. Undershoot slightly rather than risk hard truncation.
const SAFETY_MARGIN = 6;

const data = readStdin();
const width = (Number.parseInt(process.env.COLUMNS ?? "", 10) || 120) - SAFETY_MARGIN;
const cwd = data.workspace?.current_dir ?? data.cwd ?? process.cwd();

const line1 = isStarshipAvailable() ? (fetchStarshipPrompt(cwd, width) ?? "") : "";

// ── Build usage info ────────────────────────────────────────────────────────
const rightParts = [];

if (data.model?.display_name) {
	rightParts.push(cyan(` ${data.model.display_name}`));
}

if (data.effort?.level && data.effort.level !== "off") {
	rightParts.push(" " + gray(data.effort.level));
}

const inputTok = data.context_window?.total_input_tokens ?? 0;
const outputTok = data.context_window?.total_output_tokens ?? 0;
const cost = data.cost?.total_cost_usd ?? 0;

if (inputTok > 0 || outputTok > 0) {
	rightParts.push(` ${yellow(`↑${fmt(inputTok)}`)}`, ` ${yellow(`↓${fmt(outputTok)}`)}`, ` ${green(`$${cost.toFixed(3)}`)}`);
}

const usage = rightParts.join("");

// Single line when starship + usage fit (usage right-aligned).
// Two lines when they don't (usage moves below, left-aligned).
const fitsOnOneLine = visibleWidth(line1) + 1 + visibleWidth(usage) <= width;

if (fitsOnOneLine) {
	const gap = Math.max(1, width - visibleWidth(line1) - visibleWidth(usage));
	console.log(truncateToWidth(line1 + " ".repeat(gap) + usage, width));
} else {
	console.log(truncateToWidth(line1, width));
	console.log(truncateToWidth(usage, width));
}
