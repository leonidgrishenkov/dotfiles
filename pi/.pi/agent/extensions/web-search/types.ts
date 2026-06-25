/**
 * Unified web-search types shared across providers and orchestration.
 *
 * Inspired by oh-my-pi's `web/search/types.ts`: every provider, regardless of
 * its upstream API shape, normalizes into a single `SearchResponse`.
 */

export type ProviderName = "tavily" | "brave" | "perplexity" | "exa";
export type Recency = "day" | "week" | "month" | "year";

export interface SearchSource {
	title?: string;
	url: string;
	snippet?: string;
	publishedDate?: string;
}

export interface SearchResponse {
	provider: ProviderName | "none";
	answer?: string;
	sources: SearchSource[];
}

export interface SearchParams {
	query: string;
	limit: number;
	recency?: Recency;
	signal?: AbortSignal;
}

/**
 * How a provider obtains its API key.
 *
 * When `command` is set it is the sole source — env vars are ignored.
 * Otherwise `envVars` are tried in order.
 */
export interface CredentialSource {
	/** Env var names tried in order (when no `command` is set). */
	envVars: string[];
	/** Arbitrary shell command whose stdout is the API key. When present, `envVars` is ignored. */
	command?: string;
}

export interface Provider {
	name: ProviderName;
	credentials: CredentialSource;
	search(key: string, params: SearchParams): Promise<SearchResponse>;
}

/** Thrown by provider adapters for HTTP/protocol failures. */
export class SearchProviderError extends Error {
	constructor(
		public provider: ProviderName,
		message: string,
		public status?: number,
	) {
		super(message);
		this.name = "SearchProviderError";
	}
}

export function clamp(n: number, lo: number, hi: number): number {
	return Math.max(lo, Math.min(hi, n));
}

/** Shared JSON fetch helper that normalizes errors into SearchProviderError. */
export async function fetchJson(
	provider: ProviderName,
	url: string,
	init: RequestInit,
): Promise<unknown> {
	let res: Response;
	try {
		res = await fetch(url, init);
	} catch (err) {
		throw new SearchProviderError(provider, `network error: ${(err as Error).message}`);
	}
	if (!res.ok) {
		const body = await res.text().catch(() => "");
		throw new SearchProviderError(
			provider,
			`HTTP ${res.status} ${res.statusText}${body ? `: ${body.slice(0, 200)}` : ""}`,
			res.status,
		);
	}
	return res.json();
}
