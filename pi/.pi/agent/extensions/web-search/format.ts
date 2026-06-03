/**
 * LLM-facing rendering of a SearchResponse.
 *
 * Inspired by oh-my-pi's `formatForLLM()` in `web/search/index.ts`:
 * emit the answer first, then a `## Sources` section with numbered entries
 * and snippets truncated to 240 chars.
 */

import type { SearchResponse } from "./types.ts";

const SNIPPET_MAX = 240;

export function formatForLLM(r: SearchResponse): string {
	const parts: string[] = [];
	if (r.answer?.trim()) parts.push(r.answer.trim());

	if (r.sources.length > 0) {
		const lines = [`## Sources (${r.sources.length})`];
		r.sources.forEach((s, i) => {
			const date = s.publishedDate ? ` (${s.publishedDate})` : "";
			lines.push(`[${i + 1}] ${s.title ?? s.url}${date}`);
			lines.push(`    ${s.url}`);
			if (s.snippet) {
				const snip = s.snippet.replace(/\s+/g, " ").trim().slice(0, SNIPPET_MAX);
				if (snip) lines.push(`    ${snip}`);
			}
		});
		parts.push(lines.join("\n"));
	}

	return parts.join("\n\n") || "No results found.";
}
