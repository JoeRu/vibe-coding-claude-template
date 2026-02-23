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

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`. Verify the item exists and has `status="APPROVED"`.
3. **Analyze** the item's title, justification, and existing tasks against the codebase.
4. **Define technical parameters** (DA-CAP-01):
   - Identify constraints (performance, memory, compatibility, licensing)
   - Define NFRs (non-functional requirements: latency, availability, security)
   - Recommend patterns and implementation approach
5. **Create or refine tasks** – break down into concrete, ordered steps. Each task should be completable by a single developer in ≤ 1 day.
6. **Run security assessment** (DA-CAP-04):
   - Evaluate threat categories: AUTH, INPUT, DATA, NETWORK, CRYPTO, ACCESS, DISCLOSURE
   - If any apply: ensure `security="true"` and `<security-impact>` block are present
7. **Check for enabler items** – if the item requires infrastructure/tooling not yet in place, create ENABLER items (PENDING) and reference them in `depends-on`.
8. **Add optional role-context blocks** to the item XML:
   - `<capabilities>` – list technical/organizational capabilities this item delivers
   - `<technical-parameters>` – constraints, NFRs, patterns
   - `<acceptance-criteria>` – if not already present, derive from justification
9. **Set** `status="PLANNED"`.
10. **Add workflow-log entry**: `role="DA" action="planned" from-status="APPROVED" to-status="PLANNED"`.
11. **Update changelog** in `overview-features-bugs.xml`.
12. **Confirm** to user: item ID, title, PLANNED, list of tasks, any new enabler items created.

## Important

- Only APPROVED items can be planned
- Tasks must be specific and actionable — avoid vague tasks like "implement the feature"
- Security assessment is mandatory; even if no concerns apply, note that it was evaluated
- If enabler items are created, they must be APPROVED before this item can start
- Keep XML valid
