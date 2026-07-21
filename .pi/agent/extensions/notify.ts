/**
 * Native terminal / OS notification when the agent finishes a turn.
 *
 * Protocols:
 * - OSC 777: Ghostty, iTerm2, WezTerm
 * - OSC 99: Kitty
 * - Windows toast: Windows Terminal (WSL)
 * - macOS Notification Center: fallback when OSC is unlikely to work
 */
import { execFile } from "node:child_process";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function windowsToastScript(title: string, body: string): string {
	const safeBody = body.replace(/'/g, "''");
	const type = "Windows.UI.Notifications";
	const mgr = `[${type}.ToastNotificationManager, ${type}, ContentType = WindowsRuntime]`;
	const template = `[${type}.ToastTemplateType]::ToastText01`;
	const toast = `[${type}.ToastNotification]::new($xml)`;
	return [
		`${mgr} > $null`,
		`$xml = [${type}.ToastNotificationManager]::GetTemplateContent(${template})`,
		`$xml.GetElementsByTagName('text')[0].AppendChild($xml.CreateTextNode('${safeBody}')) > $null`,
		`[${type}.ToastNotificationManager]::CreateToastNotifier('${title}').Show(${toast})`,
	].join("; ");
}

function notifyOSC777(title: string, body: string): void {
	process.stdout.write(`\x1b]777;notify;${title};${body}\x07`);
}

function notifyOSC99(title: string, body: string): void {
	process.stdout.write(`\x1b]99;i=1:d=0;${title}\x1b\\`);
	process.stdout.write(`\x1b]99;i=1:p=body;${body}\x1b\\`);
}

function notifyWindows(title: string, body: string): void {
	execFile("powershell.exe", ["-NoProfile", "-Command", windowsToastScript(title, body)], () => undefined);
}

function notifyMacOS(title: string, body: string): void {
	const script = `display notification ${JSON.stringify(body)} with title ${JSON.stringify(title)}`;
	execFile("osascript", ["-e", script], () => undefined);
}

function supportsOsc777(): boolean {
	const term = (process.env.TERM_PROGRAM ?? "").toLowerCase();
	return term === "ghostty" || term === "iterm.app" || term === "wezterm" || !!process.env.GHOSTTY_RESOURCES_DIR;
}

function notify(title: string, body: string): void {
	if (!process.stdout.isTTY) return;

	if (process.env.WT_SESSION) {
		notifyWindows(title, body);
		return;
	}
	if (process.env.KITTY_WINDOW_ID) {
		notifyOSC99(title, body);
		return;
	}
	if (supportsOsc777()) {
		notifyOSC777(title, body);
		return;
	}
	if (process.platform === "darwin") {
		notifyMacOS(title, body);
		return;
	}
	notifyOSC777(title, body);
}

export default function notifyExtension(pi: ExtensionAPI): void {
	pi.on("agent_end", async (_event, ctx) => {
		if (!ctx.hasUI) return;
		notify("Pi", "Ready for input");
	});
}
