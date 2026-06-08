/**
 * Core fetch logic — pure network I/O with security hardening.
 *
 * Mirrors the role of `orchestrator.ts` in the web-search extension:
 * a single `fetchUrl()` function handles all transport concerns and
 * returns a normalized `FetchResult` (or throws `FetchError`).
 *
 * Security measures (following web_fetch.md best practices):
 *  - HTTPS upgrade by default
 *  - SSRF protection: block private IPs and localhost
 *  - Cross-host redirect detection and explicit notification
 *  - Content-length / size guard (5 MB)
 *  - Sensible timeouts (default 30 s, max 120 s)
 *  - Identified User-Agent so site operators can see bot traffic
 */

import {
	type FetchParams,
	type FetchResult,
	type OutputFormat,
	FetchError,
	MAX_BYTES,
	MAX_TIMEOUT_MS,
	DEFAULT_TIMEOUT_MS,
	USER_AGENT,
} from "./types.ts";

// ---------------------------------------------------------------------------
// URL helpers
// ---------------------------------------------------------------------------

const PRIVATE_IPV4_RE =
	/^(?:127\.|10\.|172\.(?:1[6-9]|2\d|3[01])\.|192\.168\.|169\.254\.|0\.)/;

/**
 * Ensure the URL uses HTTPS. If the caller passed `http://`, upgrade it
 * unless the host is explicitly localhost/loopback (which we block anyway).
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

/** Reject private / loopback / link-local hosts to prevent SSRF. */
function assertPublicHost(url: URL): void {
	const host = url.hostname.toLowerCase();
	if (
		host === "localhost" ||
		host === "[::1]" ||
		host === "::1" ||
		host.endsWith(".local") ||
		host.endsWith(".localhost") ||
		PRIVATE_IPV4_RE.test(host)
	) {
		throw new FetchError(
			`Blocked request to private host: ${host}`,
			undefined,
			"web_fetch refuses to contact localhost or private IPs for security.",
		);
	}
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
	assertPublicHost(originalUrl);

	// -- Build a timed-out abort controller that wraps the caller's signal ----
	const controller = new AbortController();
	if (signal) {
		if (signal.aborted) throw new FetchError("Aborted before request.");
		signal.addEventListener("abort", () => controller.abort(signal.reason), { once: true });
	}
	const timer = setTimeout(() => controller.abort(new Error(`Request timed out after ${timeout / 1000}s`)), timeout);

	let response: Response;
	try {
		response = await fetch(originalUrl.toString(), {
			signal: controller.signal,
			redirect: "follow",
			headers: {
				"User-Agent": USER_AGENT,
				Accept: acceptHeader(format),
				"Accept-Language": "en-US,en;q=0.9",
			},
		});
	} catch (err) {
		const msg = (err as Error).message;
		if (controller.signal.aborted && msg.includes("timed out")) {
			throw new FetchError(`Request timed out after ${timeout / 1000}s`);
		}
		if (signal?.aborted) throw new FetchError("Aborted.");
		throw new FetchError(`Network error: ${msg}`);
	} finally {
		clearTimeout(timer);
	}

	// -- Resolve the actual final URL (after redirects) ----------------------
	const finalUrl = new URL(response.url);
	const crossHost = originalUrl.host !== finalUrl.host;
	assertPublicHost(finalUrl); // also guard the redirect target

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
