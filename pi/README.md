# PI coding agent

## Themes

Source: https://github.com/otahontas/pi-coding-agent-catppuccin.

## Extensions

### Examples and Pre-defined

There are lots of examples here:

```sh
/opt/homebrew/Cellar/pi-coding-agent/$(pi --version)/libexec/lib/node_modules/@earendil-works/pi-coding-agent/examples/extensions
```

### Web search & fetch

Two custom tools are registered from `.pi/agent/extensions/`:

- `web_search` — Tavily-backed web search returning ranked results plus an
  optional summary answer. Source: `web-search.ts`.
- `web_fetch` — fetches a URL and returns Markdown (default), text, or HTML.
  Uses Mozilla Readability + Turndown for HTML. Source: `web-fetch.ts`.

Setup:

1. Get a Tavily API key from https://tavily.com (1k free queries/month).
2. Export it in your shell before launching pi:

   ```sh
   export TAVILY_API_KEY="tvly-..."
   ```

3. Install Node deps used by the extensions:

   ```sh
   cd ~/.pi/agent && npm install
   ```
