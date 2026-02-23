**Sprint management** — create, view, or close lightweight sprint groupings.

**Arguments:** `$ARGUMENTS`
- (empty) — show active sprint status
- `create [ID...]` — create a sprint from specified or all APPROVED items
- `close` — close the active sprint (when all scope items are DONE)

## Overview

A **SPRINT** is a lightweight release grouping for 2–5 APPROVED items without the full formal gates of a RELEASE. The SM creates and owns sprints. Use `/release` for formal versioned releases with PO approval gates.

---

## /sprint (no arguments)

1. Read `ai-docs/overview-features-bugs.xml`.
2. Find the active SPRINT item (`status="ACTIVE"`). If none exists: inform the user.
3. Display:
   ```
   Sprint SPR-N: "{title}"
   Started: YYYY-MM-DD | Status: ACTIVE

   Scope:
     [DONE]        item-42  "Feature title"
     [IN_PROGRESS] item-43  "Feature title"
     [APPROVED]    item-44  "Feature title"

   Gates:
     code-complete:  PENDING
     full-test-pass: PENDING

   Progress: 1/3 items DONE
   ```
4. If all scope items are DONE: suggest running `/sprint close`.

---

## /sprint create [ID...]

1. Read `ai-docs/overview-features-bugs.xml`.
2. Check for an existing active SPRINT — if one is ACTIVE, warn the user and ask whether to close it first.
3. Determine scope:
   - If IDs provided: use those items. Verify each exists.
   - If no IDs: collect all items with `status="APPROVED"`.
4. Count the items in scope:
   - **0 items**: inform the user there are no APPROVED items. Suggest `/approve <ID>` first.
   - **1 item**: confirm with the user — a sprint for 1 item may be unnecessary; they can use `/start <ID>` directly.
   - **2–5 items**: create SPRINT (preferred path).
   - **> 5 items**: warn user that > 5 items is large for a sprint. Suggest using `/release` for a formal release instead. Ask for confirmation to proceed.
5. Assign next sprint ID: find the highest existing SPR-N ID and increment (start at SPR-1 if none exist).
6. Create SPRINT item in `overview-features-bugs.xml`:
   ```xml
   <sprint id="SPR-N" status="ACTIVE" type="SPRINT" started="YYYY-MM-DD">
     <title>Sprint N – [short label derived from scope item titles]</title>
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
7. Update changelog.
8. Report: sprint ID, title, scope items, suggested next step (`/start <IDs>` to begin work).

---

## /sprint close

1. Read `ai-docs/overview-features-bugs.xml`.
2. Find the active SPRINT. If none exists: inform the user.
3. Check all scope items — if any are not DONE: warn the user and list the unfinished items. Do not close.
4. If all items DONE:
   - Set sprint `status="COMPLETED"`.
   - Set gate `code-complete` to `status="PASSED"` with today's date.
5. Reset `<done-since-last-fulltest>` trigger:
   - The sprint completion itself triggers the full-test recommendation.
   - Output: *"Sprint SPR-N completed. All N items DONE. Recommendation: run `/full-test` to validate overall project quality before archiving."*
6. Update changelog.

---

## Important

- Only one SPRINT can be ACTIVE at a time
- SPRINT items are NOT archived via `/archive` — they are closed via `/sprint close`
- For formal versioned releases with PO approval gates, use `/release`
- Keep XML valid
