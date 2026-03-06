**Archive** all eligible DONE and DENIED items from the implementation plan.

## Execution Backend (XML Writes)

- Use `python3 ai-docs/plan_manager.py archive-run` for archival operations.
- This command moves eligible `DONE`/`DENIED` items, rotates changelog, updates metadata, syncs completed-features/security, and extracts lessons.
- Use global `--json` for structured run summaries.

## Steps

1. Read `ai-docs/overview.xml`, `ai-docs/overview-features-bugs.xml`, and `ai-docs/overview-features-bugs-archive.xml`.
2. Identify archive candidates:
- `DONE`: archive only if no active item depends on it.
- `DENIED`: archive directly.
3. Run `plan_manager.py archive-run`.
4. Verify effects:
- Items removed from active `<items>` and appended to archive with `archived="YYYY-MM-DD"`.
- `overview.xml` receives completed-feature/security sync updates when applicable.
- `ai-docs/lessons-learned.md` receives non-trivial lessons for archived DONE items.
5. Ensure changelog policy:
- Keep main changelog in `overview-features-bugs.xml` at `<= 30` entries.
- Move overflow entries to `overview-features-bugs-archive.xml` `<changelog-history>`.
6. Update metadata timestamps consistently across all touched XML files.
7. Report:
- archived IDs,
- blocked IDs with reason,
- extracted lesson IDs,
- rotated changelog count,
- full-test recommendation context (if relevant).

## Important

- Do not keep archived items in active `<items>`.
- Keep XML well-formed and lifecycle links consistent.
