/**
 * GitHub API helpers — thin wrappers around the `gh` CLI.
 *
 * All functions are non-throwing: they return `null` when the CLI is
 * unavailable, a network call fails, or the result cannot be parsed.
 * The caller decides how to degrade (fallback to `git clone`, show an
 * error, etc.).
 *
 * Why `gh` rather than direct REST calls?
 *  - Handles authentication transparently (private repos, SSO, etc.).
 *  - Respects GitHub rate limits and token scopes out of the box.
 *  - Single dependency — no HTTP plumbing needed here.
 */

import { execFile } from "node:child_process";
import type { GitHubUrlInfo } from "./types.ts";
import { MAX_TREE_ENTRIES, MAX_INLINE_FILE_CHARS, MAX_README_CHARS } from "./types.ts";

// ---------------------------------------------------------------------------
// Availability & authentication
// ---------------------------------------------------------------------------

let ghAvailable: boolean | null = null;
let ghAuthenticated: boolean | null = null;

/** Detect whether the `gh` CLI is installed and on `$PATH`. */
async function checkGhAvailable(): Promise<boolean> {
	if (ghAvailable !== null) return ghAvailable;

	return new Promise((resolve) => {
		execFile("gh", ["--version"], { timeout: 5000 }, (err) => {
			ghAvailable = !err;
			resolve(ghAvailable);
		});
	});
}

/**
 * Detect whether the `gh` CLI is authenticated (has a valid token/session).
 * Returns `false` when `gh` is not installed or `gh auth status` fails.
 */
export async function checkGhAuthenticated(): Promise<boolean> {
	if (ghAuthenticated !== null) return ghAuthenticated;
	if (!(await checkGhAvailable())) {
		ghAuthenticated = false;
		return false;
	}

	return new Promise((resolve) => {
		execFile("gh", ["auth", "status"], { timeout: 5000 }, (err) => {
			ghAuthenticated = !err;
			resolve(ghAuthenticated);
		});
	});
}

// ---------------------------------------------------------------------------
// Repository metadata
// ---------------------------------------------------------------------------

/** Return the repository size in KB, or `null` when unavailable. */
export async function checkRepoSize(owner: string, repo: string): Promise<number | null> {
	if (!(await checkGhAuthenticated())) return null;

	return new Promise((resolve) => {
		execFile(
			"gh",
			["api", `repos/${owner}/${repo}`, "--jq", ".size"],
			{ timeout: 10_000 },
			(err, stdout) => {
				if (err) {
					resolve(null);
					return;
				}
				const kb = parseInt(stdout.trim(), 10);
				resolve(Number.isNaN(kb) ? null : kb);
			},
		);
	});
}

/** Return the repository's default branch name, or `null`. */
export async function getDefaultBranch(
	owner: string,
	repo: string,
): Promise<string | null> {
	if (!(await checkGhAuthenticated())) return null;

	return new Promise((resolve) => {
		execFile(
			"gh",
			["api", `repos/${owner}/${repo}`, "--jq", ".default_branch"],
			{ timeout: 10_000 },
			(err, stdout) => {
				if (err) {
					resolve(null);
					return;
				}
				const branch = stdout.trim();
				resolve(branch || null);
			},
		);
	});
}

// ---------------------------------------------------------------------------
// Content fetching via `gh api`
// ---------------------------------------------------------------------------

/** Fetch the recursive file tree as a newline-separated list of paths. */
async function fetchTreeViaApi(
	owner: string,
	repo: string,
	ref: string,
): Promise<string | null> {
	if (!(await checkGhAuthenticated())) return null;

	return new Promise((resolve) => {
		execFile(
			"gh",
			[
				"api",
				`repos/${owner}/${repo}/git/trees/${ref}?recursive=1`,
				"--jq",
				".tree[].path",
			],
			{ timeout: 15_000, maxBuffer: 5 * 1024 * 1024 },
			(err, stdout) => {
				if (err) {
					resolve(null);
					return;
				}
				const paths = stdout.trim().split("\n").filter(Boolean);
				if (paths.length === 0) {
					resolve(null);
					return;
				}
				const truncated = paths.length > MAX_TREE_ENTRIES;
				const display = paths.slice(0, MAX_TREE_ENTRIES).join("\n");
				resolve(
					truncated
						? `${display}\n... (${paths.length} total entries)`
						: display,
				);
			},
		);
	});
}

/** Fetch the repository README (decoded from base64), truncated to a safe size. */
async function fetchReadmeViaApi(
	owner: string,
	repo: string,
	ref: string,
): Promise<string | null> {
	if (!(await checkGhAuthenticated())) return null;

	return new Promise((resolve) => {
		execFile(
			"gh",
			[
				"api",
				`repos/${owner}/${repo}/readme?ref=${ref}`,
				"--jq",
				".content",
			],
			{ timeout: 10_000 },
			(err, stdout) => {
				if (err) {
					resolve(null);
					return;
				}
				try {
					const decoded = Buffer.from(stdout.trim(), "base64").toString(
						"utf-8",
					);
					resolve(
						decoded.length > MAX_README_CHARS
							? decoded.slice(0, MAX_README_CHARS) +
								"\n\n[README truncated at 8K chars]"
							: decoded,
					);
				} catch {
					resolve(null);
				}
			},
		);
	});
}

/** Fetch a single file's content (decoded from base64). */
async function fetchFileViaApi(
	owner: string,
	repo: string,
	path: string,
	ref: string,
): Promise<string | null> {
	if (!(await checkGhAuthenticated())) return null;

	return new Promise((resolve) => {
		execFile(
			"gh",
			[
				"api",
				`repos/${owner}/${repo}/contents/${path}?ref=${ref}`,
				"--jq",
				".content",
			],
			{ timeout: 10_000, maxBuffer: 2 * 1024 * 1024 },
			(err, stdout) => {
				if (err) {
					resolve(null);
					return;
				}
				try {
					resolve(Buffer.from(stdout.trim(), "base64").toString("utf-8"));
				} catch {
					resolve(null);
				}
			},
		);
	});
}

// ---------------------------------------------------------------------------
// Unified API entry point
// ---------------------------------------------------------------------------

/**
 * Fetch GitHub content purely through the `gh` CLI API — no cloning.
 *
 * - **blob** URLs → single file content.
 * - **root / tree** URLs → file tree + README.
 *
 * Returns `null` when every API call fails. The `sizeNote` string, when
 * provided, is prepended to the output (e.g. "repo too large to clone").
 */
export async function fetchViaApi(
	url: string,
	owner: string,
	repo: string,
	info: GitHubUrlInfo,
	sizeNote?: string,
): Promise<string | null> {
	const ref = info.ref || (await getDefaultBranch(owner, repo));
	if (!ref) return null;

	const lines: string[] = [];
	if (sizeNote) {
		lines.push(sizeNote);
		lines.push("");
	}

	// -- Single file --------------------------------------------------------
	if (info.type === "blob" && info.path) {
		const content = await fetchFileViaApi(owner, repo, info.path, ref);
		if (!content) return null;

		lines.push(`## ${info.path}`);
		if (content.length > MAX_INLINE_FILE_CHARS) {
			lines.push(content.slice(0, MAX_INLINE_FILE_CHARS));
			lines.push(`\n[File truncated at ${MAX_INLINE_FILE_CHARS / 1000}K chars]`);
		} else {
			lines.push(content);
		}

		return lines.join("\n");
	}

	// -- Repo overview (tree + README) --------------------------------------
	const [tree, readme] = await Promise.all([
		fetchTreeViaApi(owner, repo, ref),
		fetchReadmeViaApi(owner, repo, ref),
	]);

	if (!tree && !readme) return null;

	if (tree) {
		lines.push("## Structure");
		lines.push(tree);
		lines.push("");
	}

	if (readme) {
		lines.push("## README.md");
		lines.push(readme);
		lines.push("");
	}

	lines.push(
		"This is an API-only view. Clone the repo or use `read`/`bash` for deeper exploration.",
	);

	return lines.join("\n");
}
