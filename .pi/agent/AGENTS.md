# Global coding-agent rules

- Lead with the result and work autonomously until the requested outcome is verified.
- Read repository instructions and inspect the real call path before editing.
- Use `repo_map` before broad exploration; use `rg` for exact text and symbol searches.
- For non-trivial work, keep a short plan, update it as facts change, and verify the final state.
- Delegate bounded, independent research or review to subagents; keep small tasks in the main context.
- Preserve user changes. Never overwrite unrelated work or use destructive git commands without explicit approval.
- Prefer existing project patterns, the standard library, and the smallest complete change.
- Run the narrowest relevant tests, type checks, and linters. Report anything you could not verify.
- Treat generated files, lockfiles, credentials, and migrations deliberately; do not edit them by accident.
- Ask only when a missing decision would materially change the result or authorize external/destructive action.
