/**
 * Code-aware compaction — summarize goals, decisions, files, checks, and next steps.
 * Falls back to default compaction if the summarizer is unavailable or fails.
 */
import type { Api, Model } from "@earendil-works/pi-ai";
import { complete } from "@earendil-works/pi-ai/compat";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { convertToLlm, serializeConversation } from "@earendil-works/pi-coding-agent";

const SUMMARIZER_CANDIDATES: Array<{ provider: string; modelId: string }> = [
	{ provider: "cursor", modelId: "gemini-3-flash" },
	{ provider: "cursor", modelId: "gemini-2.5-flash" },
	{ provider: "cursor", modelId: "gpt-5-mini" },
	{ provider: "cursor", modelId: "claude-haiku-4-5" },
	{ provider: "openrouter", modelId: "google/gemini-2.5-flash" },
	{ provider: "openrouter", modelId: "google/gemini-flash-1.5" },
	{ provider: "openrouter", modelId: "anthropic/claude-haiku-4.5" },
];

const SUMMARY_INSTRUCTIONS = `You are a coding-session summarizer. Produce a structured markdown summary that will replace older conversation turns. Include only durable facts needed to continue the work.

Required sections:
## Goal
## Decisions
## Files / symbols
## Checks run
## Blockers / open questions
## Next steps

Rules:
- Prefer exact file paths and symbol names.
- Omit chit-chat, retries, and discarded approaches unless they affect the current plan.
- Be thorough but concise.
`;

async function resolveSummarizer(
	ctx: ExtensionContext,
): Promise<{ model: Model<Api>; label: string } | undefined> {
	for (const candidate of SUMMARIZER_CANDIDATES) {
		const model = ctx.modelRegistry.find(candidate.provider, candidate.modelId);
		if (!model) continue;
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok || !auth.apiKey) continue;
		return { model, label: `${candidate.provider}/${candidate.modelId}` };
	}

	if (ctx.model) {
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(ctx.model);
		if (auth.ok && auth.apiKey) {
			return { model: ctx.model, label: `${ctx.model.provider}/${ctx.model.id}` };
		}
	}
	return undefined;
}

export default function codeCompactionExtension(pi: ExtensionAPI): void {
	pi.on("session_before_compact", async (event, ctx) => {
		const { preparation, signal } = event;
		const { messagesToSummarize, turnPrefixMessages, tokensBefore, firstKeptEntryId, previousSummary } = preparation;

		const resolved = await resolveSummarizer(ctx);
		if (!resolved) {
			if (ctx.hasUI) ctx.ui.notify("Code compaction: no summarizer available, using default", "warning");
			return;
		}

		const { model, label } = resolved;
		const auth = await ctx.modelRegistry.getApiKeyAndHeaders(model);
		if (!auth.ok || !auth.apiKey) {
			if (ctx.hasUI) ctx.ui.notify("Code compaction: summarizer auth failed, using default", "warning");
			return;
		}

		const allMessages = [...messagesToSummarize, ...turnPrefixMessages];
		if (ctx.hasUI) {
			ctx.ui.notify(
				`Code compaction: ${allMessages.length} msgs / ${tokensBefore.toLocaleString()} tok via ${label}`,
				"info",
			);
		}

		const conversationText = serializeConversation(convertToLlm(allMessages));
		const previousContext = previousSummary ? `\n\nPrevious summary:\n${previousSummary}` : "";

		const summaryMessages = [
			{
				role: "user" as const,
				content: [
					{
						type: "text" as const,
						text: `${SUMMARY_INSTRUCTIONS}${previousContext}

<conversation>
${conversationText}
</conversation>`,
					},
				],
				timestamp: Date.now(),
			},
		];

		try {
			const response = await complete(
				model,
				{ messages: summaryMessages },
				{
					apiKey: auth.apiKey,
					headers: auth.headers,
					env: auth.env,
					maxTokens: 8192,
					signal,
				},
			);

			if (signal.aborted) return;

			const summary = response.content
				.filter((c): c is { type: "text"; text: string } => c.type === "text")
				.map((c) => c.text)
				.join("\n")
				.trim();

			if (!summary) {
				if (ctx.hasUI) ctx.ui.notify("Code compaction: empty summary, using default", "warning");
				return;
			}

			return {
				compaction: {
					summary,
					firstKeptEntryId,
					tokensBefore,
				},
			};
		} catch (error) {
			if (signal.aborted) return;
			const message = error instanceof Error ? error.message : String(error);
			if (ctx.hasUI) ctx.ui.notify(`Code compaction failed: ${message}`, "error");
			return;
		}
	});
}
