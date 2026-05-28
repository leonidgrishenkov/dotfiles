/**
 * Web Search Tool
 *
 * Registers a `web_search` tool backed by the Tavily Search API
 * (https://tavily.com). LLM-friendly snippets, optional answer summary.
 *
 * Auth: reads TAVILY_API_KEY from the environment. Throws when missing.
 *
 * Cancellation: respects ctx.signal so Esc aborts in-flight requests.
 */

import { StringEnum } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

interface TavilyResult {
	title: string;
	url: string;
	content: string;
	score?: number;
	published_date?: string;
}

interface TavilyResponse {
	query: string;
	answer?: string;
	results: TavilyResult[];
	response_time?: number;
}

interface WebSearchDetails {
	query: string;
	answer?: string;
	results: TavilyResult[];
}

const TAVILY_ENDPOINT = "https://api.tavily.com/search";

function getApiKey(): string {
	const key = process.env.TAVILY_API_KEY;
	if (!key || key.trim().length === 0) {
		throw new Error(
			"TAVILY_API_KEY is not set. Export it in your shell (e.g. ~/.config/fsh/conf.d/secrets.fish) before starting pi.",
		);
	}
	return key.trim();
}

const webSearchTool = defineTool({
	name: "web_search",
	label: "Web Search",
	description:
		"Search the web via Tavily and return ranked results (title, url, snippet) plus an optional summary answer. Prefer this over scraping with bash+curl.",
	promptSnippet: "Search the web and return ranked results with snippets",
	promptGuidelines: [
		"Use web_search when you need fresh information from the internet instead of curl or DuckDuckGo scraping.",
		"After web_search, call web_fetch on the most promising URL to get the full page contents.",
	],
	parameters: Type.Object({
		query: Type.String({ description: "Search query" }),
		max_results: Type.Optional(
			Type.Integer({
				description: "Maximum number of results (1-20)",
				minimum: 1,
				maximum: 20,
				default: 5,
			}),
		),
		search_depth: Type.Optional(
			StringEnum(["basic", "advanced"] as const, {
				description:
					"Tavily search depth. 'advanced' uses more credits but returns higher quality snippets.",
				default: "basic",
			}),
		),
		include_domains: Type.Optional(
			Type.Array(Type.String(), {
				description: "Restrict results to these domains",
			}),
		),
		exclude_domains: Type.Optional(
			Type.Array(Type.String(), {
				description: "Drop results from these domains",
			}),
		),
	}),

	async execute(_toolCallId, params, signal) {
		if (signal?.aborted) {
			return { content: [{ type: "text", text: "Cancelled" }] };
		}

		const apiKey = getApiKey();
		const maxResults = Math.min(Math.max(params.max_results ?? 5, 1), 20);
		const searchDepth = params.search_depth ?? "basic";

		const body = {
			api_key: apiKey,
			query: params.query,
			max_results: maxResults,
			search_depth: searchDepth,
			include_answer: true,
			include_raw_content: false,
			include_images: false,
			include_domains: params.include_domains,
			exclude_domains: params.exclude_domains,
		};

		const response = await fetch(TAVILY_ENDPOINT, {
			method: "POST",
			headers: { "content-type": "application/json" },
			body: JSON.stringify(body),
			signal,
		});

		if (!response.ok) {
			const errorText = await response.text().catch(() => "");
			throw new Error(
				`Tavily request failed: ${response.status} ${response.statusText}${
					errorText ? ` — ${errorText.slice(0, 500)}` : ""
				}`,
			);
		}

		const data = (await response.json()) as TavilyResponse;
		const results = Array.isArray(data.results) ? data.results : [];

		const lines: string[] = [];
		lines.push(`# Search results for: ${params.query}`);
		if (data.answer) {
			lines.push("");
			lines.push("## Summary");
			lines.push(data.answer);
		}
		if (results.length === 0) {
			lines.push("");
			lines.push("_No results._");
		} else {
			lines.push("");
			lines.push("## Results");
			results.forEach((r, i) => {
				lines.push("");
				lines.push(`### ${i + 1}. ${r.title || r.url}`);
				lines.push(r.url);
				if (r.published_date) lines.push(`_Published: ${r.published_date}_`);
				if (r.content) lines.push("");
				if (r.content) lines.push(r.content.trim());
			});
		}

		const text = lines.join("\n");

		return {
			content: [{ type: "text", text }],
			details: {
				query: params.query,
				answer: data.answer,
				results,
			} satisfies WebSearchDetails,
		};
	},

	renderResult(result, _options, theme) {
		const details = result.details as WebSearchDetails | undefined;
		if (!details) {
			const text = result.content[0];
			return new Text(text?.type === "text" ? text.text : "", 0, 0);
		}

		const lines: string[] = [];
		lines.push(theme.fg("toolTitle", theme.bold(`Search: ${details.query}`)));
		if (details.answer) {
			lines.push("");
			lines.push(theme.fg("text", details.answer));
		}
		details.results.forEach((r, i) => {
			lines.push("");
			lines.push(theme.fg("toolTitle", `${i + 1}. ${r.title || r.url}`));
			lines.push(theme.fg("muted", r.url));
			if (r.content) {
				const snippet = r.content.length > 240 ? `${r.content.slice(0, 240)}…` : r.content;
				lines.push(theme.fg("text", snippet));
			}
		});
		return new Text(lines.join("\n"), 0, 0);
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(webSearchTool);
}
