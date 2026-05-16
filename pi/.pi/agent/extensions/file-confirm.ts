/**
 * File Operation Confirmation Extension
 *
 * Asks for confirmation before creating or editing files.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		// Handle file write (create/overwrite)
		if (isToolCallEventType("write", event)) {
			if (!ctx.hasUI) {
				// Non-interactive: block by default
				return { block: true, reason: "write tool blocked (no UI for confirmation)" };
			}

			const path = event.input.path as string;
			const choice = await ctx.ui.select(
				`Create/Overwrite file:\n\n  ${path}`,
				["Yes", "No"]
			);

			if (choice !== "Yes") {
				return { block: true, reason: "Blocked by user" };
			}
			return undefined;
		}

		// Handle file edit (modify existing)
		if (isToolCallEventType("edit", event)) {
			if (!ctx.hasUI) {
				return { block: true, reason: "edit tool blocked (no UI for confirmation)" };
			}

			const edits = event.input.edits as Array<{ oldText: string; newText: string }>;
			const path = event.input.path as string;

			// Show first edit as preview
			const preview = edits.length > 0
				? `Old: "${edits[0].oldText.slice(0, 50)}${edits[0].oldText.length > 50 ? "..." : ""}"\nNew: "${edits[0].newText.slice(0, 50)}${edits[0].newText.length > 50 ? "..." : ""}"`
				: "Multiple changes";

            // TODO: мне не оч нравится отображение изменений
			const choice = await ctx.ui.select(
				`Edit file:\n\n  ${path}\n  ${edits.length} change(s)\n  ${preview}`,
				["Yes", "No"]
			);

			if (choice !== "Yes") {
				return { block: true, reason: "Blocked by user" };
			}
			return undefined;
		}

		return undefined;
	});
}
