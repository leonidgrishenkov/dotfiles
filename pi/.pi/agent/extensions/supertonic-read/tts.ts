/**
 * Supertonic TTS engine — adapted from supertonic/nodejs/helper.js
 *
 * Loads ONNX models and voice styles, runs the full inference pipeline
 * (duration predictor → text encoder → vector estimator → vocoder),
 * and produces 44.1 kHz WAV audio.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import * as ort from "onnxruntime-node";

import {
  UnicodeProcessor,
  getLatentMask,
  lengthToMask,
  chunkText,
} from "./utils.ts";

// ============================================================
// Types
// ============================================================

export interface TtsConfig {
  ae: { sample_rate: number; base_chunk_size: number };
  ttl: { chunk_compress_factor: number; latent_dim: number };
}

export interface Style {
  ttl: ort.Tensor;
  dp: ort.Tensor;
}

export interface SynthResult {
  wav: number[];
  duration: number[];
}

// ============================================================
// Tensor helpers
// ============================================================

function arrayToTensor(array: number[][][], dims: number[]): ort.Tensor {
  const flat = array.flat(Infinity) as number[];
  return new ort.Tensor("float32", Float32Array.from(flat), dims);
}

function intArrayToTensor(array: number[][], dims: number[]): ort.Tensor {
  const flat = array.flat(Infinity) as number[];
  return new ort.Tensor("int64", BigInt64Array.from(flat.map((x) => BigInt(x))), dims);
}

// ============================================================
// TextToSpeech
// ============================================================

export class TextToSpeech {
  readonly sampleRate: number;
  private baseChunkSize: number;
  private chunkCompressFactor: number;
  private ldim: number;
  private textProcessor: UnicodeProcessor;
  private dpOrt: ort.InferenceSession;
  private textEncOrt: ort.InferenceSession;
  private vectorEstOrt: ort.InferenceSession;
  private vocoderOrt: ort.InferenceSession;

  constructor(
    cfgs: TtsConfig,
    textProcessor: UnicodeProcessor,
    dpOrt: ort.InferenceSession,
    textEncOrt: ort.InferenceSession,
    vectorEstOrt: ort.InferenceSession,
    vocoderOrt: ort.InferenceSession,
  ) {
    this.sampleRate = cfgs.ae.sample_rate;
    this.baseChunkSize = cfgs.ae.base_chunk_size;
    this.chunkCompressFactor = cfgs.ttl.chunk_compress_factor;
    this.ldim = cfgs.ttl.latent_dim;
    this.textProcessor = textProcessor;
    this.dpOrt = dpOrt;
    this.textEncOrt = textEncOrt;
    this.vectorEstOrt = vectorEstOrt;
    this.vocoderOrt = vocoderOrt;
  }

  private sampleNoisyLatent(duration: number[]) {
    const wavLenMax = Math.max(...duration) * this.sampleRate;
    const wavLengths = duration.map((d) => Math.floor(d * this.sampleRate));
    const chunkSize = this.baseChunkSize * this.chunkCompressFactor;
    const latentLen = Math.floor((wavLenMax + chunkSize - 1) / chunkSize);
    const latentDim = this.ldim * this.chunkCompressFactor;

    const noisyLatent: number[][][] = [];
    for (let b = 0; b < duration.length; b++) {
      const batch: number[][] = [];
      for (let d = 0; d < latentDim; d++) {
        const row: number[] = [];
        for (let t = 0; t < latentLen; t++) {
          const eps = 1e-10;
          const u1 = Math.max(eps, Math.random());
          const u2 = Math.random();
          row.push(Math.sqrt(-2.0 * Math.log(u1)) * Math.cos(2.0 * Math.PI * u2));
        }
        batch.push(row);
      }
      noisyLatent.push(batch);
    }

    const latentMask = getLatentMask(wavLengths, this.baseChunkSize, this.chunkCompressFactor);

    for (let b = 0; b < noisyLatent.length; b++) {
      for (let d = 0; d < noisyLatent[b].length; d++) {
        for (let t = 0; t < noisyLatent[b][d].length; t++) {
          noisyLatent[b][d][t] *= latentMask[b][0][t];
        }
      }
    }

    return { noisyLatent, latentMask };
  }

  private async _infer(
    textList: string[],
    langList: string[],
    style: Style,
    totalStep: number,
    speed = 1.05,
  ): Promise<SynthResult> {
    if (textList.length !== style.ttl.dims[0]) {
      throw new Error("Number of texts must match number of style vectors");
    }
    const bsz = textList.length;
    const { textIds, textMask } = this.textProcessor.call(textList, langList);
    const textIdsShape = [bsz, textIds[0].length];
    const textMaskShape = [bsz, 1, textMask[0][0].length];
    const textMaskTensor = arrayToTensor(textMask, textMaskShape);

    // Duration predictor
    const dpResult = await this.dpOrt.run({
      text_ids: intArrayToTensor(textIds, textIdsShape),
      style_dp: style.dp,
      text_mask: textMaskTensor,
    });

    const durOnnx = Array.from(dpResult.duration.data as Float32Array);
    for (let i = 0; i < durOnnx.length; i++) {
      durOnnx[i] /= speed;
    }

    // Text encoder
    const textEncResult = await this.textEncOrt.run({
      text_ids: intArrayToTensor(textIds, textIdsShape),
      style_ttl: style.ttl,
      text_mask: textMaskTensor,
    });

    const textEmbTensor = textEncResult.text_emb;

    // Flow matching denoising
    let { noisyLatent, latentMask } = this.sampleNoisyLatent(durOnnx);
    const latentShape = [bsz, noisyLatent[0].length, noisyLatent[0][0].length];
    const latentMaskShape = [bsz, 1, latentMask[0][0].length];
    const latentMaskTensor = arrayToTensor(latentMask, latentMaskShape);
    const totalStepArray = new Array(bsz).fill(totalStep);
    const scalarShape = [bsz];
    const totalStepTensor = arrayToTensor(totalStepArray, scalarShape);

    for (let step = 0; step < totalStep; step++) {
      const currentStepArray = new Array(bsz).fill(step);

      const vectorEstResult = await this.vectorEstOrt.run({
        noisy_latent: arrayToTensor(noisyLatent, latentShape),
        text_emb: textEmbTensor,
        style_ttl: style.ttl,
        text_mask: textMaskTensor,
        latent_mask: latentMaskTensor,
        total_step: totalStepTensor,
        current_step: arrayToTensor(currentStepArray, scalarShape),
      });

      const denoisedLatent = Array.from(vectorEstResult.denoised_latent.data as Float32Array);

      let idx = 0;
      for (let b = 0; b < noisyLatent.length; b++) {
        for (let d = 0; d < noisyLatent[b].length; d++) {
          for (let t = 0; t < noisyLatent[b][d].length; t++) {
            noisyLatent[b][d][t] = denoisedLatent[idx++];
          }
        }
      }
    }

    // Vocoder
    const vocoderResult = await this.vocoderOrt.run({
      latent: arrayToTensor(noisyLatent, latentShape),
    });

    const wav = Array.from(vocoderResult.wav_tts.data as Float32Array);
    return { wav, duration: durOnnx };
  }

  /**
   * Single-speaker synthesis with automatic text chunking.
   */
  async call(
    text: string,
    lang: string,
    style: Style,
    totalStep: number,
    speed = 1.05,
    silenceDuration = 0.3,
  ): Promise<SynthResult> {
    if (style.ttl.dims[0] !== 1) {
      throw new Error("Single speaker TTS only supports single style");
    }
    const maxLen = lang === "ko" || lang === "ja" ? 120 : 300;
    const textList = chunkText(text, maxLen);

    let wavCat: number[] | null = null;
    let durCat = 0;

    for (const chunk of textList) {
      const { wav, duration } = await this._infer([chunk], [lang], style, totalStep, speed);

      if (wavCat === null) {
        wavCat = wav;
        durCat = duration[0];
      } else {
        const silenceLen = Math.floor(silenceDuration * this.sampleRate);
        const silence = new Array(silenceLen).fill(0);
        wavCat = [...wavCat, ...silence, ...wav];
        durCat += duration[0] + silenceDuration;
      }
    }

    return { wav: wavCat!, duration: [durCat] };
  }
}

// ============================================================
// Factory functions
// ============================================================

export async function loadTextToSpeech(onnxDir: string): Promise<TextToSpeech> {
  const opts: ort.InferenceSession.SessionOptions = {};

  const cfgPath = path.join(onnxDir, "tts.json");
  const cfgs: TtsConfig = JSON.parse(fs.readFileSync(cfgPath, "utf8"));

  const [dpOrt, textEncOrt, vectorEstOrt, vocoderOrt] = await Promise.all([
    ort.InferenceSession.create(path.join(onnxDir, "duration_predictor.onnx"), opts),
    ort.InferenceSession.create(path.join(onnxDir, "text_encoder.onnx"), opts),
    ort.InferenceSession.create(path.join(onnxDir, "vector_estimator.onnx"), opts),
    ort.InferenceSession.create(path.join(onnxDir, "vocoder.onnx"), opts),
  ]);

  const textProcessor = new UnicodeProcessor(
    path.join(onnxDir, "unicode_indexer.json"),
  );

  return new TextToSpeech(cfgs, textProcessor, dpOrt, textEncOrt, vectorEstOrt, vocoderOrt);
}

export function loadVoiceStyle(voiceStylePaths: string[]): Style {
  const bsz = voiceStylePaths.length;
  const firstStyle = JSON.parse(fs.readFileSync(voiceStylePaths[0], "utf8"));
  const ttlDims = firstStyle.style_ttl.dims as number[];
  const dpDims = firstStyle.style_dp.dims as number[];

  const ttlDim1 = ttlDims[1];
  const ttlDim2 = ttlDims[2];
  const dpDim1 = dpDims[1];
  const dpDim2 = dpDims[2];

  const ttlFlat = new Float32Array(bsz * ttlDim1 * ttlDim2);
  const dpFlat = new Float32Array(bsz * dpDim1 * dpDim2);

  for (let i = 0; i < bsz; i++) {
    const vs = JSON.parse(fs.readFileSync(voiceStylePaths[i], "utf8"));
    const ttlData = vs.style_ttl.data.flat(Infinity) as number[];
    ttlFlat.set(ttlData, i * ttlDim1 * ttlDim2);
    const dpData = vs.style_dp.data.flat(Infinity) as number[];
    dpFlat.set(dpData, i * dpDim1 * dpDim2);
  }

  const ttlStyle = new ort.Tensor("float32", ttlFlat, [bsz, ttlDim1, ttlDim2]);
  const dpStyle = new ort.Tensor("float32", dpFlat, [bsz, dpDim1, dpDim2]);

  return { ttl: ttlStyle, dp: dpStyle };
}
