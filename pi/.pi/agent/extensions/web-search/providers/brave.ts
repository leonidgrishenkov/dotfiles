/**
 * Brave provider — GET https://api.search.brave.com/res/v1/web/search
 * Returns sources only (no synthesized answer). `recency` maps to `freshness`.
 */

import { resolveKey } from "../config.ts";
import { clamp, fetchJson, type Provider, type SearchSource } from "../types.ts";

export const braveProvider: Provider = {
	name: "brave",
	getKey: (signal) => resolveKey(["BRAVE_API_KEY"], "brave", signal),
	async search(key, params) {
		const freshness = ({ day: "pd", week: "pw", month: "pm", year: "py" } as const)[
			params.recency ?? ("" as never)
		];
		const url = new URL("https://api.search.brave.com/res/v1/web/search");
		url.searchParams.set("q", params.query);
		url.searchParams.set("count", String(clamp(params.limit, 1, 20)));
		url.searchParams.set("extra_snippets", "true");
		if (freshness) url.searchParams.set("freshness", freshness);

		const data = (await fetchJson("brave", url.toString(), {
			headers: { accept: "application/json", "x-subscription-token": key },
			signal: params.signal,
		})) as {
			web?: {
				results?: {
					title?: string;
					url: string;
					description?: string;
					extra_snippets?: string[];
					age?: string;
				}[];
			};
		};
		const sources: SearchSource[] = (data.web?.results ?? []).map((r) => ({
			title: r.title,
			url: r.url,
			snippet: r.extra_snippets?.[0] ?? r.description,
			publishedDate: r.age,
		}));
		return { provider: "brave", sources };
	},
};
