import * as fs from "node:fs";
import * as os from "node:os";
import * as path from "node:path";
import {
	CustomEditor,
	SessionManager,
	VERSION,
	type ExtensionAPI,
	type ExtensionCommandContext,
	type ExtensionContext,
	type KeybindingsManager,
	type SessionInfo,
	type Theme,
	type ThemeColor,
} from "@earendil-works/pi-coding-agent";
import type { Component, EditorTheme, TUI } from "@earendil-works/pi-tui";
import {
	matchesKey,
	SelectList,
	truncateToWidth,
	visibleWidth,
	type SelectItem,
} from "@earendil-works/pi-tui";

/** Editor instance with submit hook (wired by interactive mode after factory returns). */
type SubmittableEditor = CustomEditor & {
	onSubmit?: (text: string) => void | Promise<void>;
};

let activeEditor: SubmittableEditor | undefined;
let activeTui: TUI | undefined;

function isCommandContext(ctx: ExtensionContext): ctx is ExtensionCommandContext {
	return typeof (ctx as ExtensionCommandContext).switchSession === "function";
}

/** Queue a slash command as if the user pressed Enter (works before the main input loop). */
function submitSlashCommand(command: string): boolean {
	const submit = activeEditor?.onSubmit;
	if (!submit) return false;
	void submit(command);
	return true;
}

const BLUE = "\u001b[38;2;122;162;247m";
const CYAN = "\u001b[38;2;125;207;255m";
const MAGENTA = "\u001b[38;2;187;154;247m";
const RESET = "\u001b[0m";
const EYES_PATH = path.join(os.homedir(), ".pi", "miku.txt");
const SESSION_FETCH = 24;
/** Alpha-nvim dashboard button column width. */
const BUTTON_WIDTH = 50;
/**
 * Home chrome under/around art (recents live in a picker, not on the greeter):
 * blank after art + title(2) + blank + footer(3) = 7
 */
const HOME_CHROME = 7;

const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const WORKING_DOTS = ["·", "•", "●", "◆", "●", "•"].map(
	(frame, i) => `${[BLUE, CYAN, MAGENTA][i % 3]}${frame}${RESET}`,
);

const KEYBIND_ROWS: { key: string; desc: string }[] = [
	{ key: "n", desc: "new session" },
	{ key: "r", desc: "recent sessions" },
	{ key: "m", desc: "select model / thinking" },
	{ key: "?", desc: "keybinds" },
	{ key: "q", desc: "quit" },
	{ key: "Esc", desc: "editor (keep greeter)" },
	{ key: "Shift+Tab", desc: "toggle plan mode" },
	{ key: "Alt+Shift+Tab", desc: "cycle thinking level" },
];

const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh"] as const;

/** Slash commands to hide from `/` autocomplete (and block on submit when possible). */
const HIDDEN_SLASH_COMMANDS = new Set(["scoped-models"]);

type HomeAction =
	| { kind: "new" }
	| { kind: "session"; path: string }
	| { kind: "model" }
	| { kind: "recent" }
	| { kind: "quit" };

type HomeMode = "main" | "keybinds";

interface HomeMeta {
	cwd: string;
	model: string;
	thinking: string;
	project: string;
}

let artCache: string[] | undefined;
let homeOpen = false;
/** Idle greeter kept as header while the empty-session editor is focused. */
let homeBackdropActive = false;
/** Latest git branch for the active session cwd (status bar + editor rail). */
let gitBranch: string | undefined;
/** Rows reserved under the backdrop for the composer + meta rows + edge spacer. */
const EDITOR_RESERVE = 9;
/** No horizontal padding — full-width Cursor-style input. */
const EDITOR_PADDING_X = 0;

/** Wall-clock start of the current agent turn (for live latency). */
let workStartedAt: number | undefined;

/** Tokens billed so far in the current agent run (completed LLM calls). */
let runTokensCommitted = { input: 0, output: 0 };
/** Live usage for the in-flight assistant message (streaming). */
let runTokensLive = { input: 0, output: 0 };

function age(date: Date): string {
	const seconds = Math.max(0, Math.floor((Date.now() - date.getTime()) / 1000));
	if (seconds < 60) return "now";
	if (seconds < 3600) return `${Math.floor(seconds / 60)}m`;
	if (seconds < 86400) return `${Math.floor(seconds / 3600)}h`;
	return `${Math.floor(seconds / 86400)}d`;
}

function formatCwd(cwd: string): string {
	const home = process.env.HOME;
	if (home && cwd.startsWith(home)) return `~${cwd.slice(home.length)}`;
	return cwd;
}

function sessionLabel(session: SessionInfo): string {
	const project = path.basename(session.cwd) || session.cwd || "unknown";
	const title = session.name || session.firstMessage || "Untitled session";
	return `${project} · ${title.replace(/\s+/g, " ").slice(0, 42)}`;
}

function formatThinking(level: string): string {
	return level === "off" ? "off" : level;
}

type EditorMode = "idle" | "working" | "bash" | "bash_exclusive" | "plan";

interface PlanModeInfo {
	enabled: boolean;
	executing: boolean;
	completed: number;
	total: number;
}

interface PlanModeEntryData {
	enabled?: boolean;
	executing?: boolean;
	todos?: { completed?: boolean; text?: string }[];
}

function readPlanMode(ctx: ExtensionContext): PlanModeInfo {
	const entries = ctx.sessionManager.getEntries();
	let latest: PlanModeEntryData | undefined;
	for (let i = entries.length - 1; i >= 0; i--) {
		const entry = entries[i];
		if (entry?.type === "custom" && entry.customType === "plan-mode") {
			latest = entry.data as PlanModeEntryData | undefined;
			break;
		}
	}
	if (!latest?.enabled) {
		return { enabled: false, executing: false, completed: 0, total: 0 };
	}
	const todos = latest.todos ?? [];
	return {
		enabled: true,
		executing: !!latest.executing,
		completed: todos.filter((t) => t.completed).length,
		total: todos.length,
	};
}

function detectBashKind(text: string): "bash" | "bash_exclusive" | null {
	const trimmed = text.trimStart();
	if (trimmed.startsWith("!!")) return "bash_exclusive";
	if (trimmed.startsWith("!")) return "bash";
	return null;
}

/**
 * Prompt chrome mode (border / ❯ / bottom chip).
 * Plan stays visible while the agent runs — Running lives on the line above the box.
 * Priority: bash > plan > working > idle
 */
function editorMode(ctx: ExtensionContext, text: string, isWorking: boolean): EditorMode {
	const bash = detectBashKind(text);
	if (bash) return bash;
	if (readPlanMode(ctx).enabled) return "plan";
	if (isWorking) return "working";
	return "idle";
}

function modeBorderColor(theme: Theme, mode: EditorMode): (text: string) => string {
	switch (mode) {
		case "working":
			return (text) => theme.fg("accent", text);
		case "bash":
		case "bash_exclusive":
			return theme.getBashModeBorderColor();
		case "plan":
			return (text) => theme.fg("warning", text);
		default:
			return (text) => theme.fg("borderMuted", text);
	}
}

function modeAccent(theme: Theme, mode: EditorMode): (text: string) => string {
	switch (mode) {
		case "working":
			return (text) => theme.fg("accent", text);
		case "bash":
		case "bash_exclusive":
			return (text) => theme.fg("bashMode", text);
		case "plan":
			return (text) => theme.fg("warning", text);
		default:
			return (text) => theme.fg("accent", text);
	}
}

/** OpenCode-style mode label for the status rail. */
function modeLabel(mode: EditorMode, plan: PlanModeInfo, spinnerFrame: string): string {
	switch (mode) {
		case "working":
			// Running indicator lives above the box — no duplicate chip here.
			return "";
		case "bash":
			return "bash";
		case "bash_exclusive":
			return "bash!";
		case "plan":
			if (plan.total > 0) return `plan ${plan.completed}/${plan.total}`;
			return plan.executing ? "plan run" : "plan";
		default:
			return "agent";
	}
}

function thinkingColorKey(level: string): ThemeColor {
	switch (level) {
		case "off":
			return "thinkingOff";
		case "minimal":
			return "thinkingMinimal";
		case "low":
			return "thinkingLow";
		case "medium":
			return "thinkingMedium";
		case "high":
			return "thinkingHigh";
		case "xhigh":
			return "thinkingXhigh";
		case "max":
			return "thinkingMax";
		default:
			return "muted";
	}
}

/** Compact token counts — matches pi footer (`15k`, `500k`). */
function formatTokens(count: number): string {
	if (count < 1000) return count.toString();
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

function formatCost(total: number): string {
	if (total <= 0) return "$0.000";
	if (total < 0.01) return `$${total.toFixed(4)}`;
	return `$${total.toFixed(3)}`;
}

function formatLatency(seconds: number): string {
	if (seconds < 10) return `${seconds.toFixed(1)}s`;
	if (seconds < 60) return `${Math.round(seconds)}s`;
	const mins = Math.floor(seconds / 60);
	const secs = Math.round(seconds % 60);
	return `${mins}m${secs.toString().padStart(2, "0")}s`;
}

function formatTps(tps: number): string {
	if (tps < 10) return `${tps.toFixed(1)}/s`;
	return `${Math.round(tps)}/s`;
}

/** Sum inference $ from all assistant turns in the session. */
function sumSessionCost(ctx: ExtensionContext): number {
	let total = 0;
	for (const entry of ctx.sessionManager.getEntries()) {
		if (entry.type === "message" && entry.message.role === "assistant") {
			const cost = entry.message.usage?.cost?.total;
			if (typeof cost === "number") total += cost;
		}
	}
	return total;
}

interface TurnMetrics {
	latencySec: number;
	tps: number | undefined;
}

/** Latency / tps from the latest completed user→assistant turn. */
function lastTurnMetrics(ctx: ExtensionContext): TurnMetrics | undefined {
	const branch = ctx.sessionManager.getBranch();
	let lastAssistantIdx = -1;
	for (let i = branch.length - 1; i >= 0; i--) {
		const entry = branch[i];
		if (entry?.type === "message" && entry.message.role === "assistant") {
			lastAssistantIdx = i;
			break;
		}
	}
	if (lastAssistantIdx < 0) return undefined;

	const assistantEntry = branch[lastAssistantIdx]!;
	if (assistantEntry.type !== "message" || assistantEntry.message.role !== "assistant") return undefined;
	const assistant = assistantEntry.message;

	let userTs: number | undefined;
	for (let i = lastAssistantIdx - 1; i >= 0; i--) {
		const entry = branch[i];
		if (entry?.type === "message" && entry.message.role === "user") {
			userTs = entry.message.timestamp;
			break;
		}
	}
	if (typeof userTs !== "number" || typeof assistant.timestamp !== "number") return undefined;

	const latencySec = (assistant.timestamp - userTs) / 1000;
	if (!(latencySec > 0) || !Number.isFinite(latencySec)) return undefined;

	const output = assistant.usage?.output;
	const tps =
		typeof output === "number" && output > 0 && latencySec > 0 ? output / latencySec : undefined;
	return { latencySec, tps };
}

function formatPlace(cwd: string, branch: string | undefined, compact: boolean): string {
	const base = compact ? path.basename(cwd) || cwd : formatCwd(cwd);
	return branch ? `${base} · ${branch}` : base;
}

/** Fit left …… right into width with a flexible gap. */
function fitStatusRow(left: string, right: string, width: number): string {
	if (width <= 0) return "";
	const minGap = 2;
	let leftText = left;
	let rightText = right;

	while (
		visibleWidth(leftText) + visibleWidth(rightText) + minGap > width &&
		visibleWidth(rightText) > 0
	) {
		rightText = truncateToWidth(rightText, Math.max(0, visibleWidth(rightText) - 1), "");
	}
	while (
		visibleWidth(leftText) + visibleWidth(rightText) + minGap > width &&
		visibleWidth(leftText) > 0
	) {
		leftText = truncateToWidth(leftText, Math.max(0, visibleWidth(leftText) - 1), "");
	}

	const gap = Math.max(minGap, width - visibleWidth(leftText) - visibleWidth(rightText));
	let line = `${leftText}${" ".repeat(gap)}${rightText}`;
	if (visibleWidth(line) > width) {
		line = truncateToWidth(line, width, "");
	}
	return line;
}

/**
 * Right side of meta row 1: `[provider] modelId (thinking)`.
 * Truncates model id first when over budget.
 */
function formatModelStatus(
	theme: Theme,
	provider: string | undefined,
	id: string | undefined,
	thinkingLevel: string,
	maxWidth: number,
): string {
	const dim = (s: string) => theme.fg("dim", s);
	const muted = (s: string) => theme.fg("muted", s);
	const thinkPaint = (s: string) => theme.fg(thinkingColorKey(thinkingLevel), s);

	const prov = provider?.trim() || "unknown";
	const modelId = id?.trim() || "no model";
	const think = formatThinking(thinkingLevel);

	const wrap = (mid: string) => `${dim("[")}${muted(prov)}${dim("]")} ${muted(mid)} ${dim("(")}${thinkPaint(think)}${dim(")")}`;

	let mid = modelId;
	let out = wrap(mid);
	while (visibleWidth(out) > maxWidth && mid.length > 4) {
		mid = truncateToWidth(mid, Math.max(4, visibleWidth(mid) - 2), "");
		out = wrap(mid);
	}
	if (visibleWidth(out) > maxWidth) {
		out = truncateToWidth(out, maxWidth, "");
	}
	return out;
}

function readMessageUsage(message: { role?: string; usage?: { input?: number; output?: number } } | undefined): {
	input: number;
	output: number;
} {
	if (!message || message.role !== "assistant" || !message.usage) {
		return { input: 0, output: 0 };
	}
	return {
		input: typeof message.usage.input === "number" ? message.usage.input : 0,
		output: typeof message.usage.output === "number" ? message.usage.output : 0,
	};
}

function currentRunTokens(): { input: number; output: number } {
	return {
		input: runTokensCommitted.input + runTokensLive.input,
		output: runTokensCommitted.output + runTokensLive.output,
	};
}

/**
 * Cursor-style line above the composer while the agent is working:
 *   ⠙ Running  1.83k in / 412 out
 */
function formatRunningIndicator(theme: Theme, spinnerFrame: string, width: number): string {
	const tokens = currentRunTokens();
	const spin = theme.fg("success", spinnerFrame);
	const label = theme.fg("text", "Running");
	const metrics = theme.fg(
		"muted",
		`${formatTokens(tokens.input)} in / ${formatTokens(tokens.output)} out`,
	);
	const line = `${spin} ${label}  ${metrics}`;
	return truncateToWidth(line, width, "");
}

/** Row 1 parts: mode …… [provider] model (thinking) */
function composerMetaRow1Parts(
	theme: Theme,
	ctx: ExtensionContext,
	pi: ExtensionAPI,
	mode: EditorMode,
	plan: PlanModeInfo,
	spinnerFrame: string,
	width: number,
): { left: string; right: string } {
	const label = modeLabel(mode, plan, spinnerFrame);
	const modeChip = label ? modeAccent(theme, mode)(label) : "";
	const thinkingLevel = formatThinking(pi.getThinkingLevel());
	const rightBudget = Math.max(12, width - visibleWidth(modeChip) - 4);
	const model = formatModelStatus(
		theme,
		ctx.model?.provider,
		ctx.model?.id,
		thinkingLevel,
		rightBudget,
	);
	return { left: modeChip, right: model };
}

/** Row 2: path · branch …… tokens / limit · $ · latency · t/s */
function buildComposerMetaRow2(
	theme: Theme,
	ctx: ExtensionContext,
	width: number,
	opts: { isWorking: boolean; liveElapsedSec: number | undefined },
): string {
	const dim = (s: string) => theme.fg("dim", s);
	const muted = (s: string) => theme.fg("muted", s);

	const place = muted(formatPlace(ctx.cwd, gitBranch, width < 60));

	const usage = ctx.getContextUsage();
	const tokens = usage?.tokens;
	const window = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
	const percent = usage?.percent ?? null;
	const used = tokens === null || tokens === undefined ? "?" : formatTokens(tokens);
	const limit = window > 0 ? formatTokens(window) : "?";
	const ctxLabel = `${used} / ${limit}`;
	const ctxColored =
		percent !== null && percent >= 90
			? theme.fg("error", ctxLabel)
			: percent !== null && percent >= 70
				? theme.fg("warning", ctxLabel)
				: dim(ctxLabel);
	const cost = dim(formatCost(sumSessionCost(ctx)));

	const rightParts: string[] = [ctxColored, cost];

	if (opts.isWorking && opts.liveElapsedSec !== undefined && opts.liveElapsedSec >= 0) {
		rightParts.push(dim(`… ${formatLatency(opts.liveElapsedSec)}`));
	} else {
		const metrics = lastTurnMetrics(ctx);
		if (metrics) {
			rightParts.push(dim(formatLatency(metrics.latencySec)));
			if (metrics.tps !== undefined && Number.isFinite(metrics.tps)) {
				rightParts.push(dim(formatTps(metrics.tps)));
			}
		}
	}

	// Progressive drop: t/s → latency → keep ctx+$ 
	const joinRight = (parts: string[]) => parts.join(dim(" · "));
	let right = joinRight(rightParts);
	while (visibleWidth(place) + visibleWidth(right) + 2 > width && rightParts.length > 2) {
		rightParts.pop();
		right = joinRight(rightParts);
	}

	return truncateToWidth(fitStatusRow(place, right, width), width, "");
}

/**
 * Prompt glyph inside the box — prepended to the first content line.
 * boxContentLine truncates after injection so overflow is safe.
 */
function injectPromptGlyph(
	lines: string[],
	contentStart: number,
	contentEnd: number,
	theme: Theme,
	mode: EditorMode,
): void {
	if (contentEnd <= contentStart) return;
	const paint = modeAccent(theme, mode);
	for (let i = contentStart; i < contentEnd; i++) {
		const line = lines[i];
		if (line === undefined) continue;
		lines[i] = i === contentStart ? `${paint("❯")} ${line}` : `  ${line}`;
	}
}

/** Ensure every line fits the terminal — defensive against padding/ANSI edge cases. */
function clampLines(lines: string[], width: number): string[] {
	if (width <= 0) return lines.map(() => "");
	return lines.map((line) => {
		const vw = visibleWidth(line);
		if (vw === width) return line;
		if (vw < width) return `${line}${" ".repeat(width - vw)}`;
		return truncateToWidth(line, width, "");
	});
}

function hasConversation(ctx: ExtensionContext): boolean {
	return ctx.sessionManager.getBranch().some(
		(entry) => entry.type === "message" && (entry.message.role === "user" || entry.message.role === "assistant"),
	);
}

function stripAnsi(text: string): string {
	return text.replace(/\u001b\[[0-9;]*m/g, "").replace(/\u001b\]8;;[^\u0007]*\u0007/g, "");
}

function findEditorBottomBorderIndex(lines: string[]): number {
	for (let i = lines.length - 1; i >= 1; i--) {
		const plain = stripAnsi(lines[i] ?? "");
		if (/^[─└┘┌┐]+$/.test(plain)) return i;
		if (/^─── [↑↓]/.test(plain) || /^[┌└]── [↑↓]/.test(plain)) return i;
		if (/^[└┌]/.test(plain) && /[┘┐]$/.test(plain)) return i;
	}
	return lines.length - 1;
}

function isScrollIndicatorLine(line: string): boolean {
	const plain = stripAnsi(line);
	return /^─── [↑↓]/.test(plain) || /^[┌└]── [↑↓]/.test(plain);
}

function fitBorder(
	left: string,
	right: string,
	width: number,
	border: (text: string) => string,
	fill: (text: string) => string = border,
	caps: { left: string; right: string } = { left: "─", right: "─" },
): string {
	if (width <= 0) return "";
	if (width === 1) return border(caps.left);

	let leftText = left;
	let rightText = right;
	const fixedWidth = 2;
	const minimumGap = 3;

	while (
		fixedWidth + visibleWidth(leftText) + visibleWidth(rightText) + minimumGap > width &&
		visibleWidth(rightText) > 0
	) {
		rightText = truncateToWidth(rightText, Math.max(0, visibleWidth(rightText) - 1), "");
	}
	while (
		fixedWidth + visibleWidth(leftText) + visibleWidth(rightText) + minimumGap > width &&
		visibleWidth(leftText) > 0
	) {
		leftText = truncateToWidth(leftText, Math.max(0, visibleWidth(leftText) - 1), "");
	}

	const gapWidth = Math.max(0, width - fixedWidth - visibleWidth(leftText) - visibleWidth(rightText));
	return `${border(caps.left)}${leftText}${fill("─".repeat(gapWidth))}${rightText}${border(caps.right)}`;
}

/** Wrap an inner editor line to full outer width with vertical box sides. */
function boxContentLine(line: string, outerWidth: number, border: (text: string) => string): string {
	const inner = Math.max(1, outerWidth - 2);
	let content = line;
	const vw = visibleWidth(content);
	if (vw < inner) content = `${content}${" ".repeat(inner - vw)}`;
	else if (vw > inner) content = truncateToWidth(content, inner, "");
	return `${border("│")}${content}${border("│")}`;
}

function readArtLines(): string[] {
	if (artCache) return artCache;
	try {
		artCache = fs.readFileSync(EYES_PATH, "utf8").replace(/\r\n/g, "\n").split("\n");
		return artCache;
	} catch {
		artCache = [];
		return artCache;
	}
}

/** Load ~/.pi/eyes.txt; trim empties; fit to cols. No boxes — alpha header style. */
function loadHeaderArt(cols: number): string[] {
	const raw = readArtLines();
	if (raw.length === 0) return [];
	const trimmed = [...raw];
	while (trimmed.length && trimmed[0]!.trim() === "") trimmed.shift();
	while (trimmed.length && trimmed[trimmed.length - 1]!.trim() === "") trimmed.pop();
	if (trimmed.length === 0) return [];

	// Pad to a rectangular block first — per-line centering shreds uneven art.
	const blockWidth = Math.max(...trimmed.map((line) => visibleWidth(line)), 0);
	const rectangular = trimmed.map((line) => {
		const pad = Math.max(0, blockWidth - visibleWidth(line));
		return pad > 0 ? `${line}${"\u2800".repeat(pad)}` : line;
	});

	const fitWidth = Math.max(1, cols);
	return rectangular.map((line) => truncateToWidth(line, fitWidth, ""));
}

function shouldShowArt(cols: number, rows: number): boolean {
	// miku.txt is ~18 lines / ~65 cols; wordmark needs far less
	return cols >= 40 && rows >= 16;
}

function centerLine(line: string, width: number): string {
	const vw = visibleWidth(line);
	if (vw >= width) return truncateToWidth(line, width, "");
	const pad = Math.floor((width - vw) / 2);
	return `${" ".repeat(pad)}${line}`;
}

/** Center a pre-normalized art block with one shared left pad. */
function centerArtBlock(lines: string[], cols: number): string[] {
	if (lines.length === 0) return [];
	const blockWidth = Math.max(...lines.map((line) => visibleWidth(line)), 0);
	const leftPad = Math.max(0, Math.floor((cols - blockWidth) / 2));
	const pad = " ".repeat(leftPad);
	return lines.map((line) => {
		const fitted = truncateToWidth(line, cols - leftPad, "");
		return `${pad}${fitted}`;
	});
}

/** Pad plain text to a visual column width (handles unicode keys like ↑↓). */
function padVisible(text: string, width: number): string {
	const vw = visibleWidth(text);
	if (vw >= width) return truncateToWidth(text, width, "");
	return `${text}${" ".repeat(width - vw)}`;
}

/** Full art line count (no height capping). */
function artFullLineCount(): number {
	const raw = readArtLines();
	const lines = [...raw];
	while (lines.length && lines[0]!.trim() === "") lines.shift();
	while (lines.length && lines[lines.length - 1]!.trim() === "") lines.pop();
	return Math.max(1, lines.length);
}

function placeLine(line: string, width: number): string {
	return centerLine(line, width);
}

/** Doom-splash style: [k] label */
function doomKeyHint(theme: Theme, key: string, label: string): string {
	const dim = (s: string) => theme.fg("dim", s);
	const muted = (s: string) => theme.fg("muted", s);
	const accent = (s: string) => theme.fg("accent", s);
	return `${dim("[")}${accent(key)}${dim("]")} ${muted(label)}`;
}

async function listHomeSessions(excludePath?: string | undefined): Promise<SessionInfo[]> {
	return (await SessionManager.listAll().catch(() => []))
		.filter((session) => session.messageCount > 0 && session.path !== excludePath)
		.sort((a, b) => b.modified.getTime() - a.modified.getTime())
		.slice(0, SESSION_FETCH);
}

function buildHomeMeta(ctx: ExtensionContext, pi: ExtensionAPI): HomeMeta {
	return {
		cwd: formatCwd(ctx.cwd),
		project: path.basename(ctx.cwd) || ctx.cwd,
		model: ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "no model",
		thinking: `thinking ${formatThinking(pi.getThinkingLevel())}`,
	};
}

function renderHomeArt(theme: Theme, cols: number, maxLines: number): string[] {
	const art = loadHeaderArt(Math.min(cols - 4, 72)).slice(0, maxLines);
	if (art.length === 0) {
		return [placeLine(theme.fg("accent", "[weeblets pi]"), cols)];
	}
	// Single theme color — paint after layout so ANSI does not affect width.
	const colored = art.map((line) => theme.fg("accent", line));
	return centerArtBlock(colored, cols);
}

function renderHomeTitle(theme: Theme, meta: HomeMeta, cols: number): string[] {
	const dim = (s: string) => theme.fg("dim", s);
	const muted = (s: string) => theme.fg("muted", s);
	const accent = (s: string) => theme.fg("accent", s);
	const metaBudget = Math.max(12, cols);
	const metaLine = truncateToWidth(
		`${muted(meta.project)}  ${dim("·")}  ${dim(meta.cwd)}  ${dim("·")}  ${dim(`π ${VERSION}`)}`,
		metaBudget,
		"",
	);
	return [placeLine(accent(theme.bold("weeblet")), cols), placeLine(metaLine, cols)];
}

/**
 * Greeter: art → title → footer (recents open via `r` picker, like model).
 * Non-overlay custom() so the editor is replaced and keys stay on this screen.
 */
class FullHomeScreen implements Component {
	private tui: TUI;
	private theme: Theme;
	private meta: HomeMeta;
	private onDone: (action: HomeAction | null) => void;
	private mode: HomeMode = "main";

	constructor(tui: TUI, theme: Theme, meta: HomeMeta, onDone: (action: HomeAction | null) => void) {
		this.tui = tui;
		this.theme = theme;
		this.meta = meta;
		this.onDone = onDone;
	}

	invalidate(): void {}

	handleInput(data: string): void {
		if (matchesKey(data, "ctrl+c") || data === "q" || data === "Q") {
			this.onDone({ kind: "quit" });
			return;
		}

		if (matchesKey(data, "escape")) {
			if (this.mode !== "main") {
				this.mode = "main";
				this.tui.requestRender();
				return;
			}
			this.onDone(null);
			return;
		}

		if (this.mode === "keybinds") {
			if (matchesKey(data, "enter") || data === "?") {
				this.mode = "main";
				this.tui.requestRender();
			}
			return;
		}

		if (data === "n" || data === "N") {
			this.onDone({ kind: "new" });
			return;
		}
		if (data === "r" || data === "R") {
			this.onDone({ kind: "recent" });
			return;
		}
		if (data === "?") {
			this.mode = "keybinds";
			this.tui.requestRender();
			return;
		}
		if (data === "m" || data === "M") {
			this.onDone({ kind: "model" });
		}
	}

	private renderKeybinds(cols: number): string[] {
		const muted = (s: string) => this.theme.fg("muted", s);
		const text = (s: string) => this.theme.fg("text", s);
		const accent = (s: string) => this.theme.fg("accent", s);
		const keyCol = Math.max(10, ...KEYBIND_ROWS.map((row) => visibleWidth(row.key)));
		const gap = 2;
		const descCol = Math.max(8, Math.min(BUTTON_WIDTH, cols) - keyCol - gap);
		const lines: string[] = [placeLine(muted("Keybinds"), cols), ""];

		for (const row of KEYBIND_ROWS) {
			const keyPad = Math.max(0, keyCol - visibleWidth(row.key));
			const descPlain = padVisible(truncateToWidth(row.desc, descCol, ""), descCol);
			const rowLine = `${accent(row.key)}${" ".repeat(keyPad)}${" ".repeat(gap)}${text(descPlain)}`;
			lines.push(placeLine(rowLine, cols));
		}

		return lines;
	}

	private renderFooter(cols: number): string[] {
		const muted = (s: string) => this.theme.fg("muted", s);
		const modelShort = truncateToWidth(this.meta.model, 42, "");
		const hint =
			this.mode === "keybinds"
				? doomKeyHint(this.theme, "esc", "back")
				: [
						doomKeyHint(this.theme, "n", "new"),
						doomKeyHint(this.theme, "r", "recent"),
						doomKeyHint(this.theme, "m", "model"),
						doomKeyHint(this.theme, "?", "keys"),
					].join("  ");
		return ["", centerLine(muted(`${modelShort}  ·  ${this.meta.thinking}`), cols), centerLine(hint, cols)];
	}

	private buildBody(cols: number, artMaxLines: number): string[] {
		const out: string[] = [];
		if (artMaxLines > 0) {
			const art = renderHomeArt(this.theme, cols, artMaxLines);
			out.push(...art);
			if (art.length) out.push("");
		}
		out.push(...renderHomeTitle(this.theme, this.meta, cols));
		out.push("");
		if (this.mode === "keybinds") {
			out.push(...this.renderKeybinds(cols));
		}
		out.push(...this.renderFooter(cols));
		return out;
	}

	private padToRows(body: string[], rows: number): string[] {
		const topPad = Math.max(0, Math.floor((rows - body.length) / 2));
		const padded = [...Array.from({ length: topPad }, () => ""), ...body];
		while (padded.length < rows) padded.push("");
		return padded.slice(0, rows);
	}

	render(width: number): string[] {
		const rows = this.tui.terminal?.rows ?? 30;
		const cols = Math.max(40, width);
		const artH = artFullLineCount();
		let artKeep = Math.min(artH, Math.max(0, rows - HOME_CHROME));
		let body = this.buildBody(cols, artKeep);
		while (body.length > rows && artKeep > 0) {
			artKeep -= 1;
			body = this.buildBody(cols, artKeep);
		}
		return this.padToRows(body, rows);
	}
}


class EmptyHeader implements Component {
	render(): string[] {
		return [];
	}
	invalidate(): void {}
}

/**
 * Edge spacer under the composer meta rows.
 * Path / tokens / latency live in the editor meta rows (always on-screen).
 */
class SessionStatusFooter implements Component {
	invalidate(): void {}

	render(): string[] {
		return [""];
	}
}

/**
 * Idle new-session greeter: eyes + brand + meta, vertically centered.
 * Prompt stays in the reserved bottom rows (no recents / no key hints).
 */
class HomeBackdropHeader implements Component {
	constructor(
		private tui: TUI,
		private theme: Theme,
		private meta: HomeMeta,
	) {}

	invalidate(): void {}

	render(width: number): string[] {
		const rows = this.tui.terminal?.rows ?? 30;
		const cols = Math.max(40, width);
		const target = Math.max(8, rows - EDITOR_RESERVE);

		const body: string[] = [];
		const art = renderHomeArt(this.theme, cols, artFullLineCount());
		body.push(...art);
		if (art.length) body.push("");
		body.push(...renderHomeTitle(this.theme, this.meta, cols));

		const topPad = Math.max(0, Math.floor((target - body.length) / 2));
		const lines = [...Array.from({ length: topPad }, () => ""), ...body];
		while (lines.length < target) lines.push("");
		return lines.slice(0, target);
	}
}

async function installHomeBackdrop(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	if (ctx.mode !== "tui") return;
	homeBackdropActive = true;
	const meta = buildHomeMeta(ctx, pi);
	ctx.ui.setHeader((tui, theme) => new HomeBackdropHeader(tui, theme, meta));
	activeTui?.requestRender();
}

function installConversationHeader(_pi: ExtensionAPI, ctx: ExtensionContext): void {
	homeBackdropActive = false;
	if (ctx.mode !== "tui") return;
	// Header stays empty — path / tokens / cost live under the composer.
	ctx.ui.setHeader(() => new EmptyHeader());
	activeTui?.requestRender();
}

function clearToEmptyHeader(ctx: ExtensionContext): void {
	homeBackdropActive = false;
	if (ctx.mode !== "tui") return;
	ctx.ui.setHeader(() => new EmptyHeader());
	activeTui?.requestRender();
}

/** Recent sessions picker (same SelectList UX as model). Returns session path or null. */
async function pickRecentSession(ctx: ExtensionContext): Promise<string | null> {
	const sessions = await listHomeSessions();
	if (sessions.length === 0) {
		ctx.ui.notify("No recent sessions", "info");
		return null;
	}
	const items: SelectItem[] = sessions.map((session) => {
		const label = sessionLabel(session);
		const search = `${label} ${session.cwd} ${session.path}`.toLowerCase();
		return {
			value: `${search}::${session.path}`,
			label,
			description: `${session.messageCount} msgs · ${age(session.modified)}`,
		};
	});
	const picked = await pickFromSelectList(ctx, "Recent sessions", items, 12);
	if (!picked) return null;
	return picked.includes("::") ? picked.split("::").pop()! : picked;
}

async function pickFromSelectList(
	ctx: ExtensionContext,
	title: string,
	items: SelectItem[],
	maxVisible = 12,
): Promise<string | null> {
	if (items.length === 0) return null;
	return ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
		const rows = tui.terminal?.rows ?? 24;
		const visible = Math.max(5, Math.min(maxVisible, rows - 8, items.length));
		const selectList = new SelectList(items, visible, {
			selectedPrefix: (t) => theme.fg("accent", t),
			selectedText: (t) => theme.fg("accent", t),
			description: (t) => theme.fg("muted", t),
			scrollInfo: (t) => theme.fg("dim", t),
			noMatch: (t) => theme.fg("warning", t),
		});
		selectList.onSelect = (item) => done(item.value);
		selectList.onCancel = () => done(null);

		let filter = "";
		const applyFilter = () => {
			// SelectList startsWith — use value that embeds searchable text
			selectList.setFilter(filter);
			tui.requestRender();
		};

		return {
			invalidate() {
				selectList.invalidate();
			},
			render(width: number): string[] {
				const border = (s: string) => theme.fg("border", s);
				const accent = (s: string) => theme.fg("accent", s);
				const dim = (s: string) => theme.fg("dim", s);
				const muted = (s: string) => theme.fg("muted", s);
				const lines: string[] = [];
				lines.push(border("─".repeat(Math.max(8, width))));
				lines.push(accent(theme.bold(` ${title}`)));
				const filterLine = filter.length
					? muted(` filter: ${filter}█`)
					: dim(" type to filter · backspace clear");
				lines.push(truncateToWidth(filterLine, width, ""));
				lines.push("");
				lines.push(...selectList.render(width));
				lines.push("");
				lines.push(dim(" ↑↓ navigate · enter select · esc cancel"));
				lines.push(border("─".repeat(Math.max(8, width))));
				return lines;
			},
			handleInput(data: string): void {
				if (matchesKey(data, "backspace") || matchesKey(data, "ctrl+h")) {
					filter = filter.slice(0, -1);
					applyFilter();
					return;
				}
				if (matchesKey(data, "ctrl+u")) {
					filter = "";
					applyFilter();
					return;
				}
				// Printable → filter (SelectList only handles arrows/enter/esc)
				if (data.length === 1 && data >= " " && data !== "\x7f") {
					filter += data;
					applyFilter();
					return;
				}
				selectList.handleInput(data);
				tui.requestRender();
			},
		};
	});
}

/**
 * Scrollable model picker (viewport + type-to-filter).
 * OpenTUI cannot own pi's terminal; this uses pi-tui SelectList the same way.
 */
async function pickModelAndThinking(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
): Promise<"cancelled" | "done"> {
	const models = ctx.modelRegistry.getAvailable();
	if (models.length === 0) {
		ctx.ui.notify("No models available — check /login or models.json", "warning");
		return "cancelled";
	}

	const current = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "";
	// Full id in label; no description column (it stole width and truncated names).
	const items: SelectItem[] = models.map((m) => {
		const id = `${m.provider}/${m.id}`;
		const search = `${m.id} ${m.provider} ${id}`.toLowerCase();
		return {
			value: `${search}::${id}`,
			label: id === current ? `${id}  (current)` : id,
		};
	});

	// Pre-select current model if present
	const currentIdx = models.findIndex((m) => `${m.provider}/${m.id}` === current);

	const picked = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
		const rows = tui.terminal?.rows ?? 24;
		const cols = tui.terminal?.columns ?? 100;
		const visible = Math.max(8, Math.min(14, rows - 10));
		let filter = "";
		let list = buildFilteredList(items, filter, visible, theme, cols);
		if (currentIdx >= 0 && !filter) {
			list.setSelectedIndex(currentIdx);
		}

		list.onSelect = (item) => done(item.value);
		list.onCancel = () => done(null);

		const rebuild = () => {
			const prev = list.getSelectedItem()?.value;
			const width = tui.terminal?.columns ?? cols;
			list = buildFilteredList(items, filter, visible, theme, width);
			list.onSelect = (item) => done(item.value);
			list.onCancel = () => done(null);
			if (prev) {
				const idx = items
					.filter((i) => matchesModelFilter(i, filter))
					.findIndex((i) => i.value === prev);
				if (idx >= 0) list.setSelectedIndex(idx);
			}
			tui.requestRender();
		};

		return {
			invalidate() {
				list.invalidate();
			},
			render(width: number): string[] {
				const border = (s: string) => theme.fg("border", s);
				const accent = (s: string) => theme.fg("accent", s);
				const dim = (s: string) => theme.fg("dim", s);
				const muted = (s: string) => theme.fg("muted", s);
				const matched = items.filter((i) => matchesModelFilter(i, filter)).length;
				const lines: string[] = [];
				lines.push(border("─".repeat(Math.max(8, width))));
				lines.push(accent(theme.bold(" Select model")));
				lines.push(
					truncateToWidth(
						filter.length
							? muted(` /${filter}█`) + dim(`  ${matched}/${items.length}`)
							: dim(` type to filter · ${items.length} models`),
						width,
						"",
					),
				);
				lines.push("");
				lines.push(...list.render(width));
				lines.push("");
				lines.push(dim(" ↑↓ navigate · enter select · esc cancel · ctrl+u clear"));
				lines.push(border("─".repeat(Math.max(8, width))));
				return lines;
			},
			handleInput(data: string): void {
				if (matchesKey(data, "backspace") || matchesKey(data, "ctrl+h")) {
					filter = filter.slice(0, -1);
					rebuild();
					return;
				}
				if (matchesKey(data, "ctrl+u")) {
					filter = "";
					rebuild();
					return;
				}
				if (data.length === 1 && data >= " " && data !== "\x7f") {
					filter += data;
					rebuild();
					return;
				}
				list.handleInput(data);
				tui.requestRender();
			},
		};
	});

	if (!picked) return "cancelled";

	const id = picked.includes("::") ? picked.split("::").pop()! : picked;
	const model = models.find((m) => `${m.provider}/${m.id}` === id);
	if (model) {
		const ok = await pi.setModel(model);
		if (ok) {
			ctx.ui.notify(`Model → ${model.provider}/${model.id}`, "info");
		} else {
			ctx.ui.notify(`No API key for ${model.provider}/${model.id}`, "warning");
		}
	}

	const curThinking = formatThinking(pi.getThinkingLevel());
	const thinkingItems: SelectItem[] = THINKING_LEVELS.map((level) => ({
		value: level,
		label: level === curThinking ? `${level}  (current)` : level,
	}));
	const thinkingPick = await pickFromSelectList(ctx, "Thinking level", thinkingItems, 8);
	if (thinkingPick) {
		const level = THINKING_LEVELS.find((l) => l === thinkingPick);
		if (level) {
			pi.setThinkingLevel(level);
			ctx.ui.notify(`Thinking → ${level}`, "info");
		}
	}
	return "done";
}

function matchesModelFilter(item: SelectItem, filter: string): boolean {
	if (!filter) return true;
	const q = filter.toLowerCase();
	return (
		item.value.toLowerCase().includes(q) ||
		item.label.toLowerCase().includes(q) ||
		(item.description?.toLowerCase().includes(q) ?? false)
	);
}

function buildFilteredList(
	items: SelectItem[],
	filter: string,
	visible: number,
	theme: Theme,
	termCols = 100,
): SelectList {
	const filtered = items.filter((i) => matchesModelFilter(i, filter));
	// Use nearly full terminal width so long openrouter/... ids are not cut at 32 cols.
	const primaryCols = Math.max(48, Math.min(120, termCols - 6));
	return new SelectList(
		filtered,
		Math.min(visible, Math.max(1, filtered.length || 1)),
		{
			selectedPrefix: (t) => theme.fg("accent", t),
			selectedText: (t) => theme.fg("accent", t),
			description: (t) => theme.fg("muted", t),
			scrollInfo: (t) => theme.fg("dim", t),
			noMatch: (t) => theme.fg("warning", t),
		},
		{
			minPrimaryColumnWidth: primaryCols,
			maxPrimaryColumnWidth: primaryCols,
		},
	);
}

async function applyHomeAction(
	pi: ExtensionAPI,
	ctx: ExtensionContext,
	action: HomeAction | null,
): Promise<"reopen-home" | void> {
	if (action?.kind === "quit") {
		ctx.shutdown();
		return;
	}

	// Esc / dismiss → keep greeter, focus the editor at the bottom.
	if (!action) {
		if (!hasConversation(ctx)) {
			await installHomeBackdrop(pi, ctx);
		}
		return;
	}
	if (action.kind === "model") {
		await pickModelAndThinking(pi, ctx);
		// Model flow was opened from the home menu — always return there.
		return "reopen-home";
	}

	if (action.kind === "recent") {
		const sessionPath = await pickRecentSession(ctx);
		if (!sessionPath) return "reopen-home";
		return applyHomeAction(pi, ctx, { kind: "session", path: sessionPath });
	}

	// newSession / switchSession only exist on ExtensionCommandContext (command handlers).
	// Auto-home runs from session_start (plain ExtensionContext), so defer via /home subcommands.
	const cmd = isCommandContext(ctx) ? ctx : undefined;

	if (action.kind === "new") {
		if (!hasConversation(ctx)) {
			await installHomeBackdrop(pi, ctx);
			return;
		}
		if (cmd) {
			await cmd.newSession({
				withSession: async (sessionCtx) => {
					await installHomeBackdrop(pi, sessionCtx);
				},
			});
			return;
		}
		setTimeout(() => {
			if (!submitSlashCommand("/home new")) {
				ctx.ui.setEditorText("/home new");
				ctx.ui.notify("Press Enter to start a new session", "info");
			}
		}, 0);
		return;
	}

	if (action.kind === "session") {
		homeBackdropActive = false;
		if (cmd) {
			await cmd.switchSession(action.path);
			return;
		}
		const slash = `/home resume ${action.path}`;
		setTimeout(() => {
			if (!submitSlashCommand(slash)) {
				ctx.ui.setEditorText(slash);
				ctx.ui.notify("Press Enter to resume session", "info");
			}
		}, 0);
	}
}

async function openFullHome(pi: ExtensionAPI, ctx: ExtensionContext): Promise<void> {
	if (ctx.mode !== "tui" || homeOpen) return;
	homeOpen = true;
	try {
		while (true) {
			const meta = buildHomeMeta(ctx, pi);
			// Non-overlay: replaces the editor and takes focus. Overlay left keys in the prompt.
			const action = await ctx.ui.custom<HomeAction | null>(
				(tui, theme, _kb, done) => new FullHomeScreen(tui, theme, meta, done),
			);
			const next = await applyHomeAction(pi, ctx, action);
			if (next === "reopen-home") continue;
			break;
		}
	} finally {
		homeOpen = false;
	}
}

export default function tokyoNightChrome(pi: ExtensionAPI): void {
	let isWorking = false;
	let spinnerIndex = 0;
	let spinnerTimer: ReturnType<typeof setInterval> | undefined;

	const stopSpinner = () => {
		if (spinnerTimer) {
			clearInterval(spinnerTimer);
			spinnerTimer = undefined;
		}
	};

	function installHiddenCommandFilter(ctx: ExtensionContext): void {
		ctx.ui.addAutocompleteProvider((current) => ({
			triggerCharacters: current.triggerCharacters,
			async getSuggestions(lines, cursorLine, cursorCol, options) {
				const result = await current.getSuggestions(lines, cursorLine, cursorCol, options);
				if (!result?.items?.length) return result;
				const items = result.items.filter((item) => {
					const raw = (item.value || item.label || "").replace(/^\//, "");
					const name = raw.split(/[\s:]/)[0] ?? "";
					return !HIDDEN_SLASH_COMMANDS.has(name);
				});
				return { ...result, items };
			},
			applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
				return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
			},
			shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
				return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
			},
		}));
	}

	function wrapEditorSubmit(editor: SubmittableEditor, ctx: ExtensionContext): void {
		const original = editor.onSubmit;
		if (!original || (editor as { __hiddenSlashWrapped?: boolean }).__hiddenSlashWrapped) return;
		(editor as { __hiddenSlashWrapped?: boolean }).__hiddenSlashWrapped = true;
		editor.onSubmit = async (text: string) => {
			const trimmed = text.trim();
			const match = trimmed.match(/^\/([^\s]+)/);
			const name = match?.[1];
			if (name && HIDDEN_SLASH_COMMANDS.has(name)) {
				editor.setText("");
				ctx.ui.notify(`/${name} is disabled`, "info");
				return;
			}
			return original(text);
		};
	}

	pi.on("agent_start", () => {
		isWorking = true;
		workStartedAt = Date.now();
		runTokensCommitted = { input: 0, output: 0 };
		runTokensLive = { input: 0, output: 0 };
		stopSpinner();
		spinnerTimer = setInterval(() => {
			spinnerIndex = (spinnerIndex + 1) % SPINNER_FRAMES.length;
			activeTui?.requestRender();
		}, 80);
		activeTui?.requestRender();
	});

	pi.on("message_update", (event) => {
		if (!isWorking) return;
		if (event.message.role !== "assistant") return;
		runTokensLive = readMessageUsage(event.message);
		activeTui?.requestRender();
	});

	pi.on("message_end", (event) => {
		if (!isWorking) return;
		if (event.message.role !== "assistant") return;
		const usage = readMessageUsage(event.message);
		runTokensCommitted = {
			input: runTokensCommitted.input + usage.input,
			output: runTokensCommitted.output + usage.output,
		};
		runTokensLive = { input: 0, output: 0 };
		activeTui?.requestRender();
	});

	pi.on("agent_end", () => {
		isWorking = false;
		workStartedAt = undefined;
		runTokensLive = { input: 0, output: 0 };
		stopSpinner();
		activeTui?.requestRender();
	});

	pi.on("session_shutdown", () => {
		stopSpinner();
		activeTui = undefined;
		activeEditor = undefined;
		homeBackdropActive = false;
	});

	pi.on("message_start", (event, ctx) => {
		if (!homeBackdropActive) return;
		if (event.message.role !== "user") return;
		installConversationHeader(pi, ctx);
		activeTui?.requestRender();
	});

	pi.on("session_start", async (event, ctx) => {
		if (ctx.mode !== "tui") return;

		installHiddenCommandFilter(ctx);

		ctx.ui.setTitle(`π · ${path.basename(ctx.cwd) || ctx.cwd}`);
		ctx.ui.setHiddenThinkingLabel("reasoning folded · Ctrl+T to expand");
		ctx.ui.setWorkingMessage("thinking");
		ctx.ui.setWorkingIndicator({ frames: WORKING_DOTS, intervalMs: 110 });
		ctx.ui.setWorkingVisible(false);
		ctx.ui.setFooter(() => new SessionStatusFooter());

		void pi.exec("git", ["branch", "--show-current"], { cwd: ctx.cwd })
			.then((result) => {
				const stdout = result?.stdout.trim();
				gitBranch = stdout && stdout.length > 0 ? stdout : undefined;
				activeTui?.requestRender();
			})
			.catch(() => {
				gitBranch = undefined;
			});

		const talking = hasConversation(ctx);
		if (talking) {
			installConversationHeader(pi, ctx);
		} else if (event.reason === "new") {
			// Fresh session from /new or home — keep greeter, editor at bottom.
			await installHomeBackdrop(pi, ctx);
		} else {
			clearToEmptyHeader(ctx);
		}

		class BorderStatusEditor extends CustomEditor {
			constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
				super(tui, theme, keybindings, { paddingX: EDITOR_PADDING_X });
				activeTui = tui;
				activeEditor = this;
			}

			handleInput(data: string): void {
				wrapEditorSubmit(this, ctx);
				super.handleInput(data);
				this.tui.requestRender();
			}

			render(width: number): string[] {
				const thm = ctx.ui.theme;
				const mode = editorMode(ctx, this.getText(), isWorking);
				const plan = readPlanMode(ctx);
				const spinner = SPINNER_FRAMES[spinnerIndex] ?? "⠋";
				this.borderColor = modeBorderColor(thm, mode);

				// Box: content inset by 2 (│…│); glyph injects into content, then truncated.
				const outer = width;
				const inner = Math.max(3, outer - 2);
				const lines = super.render(inner);
				if (lines.length < 2) return clampLines(lines, width);

				const paint = (text: string) => this.borderColor(text);
				const bottomIdx = findEditorBottomBorderIndex(lines);
				const topIsScroll = isScrollIndicatorLine(lines[0] ?? "");
				const bottomIsScroll = isScrollIndicatorLine(lines[bottomIdx] ?? "");

				injectPromptGlyph(lines, 1, bottomIdx, thm, mode);

				const liveElapsedSec =
					isWorking && workStartedAt !== undefined
						? Math.max(0, (Date.now() - workStartedAt) / 1000)
						: undefined;

				const row1 = composerMetaRow1Parts(thm, ctx, pi, mode, plan, spinner, outer);
				const row2 = buildComposerMetaRow2(thm, ctx, outer, {
					isWorking,
					liveElapsedSec,
				});

				const topLeft = topIsScroll ? " ↑ " : "";
				const topRight = bottomIsScroll ? " ↓ " : "";
				lines[0] = fitBorder(topLeft, topRight, outer, paint, paint, { left: "┌", right: "┐" });

				for (let i = 1; i < bottomIdx; i++) {
					lines[i] = boxContentLine(lines[i] ?? "", outer, paint);
				}

				lines[bottomIdx] = fitBorder(
					row1.left ? ` ${row1.left} ` : "",
					` ${row1.right} `,
					outer,
					paint,
					paint,
					{
						left: "└",
						right: "┘",
					},
				);

				const out: string[] = [];
				if (isWorking) {
					out.push(formatRunningIndicator(thm, spinner, outer));
				}
				out.push(...lines.slice(0, bottomIdx + 1), row2);
				for (let i = bottomIdx + 1; i < lines.length; i++) {
					out.push(lines[i] ?? "");
				}

				return clampLines(out, width);
			}
		}

		ctx.ui.setEditorComponent((tui, theme, keybindings) => new BorderStatusEditor(tui, theme, keybindings));

		const shouldIdleHome =
			!talking && (event.reason === "startup" || event.reason === "reload");
		if (shouldIdleHome) {
			await openFullHome(pi, ctx);
		}
	});

	pi.registerCommand("home", {
		description: "Open the weeblet home screen",
		handler: async (args, ctx) => {
			const trimmed = args.trim();
			if (trimmed === "new") {
				if (hasConversation(ctx)) {
					await ctx.newSession({
						withSession: async (sessionCtx) => {
							await installHomeBackdrop(pi, sessionCtx);
						},
					});
				} else {
					await installHomeBackdrop(pi, ctx);
				}
				return;
			}
			if (trimmed.startsWith("resume ")) {
				const sessionPath = trimmed.slice("resume ".length).trim();
				if (sessionPath) {
					homeBackdropActive = false;
					await ctx.switchSession(sessionPath);
				}
				return;
			}
			await openFullHome(pi, ctx);
		},
	});
}
