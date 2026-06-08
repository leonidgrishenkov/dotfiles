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
/** User-Agent identifying this tool to site operators. */
export const USER_AGENT =
	"Mozilla/5.0 (compatible; pi-web-fetch/1.0; +https://github.com/earendil-works/pi-coding-agent)";
