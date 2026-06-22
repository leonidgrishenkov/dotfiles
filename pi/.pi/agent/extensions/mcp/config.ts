/**
 * MCP config loading + value resolution.
 *
 * Reads standard MCP config files and merges them (project overrides global
 * per server name). Supports `${VAR}` interpolation for env, cwd, url,
 * headers, and bearer tokens.
 */

import { existsSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";

export interface ServerEntry {
	/** Executable for stdio transport. */
	command?: string;
	/** Arguments for the stdio command. */
	args?: string[];
	/** Environment variables (interpolated, merged over process.env). */
	env?: Record<string, string>;
	/** Working directory for the stdio command (interpolated). */
	cwd?: string;
	/** HTTP endpoint for StreamableHTTP/SSE transport (interpolated). */
	url?: string;
	/** HTTP headers (interpolated). */
	headers?: Record<string, string>;
	/** Set to "bearer" to send an Authorization: Bearer header. */
	auth?: "bearer";
	/** Literal bearer token (interpolated). */
	bearerToken?: string;
	/** Name of an env var holding the bearer token. */
	bearerTokenEnv?: string;
}

export interface LoadedConfig {
	mcpServers: Record<string, ServerEntry>;
	/** Files that were read, for status display. */
	sources: string[];
}

/** Resolve the Pi global agent directory (honors PI_CODING_AGENT_DIR). */
export function agentDir(): string {
	return process.env.PI_CODING_AGENT_DIR || join(homedir(), ".pi", "agent");
}

function readJson(path: string): Record<string, unknown> | null {
	if (!existsSync(path)) return null;
	try {
		const raw = JSON.parse(readFileSync(path, "utf-8"));
		return raw && typeof raw === "object" && !Array.isArray(raw)
			? (raw as Record<string, unknown>)
			: null;
	} catch (err) {
		console.warn(`mcp: failed to parse ${path}: ${err}`);
		return null;
	}
}

function extractServers(raw: Record<string, unknown>): Record<string, ServerEntry> {
	const servers = (raw.mcpServers ?? raw["mcp-servers"]) as unknown;
	if (!servers || typeof servers !== "object" || Array.isArray(servers)) return {};
	return servers as Record<string, ServerEntry>;
}

/**
 * Load and merge MCP config. Precedence (later wins per server):
 *   1. ~/.pi/agent/mcp.json        (global)
 *   2. <cwd>/.mcp.json             (project, shared standard)
 *   3. <cwd>/.pi/mcp.json          (project, Pi override)
 */
export function loadConfig(cwd: string): LoadedConfig {
	const candidates = [
		join(agentDir(), "mcp.json"),
		resolve(cwd, ".mcp.json"),
		resolve(cwd, ".pi", "mcp.json"),
	];

	const sources: string[] = [];
	let merged: Record<string, ServerEntry> = {};

	for (const path of candidates) {
		const raw = readJson(path);
		if (!raw) continue;
		sources.push(path);
		merged = { ...merged, ...extractServers(raw) };
	}

	return { mcpServers: merged, sources };
}

/** Interpolate `${VAR}` references against process.env (unknown vars → ""). */
export function interpolate(value: string): string {
	return value.replace(/\$\{([A-Za-z_][A-Za-z0-9_]*)\}/g, (_, name) => process.env[name] ?? "");
}

/** Build the env for a stdio server: process.env plus interpolated overrides. */
export function resolveEnv(env?: Record<string, string>): Record<string, string> {
	const base: Record<string, string> = {};
	for (const [k, v] of Object.entries(process.env)) {
		if (v !== undefined) base[k] = v;
	}
	if (!env) return base;
	for (const [k, v] of Object.entries(env)) base[k] = interpolate(v);
	return base;
}

/** Resolve the bearer token (literal wins over env var). */
export function resolveBearerToken(entry: ServerEntry): string | undefined {
	if (entry.bearerToken) return interpolate(entry.bearerToken);
	if (entry.bearerTokenEnv) return process.env[entry.bearerTokenEnv];
	return undefined;
}

/** Interpolate header values. */
export function resolveHeaders(headers?: Record<string, string>): Record<string, string> {
	if (!headers) return {};
	const out: Record<string, string> = {};
	for (const [k, v] of Object.entries(headers)) out[k] = interpolate(v);
	return out;
}
