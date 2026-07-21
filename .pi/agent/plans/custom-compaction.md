# Plan: Custom compaction — IMPLEMENTED

Status: shipped as `extensions/code-compaction.ts` (auto-discovered).

## What landed
- `session_before_compact` handler with structured coding summary
- Summarizer preference: cursor flash/mini/haiku → openrouter flash → current model
- Keeps `firstKeptEntryId`; falls back to default on auth/empty/error/abort

## Settings
Unchanged: `compaction.reserveTokens` 16384 / `keepRecentTokens` 24000

## Follow-ups (optional)
- Tune token budgets after real sessions
- Pin an explicit summarizer in settings if fallbacks feel noisy
