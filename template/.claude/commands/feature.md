Create a **feature, epic, enabler, or requirement item** in the implementation plan.

**Arguments:** `$ARGUMENTS` (description with optional modifiers)

## Steps

1. **Read** `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`.
2. **Parse** the description from `$ARGUMENTS`. Extract optional modifiers:
   - `!critical`, `!high`, `!medium`, `!low` → override priority (default: MEDIUM)
   - `!security` → mark as security-relevant
   - `@<ID>` → set `depends-on`
   - `^<ID>` → set `parent` (sub-item of epic)
   - `--epic` → create as `type="epic"` (XL complexity, no tasks, has acceptance-criteria)
   - `--enabler` → create as `type="enabler"` (add `mapped-to-feature` if `^<ID>` provided)
   - `--requirement` → create as `type="requirement"` (raw user need, suggest `/translate` after)
3. **Search** existing items for duplicates matching the description.
4. **If duplicate found** → inform user, update existing item if needed.
5. **If no duplicate** → create new item:
   - Default `type="feature"` (or per modifier above), `status="PENDING"`, default `priority="MEDIUM"`
   - Assign next sequential ID
   - Estimate complexity (S/M/L/XL)
     - `--epic` forces `complexity="XL"` → add `<acceptance-criteria>`, no tasks
     - XL without `--epic` → treat as epic automatically
   - If `!security`: add `security="true"`, populate `<security-impact>` with `<category>`, `<threat>`, `<mitigation>`
   - For features: add `<justification>`, `<tasks>`, `<verification>` blocks
   - For enablers: add `mapped-to-feature` attribute if parent feature ID given via `^<ID>`
   - For requirements: add `<justification>` only; note that `/translate` will decompose into EPICs and FEATUREs
6. **Impact check**: identify which existing features could be affected. Warn if any have `completeness != FULL` or `test-coverage == NONE`.
7. **Update changelog** in `overview-features-bugs.xml`.
8. **Confirm** to user: item ID, title, type, priority, status, complexity. For requirements: remind user to run `/translate <ID>` to decompose.

## Important

- Never skip `status="PENDING"`
- Always search for duplicates first
- XL features and epics must be decomposed into sub-items with `parent="ID"`
- Respect the 5-item-per-interaction limit
- Keep XML valid
