import * as path from "node:path";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type PermissionMode = "selective" | "manual" | "accept-edits" | "auto" | "plan";

const dangerous = [
	/\brm\s+(?:[^\n]*\s)?-(?:r|f|rf|fr)\b/i,
	/\bsudo\b/i,
	/\bgit\s+(?:reset\s+--hard|clean\s+-[^\s]*f|push\s+[^\n]*(?:--force|--force-with-lease))\b/i,
	/\b(?:chmod|chown)\b/i,
	/\b(?:curl|wget)\b[^|\n]*\|\s*(?:sh|bash|zsh)\b/i,
	/\b(?:mkfs|diskutil\s+erase|shutdown|reboot)\b/i,
	/\b(?:python|python3|node|perl|ruby)\s+(?:-e|--eval)\b/i,
];
const sensitive = /(^|\/)\.(?:env|npmrc|pypirc)(?:\.[^/]*)?$|(?:credentials|id_rsa|id_ed25519|\.pem|\.key)$/i;
const MODIFICATION_TOOLS = new Set(["edit", "write", "lsp_fix"]);
const DELEGATION_TOOLS = new Set(["bg_start", "workflow", "subagent_spawn"]);

function parseMode(value: string | undefined): PermissionMode {
	return value === "manual" || value === "accept-edits" || value === "auto" || value === "plan"
		? value
		: "selective";
}

function compactDetail(value: unknown, max = 2_400): string {
	const text = String(value ?? "").replace(/\u001b\[[0-9;]*m/g, "").trim();
	return text.length > max ? `${text.slice(0, max - 1)}…` : text;
}

function inputString(input: Record<string, unknown>, ...keys: string[]): string {
	for (const key of keys) {
		const value = input[key];
		if (typeof value === "string" && value.trim()) return value.trim();
	}
	return "";
}

function requestKey(toolName: string, detail: string): string {
	if (toolName === "edit" || toolName === "write" || toolName === "lsp_fix") {
		return `${toolName}:${detail}`;
	}
	return `${toolName}:${detail.split(/\s+/).slice(0, 3).join(" ")}`;
}

function updateStatus(ctx: ExtensionContext | undefined, mode: PermissionMode): void {
	if (!ctx?.hasUI) return;
	ctx.ui.setStatus("permissions", ctx.ui.theme.fg(mode === "plan" ? "warning" : "muted", `permission: ${mode}`));
}

interface PermissionRequest {
	reason: string;
	detail: string;
	key: string;
	alwaysDeny?: boolean;
}

function classify(
	toolName: string,
	input: Record<string, unknown>,
	mode: PermissionMode,
): PermissionRequest | undefined {
	const command = inputString(input, "command");
	const file = inputString(input, "path", "file_path", "filePath");
	const detail = command || file || inputString(input, "prompt", "task", "script", "workflow");
	const key = requestKey(toolName, detail);

	if (file && sensitive.test(file)) {
		return {
			reason: "sensitive file access",
			detail: path.resolve(file),
			key,
		};
	}

	if (mode === "plan" && (toolName === "bash" || MODIFICATION_TOOLS.has(toolName) || DELEGATION_TOOLS.has(toolName))) {
		return {
			reason: "plan mode blocks execution or modification",
			detail: detail || toolName,
			key,
			alwaysDeny: true,
		};
	}

	if (toolName === "bash") {
		if (dangerous.some((pattern) => pattern.test(command))) {
			return { reason: "high-risk shell command", detail: command, key };
		}
		if (mode === "manual") {
			return { reason: "shell command", detail: command, key };
		}
		return undefined;
	}

	if (MODIFICATION_TOOLS.has(toolName)) {
		if (mode === "accept-edits" || mode === "auto") return undefined;
		return { reason: "source modification", detail: file || detail || toolName, key };
	}

	if (DELEGATION_TOOLS.has(toolName)) {
		if (mode === "auto") return undefined;
		return { reason: "background or delegated execution", detail: detail || toolName, key };
	}

	return undefined;
}

export default function permissionGate(pi: ExtensionAPI): void {
	let mode = parseMode(process.env.PI_PERMISSION_MODE);
	const sessionAllows = new Set<string>();
	let statusContext: ExtensionContext | undefined;

	const chooseMode = async (ctx: ExtensionContext): Promise<void> => {
		if (!ctx.hasUI) {
			ctx.ui.notify(`Permission mode: ${mode}`, "info");
			return;
		}
		const choices = ["selective", "manual", "accept-edits", "auto", "plan"];
		const selected = await ctx.ui.select(
			"Permission mode\n\nselective preserves the existing risk gate; manual asks before commands and edits.",
			choices,
		);
		if (selected && choices.includes(selected)) {
			mode = selected as PermissionMode;
			updateStatus(ctx, mode);
			ctx.ui.notify(`Permission mode → ${mode}`, "info");
		}
	};

	pi.registerCommand("permissions", {
		description: "Choose the active permission mode",
		handler: async (_args, ctx) => chooseMode(ctx),
	});

	pi.on("session_start", (_event, ctx) => {
		statusContext = ctx;
		updateStatus(ctx, mode);
	});

	pi.on("session_shutdown", () => {
		statusContext?.ui.setStatus("permissions", undefined);
		statusContext = undefined;
		sessionAllows.clear();
	});

	pi.on("tool_call", async (event, ctx) => {
		const request = classify(event.toolName, event.input as Record<string, unknown>, mode);
		if (!request) return;
		if (sessionAllows.has(request.key)) return;
		if (request.alwaysDeny) {
			return { block: true, reason: `Blocked by ${mode}: ${request.reason}: ${request.detail}` };
		}
		if (!ctx.hasUI) {
			return { block: true, reason: `Blocked ${request.reason} without interactive approval: ${request.detail}` };
		}

		const choices = ["Allow once", "Allow for this session", "Deny"];
		const selected = await ctx.ui.select(
			`Approval required · ${mode}\n\n${request.reason}\n\n${compactDetail(request.detail)}`,
			choices,
		);
		if (selected === "Allow for this session") {
			sessionAllows.add(request.key);
			return;
		}
		if (selected === "Allow once") return;
		return { block: true, reason: `User declined ${request.reason}` };
	});
}
