# Global coding-agent rules

- Lead with the result and work autonomously until the requested outcome is verified.
- Read repository instructions and inspect the real call path before editing.
- Use `repo_map` before broad exploration; use `rg` for exact text and symbol searches.
- For non-trivial work, keep a short plan via the `todo` tool only (one Todos widget). Do not also write markdown checkbox plans or duplicate plannotator progress lists for the same steps.
- For larger design/approval work, use `/plannotator` (or `--plan`) for read-restricted planning; after approval, track execution steps only in `todo`.
- Delegate bounded, independent research or review to subagents; keep small tasks in the main context.
- Preserve user changes. Never overwrite unrelated work or use destructive git commands without explicit approval.
- Prefer existing project patterns, the standard library, and the smallest complete change.
- Run the narrowest relevant tests, type checks, and linters (`lsp_diagnostics` when available). Report anything you could not verify.
- Treat generated files, lockfiles, credentials, and migrations deliberately; do not edit them by accident.
- Ask only when a missing decision would materially change the result or authorize external/destructive action.
- On provider rate-limit or ResourceExhausted errors, switch model/provider (F2 / `/model`) and continue; do not spin retries on the same exhausted upstream.
