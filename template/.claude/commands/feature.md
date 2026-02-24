Create a **feature, epic, enabler, or requirement item** in the implementation plan. Item creation includes inline DA enrichment — the user sees a fully-planned item and only needs to `/approve` to proceed.

**Arguments:** `$ARGUMENTS` (description with optional modifiers)

## Phase 1 – Item Creation

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml` in parallel.
2. **Parse** the description from `$ARGUMENTS`. Extract optional modifiers:
   - `!critical`, `!high`, `!medium`, `!low` → override priority (default: MEDIUM)
   - `!security` → mark as security-relevant
   - `@<ID>` → set `depends-on`
   - `^<ID>` → set `parent` (sub-item of epic)
   - `--epic` → create as `type="epic"` (XL complexity, no tasks, has acceptance-criteria)
   - `--enabler` → create as `type="enabler"` (add `mapped-to-feature` if `^<ID>` provided)
   - `--requirement` → create as `type="requirement"` (raw user need — skip Phase 2; suggest `/translate` after)
3. **Search** existing items for duplicates. If found: inform user, update if needed; stop.
4. **Create the skeleton item**: `status="PENDING"`, default `priority="MEDIUM"`, next sequential ID, estimated complexity.
5. **Update `<changelog>`** and write the item to XML.

## Phase 2 – DA Enrichment (inline, before showing the item to the user)

Skip this phase for `--epic` (XL items must be decomposed first via `/translate`) and `--requirement` types.

6. **Read source files in parallel** — files referenced by related features in `overview.xml` and any files matching the item's domain. Never form technical opinions before reading.
7. **Consult** `ai-docs/lessons-learned.md` if it exists — identify applicable L-N IDs for this domain.
8. **Populate `<tasks>`** — concrete, ordered `<task>` entries; each completable by one developer in ≤ 1 day.
9. **Populate `<technical-parameters>`**:
   - `<constraint>` — hard limits (performance, memory, compatibility, licensing)
   - `<nfr type="performance|reliability|scalability|maintainability">` — measurable NFRs
   - `<pattern>` — recommended approach; cite applicable L-N lesson IDs here
10. **Populate `<verification>`** — `<tests>` with concrete, runnable test specifications.
11. **Security assessment** — evaluate AUTH, INPUT, DATA, NETWORK, CRYPTO, ACCESS, DISCLOSURE:
    - If `!security` modifier or any category applies: set `security="true"`, populate `<security-impact>` with `<category>`, `<threat>`, `<mitigation>`
    - Note the evaluation outcome even when no categories apply
12. **Impact check**: identify existing features potentially affected. Warn if any have `completeness != FULL` or `test-coverage == NONE`.
13. **If ENABLER items are needed** (technical prerequisites missing): note them for the user; create them only if clearly required.

## Output

Display the complete enriched item for user review. The item stays `status="PENDING"` — run `/approve <ID>` to confirm and proceed to implementation.

## Important

- Items stay PENDING until the user runs `/approve` — enrichment does not auto-approve
- XL items and epics: skip Phase 2; use `/translate <ID>` to decompose first
- Always search for duplicates before creating
- Keep XML valid at all times
