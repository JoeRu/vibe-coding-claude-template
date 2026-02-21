---
description: 'Manage RELEASE items — create a release, update gates, or show release status.'
name: 'Manage release'
argument-hint: '<version> [--target <date>] | status <ID> | gate <ID> <gate-name> | go <ID>'
agent: 'agent'
---

**Manage RELEASE items** — create a release, add items to scope, update gates, or show release status.

**Arguments:** `$ARGUMENTS` (one of: `<version> [--target <date>]` | `status <ID>` | `gate <ID> <gate-name>` | `go <ID>`)

## Steps

### Create a release — `$ARGUMENTS` is a version string (e.g. `v2.4.0`)

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Parse** version and optional `--target <date>` from arguments.
3. **Create** RELEASE item:
   - ID with `REL-` prefix (e.g. `REL-1`)
   - `status="PLANNING"`, `type="MINOR"` (override with `--major` or `--patch`)
   - `target-date` from argument or empty
   - Standard gates: scope-freeze (PENDING), code-complete (PENDING), full-test-pass (PENDING), release-approval (PENDING)
   - Ask user which items (features, bugs, enablers) to include in `<scope>`
4. **Update changelog** and **confirm** to user: RELEASE ID, version, target date, scope items.

### Show release status — `status <ID>`

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Find** RELEASE item by ID.
3. **Display**: version, target date, gate status, scope items with their current statuses.
4. **Summarize**: how many scope items are DONE vs. in-flight, which gates are blocking.

### Update a gate — `gate <ID> <gate-name>`

1. **Find** the RELEASE item and the named gate.
2. **Toggle** gate status: PENDING → PASSED (or ask user for status).
3. **Set** gate `date` to today.
4. **Check**: if all gates are PASSED, suggest `/release go <ID>`.
5. **Update changelog** and **confirm**.

### Approve release — `go <ID>`

1. **Verify** all gates are PASSED.
2. **Set** RELEASE `status="RELEASED"` and add release date.
3. **Update changelog** and **confirm** to user.

## Important

- RELEASE IDs use `REL-` prefix to distinguish from item IDs
- A release does not DONE its scope items — those are managed independently
- Keep XML valid
