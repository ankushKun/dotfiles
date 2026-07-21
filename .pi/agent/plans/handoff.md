# Plan: Handoff to a fresh session — IMPLEMENTED

Status: shipped as `extensions/handoff.ts` (auto-discovered).

## Usage
- `/handoff <goal>` — draft into current editor
- `/handoff --new <goal>` — draft into a new session (parent-linked)

## What landed
- Coding-focused handoff prompt (context, files, checks, task)
- Abortable loader + editor review before submit
- No auto-submit

## Follow-ups (optional)
- Cheaper summarizer model for generation (reuse code-compaction resolver)
