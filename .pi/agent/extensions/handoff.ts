/**
 * /handoff <goal> — extract durable coding context into a starter prompt.
 *
 * Default: draft lands in the current editor (review before submit).
 * /handoff --new <goal>: also open a new session with that draft.
 */
import type { AgentMessage } from "@earendil-works/pi-agent-core";
import { complete, type Message } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, SessionEntry } from "@earendil-works/pi-coding-agent";
import { BorderedLoader, convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";

const SYSTEM_PROMPT = `You are a coding-session handoff assistant. Given conversation history and the user's goal for a new thread, generate a focused starter prompt that:

1. Summarizes relevant context (decisions, approaches, key findings)
2. Lists files and symbols that matter (real paths only)
3. Notes checks already run (tests/types/lint) and their results when known
4. States the next task clearly from the user's goal
5. Is self-contained — the new thread must proceed without the old conversation

Output the prompt only. No preamble like "Here's the prompt".

Use this structure:

## Context
...

## Files
- path — why it matters

## Checks run
- command — pass/fail (or "unknown")

## Task
[Clear next action from the user's goal]
`;

function entryToMessage(entry: SessionEntry): AgentMessage | undefined {
	if (entry.type === "message") {
		return entry.message;
	}
	if (entry.type === "compaction") {
		return {
			role: "compactionSummary",
			summary: entry.summary,
			tokensBefore: entry.tokensBefore,
			timestamp: new Date(entry.timestamp).getTime(),
		};
	}
	return undefined;
}

function getHandoffMessages(branch: SessionEntry[]): AgentMessage[] {
	let compactionIndex = -1;
	for (let i = branch.length - 1; i >= 0; i--) {
		if (branch[i].type === "compaction") {
			compactionIndex = i;
			break;
		}
	}
	if (compactionIndex < 0) {
		return branch.map(entryToMessage).filter((message): message is AgentMessage => message !== undefined);
	}

	const compaction = branch[compactionIndex];
	const firstKeptIndex =
		compaction.type === "compaction" ? branch.findIndex((entry) => entry.id === compaction.firstKeptEntryId) : -1;
	const compactedBranch = [
		compaction,
		...(firstKeptIndex >= 0 ? branch.slice(firstKeptIndex, compactionIndex) : []),
		...branch.slice(compactionIndex + 1),
	];
	return compactedBranch.map(entryToMessage).filter((message): message is AgentMessage => message !== undefined);
}

function parseArgs(raw: string): { newSession: boolean; goal: string } {
	const tokens = raw.trim().split(/\s+/).filter(Boolean);
	let newSession = false;
	const goalParts: string[] = [];
	for (const token of tokens) {
		if (token === "--new") {
			newSession = true;
			continue;
		}
		goalParts.push(token);
	}
	return { newSession, goal: goalParts.join(" ").trim() };
}

export default function handoffExtension(pi: ExtensionAPI): void {
	pi.registerCommand("handoff", {
		description: "Draft a handoff prompt for a new focused thread (/handoff [--new] <goal>)",
		handler: async (args, ctx) => {
			if (ctx.mode !== "tui") {
				ctx.ui.notify("handoff requires interactive mode", "error");
				return;
			}
			if (!ctx.model) {
				ctx.ui.notify("No model selected", "error");
				return;
			}

			const { newSession, goal } = parseArgs(args);
			if (!goal) {
				ctx.ui.notify("Usage: /handoff [--new] <goal for new thread>", "error");
				return;
			}

			const messages = getHandoffMessages(ctx.sessionManager.getBranch());
			if (messages.length === 0) {
				ctx.ui.notify("No conversation to hand off", "error");
				return;
			}

			const conversationText = serializeConversation(convertToLlm(messages));
			const currentSessionFile = ctx.sessionManager.getSessionFile();

			const result = await ctx.ui.custom<string | null>((tui, theme, _kb, done) => {
				const loader = new BorderedLoader(tui, theme, "Generating handoff prompt...");
				loader.onAbort = () => done(null);

				const doGenerate = async () => {
					const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model!);
					if (!auth.ok || !auth.apiKey) {
						throw new Error(auth.ok ? `No API key for ${ctx.model!.provider}` : auth.error);
					}

					const userMessage: Message = {
						role: "user",
						content: [
							{
								type: "text",
								text: `## Conversation History\n\n${conversationText}\n\n## User's Goal for New Thread\n\n${goal}`,
							},
						],
						timestamp: Date.now(),
					};

					const response = await complete(
						ctx.model!,
						{ systemPrompt: SYSTEM_PROMPT, messages: [userMessage] },
						{ apiKey: auth.apiKey, headers: auth.headers, env: auth.env, signal: loader.signal },
					);

					if (response.stopReason === "aborted") {
						return null;
					}

					return response.content
						.filter((c): c is { type: "text"; text: string } => c.type === "text")
						.map((c) => c.text)
						.join("\n");
				};

				doGenerate()
					.then(done)
					.catch((err) => {
						console.error("Handoff generation failed:", err);
						done(null);
					});

				return loader;
			});

			if (result === null) {
				ctx.ui.notify("Cancelled", "info");
				return;
			}

			const editedPrompt = await ctx.ui.editor("Edit handoff prompt", result);
			if (editedPrompt === undefined) {
				ctx.ui.notify("Cancelled", "info");
				return;
			}

			if (!newSession) {
				ctx.ui.setEditorText(editedPrompt);
				ctx.ui.notify("Handoff draft ready in editor. Submit when ready (or /handoff --new … next time).", "info");
				return;
			}

			const newSessionResult = await ctx.newSession({
				parentSession: currentSessionFile,
				withSession: async (replacementCtx) => {
					replacementCtx.ui.setEditorText(editedPrompt);
					replacementCtx.ui.notify("Handoff ready in new session. Submit when ready.", "info");
				},
			});

			if (newSessionResult.cancelled) {
				ctx.ui.notify("New session cancelled — draft kept below if still available", "info");
				ctx.ui.setEditorText(editedPrompt);
			}
		},
	});
}
