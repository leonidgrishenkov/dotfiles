/**
 * Web Fetch Tool (entry point)
 *
 * A web_fetch tool for the pi coding agent — fetches content from a URL
 * and converts it to a clean, LLM-friendly representation.
 *
 * Layout (mirrors web-search extension structure):
 *   index.ts             - tool definition + registration (this file)
 *   types.ts             - FetchResult / FetchParams / FetchError + constants
 *   fetcher.ts           - fetchUrl() — HTTP transport, security, error handling
 *   github-extract.ts    - GitHub URL parsing, shallow clone + API fallback
 *   github-api.ts        - gh CLI wrappers (tree, README, file fetching)
 *   format.ts            - formatResultForLLM() — conversion + truncation
 *   html-to-markdown.ts  - Turndown-backed HTML → Markdown converter
 *
 * Design principles (see web_fetch.md):
 *   - HTML → Markdown by default, with text/html alternatives
 *   - GitHub URLs → structured repo content (clone for small repos,
 *     `gh api` fallback for large repos)
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
import { fetchGitHubUrl, clearGitHubCloneCache } from "./github-extract.ts";
import { formatResultForLLM } from "./format.ts";
import { FetchError, type FetchResult, type OutputFormat } from "./types.ts";

interface WebFetchDetails {
	result?: FetchResult;
	error?: string;
	/** Present when the fetch was routed through the GitHub extractor. */
	githubRepo?: { owner: string; repo: string; path?: string };
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
		"Returns the page text in the requested format with HTML converted to readable Markdown. " +
		"GitHub URLs (github.com/owner/repo, /blob, /tree) return structured repository " +
		"content — file trees, README, or file text — with a local clone path for further " +
		"exploration via `read`/`bash`.",
	promptSnippet: "Fetch and read the content of a web page at a given URL",
	promptGuidelines: [
		"Use web_fetch to retrieve the content of a specific, known URL (e.g. documentation pages, READMEs, issue trackers).",
		"Always prefer a more targeted tool when one exists — for example web_search for discovery.",
		"Do not guess URLs. Only fetch URLs the user or a previous tool result has provided.",
		"If a fetch returns a cross-host redirect notice, re-issue the request with the final URL to obtain the actual content.",
	],
	parameters: Type.Object({
		url: Type.String({ description: "The URL to fetch content from. Must start with http:// or https://. GitHub URLs (github.com/owner/repo/blob/..., /tree/...) are handled with structured extraction." }),
		format: Type.Optional(
			Type.Union([Type.Literal("markdown"), Type.Literal("text"), Type.Literal("html")], {
				description:
					"Output format: 'markdown' (default, converts HTML to clean Markdown), 'text' (stripped plain text), or 'html' (raw HTML).",
				default: "markdown",
			}),
		),
		forceClone: Type.Optional(
			Type.Boolean({
				description: "For GitHub URLs: force a full shallow clone even when the repo exceeds the size threshold.",
				default: false,
			}),
		),
	}),

	async execute(_toolCallId, params, signal) {
		const format = (params.format ?? "markdown") as OutputFormat;

		try {
			// -- GitHub URLs get structured extraction (clone or API) --------
			const isGitHub = /^https?:\/\/(www\.)?github\.com\//i.test(params.url);

			const result = isGitHub
				? await fetchGitHubUrl(params.url, signal, params.forceClone)
				: null;

			// -- GitHub extractor returned content ----------------------------
			if (result) {
				const text = formatResultForLLM(result, format);
				// Parse owner/repo from details for the renderer.
				const repoMatch = params.url.match(
					/github\.com\/([^/]+)\/([^/?#]+)/i,
				);
				const pathMatch = params.url.match(
					/github\.com\/[^/]+\/[^/]+\/(?:blob|tree)\/[^/]+\/(.+)/,
				);

				return {
					content: [{ type: "text", text }],
					details: {
						result,
						githubRepo: repoMatch
							? {
									owner: repoMatch[1],
									repo: repoMatch[2].replace(/\.git$/, ""),
									path: pathMatch?.[1],
								}
							: undefined,
					} satisfies WebFetchDetails,
					isError: false,
				};
			}

			// -- Everything else → plain HTTP fetch --------------------------
			const httpResult = await fetchUrl({
				url: params.url,
				format,
				signal,
			});

			const text = formatResultForLLM(httpResult, format);

			return {
				content: [{ type: "text", text }],
				details: { result: httpResult } satisfies WebFetchDetails,
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
					theme.fg("muted", label),
					theme.fg("error", details?.error ?? "Web fetch failed"),
				].join("\n"),
				0,
				0,
			);
		}

		const r = details.result!;
		const lines: string[] = [];

		if (details.githubRepo) {
			// GitHub fetch — show a clear label instead of the repo badge
			lines.push(theme.fg("text", "Fetching GitHub"));
		} else if (r.crossHost) {
			// Plain HTTP fetch — only note cross-host redirects, since the
			// URL itself is already shown on the renderCall line above.
			lines.push(theme.fg("muted", `(redirected from ${r.originalUrl})`));
		}

		const sizeLabel = r.content.length >= 1024
			? `${(r.content.length / 1024).toFixed(1)} KB`
			: `${r.content.length} B`;
		const typeLabel = details.githubRepo ? "git" : (r.contentType || "unknown type");
		lines.push(theme.fg("muted", `${typeLabel} · ${sizeLabel}`));
		return new Text(lines.join("\n"), 0, 0);
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(webFetchTool);

	// Clear the in-memory GitHub clone cache at the start of each session
	// so stale references from a previous session don't leak through.
	pi.on("session_start", async () => {
		clearGitHubCloneCache();
	});
}
