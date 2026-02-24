Create a **tech-debt item** in the implementation plan. Includes inline technical analysis so the user sees a fully-planned item before `/approve`.

**Arguments:** `$ARGUMENTS` (tech-debt description with optional modifiers)

## Phase 1 – Item Creation

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml` in parallel.
2. **Parse** the description from `$ARGUMENTS`. Extract optional modifiers:
   - `!critical`, `!high`, `!medium`, `!low` → override priority (default: LOW)
   - `!security` → mark as security-relevant
   - `@<ID>` → set `depends-on`
   - `^<ID>` → set `parent` (sub-item of epic)
3. **Search** existing items for duplicates. If found: inform user, update if needed; stop.
4. **Create the skeleton item**: `type="tech-debt"`, `status="PENDING"`, `priority="LOW"` (default), next sequential ID, estimated complexity.
5. **Update `<changelog>`** and write the item to XML.

## Phase 2 – DA Enrichment (inline, before showing to user)

6. **Read affected source files in parallel** — files identified from the description and related features in `overview.xml`.
7. **Consult** `ai-docs/lessons-learned.md` for applicable L-N IDs (architecture, scalability, maintainability lessons).
8. **Populate `<justification>`** — describe the compromise made originally and the cost of leaving it unresolved.
9. **Populate `<tasks>`** — concrete, ordered `<task>` entries; describe the remediation steps clearly.
10. **Populate `<technical-parameters>`** — constraints (no feature regression, migration path if data is involved), NFRs improved by this cleanup, relevant patterns.
11. **Populate `<verification>`** — `<tests>` confirming the debt is resolved and no regressions introduced.
12. **Security assessment** — tech-debt often hides security issues; evaluate all 7 categories.
13. **Impact check**: identify features sharing the affected files; note remediation risk.

## Output

Display the enriched item for user review. Stays `status="PENDING"` — run `/approve <ID>` to proceed.

## Important

- Items stay PENDING until the user runs `/approve`
- Always search for duplicates first; tech-debt is easily duplicated under different names
- Keep XML valid at all times
