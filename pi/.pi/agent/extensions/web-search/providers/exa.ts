/**
 * Exa provider — POST https://api.exa.ai/search
 * Semantic search with content highlights. Synthesizes a short answer from the
 * top result summaries (mirrors oh-my-pi's exa adapter behavior).
 */

import { clamp, fetchJson, type Provider, type SearchSource } from "../types.ts";

export const exaProvider: Provider = {
	name: "exa",
	credentials: {
		envVars: ["EXA_API_KEY"],
		// command: "op read op://Personal/Exa/credential",
	},
	async search(key, params) {
		const data = (await fetchJson("exa", "https://api.exa.ai/search", {
			method: "POST",
			headers: { "content-type": "application/json", "x-api-key": key },
			signal: params.signal,
			body: JSON.stringify({
				query: params.query,
				type: "auto",
				numResults: clamp(params.limit, 1, 25),
				contents: { text: { maxCharacters: 800 }, highlights: true },
			}),
		})) as {
			results?: {
				title?: string;
				url: string;
				text?: string;
				highlights?: string[];
				publishedDate?: string;
			}[];
		};
		const sources: SearchSource[] = (data.results ?? []).map((r) => ({
			title: r.title,
			url: r.url,
			snippet: r.highlights?.[0] ?? r.text,
			publishedDate: r.publishedDate,
		}));
		const answer = sources
			.slice(0, 3)
			.map((s) => s.snippet)
			.filter(Boolean)
			.join("\n\n");
		return { provider: "exa", answer: answer || undefined, sources };
	},
};
