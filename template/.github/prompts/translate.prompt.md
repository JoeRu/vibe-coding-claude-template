---
description: 'Decompose a REQUIREMENT item into an EPIC with child FEATURE and ENABLER items.'
name: 'Translate requirement'
argument-hint: 'REQUIREMENT item ID.'
agent: 'agent'
---
<!-- GENERATED FILE — do not edit directly.
     Source:   .claude/commands/translate.md
     Metadata: scripts/copilot-headers.json
     Regenerate: python3 scripts/generate-copilot-prompts.py -->

**Translate** a REQUIREMENT item into an EPIC with child FEATURE and ENABLER items (PO + DA collaboration).

**Arguments:** `$ARGUMENTS` (one REQUIREMENT item ID)

## Execution Backend (XML Writes)

- Use `python3 ai-docs/plan_manager.py translate --requirement-id <ID>` to create EPIC/FEATURE entries from REQUIREMENT.
- Optional: `--features <N>` to control generated feature count.
- Use global `--json` for generated ID lists.

## Steps

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** item ID from `$ARGUMENTS`.
3. **Verify** the item exists and has `type="requirement"`.
4. **Analyze** the requirement description and codebase context to decompose it:
   - What business capabilities does this requirement enable? (PO perspective)
   - What technical capabilities are needed to deliver them? (DA perspective)
   - What are the technical prerequisites (enablers)?
5. **Create EPIC** (if the requirement is large enough to warrant one):
   - `type="epic"`, `complexity="XL"`, `parent` not set
   - Include `<acceptance-criteria>` derived from the requirement
   - Link to requirement via `depends-on`
6. **Create FEATURE items** as children of the EPIC:
   - Each feature = one deliverable capability
   - `type="feature"`, `parent="<epic-ID>"`, `complexity="M"` or `"L"`
   - Include `<capabilities>` blocks with capability type and description
7. **Create ENABLER items** for each technical prerequisite:
   - `type="enabler"`, add `mapped-to-feature="<feature-ID>"`
   - Must be created before the feature that depends on them
8. **Link dependencies**: features `depends-on` their enablers; epic `depends-on` requirement.
9. **Mark** the original REQUIREMENT as `status="APPROVED"` (it is now translated).
10. **Update changelog** with a summary of all items created.
11. **Confirm** to user: EPIC ID, list of FEATURE and ENABLER IDs, dependency graph.

## Important

- Respect the 5-item limit: if decomposition yields more than 5 new items, create the EPIC and first 2-3 features, then ask the user whether to continue
- Enablers must come before their dependent features in the dependency graph
- Keep XML valid
