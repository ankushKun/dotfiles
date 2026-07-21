/**
 * Ensure only the rpiv-todo overlay owns task UI.
 * Clears competing plannotator progress widgets if anything re-registers them.
 */
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const COMPETING_WIDGETS = ["plan-todos", "plannotator-progress"] as const;

function clearCompeting(ctx: { ui: { setWidget: (id: string, value: undefined) => void } }): void {
	for (const id of COMPETING_WIDGETS) {
		ctx.ui.setWidget(id, undefined);
	}
}

export default function singleTodoWidget(pi: ExtensionAPI): void {
	pi.on("session_start", (_event, ctx) => {
		if (ctx.hasUI) clearCompeting(ctx);
	});
	pi.on("agent_end", (_event, ctx) => {
		if (ctx.hasUI) clearCompeting(ctx);
	});
}
