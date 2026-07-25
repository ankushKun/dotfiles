# Archived extensions

## plan-mode

Disabled 2026-07-21 in favor of `@plannotator/pi-extension` + `@juicesharp/rpiv-todo`.

Restoring: move back under `extensions/` and add the path to `settings.json` `extensions` if you want the old `/plan` checklist flow again. Prefer not to — it duplicated the Todos widget.

## single-todo-widget

Disabled 2026-07-26. Its only job was clearing the `plan-todos` /
`plannotator-progress` widgets on every `session_start` and `agent_end`, because
`@plannotator/pi-extension` and `@juicesharp/rpiv-todo` fought over the task UI.
Plannotator was removed from `packages` on the same date, so there is nothing
left to clear.

Restoring: only makes sense if plannotator comes back. If it does, prefer fixing
the widget ownership over re-adding a per-event cleanup hook.
