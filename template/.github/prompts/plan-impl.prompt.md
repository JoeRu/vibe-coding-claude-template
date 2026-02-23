---
description: 'Attach an implementation plan to an APPROVED item (DA role). Transitions to PLANNED.'
name: 'Plan implementation'
argument-hint: 'Item ID.'
agent: 'agent'
---
<!-- GENERATED FILE — do not edit directly.
     Source:   .claude/commands/plan-impl.md
     Metadata: scripts/copilot-headers.json
     Regenerate: python3 scripts/generate-copilot-prompts.py -->

Attach an **implementation plan** to an APPROVED item (DA role). Transitions status to PLANNED.

**Arguments:** `$ARGUMENTS` (one item ID)

## Steps

1. **Read** `ai-docs/overview.xml`, `ai-docs/overview-features-bugs.xml`, and `ai-docs/implementation-plan-template.xml` in parallel.
2. **Locate the item** by `$ARGUMENTS` ID. Verify `status="APPROVED"`.
3. **Analyze** the item's `<title>`, `<justification>`, and existing `<tasks>` against the codebase. Read source files referenced in or related to the item in parallel — never speculate about code you haven't read.
4. **Consult** `ai-docs/lessons-learned.md` if it exists. Identify lessons relevant to the item's technology, architecture, or domain; reference applicable L-N IDs in `<technical-parameters>`.
5. **Populate `<technical-parameters>`**:
   - `<constraint>` — hard limits (performance, memory, compatibility, licensing)
   - `<nfr type="performance|reliability|scalability|maintainability">` — measurable NFRs
   - `<pattern>` — recommended implementation approach; cite relevant L-N lessons here
6. **Create or refine `<tasks>`** — concrete, ordered `<task>` entries; each completable by one developer in ≤ 1 day.
7. **Run security assessment** — evaluate all 7 categories: AUTH, INPUT, DATA, NETWORK, CRYPTO, ACCESS, DISCLOSURE. If any apply: set `security="true"` and populate `<security-impact>`. Note the evaluation outcome even when no concerns apply.
8. **Create ENABLER items** if technical prerequisites are missing; add their IDs to `<depends-on>`.
9. **Add optional context blocks** if not already present:
   - `<capabilities>` — capabilities this item delivers
   - `<acceptance-criteria>` — derive from `<justification>` if missing
10. **Set** `status="PLANNED"`.
11. **Add `<workflow-log>` entry**: `role="DA" action="planned" from-status="APPROVED" to-status="PLANNED"`.
12. **Update `<changelog>`** in `overview-features-bugs.xml`.
13. **Confirm** to user: item ID, `<title>`, status PLANNED, `<tasks>` list, any new ENABLER IDs.

## Important

- Only `status="APPROVED"` items can be planned
- `<task>` entries must be specific and actionable — avoid vague entries like "implement the feature"
- Security assessment covers every item; record the evaluation even when no categories apply
- ENABLER items must be APPROVED before this item can start
- Keep XML valid at all times
