# How a Good `web_fetch` Tool Should Work in Coding Agents

Based on patterns from OpenCode, Cline, Claude Code, and similar agents, here are the key design principles.

## 1. Core Responsibilities

A `web_fetch` tool should:
- Take a **URL** and optionally a **format** (markdown/text/html) or **prompt** describing what to extract
- Fetch content, **convert HTML to a clean format** (typically markdown) optimized for LLM consumption
- Return content suitable for the model to reason about — not raw HTML noise

## 2. Content Transformation

The single biggest value-add is **HTML → Markdown conversion**:
- Strip scripts, styles, navigation chrome, ads
- Preserve semantic structure (headings, lists, code blocks, links)
- Tools like Readability.js, Turndown, or Mozilla's Readability are commonly used
- Code blocks must survive intact (critical for docs/Stack Overflow)

## 3. Safety & Security

- **HTTPS upgrade** by default (OpenCode does this)
- **Redirect handling**: explicitly notify the model when cross-host redirects occur so it can re-issue the request — prevents SSRF surprises and lets the agent make an informed choice
- **Block private IPs / localhost** unless explicitly allowed (SSRF protection)
- **Respect robots.txt** is debated but rarely enforced for agentic browsing
- **User-Agent identification** so site owners can identify bot traffic

## 4. Size & Context Management

- **Truncate or summarize** large pages — a 500KB HTML doc destroys context windows
- Two strategies in the wild:
  - **Truncate + offset/pagination** (raw approach)
  - **Sub-LLM summarization** (Claude Code uses a small model to extract relevant content based on a prompt) — much better token economy
- Cache fetched content by URL hash to avoid re-fetching during a session

## 5. Format Options

Good tools expose multiple output modes:
- `markdown` (default — best for LLM reasoning)
- `text` (stripped, for pure content extraction)
- `html` (raw, for parsing/scraping tasks)

## 6. Integration with Agent Behavior

- **Prefer dedicated tools over general fetch**: e.g., if there's a GitHub PR tool, MCP doc-search, or built-in docs fetcher, the agent should reach for that first
- **System prompt guidance**: tell the model when NOT to guess URLs (OpenCode explicitly forbids URL guessing unless they're for documentation lookups)
- **Whitelist/blacklist support** via config for enterprise use

## 7. Error Handling

- Distinguish: network errors, 4xx/5xx, redirects, timeouts, content-too-large, blocked-by-CDN (Cloudflare 403s are common)
- Return actionable errors so the model can retry intelligently (e.g., "try the archive.org cached version" or "request the raw URL on GitHub")

## 8. Performance

- Sensible **default timeout** (OpenCode caps at 120s, default ~30s is more typical)
- Streaming for large content where possible
- Concurrency limits to avoid hammering hosts

## Comparison Snapshot

| Feature | OpenCode `WebFetch` | Claude Code `WebFetch` | Cline |
|---|---|---|---|
| HTML→Markdown | Yes | Yes | Yes |
| Sub-LLM extraction | No | Yes (prompt-based) | No |
| HTTPS upgrade | Yes | Yes | Configurable |
| Redirect notification | Yes (explicit re-fetch) | Yes | Implicit |
| Format options | markdown/text/html | markdown | markdown |
| Caching | Session-level | 15-min cache | None |

## Best-in-Class Pattern

The most powerful design is **prompt-driven fetch**: the tool accepts `(url, prompt)` and uses a cheap fast model to extract only the relevant slice — this scales to massive docs without burning the main model's context. Claude Code pioneered this; it's strictly better than dumping 200KB of markdown into the conversation.

Want me to dive deeper into any specific aspect — e.g., the sub-LLM extraction pattern, SSRF protections, or how OpenCode's specific implementation handles redirects?