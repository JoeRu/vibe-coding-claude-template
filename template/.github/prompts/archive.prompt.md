---
description: 'Archive eligible DONE and DENIED items from the implementation plan.'
name: 'Archive items'
argument-hint: 'No arguments.'
agent: 'agent'
---

**Archive** all eligible DONE and DENIED items from the implementation plan.

## Steps

### 1. Read Files

- Read `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
- Check whether `ai-docs/overview-features-bugs-archive.xml` exists.

### 2. Initialize Archive File (if missing)

If `ai-docs/overview-features-bugs-archive.xml` does not exist, create it now:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<plan-archive>
  <metadata>
    <created>YYYY-MM-DD</created>
    <updated>YYYY-MM-DD</updated>
    <source>overview-features-bugs.xml</source>
  </metadata>
  <archive></archive>
  <changelog-history></changelog-history>
</plan-archive>
```

### 3. Identify Eligible Items

- `DONE` items: the item AND all its sub-items must be DONE, AND no active item has `depends-on` referencing it.
- `DENIED` items: archive immediately (should already be archived by deny, but catch any missed ones).

### 4. For Each Eligible Item

**a. Move** the item from the active section of `overview-features-bugs.xml` to `<archive>` in `overview-features-bugs-archive.xml` with `archived="{today's date}"`. Do NOT keep it in the main file's active section.

**b. Lessons extraction** (for DONE items only):
- Read the item's `<r><lessons-learned>` content.
- Skip if empty or trivially uninformative.
- For non-trivial lessons: determine category — one of: `Technologie`, `Architektur`, `Sicherheit`, `Testing`, `Prozess`.
- Append to `ai-docs/lessons-learned.md` (create if missing) with next sequential L-N ID.

**c. For DONE items:** add a `<completed-features>` entry in `overview.xml`:
- `id="CF-{item-id}"`, `completed="{date}"`, `source-item="{item-id}"`
- Include title, description, files from the item's `<r>` block

**d. For security items:** update `<security>` section in `overview.xml`:
- DONE security items: evaluate if mitigation resolved the concern
- DENIED security items: note that vulnerability is unaddressed

### 5. Changelog Rotation

After processing all items, count `<entry>` elements in `<changelog>` of `overview-features-bugs.xml`:
- If count > 30: move the oldest entries (beyond the 30 most recent) to `<changelog-history>` in `overview-features-bugs-archive.xml`.
- Always keep exactly ≤ 30 entries in the main file.

### 6. Sprint/Release Check

Check for active SPRINT items in `overview-features-bugs.xml`:
- If a sprint exists and ALL scope items are DONE: set sprint to COMPLETED, gate `code-complete` to PASSED.

### 7. Full-Test Trigger Check

Read `<done-since-last-fulltest>` from `<metadata>` in `overview-features-bugs.xml`:
- Increment by the count of DONE items archived in this run.
- If counter ≥ 5, last full-test > 14 days ago, or sprint just completed:
  - Output: *"N items archived since last full test. Recommendation: run the full-test prompt to validate overall project quality."*
- Write updated counter back to `<metadata>`.

### 8. Update Metadata

- Update `<metadata><updated>` in all modified files.

### 9. Update Changelog

Add a single changelog entry in `overview-features-bugs.xml` summarizing this archival run.

### 10. Report to User

- Number of items archived
- Lessons extracted (L-N IDs) added to `ai-docs/lessons-learned.md`
- Items that could NOT be archived (and why: active dependents, sub-items not done)
- Changes to `overview.xml`
- Full-test recommendation (if triggered)

## Lessons-Learned File Format

If `ai-docs/lessons-learned.md` does not exist, create it:

```markdown
# Lessons Learned

> Auto-generated and maintained by the DA agent. Last updated: YYYY-MM-DD.

## Technologie

## Architektur

## Sicherheit

## Testing

## Prozess
```

New lesson entry format:

```markdown
- **L-N** (YYYY-MM-DD, item-ID): Lesson text extracted from <lessons-learned>.
```

## Important

- **Do NOT keep archived items in `overview-features-bugs.xml`** — move them to `overview-features-bugs-archive.xml`
- **Changelog rotation**: main file keeps ≤ 30 entries; older entries move to archive file's `<changelog-history>`
- Do NOT archive items still referenced by active `depends-on`
- Always update BOTH `overview.xml` AND `overview-features-bugs-archive.xml`
- Keep all XML files valid at all times
