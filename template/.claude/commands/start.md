**Start** an item — transition from PLANNED (or APPROVED) to IN_PROGRESS. SM role assigns work to DEV.

**Arguments:** `$ARGUMENTS` (one item ID)

## Steps

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`.
3. **Verify** the item exists and has `status="PLANNED"` or `status="APPROVED"`.
4. **Check dependencies** – if any `depends-on` items are not DONE, warn the user and ask for confirmation to proceed.
5. **Check for active blockers** – scan for BLOCKER items that reference this item. If any are ACTIVE, warn the user.
6. **Set** `status="IN_PROGRESS"`.
7. **Add workflow-log entry**: `role="SM" action="started" from-status="PLANNED" to-status="IN_PROGRESS"`.
8. **Update changelog** in `overview-features-bugs.xml`.
9. **Confirm** to user: item ID, title, IN_PROGRESS, branch name (if set), list of tasks to complete.

## Sprint Suggestion

After verifying the single item to start, check the count of other APPROVED items:
- If there are **2 or more** other APPROVED items (beyond the one being started) AND no active SPRINT exists:
  - Offer: *"There are N other APPROVED items. Would you like to group them into a sprint? Run `/sprint create` to group all APPROVED items, or proceed with starting this item alone."*
  - Do NOT auto-create the sprint — just suggest it. Proceed with starting the requested item.

## Important

- PLANNED is the expected prior status; APPROVED is also accepted for simple items skipping /plan-impl
- Warn (but do not block) if dependencies are unresolved — the user decides
- Keep XML valid
