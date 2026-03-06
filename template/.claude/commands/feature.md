Create a **feature, epic, enabler, or requirement item** in the implementation plan.

**Arguments:** `$ARGUMENTS` (description with optional modifiers)

## Execution Backend (XML Writes)

- Use `python3 ai-docs/plan_manager.py create-item` for all item insertions into `ai-docs/overview-features-bugs.xml`.
- Recommended flags: `--kind`, `--title`, `--justification`, `--priority`, `--complexity`, optional `--security`, `--depends-on`, `--task`, `--test-file`, `--file`.
- For machine-readable orchestration output, add global `--json`.

## Phase 1 - Item Creation

1. Read `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml` in parallel.
2. Parse modifiers from `$ARGUMENTS`: `!critical|!high|!medium|!low`, `!security`, `@<ID>`, `^<ID>`, `--epic`, `--enabler`, `--requirement`, `!run`.
3. Search for duplicates and abort creation if an existing item already tracks the same scope.
4. Create item via `plan_manager.py create-item` with status `PENDING`.

## Phase 2 - DA Enrichment

1. Read relevant source files before proposing implementation details.
2. Populate tasks, technical constraints, verification targets, and affected files.
3. Perform dependency/collision checks for overlapping planned files.
4. Mark security impact when applicable.

## Phase 3 - Optional `!run`

1. If `!run` is set and item is not XL, transition the created item to `APPROVED` and continue with implementation flow.
2. If item is XL, keep it `PENDING` and require `/translate` decomposition first.

## Output

- Without `!run`: show enriched item details and keep status `PENDING`.
- With `!run`: show approval and execution summary.

## Important

- Keep XML valid at all times.
- Keep grouped changelog entries concise.
