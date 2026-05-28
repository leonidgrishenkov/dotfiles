/**
 * Web Fetch Tool
 *
 * Registers a `web_fetch` tool that downloads a URL and returns the body
 * as Markdown, plain text, or raw HTML. For HTML pages, applies Mozilla
 * Readability (reader mode) to extract main article content, then Turndown
 * to produce Markdown.
 *
 * Cancellation: respects ctx.signal so Esc aborts in-flight requests.
 */

import { StringEnum } from "@earendil-works/pi-ai";
import { defineTool, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Readability } from "@mozilla/readability";
import { JSDOM, VirtualConsole } from "jsdom";
import TurndownService from "turndown";
import { Type } from "typebox";

interface WebFetchDetails {
	url: string;
	finalUrl: string;
	contentType: string;
	title?: string;
	byteLength: number;
	truncated: boolean;
	format: "markdown" | "text" | "html";
	readerMode: boolean;
}

const DEFAULT_MAX_CHARS = 50_000;
const DEFAULT_TIMEOUT_MS = 30_000;
const USER_AGENT =
	"pi-coding-agent web_fetch/1.0 (+https://github.com/earendil-works/pi-mono)";

function stripTags(html: string): string {
	// Quick HTML -> plain text fallback (drops scripts/styles and tags).
	const noScripts = html
		.replace(/<script[\s\S]*?<\/script>/gi, "")
		.replace(/<style[\s\S]*?<\/style>/gi, "")
		.replace(/<noscript[\s\S]*?<\/noscript>/gi, "");
	const text = noScripts.replace(/<[^>]+>/g, " ");
	return text.replace(/\s+/g, " ").trim();
}

function htmlToMarkdown(html: string): string {
	const turndown = new TurndownService({
		headingStyle: "atx",
		codeBlockStyle: "fenced",
		bulletListMarker: "-",
		emDelimiter: "_",
	});
	turndown.remove(["script", "style", "noscript", "iframe", "form", "svg"]);
	return turndown.turndown(html).trim();
}

function truncate(text: string, maxChars: number): { text: string; truncated: boolean } {
	if (text.length <= maxChars) return { text, truncated: false };
	const head = text.slice(0, maxChars);
	const notice = `\n\n…[truncated ${text.length - maxChars} chars of ${text.length} total]`;
	return { text: head + notice, truncated: true };
}

const webFetchTool = defineTool({
	name: "web_fetch",
	label: "Web Fetch",
	description:
		"Fetch a URL and return its body as Markdown (default), plain text, or HTML. For HTML pages, reader mode extracts the main article. Prefer this over bash+curl when you need page contents.",
	promptSnippet: "Fetch a URL and return its contents as Markdown",
	promptGuidelines: [
		"Use web_fetch instead of curl/wget when you want to read a webpage's contents.",
		"Pair web_fetch with web_search: search for URLs, then fetch the most relevant ones.",
	],
	parameters: Type.Object({
		url: Type.String({ description: "Absolute http(s) URL to fetch" }),
		format: Type.Optional(
			StringEnum(["markdown", "text", "html"] as const, {
				description: "Output format. Defaults to markdown.",
				default: "markdown",
			}),
		),
		reader_mode: Type.Optional(
			Type.Boolean({
				description:
					"When true (default), use Readability to extract main article content for HTML pages.",
				default: true,
			}),
		),
		max_chars: Type.Optional(
			Type.Integer({
				description: `Maximum characters in returned body (default ${DEFAULT_MAX_CHARS}).`,
				minimum: 500,
				maximum: 500_000,
				default: DEFAULT_MAX_CHARS,
			}),
		),
		timeout_ms: Type.Optional(
			Type.Integer({
				description: `Network timeout in milliseconds (default ${DEFAULT_TIMEOUT_MS}).`,
				minimum: 1_000,
				maximum: 120_000,
				default: DEFAULT_TIMEOUT_MS,
			}),
		),
	}),

	async execute(_toolCallId, params, signal) {
		const rawUrl = params.url.trim().replace(/^@+/, "");
		let parsed: URL;
		try {
			parsed = new URL(rawUrl);
		} catch {
			throw new Error(`Invalid URL: ${params.url}`);
		}
		if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
			throw new Error(`Only http(s) URLs are allowed, got ${parsed.protocol}`);
		}

		const format = params.format ?? "markdown";
		const readerMode = params.reader_mode ?? true;
		const maxChars = params.max_chars ?? DEFAULT_MAX_CHARS;
		const timeoutMs = params.timeout_ms ?? DEFAULT_TIMEOUT_MS;

		// Combine caller signal with our own timeout signal.
		const timeoutController = new AbortController();
		const timeoutHandle = setTimeout(() => timeoutController.abort(), timeoutMs);
		const onAbort = () => timeoutController.abort();
		signal?.addEventListener("abort", onAbort, { once: true });

		let response: Response;
		try {
			response = await fetch(parsed.toString(), {
				redirect: "follow",
				signal: timeoutController.signal,
				headers: {
					"user-agent": USER_AGENT,
					accept: "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
					"accept-language": "en-US,en;q=0.8",
				},
			});
		} catch (err) {
			if (signal?.aborted) {
				return { content: [{ type: "text", text: "Cancelled" }] };
			}
			if (timeoutController.signal.aborted) {
				throw new Error(`Fetch timed out after ${timeoutMs}ms: ${parsed.toString()}`);
			}
			throw err;
		} finally {
			clearTimeout(timeoutHandle);
			signal?.removeEventListener("abort", onAbort);
		}

		if (!response.ok) {
			throw new Error(
				`HTTP ${response.status} ${response.statusText} for ${parsed.toString()}`,
			);
		}

		const contentType = (response.headers.get("content-type") ?? "").toLowerCase();
		const rawBody = await response.text();
		const isHtml = contentType.includes("html") || /^\s*<(!doctype|html)/i.test(rawBody);
		const isJson = contentType.includes("json");

		let title: string | undefined;
		let processed: string;

		if (isJson) {
			try {
				processed = `\`\`\`json\n${JSON.stringify(JSON.parse(rawBody), null, 2)}\n\`\`\``;
			} catch {
				processed = rawBody;
			}
		} else if (isHtml) {
			const virtualConsole = new VirtualConsole(); // swallow jsdom CSS/script noise
			const dom = new JSDOM(rawBody, { url: response.url, virtualConsole });
			title = dom.window.document.title || undefined;

			let workingHtml = rawBody;
			if (readerMode) {
				try {
					const reader = new Readability(dom.window.document.cloneNode(true) as Document);
					const article = reader.parse();
					if (article?.content) {
						workingHtml = article.content;
						if (article.title) title = article.title;
					}
				} catch {
					// fall through to whole-body processing
				}
			}

			if (format === "html") {
				processed = workingHtml;
			} else if (format === "text") {
				processed = stripTags(workingHtml);
			} else {
				processed = htmlToMarkdown(workingHtml);
			}
		} else {
			// text/plain or unknown: return as-is (optionally tagged as code).
			processed = rawBody;
		}

		const { text, truncated } = truncate(processed, maxChars);

		const headerParts = [
			`Fetched: ${parsed.toString()}`,
			response.url !== parsed.toString() ? `Final URL: ${response.url}` : null,
			title ? `Title: ${title}` : null,
			`Content-Type: ${contentType || "(unknown)"}`,
			`Bytes: ${rawBody.length}${truncated ? " (truncated)" : ""}`,
		].filter(Boolean);

		const content = `${headerParts.join("\n")}\n\n---\n\n${text}`;

		return {
			content: [{ type: "text", text: content }],
			details: {
				url: parsed.toString(),
				finalUrl: response.url,
				contentType,
				title,
				byteLength: rawBody.length,
				truncated,
				format,
				readerMode,
			} satisfies WebFetchDetails,
		};
	},

	renderResult(result, _options, theme) {
		const details = result.details as WebFetchDetails | undefined;
		const textContent = result.content[0];
		const body = textContent?.type === "text" ? textContent.text : "";
		if (!details) return new Text(body, 0, 0);

		const lines = [
			theme.fg("toolTitle", theme.bold(details.title ?? details.url)),
			theme.fg("muted", details.url),
			theme.fg(
				"muted",
				`${details.format} • ${details.byteLength} bytes${details.truncated ? " (truncated)" : ""}`,
			),
		];
		return new Text(lines.join("\n"), 0, 0);
	},
});

export default function (pi: ExtensionAPI) {
	pi.registerTool(webFetchTool);
}
