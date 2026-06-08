/**
 * LLM-facing rendering of a FetchResult.
 *
 * Mirrors `format.ts` in the web-search extension: converts the raw response
 * into a clean, context-window-friendly representation the model can reason
 * about — typically Markdown derived from HTML with large outputs truncated.
 *
 * Responsibilities:
 *  - HTML → Markdown conversion (delegated to html-to-markdown.ts)
 *  - Plain-text extraction by stripping tags (lighter alternative)
 *  - Truncation with an explicit note when the output exceeds a token budget
 *  - Redirect banner so the model knows the final URL differs from the request
 */

import { convertHtmlToMarkdown } from "./html-to-markdown.ts";
import type { FetchResult, OutputFormat } from "./types.ts";

/** Maximum characters to return to the LLM (roughly ~60K tokens). */
const MAX_OUTPUT_CHARS = 240_000;

/**
 * Build the LLM-facing text for a successful fetch.
 *
 * 1. Converts the raw content to the requested format.
 * 2. Prefixes a cross-host redirect banner when applicable.
 * 3. Truncates with a clear marker when the output is too large.
 */
export function formatResultForLLM(result: FetchResult, format: OutputFormat): string {
	const body = convertToFormat(result.content, result.contentType, format);

	const parts: string[] = [];

	// Redirect notification — critical for the model to reason about where
	// content actually came from (e.g. GitHub raw vs. blob URLs).
	if (result.crossHost && result.url !== result.originalUrl) {
		parts.push(`[Cross-host redirect] Requested: ${result.originalUrl}\nFinal URL: ${result.url}`);
	}

	parts.push(body);

	const text = parts.join("\n\n");

	// Truncate to a reasonable size to protect context windows.
	if (text.length > MAX_OUTPUT_CHARS) {
		const truncated = text.slice(0, MAX_OUTPUT_CHARS);
		return (
			truncated +
			`\n\n[Truncated — ${text.length.toLocaleString()} characters total; only the first ${MAX_OUTPUT_CHARS.toLocaleString()} are shown. ` +
			`Use web_search tool to find a smaller resource, or try a text/plain or raw version of the page.]`
		);
	}

	return text;
}

// ---------------------------------------------------------------------------
// Format-specific conversion
// ---------------------------------------------------------------------------

/** Convert raw content to the requested output format. */
function convertToFormat(content: string, contentType: string, format: OutputFormat): string {
	const isHtml = contentType.includes("text/html") || contentType.includes("application/xhtml");

	switch (format) {
		case "markdown":
			if (isHtml) return convertHtmlToMarkdown(content);
			// Server may already serve markdown or plain text — pass through.
			return content;

		case "text":
			if (isHtml) return stripHtmlTags(content);
			return content;

		case "html":
			// Return raw HTML (useful for scraping / parsing tasks).
			return content;
	}
}

/**
 * Lightweight HTML → plain-text extractor.
 *
 * Strips <script>, <style>, <noscript> blocks entirely, then concatenates
 * all remaining text nodes. No DOM dependency needed — a simple stateful
 * scan is sufficient for well-formed HTML.
 */
function stripHtmlTags(html: string): string {
	const SKIP_TAGS = new Set(["script", "style", "noscript", "iframe", "object", "embed"]);
	let text = "";
	let skipDepth = 0;
	let inTag = false;
	let currentTag = "";

	for (let i = 0; i < html.length; i++) {
		const ch = html[i];
		if (!inTag && ch === "<") {
			inTag = true;
			currentTag = "";
			continue;
		}
		if (inTag) {
			if (ch === ">") {
				inTag = false;
				// Normalize tag name: strip leading `/` and everything after whitespace/`/`.
				const name = currentTag.replace(/^\/?\s*([^/>\s]*).*/, "$1").toLowerCase();
				if (SKIP_TAGS.has(name)) {
					// Opening tags increment skip depth; closing tags decrement.
					if (!currentTag.startsWith("/")) {
						skipDepth++;
					} else if (skipDepth > 0) {
						skipDepth--;
					}
				}
				// Add whitespace for block-level tag boundaries.
				text += " ";
				continue;
			}
			currentTag += ch;
			continue;
		}
		if (skipDepth === 0) {
			text += ch;
		}
	}

	// Collapse whitespace.
	return text.replace(/\s+/g, " ").trim();
}
