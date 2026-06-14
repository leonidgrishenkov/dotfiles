/**
 * GitHub content extraction — URL-aware dispatcher with clone-or-API fallback.
 *
 * Pipeline:
 *   1. Parse the URL into owner/repo/path metadata.
 *   2. Check repo size against the configured threshold.
 *      - Small enough → shallow clone → local file tree / content.
 *      - Too large    → `gh api` for tree + README (no clone).
 *   3. Full commit-SHA URLs always use the API (cannot shallow-clone a SHA).
 *   4. On any failure → try the other path, then return null.
 *
 * The result is a `FetchResult` so the caller can format it with the
 * same pipeline used for plain HTTP fetches.
 *
 * Configuration is read from `~/.pi/web-search.json` under the
 * `"githubClone"` key, with sensible defaults when absent.
 */

import {
	existsSync,
	readFileSync,
	rmSync,
	statSync,
	readdirSync,
	openSync,
	readSync,
	closeSync,
	realpathSync,
} from "node:fs";
import { execFile } from "node:child_process";
import { homedir } from "node:os";
import { extname, join, resolve as resolvePath, sep as pathSep } from "node:path";
import type { FetchResult, GitHubCloneConfig, GitHubUrlInfo } from "./types.ts";
import {
	DEFAULT_GITHUB_CONFIG,
	MAX_TREE_ENTRIES,
	MAX_INLINE_FILE_CHARS,
	MAX_README_CHARS,
	FetchError,
} from "./types.ts";
import { fetchViaApi, checkGhAuthenticated, checkRepoSize } from "./github-api.ts";

// ---------------------------------------------------------------------------
// URL segment filtering
// ---------------------------------------------------------------------------

/**
 * GitHub path segments that are *not* source code — issues, discussions,
 * CI, project management. These URLs should be fetched via plain HTTP
 * (they return HTML, not repository content).
 */
const NON_CODE_SEGMENTS = new Set([
	"issues",
	"pull",
	"pulls",
	"discussions",
	"releases",
	"wiki",
	"actions",
	"settings",
	"security",
	"projects",
	"graphs",
	"compare",
	"commits",
	"tags",
	"branches",
	"stargazers",
	"watchers",
	"network",
	"forks",
	"milestone",
	"labels",
	"packages",
	"codespaces",
	"contribute",
	"community",
	"sponsors",
	"invitations",
	"notifications",
	"insights",
]);

// ---------------------------------------------------------------------------
// Binary / noise detection
// ---------------------------------------------------------------------------

const BINARY_EXTENSIONS = new Set([
	".png", ".jpg", ".jpeg", ".gif", ".bmp", ".ico", ".webp", ".svg", ".tiff", ".tif",
	".mp3", ".mp4", ".avi", ".mov", ".mkv", ".flv", ".wmv", ".wav", ".ogg", ".webm",
	".flac", ".aac",
	".zip", ".tar", ".gz", ".bz2", ".xz", ".7z", ".rar", ".zst",
	".exe", ".dll", ".so", ".dylib", ".bin", ".o", ".a", ".lib",
	".woff", ".woff2", ".ttf", ".otf", ".eot",
	".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",
	".sqlite", ".db", ".sqlite3",
	".pyc", ".pyo", ".class", ".jar", ".war",
	".iso", ".img", ".dmg",
]);

/** Directories to skip when building a file tree (build artefacts, caches). */
const NOISE_DIRS = new Set([
	"node_modules",
	"vendor",
	".next",
	"dist",
	"build",
	"__pycache__",
	".venv",
	"venv",
	".tox",
	".mypy_cache",
	".pytest_cache",
	"target",
	".gradle",
	".idea",
	".vscode",
]);

// ---------------------------------------------------------------------------
// URL parsing
// ---------------------------------------------------------------------------

/**
 * Parse a GitHub URL into structured metadata.
 *
 * Returns `null` for non-GitHub hosts or URLs that point to non-code
 * sections (issues, pull requests, etc.) — those should be fetched via
 * plain HTTP like any other web page.
 */
export function parseGitHubUrl(url: string): GitHubUrlInfo | null {
	let parsed: URL;
	try {
		parsed = new URL(url);
	} catch {
		return null;
	}

	const host = parsed.hostname.toLowerCase();
	if (host !== "github.com" && host !== "www.github.com") return null;

	const segments = parsed.pathname
		.split("/")
		.filter(Boolean)
		.map((segment) => {
			try {
				return decodeURIComponent(segment);
			} catch {
				return segment;
			}
		});

	if (segments.length < 2) return null;

	const owner = segments[0];
	const repo = segments[1].replace(/\.git$/, "");

	// Non-code segments → let the HTTP fetcher handle them normally.
	if (NON_CODE_SEGMENTS.has(segments[2]?.toLowerCase())) return null;

	if (segments.length === 2) {
		return { owner, repo, refIsFullSha: false, type: "root" };
	}

	const action = segments[2];
	if (action !== "blob" && action !== "tree") return null;
	if (segments.length < 4) return null;

	const ref = segments[3];
	const refIsFullSha = /^[0-9a-f]{40}$/.test(ref);
	const pathParts = segments.slice(4);
	const path = pathParts.length > 0 ? pathParts.join("/") : "";

	return { owner, repo, ref, refIsFullSha, path, type: action as "blob" | "tree" };
}

// ---------------------------------------------------------------------------
// Configuration
// ---------------------------------------------------------------------------

const CONFIG_PATH = join(homedir(), ".pi", "web-search.json");

let cachedConfig: GitHubCloneConfig | null = null;

function normalizeEnabled(value: unknown, fallback: boolean): boolean {
	return typeof value === "boolean" ? value : fallback;
}

function normalizePositiveNumber(value: unknown, fallback: number): number {
	if (typeof value !== "number" || !Number.isFinite(value)) return fallback;
	return value > 0 ? value : fallback;
}

function normalizeClonePath(value: unknown, fallback: string): string {
	if (typeof value !== "string") return fallback;
	const trimmed = value.trim();
	return trimmed.length > 0 ? trimmed : fallback;
}

/** Load GitHub config from `~/.pi/web-search.json` (falls back to defaults). */
export function loadGitHubConfig(): GitHubCloneConfig {
	if (cachedConfig) return cachedConfig;

	if (!existsSync(CONFIG_PATH)) {
		cachedConfig = { ...DEFAULT_GITHUB_CONFIG };
		return cachedConfig;
	}

	let raw: { githubClone?: Partial<GitHubCloneConfig> };
	try {
		const text = readFileSync(CONFIG_PATH, "utf-8");
		raw = JSON.parse(text) as { githubClone?: Partial<GitHubCloneConfig> };
	} catch (err) {
		const message = err instanceof Error ? err.message : String(err);
		throw new FetchError(`Failed to parse ${CONFIG_PATH}: ${message}`);
	}

	const gc = raw.githubClone ?? {};
	cachedConfig = {
		enabled: normalizeEnabled(gc.enabled, DEFAULT_GITHUB_CONFIG.enabled),
		maxRepoSizeMB: normalizePositiveNumber(
			gc.maxRepoSizeMB,
			DEFAULT_GITHUB_CONFIG.maxRepoSizeMB,
		),
		cloneTimeoutSeconds: normalizePositiveNumber(
			gc.cloneTimeoutSeconds,
			DEFAULT_GITHUB_CONFIG.cloneTimeoutSeconds,
		),
		clonePath: normalizeClonePath(gc.clonePath, DEFAULT_GITHUB_CONFIG.clonePath),
	};

	return cachedConfig;
}

// ---------------------------------------------------------------------------
// Clone helpers
// ---------------------------------------------------------------------------

let cachedCloneCache: Map<string, string | null> = new Map();

function cloneDir(
	config: GitHubCloneConfig,
	owner: string,
	repo: string,
	ref?: string,
): string {
	const dirName = ref ? `${repo}@${ref}` : repo;
	return join(config.clonePath, owner, dirName);
}

/**
 * Shallow-clone a repository. Tries `gh repo clone` first (handles auth
 * for private repos), falls back to `git clone` for public repos.
 *
 * Returns the local path on success, `null` on failure.
 */
async function cloneRepo(
	owner: string,
	repo: string,
	ref: string | undefined,
	config: GitHubCloneConfig,
	signal?: AbortSignal,
): Promise<string | null> {
	const localPath = cloneDir(config, owner, repo, ref);

	// Clean previous attempt so we get a fresh clone.
	try {
		rmSync(localPath, { recursive: true, force: true });
	} catch {
		// Directory may not exist — that's fine.
	}

	const timeoutMs = config.cloneTimeoutSeconds * 1000;
	const hasGh = await checkGhAuthenticated();

	if (hasGh) {
		const args = [
			"gh",
			"repo",
			"clone",
			`${owner}/${repo}`,
			localPath,
			"--",
			"--depth",
			"1",
			"--single-branch",
		];
		if (ref) args.push("--branch", ref);
		return execGitCommand(args, localPath, timeoutMs, signal);
	}

	// Fallback: plain `git clone` (only works for public repos without gh auth).
	const gitUrl = `https://github.com/${owner}/${repo}.git`;
	const args = ["git", "clone", "--depth", "1", "--single-branch"];
	if (ref) args.push("--branch", ref);
	args.push(gitUrl, localPath);
	return execGitCommand(args, localPath, timeoutMs, signal);
}

function execGitCommand(
	args: string[],
	localPath: string,
	timeoutMs: number,
	signal?: AbortSignal,
): Promise<string | null> {
	return new Promise((resolve) => {
		const child = execFile(args[0], args.slice(1), { timeout: timeoutMs }, (err) => {
			if (err) {
				try {
					rmSync(localPath, { recursive: true, force: true });
				} catch {
					// Cleanup is best-effort.
				}
				resolve(null);
				return;
			}
			resolve(localPath);
		});

		if (signal) {
			const onAbort = () => child.kill();
			signal.addEventListener("abort", onAbort, { once: true });
			child.on("exit", () => signal.removeEventListener("abort", onAbort));
		}
	});
}

// ---------------------------------------------------------------------------
// Binary file detection
// ---------------------------------------------------------------------------

/** True when a file extension is known-binary, or a null-byte probe finds one. */
function isBinaryFile(filePath: string): boolean {
	const ext = extname(filePath).toLowerCase();
	if (BINARY_EXTENSIONS.has(ext)) return true;

	let fd: number;
	try {
		fd = openSync(filePath, "r");
	} catch {
		return false;
	}
	try {
		const buf = Buffer.alloc(512);
		const bytesRead = readSync(fd, buf, 0, 512, 0);
		for (let i = 0; i < bytesRead; i++) {
			if (buf[i] === 0) return true;
		}
	} catch {
		return false;
	} finally {
		closeSync(fd);
	}
	return false;
}

// ---------------------------------------------------------------------------
// Tree / directory building
// ---------------------------------------------------------------------------

function formatFileSize(bytes: number): string {
	if (bytes < 1024) return `${bytes} B`;
	if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
	return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

/**
 * Resolve a relative path within a repo, refusing to escape the root.
 * Checks both the logical path and the resolved (realpath) path.
 */
function resolveWithinRepo(rootPath: string, relativePath: string): string | null {
	const normalizedRoot = resolvePath(rootPath);
	const candidate = resolvePath(normalizedRoot, relativePath);

	if (candidate !== normalizedRoot) {
		const rootPrefix = normalizedRoot.endsWith(pathSep)
			? normalizedRoot
			: normalizedRoot + pathSep;
		if (!candidate.startsWith(rootPrefix)) return null;
	}

	if (!existsSync(candidate)) return candidate;

	try {
		const realRoot = realpathSync(normalizedRoot);
		const realCandidate = realpathSync(candidate);
		if (realCandidate === realRoot) return candidate;
		const realRootPrefix = realRoot.endsWith(pathSep)
			? realRoot
			: realRoot + pathSep;
		return realCandidate.startsWith(realRootPrefix) ? candidate : null;
	} catch {
		return null;
	}
}

/** Recursively build a file tree string for the given directory. */
function buildTree(rootPath: string): string {
	const entries: string[] = [];

	function walk(dir: string, relPath: string): void {
		if (entries.length >= MAX_TREE_ENTRIES) return;

		let items: string[];
		try {
			items = readdirSync(dir).sort();
		} catch {
			return;
		}

		for (const item of items) {
			if (entries.length >= MAX_TREE_ENTRIES) return;
			if (item === ".git") continue;

			const rel = relPath ? `${relPath}/${item}` : item;
			const safePath = resolveWithinRepo(rootPath, rel);
			if (!safePath) {
				entries.push(`${rel}  [outside repo skipped]`);
				continue;
			}

			let stat;
			try {
				stat = statSync(safePath);
			} catch {
				continue;
			}

			if (stat.isDirectory()) {
				if (NOISE_DIRS.has(item)) {
					entries.push(`${rel}/  [skipped]`);
					continue;
				}
				entries.push(`${rel}/`);
				walk(safePath, rel);
			} else {
				entries.push(rel);
			}
		}
	}

	walk(rootPath, "");

	if (entries.length >= MAX_TREE_ENTRIES) {
		entries.push(`... (truncated at ${MAX_TREE_ENTRIES} entries)`);
	}

	return entries.join("\n");
}

/** Build a flat directory listing for a sub-directory. */
function buildDirListing(rootPath: string, subPath: string): string {
	const targetPath = resolveWithinRepo(rootPath, subPath);
	if (!targetPath) return "(path escapes repository root)";

	const lines: string[] = [];
	let items: string[];
	try {
		items = readdirSync(targetPath).sort();
	} catch {
		return "(directory not readable)";
	}

	for (const item of items) {
		if (item === ".git") continue;
		const rel = subPath ? `${subPath}/${item}` : item;
		const safePath = resolveWithinRepo(rootPath, rel);
		if (!safePath) {
			lines.push(`  ${item}  (outside repo)`);
			continue;
		}
		try {
			const stat = statSync(safePath);
			lines.push(
				stat.isDirectory()
					? `  ${item}/`
					: `  ${item}  (${formatFileSize(stat.size)})`,
			);
		} catch {
			lines.push(`  ${item}  (unreadable)`);
		}
	}

	return lines.join("\n");
}

/** Read a README file from the repo root (tries several common names). */
function readReadme(localPath: string): string | null {
	const candidates = [
		"README.md",
		"readme.md",
		"README",
		"README.txt",
		"README.rst",
	];
	for (const name of candidates) {
		const readmePath = join(localPath, name);
		if (existsSync(readmePath)) {
			try {
				const content = readFileSync(readmePath, "utf-8");
				return content.length > MAX_README_CHARS
					? content.slice(0, MAX_README_CHARS) + "\n\n[README truncated at 8K chars]"
					: content;
			} catch {
				continue;
			}
		}
	}
	return null;
}

// ---------------------------------------------------------------------------
// Content assembly from a local clone
// ---------------------------------------------------------------------------

function readTextFile(path: string): string | null {
	try {
		return readFileSync(path, "utf-8");
	} catch {
		return null;
	}
}

/**
 * Build the LLM-facing content string from a local clone directory.
 * Handles root (tree + README), tree (directory listing), and blob (file).
 */
function generateContent(localPath: string, info: GitHubUrlInfo): string {
	const lines: string[] = [];
	lines.push(`Repository cloned to: ${localPath}`);
	lines.push("");

	// -- Root: full tree + README -------------------------------------------
	if (info.type === "root") {
		lines.push("## Structure");
		lines.push(buildTree(localPath));
		lines.push("");

		const readme = readReadme(localPath);
		if (readme) {
			lines.push("## README.md");
			lines.push(readme);
			lines.push("");
		}

		lines.push("Use `read` and `bash` tools at the path above to explore further.");
		return lines.join("\n");
	}

	// -- Tree: directory listing --------------------------------------------
	if (info.type === "tree") {
		const dirPath = info.path || "";
		const fullDirPath = resolveWithinRepo(localPath, dirPath);

		if (!fullDirPath || !existsSync(fullDirPath)) {
			lines.push(`Path \`${dirPath}\` not found in clone. Showing repository root instead.`);
			lines.push("");
			lines.push("## Structure");
			lines.push(buildTree(localPath));
		} else {
			lines.push(`## ${dirPath || "/"}`);
			lines.push(buildDirListing(localPath, dirPath));
		}

		lines.push("");
		lines.push("Use `read` and `bash` tools at the path above to explore further.");
		return lines.join("\n");
	}

	// -- Blob: file content -------------------------------------------------
	if (info.type === "blob") {
		const filePath = info.path || "";
		const fullFilePath = resolveWithinRepo(localPath, filePath);

		if (!fullFilePath || !existsSync(fullFilePath)) {
			lines.push(`Path \`${filePath}\` not found in clone. Showing repository root instead.`);
			lines.push("");
			lines.push("## Structure");
			lines.push(buildTree(localPath));
			lines.push("");
			lines.push("Use `read` and `bash` tools at the path above to explore further.");
			return lines.join("\n");
		}

		let stat: ReturnType<typeof statSync>;
		try {
			stat = statSync(fullFilePath);
		} catch (err) {
			const message = err instanceof Error ? err.message : String(err);
			lines.push(`Could not inspect \`${filePath}\`: ${message}`);
			lines.push("");
			lines.push("Use `read` and `bash` tools at the path above to explore further.");
			return lines.join("\n");
		}

		if (stat.isDirectory()) {
			lines.push(`## ${filePath || "/"}`);
			lines.push(buildDirListing(localPath, filePath));
			lines.push("");
			lines.push("Use `read` and `bash` tools at the path above to explore further.");
			return lines.join("\n");
		}

		if (isBinaryFile(fullFilePath)) {
			const ext = extname(filePath).replace(".", "");
			lines.push(`## ${filePath}`);
			lines.push(
				`Binary file (${ext}, ${formatFileSize(stat.size)}). ` +
					"Use `read` or `bash` tools at the path above to inspect.",
			);
			return lines.join("\n");
		}

		const content = readTextFile(fullFilePath);
		if (content === null) {
			lines.push(`Could not read \`${filePath}\` as UTF-8 text.`);
			lines.push("");
			lines.push("Use `read` and `bash` tools at the path above to explore further.");
			return lines.join("\n");
		}

		lines.push(`## ${filePath}`);
		if (content.length > MAX_INLINE_FILE_CHARS) {
			lines.push(content.slice(0, MAX_INLINE_FILE_CHARS));
			lines.push("");
			lines.push(`[File truncated at ${MAX_INLINE_FILE_CHARS / 1000}K chars. Full file: ${fullFilePath}]`);
		} else {
			lines.push(content);
		}

		lines.push("");
		lines.push("Use `read` and `bash` tools at the path above to explore further.");
		return lines.join("\n");
	}

	return lines.join("\n");
}

// ---------------------------------------------------------------------------
// Main entry point
// ---------------------------------------------------------------------------

/**
 * Attempt to fetch a GitHub URL with structured content extraction.
 *
 * - Small repos are shallow-cloned; the clone path is included so the
 *   agent can use `read`/`bash` for deeper exploration.
 * - Large repos (or full-SHA URLs) fall back to the `gh` API for a
 *   read-only tree + README view.
 * - Returns `null` when the URL is not a GitHub code URL, GitHub
 *   extraction is disabled, or all fetch paths fail.
 */
export async function fetchGitHubUrl(
	url: string,
	signal?: AbortSignal,
	forceClone?: boolean,
): Promise<FetchResult | null> {
	const info = parseGitHubUrl(url);
	if (!info) return null;
	if (signal?.aborted) return null;

	const config = loadGitHubConfig();
	if (!config.enabled) return null;

	const { owner, repo } = info;
	const cacheKey = `${owner}/${repo}${info.ref ? `@${info.ref}` : ""}`;

	// -- Check session-local clone cache first ------------------------------
	if (cachedCloneCache.has(cacheKey)) {
		const cachedPath = cachedCloneCache.get(cacheKey)!;
		if (cachedPath && existsSync(cachedPath)) {
			const content = generateContent(cachedPath, info);
			const title = info.path
				? `${owner}/${repo} — ${info.path}`
				: `${owner}/${repo}`;
			return buildResult(url, title, content);
		}
		// Cached path was deleted — stale entry, fall through.
		cachedCloneCache.delete(cacheKey);
	}

	// -- Full SHA URLs can't be cloned; use API directly --------------------
	if (info.refIsFullSha) {
		const sizeNote = "Note: Commit SHA URLs use the GitHub API instead of cloning.";
		const apiContent = await fetchViaApi(url, owner, repo, info, sizeNote);
		if (apiContent) {
			const title = info.path
				? `${owner}/${repo} — ${info.path}`
				: `${owner}/${repo}`;
			return buildResult(url, title, apiContent);
		}
		return null;
	}

	// -- Check repo size to decide clone vs. API ----------------------------
	if (!forceClone) {
		const sizeKB = await checkRepoSize(owner, repo);
		if (signal?.aborted) return null;

		if (sizeKB !== null) {
			const sizeMB = sizeKB / 1024;
			if (sizeMB > config.maxRepoSizeMB) {
				if (signal?.aborted) return null;

				const sizeNote =
					`Note: Repository is ${Math.round(sizeMB)}MB (threshold: ${config.maxRepoSizeMB}MB). ` +
					`Showing API-fetched content instead of a full clone. ` +
					`To override, call web_fetch again with forceClone: true.`;

				const apiContent = await fetchViaApi(url, owner, repo, info, sizeNote);
				if (apiContent) {
					const title = info.path
						? `${owner}/${repo} — ${info.path}`
						: `${owner}/${repo}`;
					return buildResult(url, title, apiContent);
				}

				// API also failed — fall through to clone as last resort.
			}
		}
	}

	if (signal?.aborted) return null;

	// -- Attempt shallow clone ----------------------------------------------
	const localPath = await cloneRepo(owner, repo, info.ref, config, signal);
	if (signal?.aborted) return null;

	if (localPath) {
		cachedCloneCache.set(cacheKey, localPath);
		const content = generateContent(localPath, info);
		const title = info.path
			? `${owner}/${repo} — ${info.path}`
			: `${owner}/${repo}`;
		return buildResult(url, title, content);
	}

	// -- Clone failed → final API fallback ----------------------------------
	const apiContent = await fetchViaApi(url, owner, repo, info);
	if (apiContent) {
		const title = info.path
			? `${owner}/${repo} — ${info.path}`
			: `${owner}/${repo}`;
		return buildResult(url, title, apiContent);
	}

	// All paths exhausted — signal failure to the caller.
	return null;
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/** Construct a `FetchResult`-shaped object for GitHub content. */
function buildResult(
	url: string,
	_title: string,
	content: string,
): FetchResult {
	return {
		url,
		originalUrl: url,
		contentType: "text/markdown",
		crossHost: false,
		content,
		status: 200,
	};
}

/**
 * Wipe the in-memory clone cache (called on session end).
 * Does *not* delete cloned directories — they persist for the OS to clean up.
 */
export function clearGitHubCloneCache(): void {
	cachedCloneCache.clear();
	cachedConfig = null;
}
