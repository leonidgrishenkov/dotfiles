/**
 * MCP client extension for Pi.
 *
 * Registers a single token-efficient `mcp` proxy tool (~150 tokens) that
 * discovers and calls tools on configured MCP servers, plus a `/mcp` command
 * for status / reconnect / tools listing via native Pi dialogs.
 *
 * Servers connect lazily on first use and close on session shutdown.
 *
 * Config (merged, later wins per server):
 *   ~/.pi/agent/mcp.json   (global)
 *   <cwd>/.mcp.json        (project, shared standard)
 *   <cwd>/.pi/mcp.json     (project, Pi override)
 *
 * See README.md for the server entry shape.
 */

import type {
	AgentToolResult,
	ExtensionAPI,
	ExtensionContext,
} from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";
import type { AutocompleteItem } from "@earendil-works/pi-tui";
import { loadConfig, type LoadedConfig, type ServerEntry } from "./config.ts";
import {
	McpServerManager,
	transformContent,
	type McpToolMeta,
} from "./client.ts";

interface State {
	config: LoadedConfig;
	manager: McpServerManager;
}

type Result = AgentToolResult<Record<string, unknown>>;

const PROXY_DESCRIPTION = `Call tools on configured MCP (Model Context Protocol) servers.

Modes (pass one):
- status: true             → show configured servers and connection state
- search: "substring"      → find tools by name/description across all servers
- server: "name"           → list all tools on a server
- tool: "name"             → call a tool (pass args if the tool needs parameters)
  - args: { ... }          → tool arguments as a JSON object
  - server: "name"         → optional, disambiguate when a tool exists on multiple servers

Workflow: call mcp({}) to see status, then mcp({ search: "..." }) to find the right tool, then mcp({ tool: "name", args: {...} }) to call it. Servers connect lazily on first use.`;

export default function mcpExtension(pi: ExtensionAPI) {
	let state: State | null = null;

	// ---- lifecycle ----------------------------------------------------------

	pi.on("session_start", async (_event, ctx) => {
		const config = loadConfig(ctx.cwd);
		state = { config, manager: new McpServerManager() };
		refreshStatus(ctx);
	});

	pi.on("session_shutdown", async () => {
		await state?.manager.closeAll();
		state = null;
	});

	// ---- proxy tool ---------------------------------------------------------

	pi.registerTool({
		name: "mcp",
		label: "MCP",
		description: PROXY_DESCRIPTION,
		promptSnippet: "Call tools on configured MCP servers (status/search/list/call)",
		promptGuidelines: [
			"Use mcp to access external tools provided by MCP servers. Search before calling if unsure of the exact tool name.",
		],
		parameters: Type.Object({
			tool: Type.Optional(
				Type.String({ description: "Tool name to call" }),
			),
			args: Type.Optional(
				Type.Record(Type.String(), Type.Any(), {
					description: 'Arguments object for the tool, e.g. {"query": "..."}',
				}),
			),
			server: Type.Optional(
				Type.String({
					description: "Server name to list tools for, or to disambiguate a tool call",
				}),
			),
			search: Type.Optional(
				Type.String({
					description: "Substring to search for in tool names and descriptions across all servers",
				}),
			),
			status: Type.Optional(
				Type.Boolean({ description: "Show MCP server and tool status" }),
			),
		}),
		async execute(_id, params, _signal, _onUpdate, ctx) {
			if (!state) return err("MCP not initialized.");
			const { config, manager } = state;

			const wantStatus =
				params.status === true ||
				(!params.tool && !params.search && !params.server);

			if (wantStatus) return statusResult(config, manager);
			if (params.search) return await searchResult(config, manager, params.search);
			if (params.tool) {
				return await callResult(config, manager, params.tool, params.args, params.server);
			}
			if (params.server) return await listResult(config, manager, params.server);
			return statusResult(config, manager);
		},
	});

	// ---- /mcp command -------------------------------------------------------

	pi.registerCommand("mcp", {
		description: "MCP servers: status, reconnect, tools",
		getArgumentCompletions(prefix: string): AutocompleteItem[] | null {
			const subs = ["status", "reconnect", "tools"];
			const items = subs
				.filter((s) => s.startsWith(prefix))
				.map((s) => ({ value: s, label: s }));
			return items.length > 0 ? items : null;
		},
		handler: async (args, ctx) => {
			if (!state) {
				if (ctx.hasUI) ctx.ui.notify("MCP not initialized", "error");
				return;
			}
			const { config, manager } = state;
			const parts = (args ?? "").trim().split(/\s+/).filter(Boolean);
			const sub = parts[0] ?? "status";
			const target = parts[1];

			if (sub === "reconnect") {
				const server = target ?? (await pickServer(config, ctx));
				if (!server) return;
				await manager.close(server);
				try {
					await manager.connect(server, config.mcpServers[server]);
					ctx.ui?.notify(
						`✓ Reconnected to ${server} (${manager.getTools(server).length} tools)`,
						"info",
					);
				} catch (e) {
					ctx.ui?.notify(`✗ ${server}: ${msg(e)}`, "error");
				}
				refreshStatus(ctx);
				return;
			}

			if (sub === "tools") {
				const server = target ?? (await pickServer(config, ctx));
				if (!server) return;
				if (manager.getStatus(server) !== "connected") {
					try {
						await manager.connect(server, config.mcpServers[server]);
					} catch (e) {
						ctx.ui?.notify(`✗ ${server}: ${msg(e)}`, "error");
						return;
					}
				}
				const tools = manager.getTools(server);
				const lines = [
					`${server} (${tools.length} tools):`,
					...tools.map((t) => `  ${t.name}`),
				];
				ctx.ui?.notify(lines.join("\n"), "info");
				refreshStatus(ctx);
				return;
			}

			// default: status
			ctx.ui?.notify(statusText(config, manager), "info");
		},
	});

	// ---- helpers ------------------------------------------------------------

	function refreshStatus(ctx: ExtensionContext) {
		if (!ctx.hasUI || !state) {
			return;
		}
		const names = Object.keys(state.config.mcpServers);
		if (names.length === 0) {
			ctx.ui.setStatus("mcp", undefined);
			return;
		}
		const connected = names.filter((n) => state!.manager.getStatus(n) === "connected").length;
		ctx.ui.setStatus("mcp", `MCP: ${connected}/${names.length} connected`);
	}
}

// ---------------------------------------------------------------------------
// Proxy tool result builders (module scope, pure where possible)
// ---------------------------------------------------------------------------

function ok(text: string): Result {
	return { content: [{ type: "text", text }], details: {} };
}

function err(text: string): Result {
	return { content: [{ type: "text", text }], details: { error: true } };
}

function msg(e: unknown): string {
	return e instanceof Error ? e.message : String(e);
}

function statusText(config: LoadedConfig, manager: McpServerManager): string {
	const names = Object.keys(config.mcpServers);
	if (names.length === 0) {
		return "No MCP servers configured.\nAdd servers to ~/.pi/agent/mcp.json or .mcp.json (project).";
	}
	const lines = names.map((n) => {
		const s = manager.getStatus(n);
		const icon = s === "connected" ? "✓" : "○";
		const t = manager.getTools(n).length;
		return `${icon} ${n}${t ? ` (${t} tools)` : ""}`;
	});
	return ["MCP servers:", ...lines].join("\n");
}

function statusResult(config: LoadedConfig, manager: McpServerManager): Result {
	const names = Object.keys(config.mcpServers);
	if (names.length === 0) {
		return ok(
			"No MCP servers configured. Add servers to ~/.pi/agent/mcp.json or .mcp.json (project).",
		);
	}
	let text = `MCP: ${names.length} server(s)\n\n`;
	for (const name of names) {
		const s = manager.getStatus(name);
		const icon = s === "connected" ? "✓" : "○";
		const tools = manager.getTools(name);
		const toolNote = tools.length > 0 ? ` (${tools.length} tools)` : "";
		text += `${icon} ${name}${toolNote}\n`;
	}
	text +=
		"\nUse mcp({ search: \"...\" }) to find tools, mcp({ server: \"name\" }) to list a server's tools, mcp({ tool: \"name\", args: {...} }) to call.";
	return ok(text);
}

async function ensureAllConnected(config: LoadedConfig, manager: McpServerManager) {
	await Promise.all(
		Object.entries(config.mcpServers).map(async ([name, def]) => {
			if (manager.getStatus(name) === "connected") return;
			try {
				await manager.connect(name, def);
			} catch {
				/* skip disconnected servers — search just won't see them */
			}
		}),
	);
}

async function searchResult(
	config: LoadedConfig,
	manager: McpServerManager,
	query: string,
): Promise<Result> {
	const q = query.toLowerCase();
	await ensureAllConnected(config, manager);

	const matches: Array<{ server: string; tool: McpToolMeta }> = [];
	for (const name of Object.keys(config.mcpServers)) {
		for (const tool of manager.getTools(name)) {
			const hay = `${tool.name} ${tool.description ?? ""}`.toLowerCase();
			if (hay.includes(q)) matches.push({ server: name, tool });
		}
	}

	if (matches.length === 0) return ok(`No tools matching "${query}".`);
	let text = `Found ${matches.length} tool(s) matching "${query}":\n\n`;
	for (const m of matches) {
		text += `${m.server} / ${m.tool.name}`;
		if (m.tool.description) {
			text += ` — ${m.tool.description.split("\n")[0].slice(0, 100)}`;
		}
		text += "\n";
	}
	text += '\nCall with mcp({ tool: "name", args: {...}, server: "optional" }).';
	return ok(text);
}

async function listResult(
	config: LoadedConfig,
	manager: McpServerManager,
	server: string,
): Promise<Result> {
	if (!config.mcpServers[server]) return err(`Server "${server}" not configured.`);
	if (manager.getStatus(server) !== "connected") {
		try {
			await manager.connect(server, config.mcpServers[server]);
		} catch (e) {
			return err(`Failed to connect to "${server}": ${msg(e)}`);
		}
	}
	const tools = manager.getTools(server);
	if (tools.length === 0) return ok(`Server "${server}" has no tools.`);
	let text = `${server} (${tools.length} tools):\n\n`;
	for (const t of tools) {
		text += `- ${t.name}`;
		if (t.description) text += ` — ${t.description.split("\n")[0].slice(0, 100)}`;
		text += "\n";
	}
	text += '\nCall with mcp({ tool: "name", args: {...} }).';
	return ok(text);
}

function normalizeArgs(args: unknown): Record<string, unknown> | null {
	if (args === undefined || args === null) return {};
	if (typeof args !== "object" || Array.isArray(args)) return null;
	return args as Record<string, unknown>;
}

async function callResult(
	config: LoadedConfig,
	manager: McpServerManager,
	toolName: string,
	args: unknown,
	serverOverride: string | undefined,
): Promise<Result> {
	const argObj = normalizeArgs(args);
	if (argObj === null) return err("args must be a JSON object (or omitted).");

	let serverName: string | undefined;

	if (serverOverride) {
		if (!config.mcpServers[serverOverride]) {
			return err(`Server "${serverOverride}" not configured.`);
		}
		serverName = serverOverride;
		if (manager.getStatus(serverName) !== "connected") {
			try {
				await manager.connect(serverName, config.mcpServers[serverName]);
			} catch (e) {
				return err(`Failed to connect to "${serverName}": ${msg(e)}`);
			}
		}
		if (!manager.getTools(serverName).some((t) => t.name === toolName)) {
			return err(
				`Tool "${toolName}" not found on "${serverName}". Use mcp({ server: "${serverName}" }) to list its tools.`,
			);
		}
	} else {
		// Disambiguate across all servers (lazy-connect each).
		const candidates: string[] = [];
		for (const name of Object.keys(config.mcpServers)) {
			if (manager.getStatus(name) !== "connected") {
				try {
					await manager.connect(name, config.mcpServers[name]);
				} catch {
					/* skip unreachable servers */
				}
			}
			if (manager.getTools(name).some((t) => t.name === toolName)) {
				candidates.push(name);
			}
		}
		if (candidates.length === 0) {
			return err(
				`Tool "${toolName}" not found on any server. Use mcp({ search: "..." }) to find tools.`,
			);
		}
		if (candidates.length > 1) {
			return err(
				`Tool "${toolName}" exists on multiple servers: ${candidates.join(", ")}. Specify server.`,
			);
		}
		serverName = candidates[0];
	}

	try {
		const result = await manager.callTool(serverName, toolName, argObj);
		const content = transformContent((result.content ?? []) as unknown[]);
		if (result.isError) {
			const text =
				content
					.filter((c) => c.type === "text")
					.map((c) => (c as { text: string }).text)
					.join("\n") || "Tool execution failed";
			return {
				content: [{ type: "text", text: `Error: ${text}` }],
				details: { error: true, server: serverName, tool: toolName },
			};
		}
		return {
			content: content.length > 0 ? content : [{ type: "text", text: "(empty result)" }],
			details: { server: serverName, tool: toolName },
		};
	} catch (e) {
		return err(`Failed to call "${toolName}" on "${serverName}": ${msg(e)}`);
	}
}

// ---- command helpers -------------------------------------------------------

async function pickServer(
	config: LoadedConfig,
	ctx: ExtensionContext,
): Promise<string | undefined> {
	const names = Object.keys(config.mcpServers);
	if (names.length === 0) {
		ctx.ui?.notify("No MCP servers configured.", "info");
		return undefined;
	}
	if (!ctx.hasUI) return names[0];
	return await ctx.ui.select("Pick MCP server:", names);
}
