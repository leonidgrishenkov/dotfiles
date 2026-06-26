/**
 * Supertonic Read-Aloud
 *
 * /read — compact the last assistant response via LLM, synthesize speech
 *         with Supertonic TTS, and play it back.
 *
 * Pipeline:
 *   1. Extract last assistant message
 *   2. LLM compacts it (strip code/tables → pure prose) → temp .md file
 *   3. Supertonic TTS synthesizes speech → temp .wav file
 *   4. Play audio
 *   5. Clean up temp files, flash final status
 */

import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { complete } from "@earendil-works/pi-ai";
import { execFile } from "node:child_process";
import * as fs from "node:fs";
import { tmpdir } from "node:os";
import * as path from "node:path";

import { config } from "./config.ts";
import { loadTextToSpeech, loadVoiceStyle, type Style, type TextToSpeech } from "./tts.ts";
import { stripMarkdownForSpeech, writeWavFile } from "./utils.ts";

// ============================================================
// Lazy TTS singleton
// ============================================================

let _tts: TextToSpeech | null = null;
let _style: Style | null = null;
let _voice: string | null = null;

async function getTts(): Promise<{ tts: TextToSpeech; style: Style }> {
  if (_tts && _style && _voice === config.voice) return { tts: _tts, style: _style };

  const onnxDir = path.join(config.assetsDir, "onnx");
  const voicePath = path.join(config.assetsDir, "voice_styles", `${config.voice}.json`);

  if (!fs.existsSync(onnxDir))  throw new Error(`ONNX directory missing: ${onnxDir}`);
  if (!fs.existsSync(voicePath)) throw new Error(`Voice style missing: ${voicePath}`);

  _tts    = await loadTextToSpeech(onnxDir);
  _style  = loadVoiceStyle([voicePath]);
  _voice  = config.voice;

  return { tts: _tts, style: _style };
}

// ============================================================
// Extract last assistant text from the current branch
// ============================================================

function extractLastAssistantText(branch: any[]): { text: string; complete: boolean } | null {
  for (let i = branch.length - 1; i >= 0; i--) {
    const e = branch[i];
    if (e?.type !== "message" || e?.message?.role !== "assistant") continue;

    const stopReason = e.message.stopReason;
    const isDone = !stopReason || stopReason === "stop";

    const content = e.message.content;
    const parts: string[] = [];

    if (typeof content === "string") {
      parts.push(content);
    } else if (Array.isArray(content)) {
      for (const p of content) {
        if (p && typeof p === "object" && p.type === "text" && typeof p.text === "string") {
          parts.push(p.text);
        }
      }
    }

    const text = parts.join("\n").trim();
    if (text.length > 0) return { text, complete: isDone };
  }
  return null;
}

// ============================================================
// LLM compaction — strip code / tables / noise into pure prose
// ============================================================

const COMPACT_SYSTEM = `You are a text-to-speech preprocessor.
Given markdown text, produce clean, continuous prose suitable for reading aloud.

Rules:
- REMOVE all code blocks (fenced and inline)
- REMOVE tables, converting key data into natural sentences only if essential
- REMOVE bullet-point formatting — weave into fluent sentences
- REMOVE image references, links (keep visible link text as plain words)
- REMOVE blockquote markers
- FIX headings into natural sentence transitions
- PRESERVE all factual information, numbers, and substance
- USE plain prose: no markdown, no formatting, no bullet points
- Output ONLY the cleaned prose. No commentary, no preamble, no wrappers.`;

async function compactViaLlm(
  text: string,
  ctx: ExtensionCommandContext,
): Promise<string> {
  if (!ctx.model) throw new Error("No model selected. Pick a model first.");

  const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
  if (!auth.ok || !auth.apiKey) {
    throw new Error(auth.ok ? `No API key for ${ctx.model.provider}` : auth.error);
  }

  const userMessage = {
    role: "user" as const,
    content: [{ type: "text" as const, text }],
    timestamp: Date.now(),
  };

  const response = await complete(
    ctx.model,
    { systemPrompt: COMPACT_SYSTEM, messages: [userMessage] },
    { apiKey: auth.apiKey, headers: auth.headers },
  );

  return response.content
    .filter((c): c is { type: "text"; text: string } => c.type === "text")
    .map((c) => c.text)
    .join("\n")
    .trim();
}

// ============================================================
// Audio playback
// ============================================================

function playWav(filePath: string): Promise<void> {
  return new Promise((resolve, reject) => {
    let cmd: string;
    let args: string[];

    if (process.platform === "darwin") {
      cmd = "afplay";
      args = [filePath];
    } else if (process.platform === "linux") {
      cmd = "paplay";
      args = [filePath];
    } else {
      cmd = "ffplay";
      args = ["-nodisp", "-autoexit", filePath];
    }

    execFile(cmd, args, (err) => (err ? reject(err) : resolve()));
  });
}

// ============================================================
// Temp file helpers
// ============================================================

function tempPath(prefix: string, ext: string): string {
  return path.join(tmpdir(), `pi-supertonic-${prefix}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}.${ext}`);
}

function rmSafe(p: string | undefined | null) {
  if (p) try { fs.unlinkSync(p); } catch { /* noop */ }
}

// ============================================================
// Status helper (safe in all modes)
// ============================================================

function status(ctx: ExtensionCommandContext, icon: string, msg: string) {
  if (ctx.hasUI) ctx.ui.setStatus("supertonic-read", `${icon}  ${msg}`);
}

function clearStatus(ctx: ExtensionCommandContext) {
  if (ctx.hasUI) ctx.ui.setStatus("supertonic-read", "");
}

function notify(ctx: ExtensionCommandContext, msg: string, level: "info" | "error" | "warning" = "info") {
  if (ctx.hasUI) ctx.ui.notify(msg, level);
}

// ============================================================
// Extension
// ============================================================

export default function (pi: ExtensionAPI) {
  pi.registerCommand("read", {
    description: "Compact the last assistant response and read it aloud (Supertonic TTS)",

    handler: async (_args, ctx) => {
      const { icons } = config;

      // ----- Extract -------------------------------------------------
      const branch = ctx.sessionManager.getBranch();
      const extracted = extractLastAssistantText(branch);

      if (!extracted) {
        notify(ctx, "No assistant response found to read.", "warning");
        return;
      }
      if (!extracted.complete) {
        notify(ctx, "Last assistant response is incomplete. Wait for it to finish.", "warning");
        return;
      }

      let mdPath: string | undefined;
      let wavPath: string | undefined;

      try {
        // ----- Compact via LLM ---------------------------------------
        status(ctx, icons.compact, "Compacting text...");

        let compactedText: string;
        try {
          compactedText = await compactViaLlm(extracted.text, ctx);
        } catch (err: any) {
          status(ctx, icons.error, `LLM failed: ${err.message}`);
          notify(ctx, `Compaction failed: ${err.message}`, "error");
          clearStatus(ctx);
          return;
        }

        if (!compactedText || compactedText.length < 8) {
          // LLM returned nothing useful — fall back to local markdown strip
          compactedText = stripMarkdownForSpeech(extracted.text);
        }

        if (!compactedText.trim()) {
          notify(ctx, "No speakable text after compaction.", "warning");
          clearStatus(ctx);
          return;
        }

        // Write compacted text to temp .md
        mdPath = tempPath("compact", "md");
        fs.writeFileSync(mdPath, compactedText);

        // ----- TTS synthesis -----------------------------------------
        status(ctx, icons.synth, "Synthesizing speech...");

        const { tts, style } = await getTts();
        const { wav, duration } = await tts.call(
          compactedText,
          config.lang,
          style,
          config.totalSteps,
          config.speed,
          config.silenceDuration,
        );

        const wavLen = Math.floor(tts.sampleRate * duration[0]);
        wavPath = tempPath("audio", "wav");
        writeWavFile(wavPath, wav.slice(0, wavLen), tts.sampleRate);

        // ----- Playback ----------------------------------------------
        status(ctx, icons.play, `Playing (${duration[0].toFixed(1)}s)...`);

        try {
          await playWav(wavPath);
        } catch (err: any) {
          status(ctx, icons.error, `Playback failed: ${err.message}`);
          notify(ctx, `Playback error: ${err.message}`, "error");
          return;
        }

        // ----- Done --------------------------------------------------
        const words = compactedText.split(/\s+/).length;
        status(ctx, icons.done, `Read ${words} words (${duration[0].toFixed(1)}s)`);
        setTimeout(() => clearStatus(ctx), 4_000);

      } catch (err: any) {
        status(ctx, icons.error, `Error: ${err.message}`);
        notify(ctx, `Supertonic read failed: ${err.message}`, "error");
      } finally {
        rmSafe(mdPath);
        rmSafe(wavPath);
      }
    },
  });
}
