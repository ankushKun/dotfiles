import assert from "node:assert/strict";
import { test } from "node:test";
import {
  collectExtensionStatusLines,
  MAX_EXTENSION_STATUS_LINES,
} from "./extension-status.ts";

test("status lines are sorted, split, trimmed, and bounded", () => {
  const statuses = new Map([
    ["workflows", " workflow running \ncheckpointing "],
    ["subagents", "agents: 2 running"],
    ["summaries", "summarizing"],
  ]);

  assert.deepEqual(collectExtensionStatusLines(statuses), [
    "workflow running",
    "checkpointing",
    "agents: 2 running",
  ]);
});

test("status line collection handles empty and non-positive limits", () => {
  assert.deepEqual(collectExtensionStatusLines(new Map()), []);
  assert.deepEqual(collectExtensionStatusLines(new Map([["x", "ready"]]), 0), []);
  assert.equal(MAX_EXTENSION_STATUS_LINES, 3);
});
