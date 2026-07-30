export const MAX_EXTENSION_STATUS_LINES = 3;

const STATUS_PRIORITY = ["workflows", "subagents", "background-terminals", "repo-index", "summaries"];

function statusPriority(key: string): number {
  const index = STATUS_PRIORITY.indexOf(key);
  return index >= 0 ? index : STATUS_PRIORITY.length;
}

/**
 * Return a stable, bounded set of footer status lines.
 * Status text is supplied by trusted extensions, but is still trimmed and
 * bounded before it reaches the terminal chrome. Active orchestration status
 * is intentionally preferred over passive/background status so important
 * failures are not hidden by alphabetical ordering.
 */
export function collectExtensionStatusLines(
  statuses: ReadonlyMap<string, string>,
  maxLines = MAX_EXTENSION_STATUS_LINES,
): string[] {
  if (maxLines <= 0) return [];

  return Array.from(statuses.entries())
    .sort(([a], [b]) => statusPriority(a) - statusPriority(b) || a.localeCompare(b))
    .flatMap(([, text]) => text.split("\n"))
    .map((text) => text.trim())
    .filter(Boolean)
    .slice(0, maxLines);
}
