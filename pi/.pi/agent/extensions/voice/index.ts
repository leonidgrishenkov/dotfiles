/**
 * Pi Voice Extension
 *
 * Adds voice-in (STT) and voice-out (TTS) capabilities to pi.
 *
 * STT: push-to-talk shortcut records audio with `sox`, transcribes with the
 *      `whisper` CLI, and sends the transcript as a user message.
 * TTS: each finished assistant message is spoken with `piper` (local neural TTS).
 *
 * Binaries are auto-detected at startup. If a tool is missing, that feature is
 * disabled and the other still works — startup notifies you of any install hints.
 *
 * Dependencies (install once):
 *   brew install sox
 *   brew install whisper-cpp        # provides the `whisper-cli` binary
 *   brew install piper-tts           # NOT on Homebrew core — see PI_VOICE_PIPER_BIN below
 *
 * whisper-cpp does NOT ship model files. Download a GGML model (.bin) from
 *   https://huggingface.co/ggerganov/whisper.cpp/tree/main
 * and either drop it under /opt/homebrew/share/whisper-cpp or set:
 *   PI_VOICE_WHISPER_MODEL=/path/to/ggml-base.en.bin
 *
 * piper is distributed as prebuilt binaries from GitHub releases
 *   https://github.com/rhasspy/piper/releases
 * Download a voice model (.onnx + .onnx.json) from
 *   https://huggingface.co/rhasspy/piper-voices/tree/main/en/en_US
 * and set:
 *   PI_VOICE_PIPER_BIN=/path/to/piper
 *   PI_VOICE_PIPER_MODEL=/path/to/en_US-lessac-medium.onnx
 *
 * You can override any auto-detected binary via env vars:
 *   PI_VOICE_WHISPER_BIN=/path/to/whisper-cli
 *   PI_VOICE_WHISPER_MODEL=/path/to/model.bin
 *   PI_VOICE_PIPER_BIN=/path/to/piper
 *   PI_VOICE_PIPER_MODEL=/path/to/voice.onnx
 *   PI_VOICE_PIPER_LENGTH=1.0   (sentence length scale; lower = faster speech)
 *
 * Controls:
 *   Ctrl+Shift+V   push-to-talk (records for the configured duration)
 *   /voice         toggle TTS on/off and show status
 *   /voice stt     test STT only (records + prints transcript)
 *
 * Notes:
 * - Works in TUI mode only. In RPC/print/json modes the shortcut is inert and
 *   TTS is skipped (no terminal to speak into).
 * - Tool output, thinking blocks, and code fences are stripped before speaking.
 * - Re-entrant recording is blocked: pressing the shortcut while already
 *   recording is a no-op.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { execFile as execFileCb } from "node:child_process";
import { existsSync, readdirSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { promisify } from "node:util";

const execFile = promisify(execFileCb);

// --- Config ---------------------------------------------------------------

const RECORD_SECONDS = Number(process.env.PI_VOICE_RECORD_SECONDS ?? 6);
const SAMPLE_RATE = "16000";

const WHISPER_BIN =
  process.env.PI_VOICE_WHISPER_BIN ??
  resolveBin("whisper-cli") ?? // whisper.cpp (brew install whisper-cpp)
  resolveBin("whisper"); // python openai-whisper
const PIPER_BIN = process.env.PI_VOICE_PIPER_BIN ?? resolveBin("piper");
const SOX_BIN = process.env.PI_VOICE_SOX_BIN ?? resolveBin("sox") ?? "sox";

// --- Binary discovery -----------------------------------------------------

/** Search common Homebrew locations + $PATH for an executable. */
function resolveBin(name: string): string | undefined {
  const seen = new Set<string>();
  const dirs = [
    "/opt/homebrew/bin",
    "/usr/local/bin",
    "/usr/bin",
    "/bin",
    ...(process.env.PATH?.split(":") ?? []),
  ];
  for (const dir of dirs) {
    if (!dir || seen.has(dir)) continue;
    seen.add(dir);
    const p = join(dir, name);
    try {
      if (existsSync(p) && statSync(p).isFile()) return p;
    } catch {
      /* ignore */
    }
  }
  return undefined;
}

// whisper-cpp models shipped via Homebrew live under share/whisper-cpp
function findWhisperModel(): string | undefined {
  const env = process.env.PI_VOICE_WHISPER_MODEL;
  if (env && existsSync(env)) return env;
  const roots = [
    "/opt/homebrew/share/whisper-cpp",
    "/usr/local/share/whisper-cpp",
    process.env.HOME && join(process.env.HOME, ".cache/whisper"),
  ].filter(Boolean) as string[];
  for (const root of roots) {
    if (!existsSync(root)) continue;
    try {
      // prefer medium -> small -> base -> tiny -> first .bin found
      const bins = readdirSync(root).filter((f) => f.endsWith(".bin"));
      for (const pref of ["medium", "small", "base", "tiny"]) {
        const hit = bins.find((b) => b.includes(pref));
        if (hit) return join(root, hit);
      }
      if (bins.length) return join(root, bins[0]);
    } catch {
      /* ignore */
    }
  }
  return undefined;
}

// piper voices shipped via Homebrew live under share/piper-tts
function findPiperModel(): string | undefined {
  const env = process.env.PI_VOICE_PIPER_MODEL;
  if (env && existsSync(env)) return env;
  const roots = [
    "/opt/homebrew/share/piper-tts",
    "/usr/local/share/piper-tts",
    process.env.HOME && join(process.env.HOME, ".local/share/piper"),
  ].filter(Boolean) as string[];
  for (const root of roots) {
    if (!existsSync(root)) continue;
    try {
      // prefer an en_US female-ish default, else any English .onnx
      const files = readdirSync(root);
      const onnx = files.filter((f) => f.endsWith(".onnx"));
      for (const pref of ["en_US", "en_GB"]) {
        const hit = onnx.find((b) => b.includes(pref));
        if (hit) return join(root, hit);
      }
      if (onnx.length) return join(root, onnx[0]);
    } catch {
      /* ignore */
    }
  }
  return undefined;
}

const WHISPER_MODEL = findWhisperModel();
const PIPER_MODEL = findPiperModel();

// --- State ----------------------------------------------------------------

let recording = false;
let ttsEnabled = true;
const speakQueue: string[] = [];
let speaking = false;

// --- STT ------------------------------------------------------------------

async function recordAndTranscribe(): Promise<string> {
  const wav = join(tmpdir(), `pi-voice-${Date.now()}.wav`);
  const txt = wav.replace(/\.wav$/, ".txt");

  try {
    // Record: -d = default device, mono 16kHz PCM.
    await execFile(SOX_BIN, [
      "-d",
      "-r", SAMPLE_RATE,
      "-c", "1",
      "-b", "16",
      wav,
      "trim", "0", String(RECORD_SECONDS),
    ]);

    if (!WHISPER_BIN) {
      throw new Error("whisper binary not found; set PI_VOICE_WHISPER_BIN");
    }
    if (!WHISPER_MODEL) {
      throw new Error("whisper model not found; set PI_VOICE_WHISPER_MODEL");
    }

    const baseName = WHISPER_BIN.split("/").pop() ?? "";
    if (baseName === "whisper-cli" || baseName.endsWith("whisper-cli")) {
      // whisper.cpp: writes <wav>.txt next to the input.
      // -otxt = output .txt, -of = output file base, -nt = no timestamps.
      await execFile(WHISPER_BIN, [
        "-m", WHISPER_MODEL,
        "-f", wav,
        "-otxt",
        "-of", wav.replace(/\.wav$/, ""),
        "-nt",
      ]);
    } else {
      // python openai-whisper: --output_format txt writes <stem>.txt into --output_dir.
      await execFile(WHISPER_BIN, [
        wav,
        "--model", WHISPER_MODEL,
        "--output_format", "txt",
        "--output_dir", tmpdir(),
        "--verbose", "False",
      ]);
      // python names the output after the input stem, e.g. pi-voice-<ts>.txt
      const stem = wav.split("/").pop()!.replace(/\.wav$/, "");
      const pyTxt = join(tmpdir(), `${stem}.txt`);
      const { readFile: rf, unlink: ul } = await import("node:fs/promises");
      try {
        return (await rf(pyTxt, "utf8")).trim();
      } catch {
        return "";
      } finally {
        await ul(pyTxt).catch(() => {});
      }
    }

    const { readFile } = await import("node:fs/promises");
    try {
      return (await readFile(txt, "utf8")).trim();
    } catch {
      // Some builds print to stdout instead.
      return "";
    }
  } finally {
    const { unlink } = await import("node:fs/promises");
    await unlink(wav).catch(() => {});
    await unlink(txt).catch(() => {});
  }
}

// --- TTS ------------------------------------------------------------------

/** Strip noise we don't want spoken: code fences, thinking, tool chatter. */
function cleanForSpeech(text: string): string {
  return text
    .replace(/```[\s\S]*?```/g, " (code block) ")
    .replace(/<thinking>[\s\S]*?<\/thinking>/gi, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/https?:\/\/\S+/g, " (link) ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, 1500);
}

async function speak(text: string): Promise<void> {
  const clean = cleanForSpeech(text);
  if (!clean) return;
  speakQueue.push(clean);
  void drainQueue();
}

async function drainQueue(): Promise<void> {
  if (speaking) return;
  speaking = true;
  try {
    while (speakQueue.length) {
      const next = speakQueue.shift()!;
      await synthesize(next);
    }
  } finally {
    speaking = false;
  }
}

async function synthesize(text: string): Promise<void> {
  if (!PIPER_BIN) {
    // Fallback to macOS `say` if piper isn't available.
    if (process.platform === "darwin") {
      await execFile("say", ["-r", "200", text.slice(0, 1000)]).catch(() => {});
    }
    return;
  }
  const lengthScale = process.env.PI_VOICE_PIPER_LENGTH ?? "1.0";
  const out = join(tmpdir(), `pi-tts-${Date.now()}.wav`);
  const player =
    process.platform === "darwin"
      ? ["afplay", out]
      : ["play", out]; // sox on Linux

  try {
    // piper reads text on stdin and writes a WAV file via --output_file.
    await new Promise<void>((resolve) => {
      const { spawn } = require("node:child_process");
      const args = ["--model", PIPER_MODEL ?? "", "--length-scale", lengthScale, "--output-file", out];
      const piper = spawn(PIPER_BIN, args, { stdio: ["pipe", "ignore", "ignore"] });
      piper.stdin.write(text);
      piper.stdin.end();
      piper.on("close", resolve);
      piper.on("error", resolve);
      // Safety: never wait more than 30s for synthesis.
      setTimeout(() => {
        try { piper.kill("SIGKILL"); } catch { /* */ }
        resolve();
      }, 30_000);
    });
    if (!existsSync(out)) return; // synthesis failed silently
    await execFile(player[0], player.slice(1)).catch(() => {});
  } finally {
    const { unlink } = await import("node:fs/promises");
    await unlink(out).catch(() => {});
  }
}

// --- Extension ------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  const sttReady = Boolean(WHISPER_BIN && WHISPER_MODEL && SOX_BIN);
  const ttsReady = Boolean(PIPER_BIN && PIPER_MODEL) || process.platform === "darwin";

  // Startup diagnostics — surface missing tools without failing the load.
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.mode !== "tui") return;
    const missing: string[] = [];
    if (!SOX_BIN) missing.push("sox (brew install sox)");
    if (!WHISPER_BIN) missing.push("whisper (brew install whisper-cpp)");
    if (!WHISPER_MODEL) missing.push("whisper model (set PI_VOICE_WHISPER_MODEL)");
    if (!PIPER_MODEL) missing.push("piper voice (set PI_VOICE_PIPER_MODEL)");
    if (missing.length) {
      ctx.ui.setStatus(
        "voice",
        `voice: partial — install: ${missing.join("; ")}`,
      );
    } else {
      ctx.ui.setStatus("voice", "voice: ready (Ctrl+Shift+V to talk)");
    }
  });

  // Push-to-talk shortcut.
  pi.registerShortcut("ctrl+shift+v", {
    description: "Voice input (push-to-talk)",
    handler: async (ctx) => {
      if (ctx.mode !== "tui") return;
      if (recording) return; // ignore re-entrance
      if (!sttReady) {
        ctx.ui.notify(
          "STT not ready. Install sox + whisper-cpp and set PI_VOICE_WHISPER_MODEL.",
          "error",
        );
        return;
      }
      recording = true;
      ctx.ui.setStatus("voice", `🎙️  recording ${RECORD_SECONDS}s…`);
      try {
        const text = await recordAndTranscribe();
        if (text) {
          ctx.ui.setStatus("voice", `→ ${text.slice(0, 60)}${text.length > 60 ? "…" : ""}`);
          pi.sendUserMessage(text);
        } else {
          ctx.ui.setStatus("voice", "voice: no transcript");
          ctx.ui.notify("No speech detected", "info");
        }
      } catch (e) {
        ctx.ui.setStatus("voice", "voice: STT error");
        ctx.ui.notify(`STT failed: ${(e as Error).message}`, "error");
      } finally {
        recording = false;
        // Restore idle status after a short beat.
        setTimeout(() => {
          if (!recording) {
            ctx.ui.setStatus("voice", "voice: ready (Ctrl+Shift+V to talk)");
          }
        }, 1500);
      }
    },
  });

  // Speak every finished assistant message.
  pi.on("message_end", async (event, ctx) => {
    if (!ttsEnabled || !ttsReady) return;
    if (ctx.mode !== "tui") return;
    const msg = event.message as { role?: string; content?: unknown };
    if (msg.role !== "assistant") return;
    const parts = (msg.content ?? []) as Array<{ type?: string; text?: string }>;
    const text = parts
      .filter((c) => c.type === "text" && c.text)
      .map((c) => c.text!)
      .join("\n");
    if (text) void speak(text);
  });

  // /voice command: toggle TTS or test STT.
  pi.registerCommand("voice", {
    description: "Voice: toggle TTS or test STT",
    handler: async (args, ctx) => {
      const sub = (args ?? "").trim();
      if (sub === "off") {
        ttsEnabled = false;
        ctx.ui.notify("TTS off", "info");
        return;
      }
      if (sub === "on") {
        ttsEnabled = true;
        ctx.ui.notify("TTS on", "info");
        return;
      }
      if (sub === "toggle") {
        ttsEnabled = !ttsEnabled;
        ctx.ui.notify(`TTS ${ttsEnabled ? "on" : "off"}`, "info");
        return;
      }
      if (sub === "stt") {
        if (!sttReady) {
          ctx.ui.notify("STT not ready", "error");
          return;
        }
        ctx.ui.setStatus("voice", `🎙️  recording ${RECORD_SECONDS}s…`);
        recording = true;
        try {
          const text = await recordAndTranscribe();
          ctx.ui.setStatus("voice", `transcript: ${text || "(empty)"}`);
          ctx.ui.notify(text ? `Heard: ${text}` : "No speech detected", "info");
        } catch (e) {
          ctx.ui.setStatus("voice", "voice: STT error");
          ctx.ui.notify(`STT failed: ${(e as Error).message}`, "error");
        } finally {
          recording = false;
        }
        return;
      }
      // default: status
      ctx.ui.notify(
        [
          `STT: ${sttReady ? "ready" : "missing deps"}`,
          `TTS: ${ttsReady ? "ready" : "missing deps"} (${ttsEnabled ? "on" : "off"})`,
          "Usage: /voice [on|off|toggle|stt]",
        ].join(" · "),
        "info",
      );
    },
  });
}
