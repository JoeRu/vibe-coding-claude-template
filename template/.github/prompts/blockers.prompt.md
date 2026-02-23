---
description: 'Manage BLOCKER items — list, create, or resolve blockers.'
name: 'Manage blockers'
argument-hint: 'Empty | resolve <ID> | <title> --blocks <ID,...>'
agent: 'agent'
---
<!-- GENERATED FILE — do not edit directly.
     Source:   .claude/commands/blockers.md
     Metadata: scripts/copilot-headers.json
     Regenerate: python3 scripts/generate-copilot-prompts.py -->

**Manage BLOCKER items** — list, create, or resolve blockers that impede other items.

**Arguments:** `$ARGUMENTS` (one of: empty | `resolve <ID>` | `<title> --blocks <ID,...>`)

## Steps

### If `$ARGUMENTS` is empty — list blockers

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Find** all BLOCKER items with `status="ACTIVE"`.
3. **Display** each blocker: ID, title, severity, what it blocks, assigned-to, resolution-plan.
4. If no active blockers: confirm "No active blockers."

### If `$ARGUMENTS` starts with `resolve <ID>` — resolve a blocker

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Parse** BLOCKER ID.
3. **Verify** it exists and has `status="ACTIVE"`.
4. **Prompt** user for resolution description (or extract from arguments after the ID).
5. **Set** `status="RESOLVED"`, populate `<resolved-date>` and `<resolution>`.
6. **Update changelog** and **confirm** to user.

### If `$ARGUMENTS` contains `--blocks` — create a new blocker

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Parse** title and `--blocks <ID,...>` from arguments.
3. **Verify** all referenced item IDs exist.
4. **Create** BLOCKER item:
   - Assign next sequential ID with `BLK-` prefix
   - `status="ACTIVE"`, `severity="HIGH"` (default, overridable with `!critical !medium !low`)
   - `raised-by="SM"` (default)
   - Add `<blocks>` with item-refs
   - Ask user for `<resolution-plan>` or leave empty
5. **Update changelog** and **confirm** to user: BLOCKER ID, what it blocks.

## Important

- BLOCKER IDs use `BLK-` prefix (e.g. `BLK-1`) to distinguish from item IDs
- Severity overrides: `!critical`, `!high`, `!medium`, `!low`
- Keep XML valid
