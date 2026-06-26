/**
 * Supertonic Read — configuration.
 *
 * Edit values here and /reload in pi.
 */

export const config = {
  /** Path to Supertonic assets (must contain onnx/ and voice_styles/ subdirectories) */
  assetsDir: "/Users/leonidgrishenkov/.cache/supertonic3",

  /** Voice preset: M1–M5 or F1–F5 */
  voice: "F1",

  /** Language tag: en, ko, ja, na, etc. */
  lang: "en",

  /** Flow-matching denoising steps (5–12, lower = faster, higher = cleaner) */
  totalSteps: 8,

  /** Speech speed multiplier (0.7–2.0) */
  speed: 1.05,

  /** Hard character ceiling before LLM compaction */
  maxLength: 6000,

  /** Seconds of silence inserted between text chunks */
  silenceDuration: 0.3,

  /** Nerd Font devicons shown in the TUI status footer during each pipeline step */
  icons: {
    compact: "\uf0d0",  // nf-fa-magic
    synth: "\uf028",    // nf-fa-volume_up
    play: "\uf04b",     // nf-fa-play
    done: "\uf00c",     // nf-fa-check
    error: "\uf071",    // nf-fa-warning
  },
} as const;

export type Config = typeof config;
