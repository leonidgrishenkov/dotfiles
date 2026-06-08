/**
 * Web Fetch Tool (entry point)
 *
 * A web_fetch tool for the pi coding agent — fetches content from a URL
 * and converts it to a clean, LLM-friendly representation.
 *
 * Layout (mirrors web-search extension structure):
 *   index.ts             - tool definition + registration (this file)
 *   types.ts             - FetchResult / FetchParams / FetchError + constants
 *   fetcher.ts           - fetchUrl() — transport, security, error handling
 *   format.ts            - formatResultForLLM() — conversion + truncation
 *   html-to-markdown.ts  - Turndown-backed HTML → Markdown converter
 *
 * Design principles (see web_fetch.md):
 *   - HTML → Markdown by default, with text/html alternatives
 *   - HTTPS upgrade + SSRF protection
 *   - Cross-host redirect detection with explicit notification
 *   - 5 MB response guard + 240K-character output truncation
 *   - Default 30 s timeout, max 120 s
 *   - Identified User-Agent
 *   - Actionable error hints so the model can retry intelligently
 */

import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { fetchUrl } from "./fetcher.ts";
import { formatResultForLLM } from "./format.ts";
import { FetchError, type FetchResult, type OutputFormat } from "./types.ts";

interface WebFetchDetails {
	result?: FetchResult;
	error?: string;
}

/** Compact human-readable summary of the fetch params the LLM submitted. */
function formatArgs(args: { url?: string; format?: string }): string {
	const url = typeof args.url === "string" ? args.url : "(no url)";
	const fmt = args.format && args.format !== "markdown" ? ` [${args.format}]` : "";
	return `${url}${fmt}`;
}

const webFetchTool = defineTool({
	name: "web_fetch",
	label: "Web Fetch",
	description:
		"Fetch content from a URL and convert it to a clean format (markdown by default). " +
		"Use for reading documentation, articles, or any web page content. " +
		"Returns the page text in the requested format with HTML converted to readable Markdown.",
	promptSnippet: "Fetch and read the content of a web page at a given URL",
	promptGuidelines: [
		"Use web_fetch to retrieve the content of a specific, known URL (e.g. documentation pages, READMEs, issue trackers).",
		"Always prefer a more targeted tool when one exists — for example web_search for discovery, or a GitHub/MCP tool for GitHub resources.",
		"Do not guess URLs. Only fetch URLs the user or a previous tool result has provided.",
		"If a fetch returns a cross-host redirect notice, re-issue the request with the final URL to obtain the actual content.",
	],
	parameters: Type.Object({
		url: Type.String({ description: "The URL to fetch content from. Must start with http:// or https://." }),
		format: Type.Optional(
			Type.Union([Type.Literal("markdown"), Type.Literal("text"), Type.Literal("html")], {
				description:
					"Output format: 'markdown' (default, converts HTML to clean Markdown), 'text' (stripped plain text), or 'html' (raw HTML).",
				default: "markdown",
			}),
		),
	}),

	async execute(_toolCallId, params, signal) {
		const format = (params.format ?? "markdown") as OutputFormat;

		try {
			const result = await fetchUrl({
				url: params.url,
				format,
				signal,
			});

			const text = formatResultForLLM(result, format);

			return {
				content: [{ type: "text", text }],
				details: { result } satisfies WebFetchDetails,
				isError: false,
			};
		} catch (err) {
			const isAbort = signal?.aborted && (err as Error).message === "Aborted.";
			const message = err instanceof FetchError ? err.message : (err as Error).message;

			return {
				content: [{ type: "text", text: `Error: ${message}` }],
				details: { error: message } satisfies WebFetchDetails,
				isError: !isAbort,
			};
		}
	},

	renderCall(args, theme) {
		return new Text(
			`${theme.fg("toolTitle", theme.bold("web_fetch"))} ${theme.fg("text", formatArgs(args))}`,
			0,
			0,
		);
	},

	renderResult(result, _options, theme, context) {
		const details = result.details as WebFetchDetails | undefined;
		const label = formatArgs(context.args);

		if (!details || details.error) {
			return new Text(
				[
					theme.fg("toolTitle", theme.bold("web_fetch")) + theme.fg("muted", `  ${label}`),
					theme.fg("error", details?.error ?? "Web fetch failed"),
				].join("\n"),
				0,
				0,
			);
		}

		const r = details.result!;
		const lines = [
			theme.fg("toolTitle", theme.bold("web_fetch")),
			theme.fg("text", r.url),
		];
		if (r.crossHost) {
			lines.push(theme.fg("muted", `(redirected from ${r.originalUrl})`));
		}
		const sizeLabel = r.content.length >= 1024
			? `${(r.content.length / 1024).toFixed(1)} KB`
			: `${r.content.length} B`;
		lines.push(theme.fg("muted", `${r.contentType || "unknown type"} · ${sizeLabel}`));
		return new Text(lines.join("\n"), 0, 0);
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(webFetchTool);
}
