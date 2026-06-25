/**
 * Credential resolution for web search providers.
 *
 * Resolution order:
 *   1. `command` — if set, it is the sole credential source (env vars ignored).
 *   2. `envVars` — tried in order when no `command` is configured.
 */

import { execFile } from "node:child_process";
import { promisify } from "node:util";
import type { CredentialSource } from "./types.ts";

const execFileAsync = promisify(execFile);

/**
 * Resolve an API key from the given credential source.
 * Returns undefined when no key is available.
 */
export async function resolveKey(
	source: CredentialSource,
	signal?: AbortSignal,
): Promise<string | undefined> {
	// 1) command takes priority — when present, env vars are ignored entirely
	if (source.command) {
		try {
			const { stdout } = await execFileAsync("sh", ["-c", source.command], { signal });
			const key = stdout.trim();
			if (key) return key;
		} catch {
			// Command failed or not installed — treat as unavailable
		}
		return undefined;
	}

	// 2) No command — fall back to env vars
	for (const name of source.envVars ) {
		const v = process.env[name];
		if (v) return v;
	}

	return undefined;
}
