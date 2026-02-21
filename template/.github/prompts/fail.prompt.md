---
description: 'TST rejects an item in REVIEW — creates a linked BUG and returns to IN_PROGRESS.'
name: 'Fail item'
argument-hint: 'Item ID reason'
agent: 'agent'
---

**Fail** an item — TST rejects it, transitions from REVIEW back to IN_PROGRESS, and creates a linked BUG item.

**Arguments:** `$ARGUMENTS` (one item ID, reason for failure)

## Steps

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`. Extract failure reason (required — ask if missing).
3. **Verify** the item exists and has `status="REVIEW"`.
4. **Set** `status="FAILED"` momentarily (for the log entry), then immediately transition to `status="IN_PROGRESS"`.
5. **Add workflow-log entry**: `role="TST" action="failed" from-status="REVIEW" to-status="FAILED"`.
6. **Create a BUG item** (PENDING) linked to this item:
   - `type="bug"`, `priority="HIGH"`, `depends-on="<original-item-ID>"`
   - Title: `[FAIL] <original title> – <short reason>`
   - Include steps-to-reproduce and expected vs. actual result from the failure reason
   - Add `<analysis>` block with initial hypothesis
7. **Add second workflow-log entry** on the original item: `role="SM" action="reopened" from-status="FAILED" to-status="IN_PROGRESS"`.
8. **Update changelog** in `overview-features-bugs.xml`.
9. **Confirm** to user: original item is back IN_PROGRESS, new BUG item ID and title created.

## Important

- A failure reason is required — never fail without documenting why
- The BUG item must be created in the same interaction
- The original item returns to IN_PROGRESS (not PENDING) — work continues, not restarted
- Keep XML valid
