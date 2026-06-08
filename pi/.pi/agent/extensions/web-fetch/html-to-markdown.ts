/**
 * HTML → Markdown conversion using Turndown.
 *
 * Strips scripts, styles, navigation chrome, and ads while preserving
 * semantic structure (headings, lists, code blocks, links). Code blocks
 * survive intact — critical for docs and Stack Overflow content.
 */

import TurndownService from "turndown";

let service: TurndownService | undefined;

function getService(): TurndownService {
	if (service) return service;
	service = new TurndownService({
		headingStyle: "atx",
		hr: "---",
		bulletListMarker: "-",
		codeBlockStyle: "fenced",
		emDelimiter: "*",
	});
	// Strip noise that pollutes LLM context: scripts, stylesheets, nav metadata.
	service.remove(["script", "style", "noscript", "meta", "link", "svg", "picture"]);
	return service;
}

/** Convert raw HTML to clean Markdown optimized for LLM consumption. */
export function convertHtmlToMarkdown(html: string): string {
	return getService().turndown(html);
}
