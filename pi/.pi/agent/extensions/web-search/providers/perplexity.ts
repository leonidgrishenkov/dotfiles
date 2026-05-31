/**
 * Perplexity provider — POST https://api.perplexity.ai/chat/completions
 * API-key mode only (no OAuth/cookie flow). Uses sonar-pro with web search.
 */

import { resolveKey } from "../config.ts";
import { fetchJson, type Provider, type SearchSource } from "../types.ts";

export const perplexityProvider: Provider = {
	name: "perplexity",
	getKey: (signal) => resolveKey(["PERPLEXITY_API_KEY", "PPLX_API_KEY"], "perplexity", signal),
	async search(key, params) {
		const data = (await fetchJson("perplexity", "https://api.perplexity.ai/chat/completions", {
			method: "POST",
			headers: { "content-type": "application/json", authorization: `Bearer ${key}` },
			signal: params.signal,
			body: JSON.stringify({
				model: "sonar-pro",
				search_mode: "web",
				messages: [{ role: "user", content: params.query }],
				...(params.recency ? { search_recency_filter: params.recency } : {}),
			}),
		})) as {
			choices?: { message?: { content?: string } }[];
			search_results?: { title?: string; url: string; date?: string }[];
			citations?: string[];
		};
		const answer = data.choices?.[0]?.message?.content;
		let sources: SearchSource[] = (data.search_results ?? []).map((r) => ({
			title: r.title,
			url: r.url,
			publishedDate: r.date,
		}));
		if (sources.length === 0 && data.citations) {
			sources = data.citations.map((url) => ({ url }));
		}
		return { provider: "perplexity", answer, sources: sources.slice(0, params.limit) };
	},
};
