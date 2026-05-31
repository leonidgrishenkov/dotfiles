/**
 * Configuration + credential lookup.
 *
 * Inspired by oh-my-pi's `web/search/providers/utils.ts` (credential lookup)
 * and `provider.ts` (preferred-provider selection), but key sources are
 * env-first then 1Password `op`, and preferences live in a small JSON file.
 *
 * Optional config file ~/.pi/agent/web-search.json:
 *   {
 *     "provider": "auto",            // "auto" | "tavily" | "brave" | "perplexity" | "exa"
 *     "op": {
 *       "tavily":     "op://Vault/Tavily/credential",
 *       "brave":      "op://Vault/Brave/credential",
 *       "perplexity": "op://Vault/Perplexity/credential",
 *       "exa":        "op://Vault/Exa/credential"
 *     }
 *   }
 */

import { execFile } from "node:child_process";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { promisify } from "node:util";
import { getAgentDir } from "@earendil-works/pi-coding-agent";
import type { ProviderName } from "./types.ts";

const execFileAsync = promisify(execFile);

interface WebSearchConfig {
	provider?: string;
	op?: Partial<Record<ProviderName, string>>;
}

let cachedConfig: WebSearchConfig | undefined;

export function loadConfig(): WebSearchConfig {
	if (cachedConfig) return cachedConfig;
	let config: WebSearchConfig = {};
	try {
		const path = join(getAgentDir(), "web-search.json");
		if (existsSync(path)) config = JSON.parse(readFileSync(path, "utf-8")) as WebSearchConfig;
	} catch {
		// Malformed config -> fall back to env-only.
	}
	cachedConfig = config;
	return config;
}

// --- 1Password (op) ---------------------------------------------------------

let opAvailable: boolean | undefined;

async function readOp(ref: string, signal?: AbortSignal): Promise<string | undefined> {
	if (opAvailable === false) return undefined;
	try {
		const { stdout } = await execFileAsync("op", ["read", ref], { signal });
		opAvailable = true;
		return stdout.trim() || undefined;
	} catch (err: unknown) {
		// `op` not installed -> remember and stop trying.
		if ((err as { code?: string })?.code === "ENOENT") opAvailable = false;
		return undefined;
	}
}

/** Resolve a key from env vars first, then from an op:// ref in config. */
export async function resolveKey(
	envVars: string[],
	provider: ProviderName,
	signal?: AbortSignal,
): Promise<string | undefined> {
	for (const name of envVars) {
		const v = process.env[name];
		if (v) return v;
	}
	const ref = loadConfig().op?.[provider];
	if (ref) return readOp(ref, signal);
	return undefined;
}
