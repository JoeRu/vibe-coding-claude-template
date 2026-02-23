---
description: 'Manage sprints — create, view, or close lightweight sprint groupings of 2–5 APPROVED items.'
name: 'Sprint management'
argument-hint: '[create [ID...] | close]'
agent: 'agent'
---

**Sprint management** — create, view, or close lightweight sprint groupings.

**Arguments:** `$ARGUMENTS`
- (empty) — show active sprint status
- `create [ID...]` — create a sprint from specified or all APPROVED items
- `close` — close the active sprint (when all scope items are DONE)

## Overview

A **SPRINT** is a lightweight release grouping for 2–5 APPROVED items without the full formal gates of a RELEASE. Use the `release` prompt for formal versioned releases with PO approval gates.

---

## (no arguments) — Show Active Sprint

1. Read `ai-docs/overview-features-bugs.xml`.
2. Find the active SPRINT item (`status="ACTIVE"`). If none: inform the user.
3. Display scope items with statuses, gates, and progress count.
4. If all scope items are DONE: suggest running `/sprint close`.

---

## create [ID...]

1. Read `ai-docs/overview-features-bugs.xml`.
2. Check for an existing active SPRINT — warn if one is already ACTIVE.
3. Determine scope: use provided IDs, or all APPROVED items if none given.
4. Count items:
   - 0: no APPROVED items — suggest approving items first
   - 1: confirm with user (single item may not need a sprint)
   - 2–5: create SPRINT
   - > 5: warn and suggest formal release; ask for confirmation
5. Assign next SPR-N ID. Create SPRINT item:
   ```xml
   <sprint id="SPR-N" status="ACTIVE" type="SPRINT" started="YYYY-MM-DD">
     <title>Sprint N – [short label]</title>
     <scope>
       <item-ref id="N" type="{type}" status="{status}">Title</item-ref>
     </scope>
     <gates>
       <gate name="code-complete"  status="PENDING" date="" owner="SM" />
       <gate name="full-test-pass" status="PENDING" date="" owner="TST" />
     </gates>
     <release-test>
       <run date="" result=""><total></total><passed></passed><failed></failed></run>
     </release-test>
   </sprint>
   ```
6. Update changelog. Report: sprint ID, scope, suggested next steps.

---

## close

1. Read `ai-docs/overview-features-bugs.xml`.
2. Find active SPRINT. Verify all scope items are DONE (warn and halt if not).
3. Set sprint `status="COMPLETED"`, gate `code-complete` to PASSED.
4. Output full-test recommendation.
5. Update changelog.

---

## Important

- Only one SPRINT can be ACTIVE at a time
- SPRINT items are closed via `sprint close`, not via archive
- Keep XML valid
