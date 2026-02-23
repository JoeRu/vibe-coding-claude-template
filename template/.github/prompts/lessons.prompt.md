---
description: 'Show lessons learned from past implementation items, optionally filtered by category.'
name: 'Lessons learned'
argument-hint: '[category: technologie | architektur | sicherheit | testing | prozess]'
agent: 'agent'
---

Show lessons learned from past implementation items.

**Arguments:** `$ARGUMENTS` (optional: category filter — `technologie`, `architektur`, `sicherheit`, `testing`, `prozess`)

## Steps

1. **Read** `ai-docs/lessons-learned.md`.
   - If the file does not exist: inform the user that no lessons have been recorded yet. Suggest archiving completed items to populate this knowledge base.

2. **If no argument**: display all lessons grouped by category.

3. **If a category argument is provided**: display only the lessons under the matching category heading (case-insensitive match).

4. **Output format:**

```
Lessons Learned  [category: {filter or "all"}]
Last updated: YYYY-MM-DD

## Technologie
  L-1 (2026-02-21, item-42): GitHub gives no email scope by default — request it explicitly.

## Architektur
  L-2 (2026-02-22, item-53): Queue-based processing required for async workloads > 10 pages.

...
```

5. **If the category argument matches no heading or has no entries**: inform the user and list available categories.

## Important

- This is a read-only command — do NOT modify `lessons-learned.md`
- Lessons are extracted automatically during archival from item `<r><lessons-learned>` blocks
