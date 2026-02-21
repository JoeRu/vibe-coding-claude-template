---
description: 'Show the dependency tree for an item — what it depends on, what depends on it, and any blockers.'
name: 'Check dependencies'
argument-hint: 'Item ID'
agent: 'agent'
---

Show the **dependency tree** for an item — what it depends on, what depends on it, and any blocking issues.

**Arguments:** `$ARGUMENTS` (one item ID)

## Steps

1. **Read** `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`.
3. **Verify** the item exists.
4. **Build dependency tree upward** (what this item depends on):
   - Follow `depends-on` and `parent` chains recursively
   - For each dependency: show ID, title, type, status
   - Flag any dependency that is DENIED, FAILED, or PENDING (not yet approved)
5. **Build dependent tree downward** (what depends on this item):
   - Find all items that list this ID in their `depends-on`
   - Show ID, title, type, status
6. **Check for active BLOCKERs** that reference this item.
7. **Display** in a tree format:

```
Item #42 "PDF Export" [IN_PROGRESS]

Depends on:
  ✓ #38 "Report Dashboard Base" [DONE]
  ✓ #18 "PDF Rendering Library" [DONE]
  ⚠ #35 "Queue Service" [APPROVED] — not yet started

Depended on by:
  · #50 "Bulk Export Feature" [PENDING]

Blockers:
  ⛔ BLK-1 "PDF library license" [ACTIVE] — blocks this item
```

8. **Summarize**: is this item safe to start/continue? What is blocking it (if anything)?

## Important

- Use ✓ for DONE, ⚠ for in-flight (APPROVED/PLANNED/IN_PROGRESS/REVIEW), ✗ for DENIED/FAILED, · for PENDING
- Keep the tree concise — max 3 levels deep in each direction
