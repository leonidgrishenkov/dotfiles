/**
 * Tavily provider — POST https://api.tavily.com/search
 * Returns an LLM-ready answer plus sources. Great default.
 */

import { clamp, fetchJson, type Provider, type SearchSource } from "../types.ts";

export const tavilyProvider: Provider = {
	name: "tavily",
	credentials: {
		envVars: ["TAVILY_API_KEY"],
		// command: "op read op://Dev/tavily.api-auth/api-key",
	},
	async search(key, params) {
		const data = (await fetchJson("tavily", "https://api.tavily.com/search", {
			method: "POST",
			headers: { "content-type": "application/json", authorization: `Bearer ${key}` },
			signal: params.signal,
			body: JSON.stringify({
				query: params.query,
				include_answer: "advanced",
				max_results: clamp(params.limit, 1, 20),
				...(params.recency ? { time_range: params.recency } : {}),
			}),
		})) as {
			answer?: string;
			results?: { title?: string; url: string; content?: string; published_date?: string }[];
		};
		const sources: SearchSource[] = (data.results ?? []).map((r) => ({
			title: r.title,
			url: r.url,
			snippet: r.content,
			publishedDate: r.published_date,
		}));
		return { provider: "tavily", answer: data.answer, sources };
	},
};
