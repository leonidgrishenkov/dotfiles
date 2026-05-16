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

			const choice = await ctx.ui.select(
				`Confirm write?`,
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

			const choice = await ctx.ui.select(
				`Confirm edit?`,
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
