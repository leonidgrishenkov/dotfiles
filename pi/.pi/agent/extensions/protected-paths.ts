/**
 * Protected Paths Extension
 *
 * Blocks access to paths based on a single configuration list.
 * Each entry specifies which operations to block:
 *   - read  → blocks the `read` tool
 *   - write → blocks the `write` and `edit` tools
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

// true means being able to read/write, false - not, protect it from read/write
class ProtectedPath {
	constructor(
		public readonly pattern: string,
		public readonly read: boolean = true,
		public readonly write: boolean = false,
	) {}
}

const PROTECTED_PATHS = [
	new ProtectedPath(".envrc", false),
	new ProtectedPath(".env", false),
	new ProtectedPath(".git/"),
	new ProtectedPath("node_modules/"),
    new ProtectedPath(".terraform", false),
    new ProtectedPath(".tfstate", false),
];

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		const { toolName } = event;

        // quit fast if it's not a tool we're lookin' for
        if (!['read', 'write', 'edit'].includes(toolName)) return undefined;

		let operation: "read" | "write" | null = null;
		if (toolName === "read") operation = "read";
		else if (toolName === "write" || toolName === "edit") operation = "write";

		if (!operation) return undefined;

		const path = (event.input as { path?: string }).path;
		if (!path) return undefined;

		const rule = PROTECTED_PATHS.find(
			(p) => path.includes(p.pattern) && !p[operation],
		);

		if (rule) {
			ctx.hasUI &&
				ctx.ui.notify(
					`Blocked '${toolName}' tool on protected path: ${path}`,
					"warning",
				);
			return {
				block: true,
				reason: [
					`Path "${path}" is protected from '${operation}' operation.`,
					`Do NOT attempt to access this path using the bash tool (e.g. cat, echo, etc.).`,
                    `Tell user that you can't do that, even if they asked.`
				].join(" "),
			};
		}

		return undefined;
	});
}
