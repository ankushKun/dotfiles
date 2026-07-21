# Plan: Notify on agent idle — IMPLEMENTED

Status: shipped as `extensions/notify.ts` (auto-discovered).

## Goal
Get a native terminal notification when Pi finishes a turn and is waiting for input — useful for long tool loops.

## What landed
- `agent_end` → OSC 777 / OSC 99 / Windows toast / macOS Notification Center fallback
- Skips when `!ctx.hasUI` or non-TTY
- Title `Pi`, body `Ready for input`

## Follow-ups (optional)
- `notify.onErrorOnly`
- Skip when terminal is focused
