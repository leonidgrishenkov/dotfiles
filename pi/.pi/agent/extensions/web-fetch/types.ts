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

// ---------------------------------------------------------------------------
// GitHub types & constants
// ---------------------------------------------------------------------------

/** Parsed representation of a github.com/owner/repo URL. */
export interface GitHubUrlInfo {
	owner: string;
	repo: string;
	ref?: string;
	/** True when ref is a full 40-char commit SHA (cannot shallow-clone). */
	refIsFullSha: boolean;
	path?: string;
	type: "root" | "blob" | "tree";
}

/** Configuration for GitHub clone behaviour (read from web-search.json). */
export interface GitHubCloneConfig {
	/** Whether GitHub extraction is enabled at all. */
	enabled: boolean;
	/** Repos larger than this (MB) use the API view instead of cloning. */
	maxRepoSizeMB: number;
	/** Hard timeout for a `git clone` operation (seconds). */
	cloneTimeoutSeconds: number;
	/** Base directory where shallow clones are stored. */
	clonePath: string;
}

export const DEFAULT_GITHUB_CONFIG: Readonly<GitHubCloneConfig> = {
	enabled: true,
	maxRepoSizeMB: 350,
	cloneTimeoutSeconds: 60,
	clonePath: "/tmp/pi-github-repos",
};

/** Maximum tree entries returned in a single listing. */
export const MAX_TREE_ENTRIES = 200;

/** Maximum characters for a single inlined file. */
export const MAX_INLINE_FILE_CHARS = 100_000;

/** Maximum characters for an inlined README. */
export const MAX_README_CHARS = 8192;
