/**
 * Starship Footer Extension
 *
 * Replaces the pi TUI footer with a two-line layout:
 *   Line 1 — starship prompt (directory, git branch/status, language versions, etc.)
 *   Line 2 — pi usage info right-aligned (model, thinking level, tokens, cost)
 *
 * Prerequisites: starship must be in PATH. The extension is a no-op otherwise.
 */

import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

function isStarshipAvailable(): boolean {
  try {
    const { execFileSync } = require("node:child_process");
    execFileSync("starship", ["--version"], { stdio: "ignore" });
    return true;
  } catch {
    return false;
  }
}

async function fetchStarshipPrompt(cwd: string, width: number): Promise<string | null> {
  try {
    const env: Record<string, string | undefined> = {
      ...process.env,
      PWD: cwd,
      STARSHIP_SHELL: "bash",
    };
    // Preserve STARSHIP_CONFIG so the user's config is used
    if (process.env.STARSHIP_CONFIG) {
      env.STARSHIP_CONFIG = process.env.STARSHIP_CONFIG;
    }

    const { stdout } = await execFileAsync(
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
      { cwd, timeout: 3000, env },
    );

    // Starship emits an initial newline when add_newline=true, then the
    // info line, then $line_break, then the ❯ character line.  We want the
    // first non-blank line — the info bar without the prompt character.
    const lines = stdout.split("\n");
    const firstLine = lines.find((l) => l.trim().length > 0) ?? "";

    // bash format: \[ and \] are non-printing markers; ESC is already present
    // inside them, so just strip the markers.
    // zsh format: %{ and %} wrap content WITHOUT ESC; add ESC when stripping.
    const ansi = firstLine
      .replace(/\\\[/g, "")        // bash: remove \[ (ESC already inside)
      .replace(/\\\]/g, "")        // bash: remove \]
      .replace(/%\{/g, "\x1b")     // zsh:  %{ → ESC
      .replace(/%\}/g, "");         // zsh:  remove %}

    // Strip trailing ANSI reset codes, then trim trailing whitespace
    const clean = ansi
      .replace(/(\x1b\[[0-9;]*m)+$/g, "")
      .trimEnd();

    return clean || null;
  } catch {
    return null;
  }
}

// ── Extension ────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  if (!isStarshipAvailable()) {
    return; // Silently disable — starship is not installed
  }

  let starshipPrompt: string | null = null;
  let thinkingLevel: string = "off";
  let lastRenderWidth = 120;
  let requestRender: (() => void) | undefined;

  async function refreshStarship(cwd: string, width: number) {
    starshipPrompt = await fetchStarshipPrompt(cwd, width);
    requestRender?.();
  }

  pi.on("session_start", async (_event, ctx) => {
    thinkingLevel = pi.getThinkingLevel();
    refreshStarship(ctx.cwd, lastRenderWidth);

    ctx.ui.setFooter((tui, theme, footerData) => {
      requestRender = () => tui.requestRender();

      // Re-fetch when git branch changes
      const unsub = footerData.onBranchChange(() => refreshStarship(ctx.cwd, lastRenderWidth));

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          // Re-fetch starship if terminal was resized
          if (width !== lastRenderWidth) {
            lastRenderWidth = width;
            refreshStarship(ctx.cwd, width);
          }

          // ── Line 1: starship prompt (full width) ───────────────────────
          const line1 = starshipPrompt ?? "";

          // ── Line 2: pi usage info (right-aligned) ──────────────────────
          // All colors come from the active pi theme so they update
          // automatically when the theme changes.
          const rightParts: string[] = [];

          if (ctx.model) {
            rightParts.push(
              theme.fg("dim", ctx.model.provider + " → ") +
                theme.fg("accent", ctx.model.name),
            );
          }

          if (thinkingLevel !== "off") {
            rightParts.push(" " + theme.fg("dim", " ") + theme.fg("accent", thinkingLevel));
          }

          let inputTok = 0,
            outputTok = 0,
            totalCost = 0;
          for (const e of ctx.sessionManager.getBranch()) {
            if (e.type === "message" && e.message.role === "assistant") {
              const m = e.message as AssistantMessage;
              inputTok += m.usage.input;
              outputTok += m.usage.output;
              totalCost += m.usage.cost.total;
            }
          }

          if (inputTok > 0 || outputTok > 0) {
            const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
            rightParts.push(
              ` ${theme.fg("muted", `↑${fmt(inputTok)}`)}`,
              ` ${theme.fg("muted", `↓${fmt(outputTok)}`)}`,
              ` ${theme.fg("success", `$${totalCost.toFixed(3)}`)}`,
            );
          }

          const line2 = rightParts.join("");

          return [truncateToWidth(line1, width), truncateToWidth(line2, width)];
        },
      };
    });
  });

  // Refresh starship after each agent turn (files may have changed, etc.)
  pi.on("agent_end", (_event, ctx) => {
    refreshStarship(ctx.cwd, lastRenderWidth);
  });

  // Update thinking level immediately
  pi.on("thinking_level_select", async (event, _ctx) => {
    thinkingLevel = event.level;
    requestRender?.();
  });
}
