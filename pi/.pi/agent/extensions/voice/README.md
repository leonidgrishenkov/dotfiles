# voice

Voice-in (STT) and voice-out (TTS) for the pi agent.

- **Push-to-talk:** press `Ctrl+Shift+V`, speak for the configured duration, and
  your transcription is sent to the agent as a user message.
- **Spoken replies:** every finished assistant message is spoken aloud.
- **`/voice` command:** toggle TTS, test STT, or show status.

## Dependencies

Install once with Homebrew:

```bash
brew install sox          # audio recording + playback fallback
brew install whisper-cpp  # provides the `whisper-cli` binary
```

`whisper-cpp` does **not** ship model files. Download a GGML model (`.bin`) from
<https://huggingface.co/ggerganov/whisper.cpp/tree/main> and either drop it under
`/opt/homebrew/share/whisper-cpp/` or point `PI_VOICE_WHISPER_MODEL` at it.

Piper TTS is **not** on Homebrew core. Download a prebuilt binary from
<https://github.com/rhasspy/piper/releases> and a voice model (`.onnx` +
`.onnx.json`) from <https://huggingface.co/rhasspy/piper-voices>, then set:

```bash
export PI_VOICE_PIPER_BIN=/path/to/piper
export PI_VOICE_PIPER_MODEL=/path/to/en_US-lessac-medium.onnx
```

If Piper is unavailable on macOS, TTS falls back to the built-in `say` command.

## Configuration (env vars)

| Variable | Default | Purpose |
| --- | --- | --- |
| `PI_VOICE_RECORD_SECONDS` | `6` | Push-to-talk recording length |
| `PI_VOICE_WHISPER_BIN` | auto (`whisper-cli` → `whisper`) | STT binary |
| `PI_VOICE_WHISPER_MODEL` | auto-discovered | Path to a `.bin` model |
| `PI_VOICE_PIPER_BIN` | auto (`piper`) | TTS binary |
| `PI_VOICE_PIPER_MODEL` | auto-discovered | Path to a `.onnx` voice |
| `PI_VOICE_PIPER_LENGTH` | `1.0` | Sentence length scale (lower = faster) |
| `PI_VOICE_SOX_BIN` | auto (`sox`) | Recording binary |

Binaries are auto-detected from Homebrew paths and `$PATH`. Missing tools are
reported in the footer status line at startup without disabling the rest.
