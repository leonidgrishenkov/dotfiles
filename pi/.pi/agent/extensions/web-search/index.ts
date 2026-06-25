/**
 * Web Search Tool (entry point)
 *
 * A lean web_search tool inspired by oh-my-pi's design, trimmed to the
 * providers I use: Tavily, Brave, Perplexity, Exa.
 *
 * Layout:
 *   index.ts             - tool definition + registration (this file)
 *   types.ts             - unified SearchResponse, Provider, CredentialSource, errors, fetch helper
 *   credentials.ts       - resolveKey(): env vars -> shell command fallback
 *   format.ts            - formatForLLM()
 *   orchestrator.ts      - executeSearch() fallback chain (cycles all providers)
 *   providers/*.ts       - one adapter per provider (declares CredentialSource inline)
 *
 * Credentials: each provider declares envVars[] and an optional command string.
 * The orchestrator tries them in order (tavily, brave, perplexity, exa), skipping
 * providers whose credentials can't be resolved.
 */

import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { executeSearch } from "./orchestrator.ts";
import type { SearchResponse } from "./types.ts";

interface WebSearchDetails {
	response: SearchResponse;
	error?: string;
}

/** Compact, human-readable summary of the search params the LLM submitted. */
function formatQuery(args: { query?: string; recency?: string; limit?: number }): string {
	const query = typeof args.query === "string" ? args.query : "";
	const flags: string[] = [];
	if (args.recency) flags.push(`recency=${args.recency}`);
	if (typeof args.limit === "number") flags.push(`limit=${args.limit}`);
	const suffix = flags.length > 0 ? ` (${flags.join(", ")})` : "";
	return `"${query}"${suffix}`;
}

const webSearchTool = defineTool({
	name: "web_search",
	label: "Web Search",
	description:
		"Search the web for up-to-date information. Returns a synthesized answer (when available) plus a list of source URLs with snippets. Use for current events, documentation, library versions, or anything beyond your training data.",
	promptSnippet: "Search the web for current information and source URLs",
	promptGuidelines: [
		"Use web_search when the user asks about recent events, current library/API versions, or facts that may be newer than your training data.",
        // WARN: models completly ignores this instuction
        "Do not append years (e.g. 2024, 2025) to a web_search query to bias toward recency; pass the user's intent verbatim and use the recency parameter when a time window matters.",
		"Cite source URLs from web_search results when reporting findings.",
	],
	parameters: Type.Object({
		query: Type.String({ description: "Search query." }),
        // TODO: Why we have this types here: `Type.Literal`? It's perhaps should be a liternal number?
        // Anyway, we need to search what is the correct way to specify year in search APIs.
		recency: Type.Optional(
			Type.Union(
				[
					Type.Literal("day"),
					Type.Literal("week"),
					Type.Literal("month"),
					Type.Literal("year"),
				],
				{ description: "Optional time filter for results." },
			),
		),
		limit: Type.Optional(
			Type.Number({ description: "Max number of sources to return (default 10).", default: 10 }),
		),
	}),

	async execute(_toolCallId, params, signal) {
		const result = await executeSearch({
			query: params.query,
			limit: typeof params.limit === "number" ? params.limit : 10,
			recency: params.recency,
			signal,
		});
		return {
			content: [{ type: "text", text: result.text }],
			details: { response: result.response, error: result.error } satisfies WebSearchDetails,
			isError: Boolean(result.error),
		};
	},

	renderCall(args, theme) {
		return new Text(
			`${theme.fg("toolTitle", theme.bold("web_search"))} ${theme.fg("text", formatQuery(args))}`,
			0,
			0,
		);
	},

	renderResult(result, _options, theme, context) {
		const details = result.details as WebSearchDetails | undefined;
		const query = formatQuery(context.args);
		if (!details || details.error) {
			return new Text(
				[
					theme.fg("toolTitle", theme.bold("web_search")) + theme.fg("muted", `  ${query}`),
					theme.fg("error", details?.error ?? "Web search failed"),
				].join("\n"),
				0,
				0,
			);
		}
		const r = details.response;
		const lines = [
			theme.fg("toolTitle", theme.fg('muted',`via ${r.provider}`)),
			theme.fg("muted", `${r.sources.length} source(s)`),
		];
		r.sources.slice(0, 10).forEach((s, i) => {
			lines.push(theme.fg("text", `${i + 1}. ${s.title ?? s.url}`));
			lines.push(theme.fg("muted", `   ${s.url}`));
		});
		return new Text(lines.join("\n"), 0, 0);
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(webSearchTool);
}
