# Implementation Plan Workflow

## Overview

This project uses a structured XML-based implementation plan to track all features, bugs, refactoring, and tech-debt. The plan is the single source of truth for what exists, what's planned, and what's been decided against.

A separate `overview.xml` captures the project's architectural baseline – structure, dependencies, existing features, and security concerns. It is created during the initial code analysis and kept in sync as items are archived.

## Files & Locations

| File | Purpose | When updated |
|---|---|---|
| `ai-docs/overview.xml` | Project architecture, dependencies, environments, security, completed features | Initial analysis + every archival |
| `ai-docs/overview-features-bugs.xml` | Active and pending items (features, bugs, refactoring, tech-debt) | Every interaction that changes scope or code |
| `ai-docs/implementation-plan-template-v3.1.xml` | Schema reference (do not edit) | Never |
| `ai-docs/` | All other markdown and planning documents | As needed |

## Initial Code Analysis

When first encountering a project (no `overview.xml` exists), perform a full code analysis before any other work:

### Steps

1. **Scan the codebase**: directory structure, languages, frameworks, config files, package manifests
2. **Identify architecture**: patterns, layers, entry points, data flow
3. **Catalog dependencies**: system requirements (runtime, OS) and external dependencies (APIs, databases, services)
4. **Map existing features**: what the code already does – derive from routes, modules, tests, README
5. **Note interfaces**: inbound (APIs, UIs, webhooks) and outbound (external calls, queues, file outputs)
6. **Check for security concerns**: auth mechanisms, exposed secrets, input validation, known vulnerability patterns
7. **Detect environments**: dev/staging/prod configurations, environment variables, deploy scripts

### Output

Generate `ai-docs/overview.xml` with the full project baseline:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project-overview>
  <metadata>
    <title>Project Title</title>
    <version>1.0</version>
    <analyzed>2026-02-08</analyzed>
    <updated>2026-02-08</updated>
    <repository>https://github.com/org/repo</repository>
  </metadata>

  <architecture>
    <description>Overall architecture description</description>
    <patterns>
      <pattern>e.g. MVC, Event-Driven</pattern>
    </patterns>
    <system-requirements>
      <requirement>e.g. Node.js >= 20</requirement>
    </system-requirements>
    <external-dependencies>
      <dependency>e.g. PostgreSQL 16, Stripe API</dependency>
    </external-dependencies>
    <interfaces>
      <interface type="inbound|outbound">Description</interface>
    </interfaces>
    <design-decisions>
      <decision date="2026-02-08">Decision and rationale</decision>
    </design-decisions>
  </architecture>

  <environments>
    <environment name="dev">Setup notes</environment>
    <environment name="staging">Details</environment>
    <environment name="prod">Details</environment>
  </environments>

  <security>
    <concern>
      <threat>Threat description</threat>
      <risk>LOW|MEDIUM|HIGH|CRITICAL</risk>
      <vulnerability>Potential vulnerability</vulnerability>
      <mitigation>How addressed</mitigation>
    </concern>
  </security>

  <!-- Completed features – populated from initial analysis and archival -->
  <completed-features>
    <feature id="CF1" completed="2026-02-08">
      <title>Feature title</title>
      <description>What it does</description>
      <files>
        <file>path/to/relevant/file</file>
      </files>
    </feature>
  </completed-features>
</project-overview>
```

Also generate `ai-docs/overview-features-bugs.xml` with any identified issues, improvements, or TODOs as items with `status="PENDING"`.

If `overview.xml` already exists, **read it** at the start of every session for project context.

## Core Rules

### 1. Always Check Before Acting

Before implementing ANY user request (feature, bug, change, question about the codebase):

1. **Read** `ai-docs/overview.xml` (project context)
2. **Read** `ai-docs/overview-features-bugs.xml` (active items)
3. **Search** for existing items that match the request (by title, description, related files, or affected area)
4. **Decide**:
   - **Existing item found** → update that item (status, tasks, details) rather than creating a duplicate
   - **No match** → create a new item with `status="PENDING"`
5. **Inform the user** which item ID was created or updated

### 2. Always Update the Plan

Every interaction that involves code changes, bug reports, or feature discussion **must** result in an update to `overview-features-bugs.xml`. This includes:

- New feature requests → new `<item type="feature" status="PENDING">`
- Bug reports → new `<item type="bug" status="PENDING">`
- Scope changes → update existing item's tasks, acceptance-criteria, or justification
- Implementation progress → update status (`PENDING` → `APPROVED` → `IN_PROGRESS` → `DONE`)
- Bugs found during implementation → new `<item type="bug">` with `depends-on` referencing the parent item
- Verification results → fill `<r>` block with outcome, observations, lessons-learned, files

### 3. Default Status is PENDING

All new items are created with `status="PENDING"`. The user must explicitly approve before implementation begins. Never skip to `APPROVED` or `IN_PROGRESS` without user confirmation.

Status lifecycle:
```
PENDING ──→ APPROVED ──→ IN_PROGRESS ──→ DONE
   │
   └──→ DENIED
```

### 4. ID Assignment

- Read the current highest ID in `overview-features-bugs.xml`
- Assign the next sequential integer
- Sub-items use the parent ID as prefix for tasks: item 15 → tasks `15.1`, `15.2`, etc.

### 5. Complexity & Decomposition

Estimate complexity for every new item:
- **S** = isolated change, single file, < 1 day
- **M** = few files, clear scope, 1–3 days
- **L** = cross-cutting, multiple components, 3–7 days
- **XL** = epic-level → **must** be decomposed into sub-items with `parent="ID"`

If an item is XL: create the epic with `<acceptance-criteria>` and create sub-items with individual tasks. Do not put tasks directly on XL items.

### 6. Branch Naming Convention

Branches follow the pattern `{type}/item-{ID}-{slug}`:

```
feature/item-12-oauth-integration
bug/item-20-auth-race-condition
refactoring/item-35-cleanup-token-cache
tech-debt/item-41-migrate-to-v2-api
```

Rules:
- **Slug**: max 5 words, kebab-case, derived from the item title
- **Sub-items**: use the parent's branch (they work on the same feature)
- **Auto-fill**: populate `<branch>` in XML when status changes to `APPROVED`
- **No branch** for DENIED or PENDING items

### 7. Changelog

Update the `<changelog>` block in `overview-features-bugs.xml` **once per interaction** (not per item change). Group all changes from the same interaction into a single entry.

Format:
```xml
<changelog>
  <entry date="2026-02-08">Items 12, 14 created (PENDING). Item 3 → IN_PROGRESS.</entry>
  <entry date="2026-02-07">Item 10 → DONE, archived. Bug item 20 created from verification.</entry>
</changelog>
```

No entry for read-only interactions (Claude reads the plan but changes nothing).

### 8. Max Items per Interaction

Soft limit: **5 items** created or updated per response.

- **Create**: max 5 new items
- **Update**: max 5 existing items
- **Mixed**: max 5 total (creates + updates combined)
- **Overflow**: list remaining items as preview, ask user whether to continue
- **Exception**: initial project analysis (first-time plan creation) has no limit

### 9. Archival

Completed and denied items are moved to the `<archive>` block in `overview-features-bugs.xml` and simultaneously registered in `overview.xml`.

**When to archive:**
- `DONE` items: when the item AND all its sub-items are DONE, AND no active item has a `depends-on` referencing it
- `DENIED` items: immediately (no dependencies possible)

**Archival process (both files updated in one step):**

1. **Move** the item from the active section to `<archive>` in `overview-features-bugs.xml`:
   ```xml
   <archive>
     <item id="1" status="DONE" archived="2026-02-08" ...>
       <!-- full item preserved for history -->
     </item>
   </archive>
   ```

2. **Add** a `<completed-features>` entry in `overview.xml` (for DONE items only):
   ```xml
   <completed-features>
     <feature id="CF-1" completed="2026-02-08" source-item="1">
       <title>Feature title (from item)</title>
       <description>Brief summary of what was built and why</description>
       <files>
         <file>path/to/file (from item's result block)</file>
       </files>
     </feature>
   </completed-features>
   ```

3. **Update** `<metadata><updated>` in `overview.xml` with the current date

4. **Update** architecture, dependencies, or security sections in `overview.xml` if the archived item introduced changes to any of these

**Do not archive** items that are still referenced by active `depends-on`.

## XML Structure Quick Reference

```xml
<!-- Simple feature or bug -->
<item id="N" type="feature|bug|refactoring|tech-debt" status="PENDING" priority="CRITICAL|HIGH|MEDIUM|LOW" complexity="S|M|L|XL">
  <title>Short descriptive title</title>
  <branch>type/item-N-slug</branch>
  <justification>Why this is needed</justification>
  <depends-on>comma-separated item IDs or empty</depends-on>
  <tasks>
    <task id="N.1">Task description</task>
  </tasks>
  <verification>
    <tests>
      <test type="unit|integration|e2e|human">
        <file>path/to/test</file>
        <description>What is tested</description>
        <assertions>Expected behavior</assertions>
      </test>
    </tests>
  </verification>
  <r>
    <outcome>DONE|PROBLEM</outcome>
    <observations></observations>
    <lessons-learned></lessons-learned>
    <files><file>path/to/file</file></files>
  </r>
</item>

<!-- Epic (XL) with acceptance criteria -->
<item id="N" type="feature" status="PENDING" priority="HIGH" complexity="XL">
  <title>Epic title</title>
  <acceptance-criteria>
    <criterion id="AC1">Measurable criterion</criterion>
  </acceptance-criteria>
  <risks>
    <risk>Risk and mitigation</risk>
  </risks>
</item>

<!-- Sub-item of epic -->
<item id="N+1" type="feature" status="PENDING" priority="HIGH" complexity="M" parent="N">
  <title>Sub-feature of epic</title>
  <depends-on>N</depends-on>
  ...
</item>

<!-- Complex bug with analysis -->
<item id="N" type="bug" status="PENDING" priority="HIGH" complexity="L">
  <steps-to-reproduce>
    <step order="1">Step description</step>
  </steps-to-reproduce>
  <expected-result>What should happen</expected-result>
  <analysis>
    <hypothesis id="H1" status="OPEN|CONFIRMED|REJECTED">Description</hypothesis>
    <root-cause>When identified</root-cause>
    <affected-files><file>path</file></affected-files>
  </analysis>
</item>
```

## Workflow Summary

```
First encounter (no overview.xml)
     │
     ▼
Scan codebase → generate overview.xml + overview-features-bugs.xml
     │
     ▼
─────────────────────────────────────────────────────
     │
Every subsequent request
     │
     ▼
Read overview.xml + overview-features-bugs.xml
     │
     ├─ Existing item? ──→ Update item (status, tasks, details)
     │
     └─ New request? ──→ Create item with status="PENDING"
                              │
                              ▼
                    Inform user of item ID
                              │
                              ▼
                    Wait for user approval
                              │
                    ┌─────────┴─────────┐
                    ▼                   ▼
              APPROVED              DENIED
                    │                   │
                    ▼                   ▼
              Implement          Archive immediately
                    │
                    ▼
              Verify & update <r> block
                    │
                    ▼
              Status → DONE
                    │
                    ▼
              Archive if no active dependents
                    │
                    ├──→ Move to <archive> in overview-features-bugs.xml
                    └──→ Add to <completed-features> in overview.xml
```

## Important Reminders

- **Never implement without checking both XML files first**
- **Never create duplicate items** – always search existing items before adding
- **Never skip PENDING** – the user decides what gets built
- **Always update `<r>` after implementation** – outcomes and lessons-learned are mandatory
- **Always archive to both files** – overview.xml stays in sync with completed work
- **Keep the XML valid** – malformed XML breaks the workflow
- **Respect the 5-item limit** – ask before processing more
- **Update changelog once per interaction** – grouped, not per item
- When in doubt about priority or complexity, **ask the user**
