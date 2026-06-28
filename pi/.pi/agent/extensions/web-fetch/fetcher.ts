/**
 * Core fetch logic — pure network I/O with security hardening.
 *
 * Mirrors the role of `orchestrator.ts` in the web-search extension:
 * a single `fetchUrl()` function handles all transport concerns and
 * returns a normalized `FetchResult` (or throws `FetchError`).
 *
 * Security measures (following web_fetch.md best practices):
 *  - HTTPS upgrade by default
 *  - SSRF protection: DNS-aware private/reserved IP blocking (IPv4 + IPv6),
 *    with every redirect hop re-validated (see ssrf-protection.ts)
 *  - Cross-host redirect detection and explicit notification
 *  - Content-length / size guard (5 MB)
 *  - Sensible timeouts (default 30 s, max 120 s)
 *  - Two-tier User-Agent: browser UA first, honest fallback on Cloudflare 403
 */

import {
	type FetchParams,
	type FetchResult,
	type OutputFormat,
	FetchError,
	MAX_BYTES,
	MAX_TIMEOUT_MS,
	DEFAULT_TIMEOUT_MS,
	USER_AGENT_BROWSER,
	USER_AGENT_HONEST,
} from "./types.ts";
import { fetchRemoteUrl, validateRemoteUrl } from "./ssrf-protection.ts";

// ---------------------------------------------------------------------------
// URL helpers
// ---------------------------------------------------------------------------

/**
 * Ensure the URL uses HTTPS. If the caller passed `http://`, upgrade it
 * (localhost/private hosts are rejected later by the SSRF guard).
 */
function normalizeUrl(raw: string): URL {
	if (!/^https?:\/\//i.test(raw)) {
		throw new FetchError(
			`Invalid URL: "${raw}"`,
			undefined,
			"The URL must start with http:// or https://.",
		);
	}
	return new URL(raw.replace(/^http:\/\//i, "https://"));
}

// ---------------------------------------------------------------------------
// Accept header negotiation
// ---------------------------------------------------------------------------

function acceptHeader(format: OutputFormat): string {
	switch (format) {
		case "markdown":
			return "text/markdown;q=1.0, text/x-markdown;q=0.9, text/plain;q=0.8, text/html;q=0.7, */*;q=0.1";
		case "text":
			return "text/plain;q=1.0, text/markdown;q=0.9, text/html;q=0.8, */*;q=0.1";
		case "html":
			return "text/html;q=1.0, application/xhtml+xml;q=0.9, text/plain;q=0.8, text/markdown;q=0.7, */*;q=0.1";
	}
}

// ---------------------------------------------------------------------------
// Fetch helpers
// ---------------------------------------------------------------------------

interface DoFetchOptions {
	signal?: AbortSignal;
	userAgent: string;
	accept: string;
	allowRanges?: string[];
}

/**
 * Single fetch attempt routed through the SSRF guard.
 *
 * `fetchRemoteUrl` validates the initial URL *and every redirect hop* against
 * the private/reserved IP blocklist (resolving DNS each time), following
 * redirects manually so an internal target can never be contacted. Throws
 * `FetchError` on network, abort, or security failures.
 */
async function doFetch(url: string, opts: DoFetchOptions): Promise<Response> {
	try {
		return await fetchRemoteUrl(
			url,
			{
				signal: opts.signal,
				headers: {
					"User-Agent": opts.userAgent,
					Accept: opts.accept,
					"Accept-Language": "en-US,en;q=0.9",
				},
			},
			{ allowRanges: opts.allowRanges },
		);
	} catch (err) {
		if (opts.signal?.aborted) {
			// Distinguish timeout abort from explicit abort (e.g. Esc key).
			const reason = opts.signal.reason;
			if (reason instanceof Error && /timed out/i.test(reason.message)) {
				throw new FetchError(reason.message);
			}
			throw new FetchError("Aborted.");
		}
		const message = (err as Error).message;
		// Surface SSRF guard rejections as a clear, non-retryable security error.
		if (/^Blocked internal|^Only HTTP|^Failed to resolve|redirects fetching/i.test(message)) {
			throw new FetchError(
				`Blocked request: ${message}`,
				undefined,
				"web_fetch refuses to contact localhost, private, or reserved IP ranges for security.",
			);
		}
		throw new FetchError(`Network error: ${message}`);
	}
}

/** True when a response is a Cloudflare bot-detection challenge. */
function isCloudflareChallenge(res: Response): boolean {
	return res.status === 403 && res.headers.get("cf-mitigated") === "challenge";
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------

/**
 * Fetch `params.url` and return the raw response body + metadata.
 *
 * Throws `FetchError` for validation/network/security failures so the
 * caller can turn them into structured tool-result errors.
 *
 * Uses `redirect: "follow"` (up to 5 automatic hops) and detects
 * cross-host redirects by comparing the request URL with `response.url`.
 */
export async function fetchUrl(params: FetchParams): Promise<FetchResult> {
	const { format, signal } = params;
	const timeout = Math.min(
		(params.timeout ?? DEFAULT_TIMEOUT_MS / 1000) * 1000,
		MAX_TIMEOUT_MS,
	);
	const maxBytes = params.maxBytes ?? MAX_BYTES;

	// -- Validate & normalize URL -------------------------------------------
	const originalUrl = normalizeUrl(params.url);
	// Pre-flight SSRF check (DNS-aware). The transport-level check in
	// `fetchRemoteUrl` re-validates this plus every redirect hop, but doing it
	// here first yields a clean security error before the abort timer starts.
	try {
		await validateRemoteUrl(originalUrl, { allowRanges: params.allowRanges });
	} catch (err) {
		throw new FetchError(
			`Blocked request: ${(err as Error).message}`,
			undefined,
			"web_fetch refuses to contact localhost, private, or reserved IP ranges for security.",
		);
	}

	// -- Build a timed-out abort controller that wraps the caller's signal ----
	const controller = new AbortController();
	if (signal) {
		if (signal.aborted) throw new FetchError("Aborted before request.");
		signal.addEventListener("abort", () => controller.abort(signal.reason), { once: true });
	}
	const timer = setTimeout(() => controller.abort(new Error(`Request timed out after ${timeout / 1000}s`)), timeout);

	const accept = acceptHeader(format);

	// First attempt: browser-like UA to pass standard bot gates.
	let response = await doFetch(originalUrl.toString(), {
		signal: controller.signal,
		userAgent: USER_AGENT_BROWSER,
		accept,
		allowRanges: params.allowRanges,
	});

	// Retry with honest UA when Cloudflare blocks the browser UA via
	// TLS fingerprint mismatch (403 + cf-mitigated: challenge).
	if (isCloudflareChallenge(response)) {
		response = await doFetch(originalUrl.toString(), {
			signal: controller.signal,
			userAgent: USER_AGENT_HONEST,
			accept,
			allowRanges: params.allowRanges,
		});
	}

	clearTimeout(timer);

	// -- Resolve the actual final URL (after redirects) ----------------------
	// Every hop was already SSRF-validated inside fetchRemoteUrl; here we only
	// need the final URL to report cross-host redirects to the caller.
	const finalUrl = new URL(response.url || originalUrl.toString());
	const crossHost = originalUrl.host !== finalUrl.host;

	// -- Size guard (Content-Length) ----------------------------------------
	const contentLength = response.headers.get("content-length");
	if (contentLength && parseInt(contentLength, 10) > maxBytes) {
		throw new FetchError(
			`Response too large (${contentLength} bytes, exceeds ${(maxBytes / 1024 / 1024).toFixed(0)} MB limit).`,
			undefined,
			"Try fetching a smaller variant of the page, or use web_search tool to locate an alternative source.",
		);
	}

	// -- HTTP error handling with actionable hints ---------------------------
	if (!response.ok) {
		const body = await response.text().catch(() => "");
		const status = response.status;
		let hint: string | undefined;
		if (status === 403) hint = "Access was denied. Try web_search tool to locate an alternative source, or check if the URL requires authentication.";
		if (status === 404) hint = "Page not found. Verify the URL or try web_search tool to locate the correct resource.";
		if (status === 429) hint = "Rate limited. Retry after the period indicated by Retry-After header.";
		if (status >= 500) hint = "Server error. Try again in a moment or check the service status page.";
		throw new FetchError(
			`HTTP ${status} ${response.statusText}${body ? `: ${body.slice(0, 200)}` : ""}`,
			status,
			hint,
		);
	}

	// -- Read the body -------------------------------------------------------
	let arrayBuffer: ArrayBuffer;
	try {
		arrayBuffer = await response.arrayBuffer();
	} catch (err) {
		throw new FetchError(`Failed to read response body: ${(err as Error).message}`);
	}

	if (arrayBuffer.byteLength > maxBytes) {
		throw new FetchError(
			`Response body too large (${arrayBuffer.byteLength} bytes, exceeds ${(maxBytes / 1024 / 1024).toFixed(0)} MB limit).`,
		);
	}

	const contentType = response.headers.get("content-type") ?? "";
	const content = new TextDecoder().decode(arrayBuffer);

	return {
		url: finalUrl.toString(),
		originalUrl: originalUrl.toString(),
		contentType,
		crossHost,
		content,
		status: response.status,
	};
}
