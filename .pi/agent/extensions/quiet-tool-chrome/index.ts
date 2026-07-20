/**
 * Cursor-like quiet tool chrome for pi.
 *
 * - Soft status via text color (pending / error), not background bars
 * - Compact grep/find results (FFF keeps execute; we only restyle)
 * - Strip blank padding around tool rows (pi's Spacer + Box paddingY)
 *
 * Loaded first in settings.packages so registerTool is wrapped before
 * other packages (FFF, tool-display) register tools.
 */
import { ToolExecutionComponent, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";

const WRAPPED = Symbol.for("quiet-tool-chrome.wrapped");
const SPACING_PATCHED = Symbol.for("quiet-tool-chrome.spacing-patched");

type ThemeLike = {
	fg: (color: string, text: string) => string;
	bold?: (text: string) => string;
	italic?: (text: string) => string;
	[key: string]: unknown;
};

type RenderContext = {
	isPartial?: boolean;
	isError?: boolean;
};

type ToolLike = {
	name?: string;
	renderShell?: string;
	renderCall?: (args: unknown, theme: ThemeLike, context?: RenderContext) => unknown;
	renderResult?: (
		result: unknown,
		options: { expanded?: boolean; isPartial?: boolean },
		theme: ThemeLike,
		context?: RenderContext,
	) => unknown;
	[key: string]: unknown;
};

function countContentLines(result: unknown): number {
	const record = result as { content?: unknown } | null;
	const content = record?.content;
	if (!Array.isArray(content)) return 0;
	let lines = 0;
	for (const block of content) {
		if (!block || typeof block !== "object") continue;
		const text = (block as { type?: string; text?: string }).text;
		if (typeof text !== "string") continue;
		lines += text.split("\n").filter((l) => l.length > 0).length;
	}
	return lines;
}

function searchSummary(result: unknown, theme: ThemeLike, isError: boolean): string {
	const details = (result as { details?: { totalMatched?: number; totalFiles?: number } })?.details;
	const matched =
		typeof details?.totalMatched === "number" ? details.totalMatched : countContentLines(result);
	const files = typeof details?.totalFiles === "number" ? details.totalFiles : undefined;
	const body =
		files !== undefined
			? `Found ${matched} ${matched === 1 ? "match" : "matches"} in ${files} ${files === 1 ? "file" : "files"}`
			: `Found ${matched} ${matched === 1 ? "match" : "matches"}`;
	return theme.fg(isError ? "error" : "dim", body);
}

/** Proxy theme so tool titles pick pending/error/muted status colors. */
function statusTheme(theme: ThemeLike, context?: RenderContext): ThemeLike {
	const status = context?.isPartial ? "pending" : context?.isError ? "error" : "ok";
	return new Proxy(theme, {
		get(target, prop, receiver) {
			if (prop === "fg") {
				return (color: string, text: string) => {
					let next = color;
					if (color === "toolTitle") {
						if (status === "pending") next = "text";
						else if (status === "error") next = "error";
						else next = "muted";
					}
					return target.fg(next, text);
				};
			}
			const value = Reflect.get(target, prop, receiver);
			return typeof value === "function" ? (value as (...a: unknown[]) => unknown).bind(target) : value;
		},
	});
}

function isVisuallyBlank(line: string): boolean {
	return line.replace(/\u001b\[[0-9;]*m/g, "").trim() === "";
}

/** Drop leading/trailing spacer + Box paddingY blanks so tool rows stack tightly. */
function trimBlankEdges(lines: string[]): string[] {
	let start = 0;
	let end = lines.length;
	while (start < end && isVisuallyBlank(lines[start]!)) start++;
	while (end > start && isVisuallyBlank(lines[end - 1]!)) end--;
	return lines.slice(start, end);
}

function patchToolExecutionSpacing(): void {
	const ctor = ToolExecutionComponent as unknown as { [SPACING_PATCHED]?: boolean };
	if (ctor[SPACING_PATCHED]) return;
	ctor[SPACING_PATCHED] = true;

	const proto = ToolExecutionComponent.prototype as {
		render: (width: number) => string[];
	};
	const original = proto.render;
	proto.render = function (this: unknown, width: number) {
		return trimBlankEdges(original.call(this, width));
	};
}

function wrapTool(tool: ToolLike): void {
	if (!tool || typeof tool !== "object") return;
	if ((tool as { [WRAPPED]?: boolean })[WRAPPED]) return;
	(tool as { [WRAPPED]?: boolean })[WRAPPED] = true;

	const name = typeof tool.name === "string" ? tool.name : "";
	const isSearch = name === "grep" || name === "find";

	// Prefer self shell: skips Box paddingY (extra blank rows around every tool).
	if (typeof tool.renderShell !== "string") {
		tool.renderShell = "self";
	}

	const originalCall = typeof tool.renderCall === "function" ? tool.renderCall.bind(tool) : undefined;
	const originalResult =
		typeof tool.renderResult === "function" ? tool.renderResult.bind(tool) : undefined;

	if (originalCall) {
		tool.renderCall = (args, theme, context) =>
			originalCall(args, statusTheme(theme, context), context);
	}

	if (isSearch) {
		tool.renderResult = (result, options, theme, context) => {
			if (options?.expanded && originalResult) {
				return originalResult(result, options, theme, context);
			}
			return new Text(searchSummary(result, theme, context?.isError === true), 0, 0);
		};
	}
}

export default function (pi: ExtensionAPI) {
	patchToolExecutionSpacing();

	const originalRegisterTool = pi.registerTool.bind(pi);
	pi.registerTool = ((tool: ToolLike) => {
		wrapTool(tool);
		return originalRegisterTool(tool as never);
	}) as ExtensionAPI["registerTool"];
}
