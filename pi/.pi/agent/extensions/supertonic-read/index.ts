/**
 * Pi Extension: Supertonic Read-Aloud
 *
 * Reads the last assistant model output aloud using Supertonic TTS.
 *
 * Commands:
 *   /read          — Read the last assistant response aloud
 *   /read-config   — Show or update TTS configuration
 *
 * Config: ~/.pi/agent/extensions/supertonic-read/config.json
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import * as fs from "node:fs";
import * as path from "node:path";
import { execFile } from "node:child_process";
import { tmpdir } from "node:os";

import { TextToSpeech, loadTextToSpeech, loadVoiceStyle, type Style } from "./tts.ts";
import { stripMarkdownForSpeech, writeWavFile } from "./utils.ts";

// ============================================================
// Config
// ============================================================

interface ReadConfig {
  assetsDir: string;
  voice: string;
  lang: string;
  totalSteps: number;
  speed: number;
  maxLength: number;
  autoPlay: boolean;
}

const CONFIG_PATH = path.join(
  path.dirname(new URL(import.meta.url).pathname),
  "config.json",
);

function loadConfig(): ReadConfig {
  const defaults: ReadConfig = {
    assetsDir: "",
    voice: "F1",
    lang: "en",
    totalSteps: 8,
    speed: 1.05,
    maxLength: 2000,
    autoPlay: false,
  };

  try {
    const raw = fs.readFileSync(CONFIG_PATH, "utf8");
    return { ...defaults, ...JSON.parse(raw) };
  } catch {
    return defaults;
  }
}

function saveConfig(cfg: ReadConfig): void {
  fs.writeFileSync(CONFIG_PATH, JSON.stringify(cfg, null, 2) + "\n");
}

// ============================================================
// Extract last assistant text from session
// ============================================================

type ContentBlock = {
  type?: string;
  text?: string;
  name?: string;
  arguments?: Record<string, unknown>;
};

function extractAssistantText(entries: any[]): string {
  // Walk backwards through the branch looking for the last assistant message
  for (let i = entries.length - 1; i >= 0; i--) {
    const entry = entries[i];
    if (
      entry?.type === "message" &&
      entry?.message?.role === "assistant" &&
      entry?.message?.content
    ) {
      const content = entry.message.content;
      const textParts: string[] = [];

      if (typeof content === "string") {
        textParts.push(content);
      } else if (Array.isArray(content)) {
        for (const part of content) {
          if (part && typeof part === "object" && (part as ContentBlock).type === "text") {
            const t = (part as ContentBlock).text;
            if (t) textParts.push(t);
          }
        }
      }

      const combined = textParts.join("\n").trim();
      if (combined.length > 0) return combined;
    }
  }
  return "";
}

// ============================================================
// Audio playback
// ============================================================

function playAudio(filePath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    // macOS: use afplay; Linux: try paplay, aplay, or ffplay
    const platform = process.platform;
    let cmd: string;
    let args: string[];

    if (platform === "darwin") {
      cmd = "afplay";
      args = [filePath];
    } else if (platform === "linux") {
      cmd = "paplay";
      args = [filePath];
    } else {
      cmd = "ffplay";
      args = ["-nodisp", "-autoexit", filePath];
    }

    const child = execFile(cmd, args, (error) => {
      if (error) reject(error);
      else resolve();
    });
  });
}

// ============================================================
// Lazy TTS singleton
// ============================================================

let ttsInstance: TextToSpeech | null = null;
let ttsStyle: Style | null = null;
let ttsConfig: ReadConfig | null = null;

async function getTts(): Promise<{ tts: TextToSpeech; style: Style; cfg: ReadConfig }> {
  const cfg = loadConfig();

  if (!cfg.assetsDir) {
    throw new Error(
      "Supertonic assets path not configured. " +
      `Edit ${CONFIG_PATH} and set "assetsDir" to the path containing onnx/ and voice_styles/ directories.`,
    );
  }

  const onnxDir = path.join(cfg.assetsDir, "onnx");
  const voiceStylePath = path.join(cfg.assetsDir, "voice_styles", `${cfg.voice}.json`);

  if (!fs.existsSync(onnxDir)) {
    throw new Error(`ONNX model directory not found: ${onnxDir}`);
  }
  if (!fs.existsSync(voiceStylePath)) {
    throw new Error(`Voice style file not found: ${voiceStylePath}`);
  }

  // Reload models only if config changed
  const configKey = JSON.stringify({ assetsDir: cfg.assetsDir, voice: cfg.voice });
  const prevKey = ttsConfig ? JSON.stringify({ assetsDir: ttsConfig.assetsDir, voice: ttsConfig.voice }) : "";

  if (!ttsInstance || !ttsStyle || configKey !== prevKey) {
    ttsInstance = await loadTextToSpeech(onnxDir);
    ttsStyle = loadVoiceStyle([voiceStylePath]);
    ttsConfig = cfg;
  }

  return { tts: ttsInstance, style: ttsStyle, cfg };
}

// ============================================================
// Extension
// ============================================================

export default function (pi: ExtensionAPI) {
  // --- /read command ---
  pi.registerCommand("read", {
    description: "Read the last assistant response aloud using Supertonic TTS",
    handler: async (_args, ctx) => {
      const branch = ctx.sessionManager.getBranch();
      const rawText = extractAssistantText(branch);

      if (!rawText) {
        if (ctx.hasUI) ctx.ui.notify("No assistant response found to read.", "warning");
        return;
      }

      // Strip markdown for speech
      let speechText = stripMarkdownForSpeech(rawText);

      const cfg = loadConfig();
      if (speechText.length > cfg.maxLength) {
        speechText = speechText.slice(0, cfg.maxLength).trim();
        // Try to end at a sentence boundary
        const lastPeriod = speechText.lastIndexOf(". ");
        if (lastPeriod > cfg.maxLength * 0.7) {
          speechText = speechText.slice(0, lastPeriod + 1);
        }
      }

      if (!speechText.trim()) {
        if (ctx.hasUI) ctx.ui.notify("No speakable text after stripping markdown.", "warning");
        return;
      }

      const wordCount = speechText.split(/\s+/).length;
      if (ctx.hasUI) {
        ctx.ui.setStatus(
          "supertonic-read",
          `🔊 Synthesizing ${wordCount} words with ${cfg.voice}...`,
        );
      }

      try {
        const { tts, style } = await getTts();

        // Synthesize to temp WAV file
        const { wav, duration } = await tts.call(
          speechText,
          cfg.lang,
          style,
          cfg.totalSteps,
          cfg.speed,
        );

        const wavLen = Math.floor(tts.sampleRate * duration[0]);
        const wavOut = wav.slice(0, wavLen);

        const tmpFile = path.join(tmpdir(), `pi-supertonic-read-${Date.now()}.wav`);
        writeWavFile(tmpFile, wavOut, tts.sampleRate);

        if (ctx.hasUI) {
          ctx.ui.setStatus(
            "supertonic-read",
            `🔊 Playing ${duration[0].toFixed(1)}s of audio...`,
          );
        }

        await playAudio(tmpFile);

        if (ctx.hasUI) {
          ctx.ui.setStatus("supertonic-read", "");
          ctx.ui.notify(
            `✅ Read ${wordCount} words (${duration[0].toFixed(1)}s, voice: ${cfg.voice})`,
            "info",
          );
        }

        // Cleanup temp file
        try { fs.unlinkSync(tmpFile); } catch { /* ignore */ }
      } catch (err: any) {
        if (ctx.hasUI) {
          ctx.ui.setStatus("supertonic-read", "");
          ctx.ui.notify(`TTS error: ${err.message}`, "error");
        }
      }
    },
  });

  // --- /read-config command ---
  pi.registerCommand("read-config", {
    description: "Show or update Supertonic TTS configuration",
    handler: async (args, ctx) => {
      const cfg = loadConfig();

      if (!args || args.trim() === "" || args.trim() === "show") {
        const info = [
          `Assets: ${cfg.assetsDir || "(not set)"}`,
          `Voice: ${cfg.voice}`,
          `Language: ${cfg.lang}`,
          `Steps: ${cfg.totalSteps}`,
          `Speed: ${cfg.speed}`,
          `Max chars: ${cfg.maxLength}`,
          `Auto-play: ${cfg.autoPlay}`,
        ].join("\n");

        if (ctx.hasUI) {
          ctx.ui.notify(`Supertonic Read Config:\n${info}`, "info");
        }

        if (ctx.mode === "tui" && ctx.hasUI) {
          const voices = ["M1", "M2", "M3", "M4", "M5", "F1", "F2", "F3", "F4", "F5"];
          const choice = await ctx.ui.select(
            "Change voice?",
            ["(keep current)", ...voices],
          );
          if (choice && choice !== "(keep current)") {
            cfg.voice = choice;
            saveConfig(cfg);
            // Reset cached TTS so next /read picks up the new voice
            ttsInstance = null;
            ttsStyle = null;
            ctx.ui.notify(`Voice changed to ${choice}`, "info");
          }
        }
        return;
      }

      // Parse key=value pairs, e.g. "voice=M2 speed=1.2"
      const parsed: Record<string, string> = {};
      for (const pair of args.trim().split(/\s+/)) {
        const eq = pair.indexOf("=");
        if (eq > 0) {
          parsed[pair.slice(0, eq)] = pair.slice(eq + 1);
        }
      }

      let changed = false;
      if (parsed.assetsDir !== undefined) { cfg.assetsDir = parsed.assetsDir; changed = true; }
      if (parsed.voice !== undefined) { cfg.voice = parsed.voice; changed = true; }
      if (parsed.lang !== undefined) { cfg.lang = parsed.lang; changed = true; }
      if (parsed.totalSteps !== undefined) {
        cfg.totalSteps = Math.max(1, Math.min(20, parseInt(parsed.totalSteps) || 8));
        changed = true;
      }
      if (parsed.speed !== undefined) {
        cfg.speed = Math.max(0.5, Math.min(3.0, parseFloat(parsed.speed) || 1.05));
        changed = true;
      }
      if (parsed.maxLength !== undefined) {
        cfg.maxLength = Math.max(100, parseInt(parsed.maxLength) || 2000);
        changed = true;
      }
      if (parsed.autoPlay !== undefined) {
        cfg.autoPlay = parsed.autoPlay === "true";
        changed = true;
      }

      if (changed) {
        saveConfig(cfg);
        ttsInstance = null;
        ttsStyle = null;
        if (ctx.hasUI) ctx.ui.notify("Config updated.", "info");
      } else {
        if (ctx.hasUI) ctx.ui.notify("No valid key=value pairs found.", "warning");
      }
    },
  });

  // --- Auto-play on agent_end (if enabled in config) ---
  pi.on("agent_end", async (_event, ctx) => {
    const cfg = loadConfig();
    if (!cfg.autoPlay) return;

    // Fire /read command logic
    const branch = ctx.sessionManager.getBranch();
    const rawText = extractAssistantText(branch);
    if (!rawText) return;

    let speechText = stripMarkdownForSpeech(rawText);
    if (speechText.length > cfg.maxLength) {
      speechText = speechText.slice(0, cfg.maxLength).trim();
      const lastPeriod = speechText.lastIndexOf(". ");
      if (lastPeriod > cfg.maxLength * 0.7) {
        speechText = speechText.slice(0, lastPeriod + 1);
      }
    }
    if (!speechText.trim()) return;

    try {
      const { tts, style } = await getTts();
      const { wav, duration } = await tts.call(
        speechText, cfg.lang, style, cfg.totalSteps, cfg.speed,
      );
      const wavLen = Math.floor(tts.sampleRate * duration[0]);
      const tmpFile = path.join(tmpdir(), `pi-supertonic-read-${Date.now()}.wav`);
      writeWavFile(tmpFile, wav.slice(0, wavLen), tts.sampleRate);
      await playAudio(tmpFile);
      try { fs.unlinkSync(tmpFile); } catch { /* ignore */ }
    } catch { /* silent fail for auto-play */ }
  });
}
