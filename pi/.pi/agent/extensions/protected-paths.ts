/**
 * Protected Paths Extension
 *
 * Blocks write and edit operations to protected paths.
 * Useful for preventing accidental modifications to sensitive files.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

//TODO: это не будет работать в такой ситуации: `echo "anything" > .env`. Нужно обработать подобные сценарии тоже.
const PROTECTED_PATHS = [".envrc", ".env", ".git/", "node_modules/"];

// Tools that accept a file path argument
const TOOLS = ["read", "write", "edit"];

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (!TOOLS.includes(event.toolName)) {
			return undefined;
		}

		const path = event.input.path as string;
		if (!path) return undefined;

		const isProtected = PROTECTED_PATHS.some((p) => path.includes(p));

		if (isProtected) {
			if (ctx.hasUI) {
				ctx.ui.notify(`Blocked ${event.toolName} on protected path: ${path}`, "warning");
			}
			return { block: true, reason: `Path "${path}" is protected` };
		}

		return undefined;
	});
}
