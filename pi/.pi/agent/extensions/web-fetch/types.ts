/**
 * Shared types for the web_fetch extension.
 *
 * Every fetch — regardless of the actual content type or format requested —
 * normalizes into a single `FetchResult` so the formatter and renderer can
 * stay decoupled from transport details.
 */

export type OutputFormat = "markdown" | "text" | "html";

export interface FetchResult {
	/** The final URL after redirects. */
	url: string;
	/** The original URL that was requested. */
	originalUrl: string;
	/** MIME type of the response (e.g. "text/html", "application/json"). */
	contentType: string;
	/** Whether the response was redirected across hosts. */
	crossHost: boolean;
	/** The raw response body as a string (after decoding). */
	content: string;
	/** HTTP status code. */
	status: number;
}

export interface FetchParams {
	url: string;
	format: OutputFormat;
	timeout?: number;
	signal?: AbortSignal;
	maxBytes?: number;
}

/** Thrown for HTTP, network, and security failures with actionable messages. */
export class FetchError extends Error {
	constructor(
		message: string,
		public status?: number,
		public hint?: string,
	) {
		super(hint ? `${message}\nHint: ${hint}` : message);
		this.name = "FetchError";
	}
}

/** Default timeout in milliseconds. */
export const DEFAULT_TIMEOUT_MS = 30_000;
/** Hard cap on timeout in milliseconds. */
export const MAX_TIMEOUT_MS = 120_000;
/** Maximum response body in bytes (5 MB). */
export const MAX_BYTES = 5 * 1024 * 1024;
/**
 * Default User-Agent disguised as a real browser. Most sites serve content
 * normally when they see this; Cloudflare and similar WAFs block "bot" UAs
 * by default, so a polished browser UA gets us through the door.
 */
export const USER_AGENT_BROWSER =
	"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36";

/**
 * Fallback honest User-Agent used when Cloudflare rejects the browser UA
 * with a 403 + cf-mitigated challenge. Some sites accept an identifier UA
 * on retry where the browser UA fails TLS fingerprint inspection.
 */
export const USER_AGENT_HONEST = "pi-coding-agent";
