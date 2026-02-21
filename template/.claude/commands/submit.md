**Submit** an item for review — transition from IN_PROGRESS to REVIEW. DEV role confirms implementation is complete and unit tests pass.

**Arguments:** `$ARGUMENTS` (one item ID, optional notes)

## Steps

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`. Extract any notes (text after the ID).
3. **Verify** the item exists and has `status="IN_PROGRESS"`.
4. **Verify task completion** – list all tasks; confirm which are done. If any critical tasks are incomplete, warn the user and ask for confirmation.
5. **Check unit tests** – ask the user to confirm unit tests pass (or note test results if provided). Do not proceed to REVIEW if tests are known to fail.
6. **Update `<r>` block** with what has been completed so far (outcome left empty until DONE):
   - `<observations>`: what was found during implementation
   - `<files>`: list files changed
7. **Set** `status="REVIEW"`.
8. **Add workflow-log entry**: `role="DEV" action="submitted" from-status="IN_PROGRESS" to-status="REVIEW"`.
9. **Update changelog** in `overview-features-bugs.xml`.
10. **Confirm** to user: item ID, title, REVIEW, which tasks are complete, files changed.

## Important

- Do not set REVIEW if the user indicates tests are failing
- Incomplete tasks should be noted but don't automatically block submission
- Keep XML valid
