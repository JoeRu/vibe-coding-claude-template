---
description: 'TST signs off on an item in REVIEW — transitions to DONE.'
name: 'Pass item'
argument-hint: 'Item ID [test notes]'
agent: 'agent'
---

**Pass** an item — TST signs off, transitions from REVIEW to DONE.

**Arguments:** `$ARGUMENTS` (one item ID, optional test notes)

## Steps

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`. Extract any test notes.
3. **Verify** the item exists and has `status="REVIEW"`.
4. **Verify acceptance criteria** – if `<acceptance-criteria>` is present, confirm each criterion is met. If not all met, warn and ask for confirmation.
5. **Update `<r>` block**:
   - `<outcome>DONE</outcome>`
   - `<observations>`: test results, coverage notes, any observations
   - `<lessons-learned>`: what was learned during this item
   - `<files>`: confirm list of changed files
6. **Set** `status="DONE"`.
7. **Add workflow-log entry**: `role="TST" action="passed" from-status="REVIEW" to-status="DONE"`.
8. **Update changelog** in `overview-features-bugs.xml`.
9. **Check archival eligibility** – if no active items have `depends-on` referencing this item, and all sub-items are DONE, suggest `/archive`.
10. **Confirm** to user: item ID, title, DONE, summary of what was delivered.

## Important

- All acceptance criteria should be verified before passing
- Suggest `/archive` when eligible — but do not auto-archive
- Keep XML valid
