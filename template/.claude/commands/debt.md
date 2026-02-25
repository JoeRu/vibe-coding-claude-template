Create a **tech-debt item** in the implementation plan. Includes inline technical analysis so the user sees a fully-planned item before `/approve`.

**Arguments:** `$ARGUMENTS` (tech-debt description with optional modifiers)

## Phase 1 – Item Creation

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml` in parallel.
2. **Parse** the description from `$ARGUMENTS`. Extract optional modifiers:
   - `!critical`, `!high`, `!medium`, `!low` → override priority (default: LOW)
   - `!security` → mark as security-relevant
   - `@<ID>` → set `depends-on`
   - `^<ID>` → set `parent` (sub-item of epic)
   - `!run` → short-path: auto-approve after enrichment and execute immediately (see Phase 3)
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

## Phase 3 – Auto-run (only when `!run` modifier is present)

Skip this phase when `!run` is not set — the item stays `status="PENDING"` and waits for `/approve`.

After Phase 2 completes:

14. **Guard**: if complexity is `XL`, abort Phase 3 — set `status="PENDING"` and warn: `"!run is not allowed on XL items."`.
15. **Auto-approve**: set `status="APPROVED"`. The `!run` modifier IS the user's explicit approval.
    - Generate branch name per the branch naming convention and set `<branch>`.
    - Add `<workflow-log>` entry: `role="PO" action="auto-approved" from-status="PENDING" to-status="APPROVED" note="!run short-path"`.
    - Update `<changelog>`.
16. **Announce**: `"Item N auto-approved via !run — executing..."`.
17. **Execute**: run the full `/run` logic for this item (Phases 2 and 3 of `run.md`).

## Output

**Without `!run`:** Display the enriched item for user review. Stays `status="PENDING"` — run `/approve <ID>` to proceed.

**With `!run`:** Display enrichment summary, then proceed directly to execution output.

## Important

- Items stay PENDING until the user runs `/approve` **unless `!run` is set** — `!run` is the user's in-command approval
- `!run` is blocked on XL complexity items
- Always search for duplicates first; tech-debt is easily duplicated under different names
- Keep XML valid at all times
