**Auto-pilot execution** — takes APPROVED items through the complete lifecycle (start → implement → test → fix bugs → done) without manual steps between stages.

**Arguments:** `$ARGUMENTS` (optional: one or more item IDs, comma- or space-separated. If empty: all APPROVED items.)

## Overview

`/run` orchestrates the full DEV → TST → bug-fix cycle automatically. It stops only when a decision genuinely requires the user: a bug that cannot be fixed after 2 attempts, a blocker, an unresolvable PROBLEM, or a security finding that requires design change.

After `/run` completes, run `/archive` to extract lessons and rotate the changelog.

---

## Phase 1 — Prepare

1. **Read** both XML files in parallel.
2. **Collect items to run**:
   - If IDs provided: verify each exists with `status="APPROVED"`. Warn and skip any that are not.
   - If no IDs: collect all items with `status="APPROVED"`.
   - If no APPROVED items found: inform user; suggest `/list approved` or `/approve`.
3. **5-item limit**: if more than 5 items collected, process the first 5 and offer to continue afterward.
4. **Sprint grouping**: if ≥ 2 items and no active SPRINT exists:
   - Create `<sprint id="SPR-N" status="ACTIVE" type="SPRINT" started="{today}">` with all items in `<scope>`.
   - Announce: "Sprint SPR-N created for N items."
5. **Announce** the run: list item IDs and `<title>` values, then proceed.

---

## Phase 2 — Execute Each Item

For each item in order:

### 2a. Start (SM role)
- Check `<depends-on>` — if any referenced IDs are not DONE: skip item with warning.
- Check BLOCKER items with `status="ACTIVE"` that list this item in `<blocks>`: **STOP** → report blocker to user; do not continue.
- Set `status="IN_PROGRESS"`.
- Add `<workflow-log>` entry: `role="SM" action="started" from-status="APPROVED" to-status="IN_PROGRESS"`.
- Update `<changelog>`.

### 2b. Implement (DEV role)
- Read `<tasks>`, `<verification>`, `<technical-parameters>` blocks.
- If `security="true"`: read `<security-impact>` before writing any code; implement each `<mitigation>` explicitly.
- Read all source files referenced in the item and related features in parallel.
- Execute each `<task>` in order; write clean, focused code — only what the item requires.
- Create or update unit tests per `<verification><tests>`.
- Run tests locally; fix failures before continuing.
- Fill `<r>` block: `<outcome>`, `<observations>`, `<lessons-learned>`, `<files>`.
- **STOP if PROBLEM**: if an unresolvable blocker is encountered (missing dependency, incompatible architecture, environment issue):
  - Set `<outcome>PROBLEM</outcome>` in `<r>`, describe the issue in `<observations>`.
  - Keep `status="IN_PROGRESS"`.
  - Report to user: "Item N blocked — manual intervention needed."
  - Do not process remaining items.

### 2c. Submit (DEV role)
- Verify unit tests pass; do not proceed if they fail.
- Set `status="REVIEW"`.
- Add `<workflow-log>` entry: `role="DEV" action="submitted" from-status="IN_PROGRESS" to-status="REVIEW"`.
- Update `<changelog>`.

### 2d. Verify (TST role)
- Read `<acceptance-criteria>` and `<verification><tests>` blocks.
- Run the full test suite.
- Run regression check: read `<r><files>` to identify changed files; run tests for adjacent features that use those files.
- Verify each `<criterion>` in `<acceptance-criteria>` is provably satisfied.

### 2e. Pass
If all tests and criteria pass:
- Set `status="DONE"`, fill `<r>` block: `<outcome>DONE</outcome>`, test results in `<observations>`.
- Add `<workflow-log>` entry: `role="TST" action="passed" from-status="REVIEW" to-status="DONE"`.
- Update `<changelog>`.
- Announce: "✓ Item N — DONE."
- Continue to the next item.

### 2f. Fail — Attempt 1 (auto bug-fix cycle)
If any test or criterion fails:
- Set item `status="FAILED"`.
- Add `<workflow-log>` entry: `role="TST" action="failed"`.
- **Create BUG item** (next sequential ID):
  ```xml
  <item id="N+1" type="bug" status="APPROVED" priority="HIGH" complexity="S"
        depends-on="{original-item-ID}">
    <title>Bug: [exact failure description]</title>
    <justification>Verification of item N failed: [which test / criterion]</justification>
    <steps-to-reproduce>
      <step order="1">Run: [test command]</step>
    </steps-to-reproduce>
    <expected-result>[what the criterion requires]</expected-result>
    <analysis>
      <hypothesis id="H1" status="OPEN">[most likely root cause from test output]</hypothesis>
    </analysis>
    <tasks>
      <task order="1">[specific fix step]</task>
    </tasks>
    <verification>
      <tests>[re-run the failed test and the original item's full test suite]</tests>
    </verification>
    <workflow-log>
      <entry timestamp="{today}" role="TST" action="created" from-status="" to-status="APPROVED" />
    </workflow-log>
    <r><outcome></outcome><files><file></file></files></r>
  </item>
  ```
- Update `<changelog>`.
- **Execute the BUG item** (repeat 2b–2c for the new BUG item).
- **Re-verify the ORIGINAL item** (repeat 2d):
  - If pass → set BUG `status="DONE"`, set original item back to `status="DONE"`; announce; continue.
  - If fail → go to **2g**.

### 2g. Fail — Attempt 2 (escalate to user)
- Create a second BUG item for the new failure (same structure as 2f).
- Set original item `status="FAILED"` (keep).
- **STOP**:
  ```
  ⛔ Item N "{title}" failed verification after 2 fix attempts.
  Bugs created: ID-X (attempt 1), ID-Y (attempt 2).
  Please review the failures manually before continuing.
  ```
- Do not process remaining items; wait for user input.

---

## Phase 3 — Completion

After all items in the batch are DONE:

1. **Sprint close** (if a sprint was active):
   - Verify all `<item-ref>` in `<scope>` are DONE.
   - Set sprint `status="COMPLETED"`, gate `code-complete` to `status="PASSED"` with today's date.
2. **Full-test trigger**: read `<done-since-last-fulltest>` counter; if ≥ 5 or last full-test > 14 days: recommend running `/full-test`.
3. **Announce**:
   ```
   Run complete. N/N items DONE.
   Next step: /archive  (extracts lessons, rotates changelog)
   ```

---

## Stopping Conditions

`/run` halts and returns control to the user when:

| Condition | Action |
|---|---|
| Bug fails 2 fix attempts | Report both BUG items; stop |
| Active BLOCKER on an item | Report blocker; stop |
| Item reaches PROBLEM outcome | Report the issue; stop |
| Security finding requiring design change | Report; stop (design must be updated first via `/plan-impl`) |
| ENABLER dependency missing | Report missing prerequisite; stop |

---

## Important

- **Max 5 items per run** — offer to continue if more are queued
- **Do not skip gates** — even in auto mode, each workflow-log entry and status transition must be written
- **Write XML immediately** after each transition — do not batch writes
- **Keep XML valid** at all times
- `/run` does not replace `/implement` — use `/implement` for manual single-item control
