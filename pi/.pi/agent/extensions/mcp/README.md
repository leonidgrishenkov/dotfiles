# pi-mcp

Minimal MCP (Model Context Protocol) client extension for the
[pi coding agent](https://pi.dev). Connects pi to external MCP servers and
exposes their tools through a single token-efficient proxy tool.

## Install

The extension lives at `~/.pi/agent/extensions/mcp/` (stowed from this repo).
Install its single dependency:

```bash
cd ~/.pi/agent/extensions/mcp
npm install
```

Then restart pi (or run `/reload`).

## Config

MCP servers are declared in standard MCP config files, merged in this order
(later wins per server name):

1. `~/.pi/agent/mcp.json` — global
2. `<cwd>/.mcp.json` — project, shared standard
3. `<cwd>/.pi/mcp.json` — project, pi override

### Server entry

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/abs/path"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}" }
    },
    "my-api": {
      "url": "https://mcp.example.com/mcp",
      "auth": "bearer",
      "bearerTokenEnv": "MY_MCP_TOKEN"
    }
  }
}
```

| Field           | Transport | Description                                            |
| --------------- | --------- | ------------------------------------------------------ |
| `command`       | stdio     | Executable to run                                      |
| `args`          | stdio     | Arguments for the command                              |
| `env`           | stdio     | Env vars (interpolated, merged over `process.env`)     |
| `cwd`           | stdio     | Working directory (interpolated)                       |
| `url`           | http      | Endpoint (StreamableHTTP, falls back to SSE)           |
| `headers`       | http      | Headers (interpolated)                                 |
| `auth`          | http      | Set to `"bearer"` to send `Authorization: Bearer`      |
| `bearerToken`   | http      | Literal token (interpolated)                           |
| `bearerTokenEnv`| http      | Env var name holding the token                         |

`${VAR}` interpolation is supported in `env`, `cwd`, `url`, `headers`, and
`bearerToken`.

## Usage

### From the agent (the `mcp` tool)

```text
mcp({})                                  // status: configured servers
mcp({ search: "screenshot" })            // find tools across all servers
mcp({ server: "github" })                // list a server's tools
mcp({ tool: "create_issue", args: { ... } })           // call a tool
mcp({ tool: "list_repos", server: "github" })          // disambiguate
```

`args` is a JSON object, not a string.

### From the user (the `/mcp` command)

```
/mcp                    // show status (notify)
/mcp tools              // pick a server, list its tools
/mcp tools github       // list tools for a specific server
/mcp reconnect          // pick a server, reconnect
/mcp reconnect github   // reconnect a specific server
```

## What's intentionally not here

- **No OAuth.** Use `bearerToken` / `bearerTokenEnv` for HTTP auth.
- **No config import** from Cursor / Claude Code / Codex / Claude Desktop.
- **No on-disk metadata cache.** Tool metadata is fetched per session.
- **No direct-tool registration.** A single `mcp` proxy tool keeps the
  context window small.
- **No custom UI panel.** `/mcp` uses native pi dialogs only.

## Layout

```
mcp/
├── package.json   # @modelcontextprotocol/sdk dependency
├── index.ts       # entry: tool + command registration, lifecycle, dispatch
├── client.ts      # McpServerManager: transports, connect/list/call, content
└── config.ts      # config loading/merging + ${VAR} interpolation
```
