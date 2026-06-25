/**
 * Provider chain resolution and sequential fallback execution.
 *
 * Cycles through all providers in order, skipping those whose credentials
 * can't be resolved (no env var and no working command). On the first
 * success returns its formatted result; if all fail, returns a normalized
 * error string (never throws, except on abort).
 */

import { resolveKey } from "./credentials.ts";
import { formatForLLM } from "./format.ts";
import { braveProvider } from "./providers/brave.ts";
import { exaProvider } from "./providers/exa.ts";
import { perplexityProvider } from "./providers/perplexity.ts";
import { tavilyProvider } from "./providers/tavily.ts";
import {
	type ProviderName,
	type SearchParams,
	type SearchResponse,
	SearchProviderError,
} from "./types.ts";

const PROVIDERS: Record<ProviderName, Provider> = {
	tavily: tavilyProvider,
	brave: braveProvider,
	perplexity: perplexityProvider,
	exa: exaProvider,
};

const PROVIDER_ORDER: ProviderName[] = ["tavily", "brave", "perplexity", "exa"];

export interface SearchExecResult {
	response: SearchResponse;
	error?: string;
	text: string;
}

/**
 * Strip recency-padding years that LLMs habitually append to "latest version"
 * style queries (e.g. `latest Python version 2024 2025`). Only trailing,
 * standalone year tokens are removed, so meaningful years inside the question
 * (e.g. `python release history 2008`) are preserved. Time filtering should
 * use the `recency` param instead.
 */
export function cleanQuery(query: string): string {
	const cleaned = query.replace(/\s+(?:19|20)\d{2}(?=(?:\s+(?:19|20)\d{2})*\s*$)/g, "");
	const trimmed = cleaned.trim();
	// Never reduce the query to empty (e.g. a query that was only a year).
	return trimmed.length > 0 ? trimmed : query.trim();
}

export async function executeSearch(params: SearchParams): Promise<SearchExecResult> {
	params = { ...params, query: cleanQuery(params.query) };
	const failures: string[] = [];
	let attempted = false;

	for (const name of PROVIDER_ORDER) {
		if (params.signal?.aborted) throw new Error("aborted");
		const provider = PROVIDERS[name];
		const key = await resolveKey(provider.credentials, params.signal);
		if (!key) continue; // no credentials -> skip silently
		attempted = true;
		try {
			const response = await provider.search(key, params);
			return { response, text: formatForLLM(response) };
		} catch (err) {
			if (params.signal?.aborted) throw err;
			const msg = err instanceof SearchProviderError ? err.message : (err as Error).message;
			failures.push(`${name}: ${msg}`);
		}
	}

	const error = !attempted
		? "No web search provider configured. Set an env var (TAVILY_API_KEY, BRAVE_API_KEY, PERPLEXITY_API_KEY, EXA_API_KEY) or uncomment the `command` field in the provider file under providers/*.ts."
		: failures.length > 1
			? `All web search providers failed: ${failures.join("; ")}`
			: (failures[0] ?? "Web search failed.");

	return { response: { provider: "none", sources: [] }, error, text: `Error: ${error}` };
}
