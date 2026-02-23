---
description: 'Show a kanban-style board of all active items grouped by status column.'
name: 'Show board'
argument-hint: 'Optional filter: type, priority, or keyword.'
agent: 'agent'
---
<!-- GENERATED FILE — do not edit directly.
     Source:   .claude/commands/board.md
     Metadata: scripts/copilot-headers.json
     Regenerate: python3 scripts/generate-copilot-prompts.py -->

Show a **kanban-style board** of all active items grouped by status column.

**Arguments:** `$ARGUMENTS` (optional filter: type, priority, or role keyword)

## Steps

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Parse** optional filter from `$ARGUMENTS` (e.g. `bug`, `high`, `feature`, `security`).
3. **Group active items** by status column in this order:
   - PENDING · APPROVED · PLANNED · IN_PROGRESS · REVIEW · FAILED
   - Exclude DONE, DENIED, ARCHIVED (those are in the archive)
4. **Apply filter** if provided (by type, priority, or `security="true"`).
5. **Display** in a compact board format:

```
PENDING (3)                  APPROVED (1)      PLANNED (2)      IN_PROGRESS (1)    REVIEW (1)
───────────────────────      ─────────────     ─────────────    ───────────────    ─────────
#7  [BUG] Login race   HIGH  #12 OAuth int     #15 PDF export   #18 CSV import     #20 Dark
#9  [FEAT] Dark mode   MED       MEDIUM           HIGH M           MEDIUM M            mode
#11 [DEBT] DB migrate  LOW                     #16 Queue setup                       HIGH
```

6. **Summarize** below the board: total active items, next actionable (APPROVED items that can be planned, PLANNED items that can be started).
7. **List active BLOCKERs** if any exist.

## Important

- Only show active items (not archive)
- RELEASE items are shown separately if any exist
- Keep output compact — use abbreviations for long titles
