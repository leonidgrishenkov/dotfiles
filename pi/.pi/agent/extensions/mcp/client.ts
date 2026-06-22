/**
 * MCP server connection manager.
 *
 * Thin wrapper over @modelcontextprotocol/sdk:
 *   - stdio transport for `command` servers
 *   - StreamableHTTP for `url` servers, with legacy SSE fallback
 *   - lazy connect with concurrent-connect dedup
 *   - in-memory tool metadata cache per server
 *   - content block translation (MCP → Pi tool result content)
 *
 * No OAuth, no disk cache, no sampling/elicitation. Keep it simple.
 */

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp.js";
import { SSEClientTransport } from "@modelcontextprotocol/sdk/client/sse.js";
import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";
import {
	type ServerEntry,
	interpolate,
	resolveBearerToken,
	resolveEnv,
	resolveHeaders,
} from "./config.ts";

export interface McpToolMeta {
	name: string;
	description?: string;
	inputSchema?: Record<string, unknown>;
}

export type ContentBlock =
	| { type: "text"; text: string }
	| { type: "image"; data: string; mimeType: string };

type Closable = { close(): Promise<void> };

interface Connection {
	client: Client;
	transport: Closable;
	tools: McpToolMeta[];
	status: "connected" | "closed";
}

export class McpServerManager {
	private connections = new Map<string, Connection>();
	private connectPromises = new Map<string, Promise<Connection>>();

	getStatus(name: string): "connected" | "closed" {
		return this.connections.get(name)?.status ?? "closed";
	}

	getTools(name: string): McpToolMeta[] {
		return this.connections.get(name)?.tools ?? [];
	}

	/** Connect (or reuse) a server. Concurrent calls for the same name dedupe. */
	async connect(name: string, def: ServerEntry): Promise<Connection> {
		const existing = this.connections.get(name);
		if (existing?.status === "connected") return existing;
		const inflight = this.connectPromises.get(name);
		if (inflight) return inflight;

		const promise = this.doConnect(name, def);
		this.connectPromises.set(name, promise);
		try {
			const conn = await promise;
			this.connections.set(name, conn);
			return conn;
		} finally {
			this.connectPromises.delete(name);
		}
	}

	private async doConnect(name: string, def: ServerEntry): Promise<Connection> {
		if (def.command) {
			const client = new Client({ name: `pi-mcp-${name}`, version: "1.0.0" });
			const transport = new StdioClientTransport({
				command: def.command,
				args: def.args ?? [],
				env: resolveEnv(def.env),
				cwd: def.cwd ? interpolate(def.cwd) : undefined,
				stderr: "ignore",
			});
			await client.connect(transport);
			const tools = await fetchTools(client);
			return { client, transport, tools, status: "connected" };
		}

		if (def.url) {
			const headers = resolveHeaders(def.headers);
			if (def.auth === "bearer") {
				const token = resolveBearerToken(def);
				if (token) headers["Authorization"] = `Bearer ${token}`;
			}
			const requestInit = Object.keys(headers).length > 0 ? { headers } : undefined;
			const url = new URL(interpolate(def.url));

			// Try StreamableHTTP first; fall back to legacy SSE for older servers.
			// Never fall back on auth errors (401/403) — those mean the same for
			// both transports, and SSE's GET would just produce a misleading 405.
			let streamableError: unknown;
			try {
				const client = new Client({ name: `pi-mcp-${name}`, version: "1.0.0" });
				const transport = new StreamableHTTPClientTransport(url, { requestInit });
				await client.connect(transport);
				const tools = await fetchTools(client);
				return { client, transport, tools, status: "connected" };
			} catch (e) {
				if (isAuthError(e)) throw authError(name, e);
				streamableError = e;
			}

			try {
				const client = new Client({ name: `pi-mcp-${name}`, version: "1.0.0" });
				const transport = new SSEClientTransport(url, { requestInit });
				await client.connect(transport);
				const tools = await fetchTools(client);
				return { client, transport, tools, status: "connected" };
			} catch (sseError) {
				if (isAuthError(sseError)) throw authError(name, sseError);
				// Surface the StreamableHTTP error as the primary cause — it's the
				// modern transport and usually the more informative failure.
				const primary = errMsg(streamableError);
				const secondary = errMsg(sseError);
				throw new Error(
					`Failed to connect to "${name}" via HTTP (StreamableHTTP: ${primary}; SSE: ${secondary}). ` +
						`The server may require OAuth — check its .well-known/oauth-protected-resource.`,
				);
			}
		}

		throw new Error(`Server "${name}" has neither command nor url`);
	}

	async callTool(
		name: string,
		tool: string,
		args: Record<string, unknown>,
	): Promise<CallToolResult> {
		const conn = this.connections.get(name);
		if (!conn || conn.status !== "connected") {
			throw new Error(`Server "${name}" is not connected`);
		}
		return conn.client.callTool({ name: tool, arguments: args });
	}

	async close(name: string): Promise<void> {
		const conn = this.connections.get(name);
		if (!conn) return;
		conn.status = "closed";
		this.connections.delete(name);
		await conn.client.close().catch(() => {});
		await conn.transport.close().catch(() => {});
	}

	async closeAll(): Promise<void> {
		await Promise.all([...this.connections.keys()].map((n) => this.close(n)));
	}
}

/** Page through listTools (servers may paginate via nextCursor). */
async function fetchTools(client: Client): Promise<McpToolMeta[]> {
	const all: McpToolMeta[] = [];
	let cursor: string | undefined;
	do {
		const res = await client.listTools(cursor ? { cursor } : undefined);
		all.push(...(res.tools ?? []));
		cursor = res.nextCursor;
	} while (cursor);
	return all;
}

/** Extract a message from an unknown error (used for HTTP error reporting). */
function errMsg(e: unknown): string {
	return e instanceof Error
		? `${e.message} ${String((e as Error & { status?: number }).status ?? "")}`.trim()
		: String(e);
}

/** True if an error looks like an HTTP auth failure (401/403). */
function isAuthError(e: unknown): boolean {
	return /\b(401|403)\b|unauthor/i.test(errMsg(e));
}

/** Build a clear auth-required error mentioning the likely OAuth flow. */
function authError(name: string, e: unknown): Error {
	return new Error(
		`Server "${name}" requires authentication (HTTP 401/403). This extension supports bearer tokens only (set "auth":"bearer" + "bearerToken"/"bearerTokenEnv"); OAuth is not supported.`,
	);
}

/** Translate MCP content blocks into Pi tool-result content blocks. */
export function transformContent(content: unknown[]): ContentBlock[] {
	const out: ContentBlock[] = [];
	for (const raw of content as Array<Record<string, unknown>>) {
		if (!raw || typeof raw !== "object") continue;
		switch (raw.type) {
			case "text":
				out.push({ type: "text", text: String(raw.text ?? "") });
				break;
			case "image":
				out.push({
					type: "image",
					data: String(raw.data ?? ""),
					mimeType: String(raw.mimeType ?? "image/png"),
				});
				break;
			case "resource": {
				const resource = raw.resource as Record<string, unknown> | undefined;
				const uri = resource?.uri ?? "(no uri)";
				const text = resource?.text ?? (resource ? JSON.stringify(resource) : "(no content)");
				out.push({ type: "text", text: `[Resource: ${uri}]\n${text}` });
				break;
			}
			case "resource_link":
				out.push({
					type: "text",
					text: `[Resource Link: ${raw.name ?? raw.uri ?? "unknown"}]`,
				});
				break;
			case "audio":
				out.push({ type: "text", text: `[Audio: ${raw.mimeType ?? "audio/*"}]` });
				break;
			default:
				out.push({ type: "text", text: JSON.stringify(raw) });
		}
	}
	return out;
}
