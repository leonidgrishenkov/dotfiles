/**
 * Text processing and WAV utilities for Supertonic TTS.
 * Adapted from supertonic/nodejs/helper.js
 */

import * as fs from "node:fs";
import * as path from "node:path";

const AVAILABLE_LANGS = [
  "en", "ko", "ja", "ar", "bg", "cs", "da", "de", "el", "es",
  "et", "fi", "fr", "hi", "hr", "hu", "id", "it", "lt", "lv",
  "nl", "pl", "pt", "ro", "ru", "sk", "sl", "sv", "tr", "uk", "vi", "na",
];

// ============================================================
// Text preprocessing
// ============================================================

export class UnicodeProcessor {
  private indexer: Record<string, number>;

  constructor(unicodeIndexerJsonPath: string) {
    this.indexer = JSON.parse(fs.readFileSync(unicodeIndexerJsonPath, "utf8"));
  }

  preprocessText(text: string, lang: string): string {
    text = text.normalize("NFKD");

    // Remove emojis
    const emojiPattern =
      /[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]+/gu;
    text = text.replace(emojiPattern, "");

    // Replace dashes and symbols
    const replacements: Record<string, string> = {
      "–": "-", "‑": "-", "—": "-", "_": " ",
      "\u201C": '"', "\u201D": '"', "\u2018": "'", "\u2019": "'",
      "´": "'", "`": "'",
      "[": " ", "]": " ", "|": " ", "/": " ", "#": " ",
      "→": " ", "←": " ",
    };
    for (const [k, v] of Object.entries(replacements)) {
      text = text.replaceAll(k, v);
    }

    text = text.replace(/[♥☆♡©\\]/g, "");

    const exprReplacements: Record<string, string> = {
      "@": " at ",
      "e.g.,": "for example, ",
      "i.e.,": "that is, ",
    };
    for (const [k, v] of Object.entries(exprReplacements)) {
      text = text.replaceAll(k, v);
    }

    // Fix spacing around punctuation
    text = text.replace(/ ,/g, ",");
    text = text.replace(/ \./g, ".");
    text = text.replace(/ !/g, "!");
    text = text.replace(/ \?/g, "?");
    text = text.replace(/ ;/g, ";");
    text = text.replace(/ :/g, ":");
    text = text.replace(/ '/g, "'");

    // Remove duplicate quotes
    while (text.includes('""')) text = text.replace('""', '"');
    while (text.includes("''")) text = text.replace("''", "'");

    // Collapse whitespace
    text = text.replace(/\s+/g, " ").trim();

    // Ensure ends with punctuation
    if (!/[.!?;:,'\"')\]}…。」』】〉》›»]$/.test(text)) {
      text += ".";
    }

    if (!AVAILABLE_LANGS.includes(lang)) {
      throw new Error(`Invalid language: ${lang}. Available: ${AVAILABLE_LANGS.join(", ")}`);
    }

    text = `<${lang}>` + text + `</${lang}>`;
    return text;
  }

  textToUnicodeValues(text: string): number[] {
    return Array.from(text).map((char) => char.charCodeAt(0));
  }

  call(textList: string[], langList: string[]) {
    const processedTexts = textList.map((t, i) => this.preprocessText(t, langList[i]));
    const textIdsLengths = processedTexts.map((t) => t.length);
    const maxLen = Math.max(...textIdsLengths);

    const textIds: number[][] = [];
    for (let i = 0; i < processedTexts.length; i++) {
      const row = new Array(maxLen).fill(0);
      const unicodeVals = this.textToUnicodeValues(processedTexts[i]);
      for (let j = 0; j < unicodeVals.length; j++) {
        row[j] = this.indexer[unicodeVals[j]] ?? 0;
      }
      textIds.push(row);
    }

    const textMask = lengthToMask(textIdsLengths);
    return { textIds, textMask };
  }
}

// ============================================================
// Mask utilities
// ============================================================

export function lengthToMask(lengths: number[], maxLen?: number): number[][][] {
  maxLen = maxLen ?? Math.max(...lengths);
  const mask: number[][][] = [];
  for (let i = 0; i < lengths.length; i++) {
    const row: number[] = [];
    for (let j = 0; j < maxLen; j++) {
      row.push(j < lengths[i] ? 1.0 : 0.0);
    }
    mask.push([row]);
  }
  return mask;
}

export function getLatentMask(
  wavLengths: number[],
  baseChunkSize: number,
  chunkCompressFactor: number,
): number[][][] {
  const latentSize = baseChunkSize * chunkCompressFactor;
  const latentLengths = wavLengths.map((len) =>
    Math.floor((len + latentSize - 1) / latentSize),
  );
  return lengthToMask(latentLengths);
}

// ============================================================
// WAV writer
// ============================================================

export function writeWavFile(filename: string, audioData: number[], sampleRate: number): void {
  const numChannels = 1;
  const bitsPerSample = 16;
  const byteRate = (sampleRate * numChannels * bitsPerSample) / 8;
  const blockAlign = (numChannels * bitsPerSample) / 8;
  const dataSize = (audioData.length * bitsPerSample) / 8;

  const buffer = Buffer.alloc(44 + dataSize);

  buffer.write("RIFF", 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write("WAVE", 8);
  buffer.write("fmt ", 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(numChannels, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(byteRate, 28);
  buffer.writeUInt16LE(blockAlign, 32);
  buffer.writeUInt16LE(bitsPerSample, 34);
  buffer.write("data", 36);
  buffer.writeUInt32LE(dataSize, 40);

  for (let i = 0; i < audioData.length; i++) {
    const sample = Math.max(-1, Math.min(1, audioData[i]));
    const intSample = Math.floor(sample * 32767);
    buffer.writeInt16LE(intSample, 44 + i * 2);
  }

  fs.writeFileSync(filename, buffer);
}

export function writeWavBuffer(audioData: number[], sampleRate: number): Buffer {
  const numChannels = 1;
  const bitsPerSample = 16;
  const byteRate = (sampleRate * numChannels * bitsPerSample) / 8;
  const blockAlign = (numChannels * bitsPerSample) / 8;
  const dataSize = (audioData.length * bitsPerSample) / 8;

  const buffer = Buffer.alloc(44 + dataSize);

  buffer.write("RIFF", 0);
  buffer.writeUInt32LE(36 + dataSize, 4);
  buffer.write("WAVE", 8);
  buffer.write("fmt ", 12);
  buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20);
  buffer.writeUInt16LE(numChannels, 22);
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(byteRate, 28);
  buffer.writeUInt16LE(blockAlign, 32);
  buffer.writeUInt16LE(bitsPerSample, 34);
  buffer.write("data", 36);
  buffer.writeUInt32LE(dataSize, 40);

  for (let i = 0; i < audioData.length; i++) {
    const sample = Math.max(-1, Math.min(1, audioData[i]));
    const intSample = Math.floor(sample * 32767);
    buffer.writeInt16LE(intSample, 44 + i * 2);
  }

  return buffer;
}

// ============================================================
// Text chunking
// ============================================================

export function chunkText(text: string, maxLen = 300): string[] {
  if (typeof text !== "string") {
    throw new Error(`chunkText expects a string, got ${typeof text}`);
  }

  const paragraphs = text.trim().split(/\n\s*\n+/).filter((p) => p.trim());
  const chunks: string[] = [];

  for (let paragraph of paragraphs) {
    paragraph = paragraph.trim();
    if (!paragraph) continue;

    const sentences = paragraph.split(
      /(?<!Mr\.|Mrs\.|Ms\.|Dr\.|Prof\.|Sr\.|Jr\.|Ph\.D\.|etc\.|e\.g\.|i\.e\.|vs\.|Inc\.|Ltd\.|Co\.|Corp\.|St\.|Ave\.|Blvd\.)(?<!\b[A-Z]\.)(?<=[.!?])\s+/,
    );

    let currentChunk = "";

    for (const sentence of sentences) {
      if (currentChunk.length + sentence.length + 1 <= maxLen) {
        currentChunk += (currentChunk ? " " : "") + sentence;
      } else {
        if (currentChunk) chunks.push(currentChunk.trim());
        currentChunk = sentence;
      }
    }

    if (currentChunk) chunks.push(currentChunk.trim());
  }

  return chunks;
}

// ============================================================
// Markdown → speech-friendly plain text
// ============================================================

export function stripMarkdownForSpeech(markdown: string): string {
  let text = markdown;

  // Remove code blocks entirely (```...```)
  text = text.replace(/```[\s\S]*?```/g, "");

  // Remove inline code
  text = text.replace(/`([^`]+)`/g, "$1");

  // Remove images
  text = text.replace(/!\[([^\]]*)\]\([^)]*\)/g, "");

  // Convert links to just their text
  text = text.replace(/\[([^\]]*)\]\([^)]*\)/g, "$1");

  // Remove HTML tags
  text = text.replace(/<[^>]+>/g, "");

  // Remove headers markers (keep text)
  text = text.replace(/^#{1,6}\s+/gm, "");

  // Remove bold/italic markers
  text = text.replace(/\*{1,3}([^*]+)\*{1,3}/g, "$1");
  text = text.replace(/_{1,3}([^_]+)_{1,3}/g, "$1");

  // Remove strikethrough
  text = text.replace(/~~([^~]+)~~/g, "$1");

  // Remove blockquote markers (keep text)
  text = text.replace(/^>\s+/gm, "");

  // Remove horizontal rules
  text = text.replace(/^[-*_]{3,}\s*$/gm, "");

  // Remove list markers
  text = text.replace(/^[\s]*[-*+]\s+/gm, "");
  text = text.replace(/^[\s]*\d+\.\s+/gm, "");

  // Remove table separators (|---|---|)
  text = text.replace(/^\|[-|: ]+\|$/gm, "");

  // Convert table cells to sentences (| a | b | → a, b)
  text = text.replace(/^\|(.+)\|$/gm, (_, cells: string) => {
    return cells
      .split("|")
      .map((c: string) => c.trim())
      .filter(Boolean)
      .join(", ");
  });

  // Collapse multiple newlines
  text = text.replace(/\n{3,}/g, "\n\n");

  // Trim and collapse whitespace within lines
  text = text
    .split("\n")
    .map((line) => line.replace(/\s+/g, " ").trim())
    .filter((line) => line.length > 0)
    .join(" ");

  return text.trim();
}
