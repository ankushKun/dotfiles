import * as path from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const dangerous = [
	/\brm\s+(?:[^\n]*\s)?-(?:r|f|rf|fr)\b/i,
	/\bsudo\b/i,
	/\bgit\s+(?:reset\s+--hard|clean\s+-[^\s]*f|push\s+[^\n]*--force)\b/i,
	/\b(?:chmod|chown)\b/i,
	/\b(?:curl|wget)\b[^|\n]*\|\s*(?:sh|bash|zsh)\b/i,
	/\b(?:mkfs|diskutil\s+erase|shutdown|reboot)\b/i,
];
const sensitive = /(^|\/)\.(?:env|npmrc|pypirc)$|(?:credentials|id_rsa|id_ed25519|\.pem|\.key)$/i;

export default function permissionGate(pi: ExtensionAPI): void {
	pi.on("tool_call", async (event, ctx) => {
		let reason: string | undefined;
		let detail = "";
		if (event.toolName === "bash") {
			const command = String(event.input.command ?? "");
			if (dangerous.some((pattern) => pattern.test(command))) {
				reason = "high-risk shell command";
				detail = command;
			}
		} else if (event.toolName === "write" || event.toolName === "edit") {
			const file = String(event.input.path ?? event.input.file_path ?? "");
			if (sensitive.test(file)) {
				reason = "sensitive file modification";
				detail = path.resolve(ctx.cwd, file);
			}
		}
		if (!reason) return;
		if (!ctx.hasUI) return { block: true, reason: `Blocked ${reason} without interactive approval: ${detail}` };
		const allowed = await ctx.ui.confirm("Approval required", `${reason}\n\n${detail}\n\nAllow this once?`);
		if (!allowed) return { block: true, reason: `User declined ${reason}` };
	});
}
