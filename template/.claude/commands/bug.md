Create a **bug or problem item** in the implementation plan. Includes inline root-cause analysis and fix planning so the user sees a fully-analyzed item before `/approve`.

**Arguments:** `$ARGUMENTS` (description with optional modifiers)

## Phase 1 – Item Creation

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml` in parallel.
2. **Parse** the description from `$ARGUMENTS`. Extract optional modifiers:
   - `!critical`, `!high`, `!medium`, `!low` → override priority (default: HIGH for bugs)
   - `!security` → mark as security-relevant
   - `@<ID>` → set `depends-on`
   - `^<ID>` → set `parent` (sub-item of epic)
   - `--problem` → create as `type="problem"` (systemic/environmental issue, not a code defect)
3. **Search** existing items for duplicates. If found: inform user, update if needed; stop.
4. **Create the skeleton item**: `status="PENDING"`, `priority="HIGH"` (default), next sequential ID, estimated complexity.
   - For bugs: add `<steps-to-reproduce>`, `<expected-result>`, `<analysis>` with initial hypothesis from description
   - For problems: add `<justification>` describing the systemic issue and its impact
   - If `!security`: set `security="true"`, prefix title with `[SECURITY]`
5. **Update `<changelog>`** and write the item to XML.

## Phase 2 – DA Enrichment (inline bug analysis)

6. **Read suspected source files in parallel** — files related to the reported symptom, referenced features in `overview.xml`, and any files mentioned in the description.
7. **Enrich `<analysis>`** — add code-based hypotheses; update or confirm the initial hypothesis with evidence from the code.
8. **Populate `<tasks>`** — root-cause investigation steps + fix implementation steps.
9. **Populate `<verification>`** — `<tests>` that confirm the bug is fixed and no regressions are introduced.
10. **Security assessment** — if `!security` or any AUTH/INPUT/DATA/NETWORK/CRYPTO/ACCESS/DISCLOSURE category applies: populate `<security-impact>`.
11. **Impact check**: identify which existing features could be affected; warn if any have `completeness != FULL` or `test-coverage == NONE`.

## Output

Display the enriched bug item for user review. The item stays `status="PENDING"` — run `/approve <ID>` to proceed.

## Important

- Items stay PENDING until the user runs `/approve`
- PROBLEM items are for systemic issues (environment, process, architecture) — not code defects; skip Phase 2 for PROBLEM items
- Always search for duplicates first
- Keep XML valid at all times
