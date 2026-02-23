# Role-Based Workflow

This chapter defines the five AI roles used in this workflow, their capabilities, item ownership, lifecycle gate authority, and the end-to-end flow between them.

Read this chapter alongside `CLAUDE-implementation-plan-chapter.md`. That chapter defines the XML rules and item mechanics; this chapter defines **who does what** at each gate.

---

## Roles and Capabilities

### Product Owner (PO)

**Domain:** Business value, requirements, prioritization

| Capability | Description |
|---|---|
| `requirement-elicitation` | Extract, clarify, and document requirements from user conversations |
| `priority-assignment` | Assign and adjust priority levels (CRITICAL / HIGH / MEDIUM / LOW) |
| `capability-translation` | Translate business needs into capability descriptions (with DA) |
| `backlog-planning` | Create and groom backlog items (REQUIREMENT, EPIC, FEATURE) |
| `acceptance-definition` | Define acceptance criteria for features and epics |
| `stakeholder-approval` | Approve or deny items at PENDING gate |
| `scope-negotiation` | Negotiate scope changes, deferrals, and trade-offs |

**Item ownership:** REQUIREMENT, EPIC, FEATURE (business side)
**Gates:** PENDING → APPROVED (with user confirmation), REVIEW → DONE (approval)

---

### Scrum Master (SM)

**Domain:** Process governance, flow, impediment removal

| Capability | Description |
|---|---|
| `status-management` | Transition item statuses according to lifecycle rules |
| `process-sync` | Synchronize work across roles; ensure handoffs happen |
| `blocker-resolution` | Identify, escalate, and track blockers |
| `release-management` | Initiate, coordinate, and track release cycles |
| `sprint-management` | Create, track, and close sprint groupings (SPRINT type) |
| `archive-management` | Move DONE/DENIED items to archive file; maintain changelog rotation |
| `dependency-tracking` | Track and flag cross-item dependencies and sequencing |

**Item ownership:** All item types (status transitions only), RELEASE, SPRINT, BLOCKER
**Gates:** IN_PROGRESS → REVIEW, REVIEW → DONE (with TST sign-off)

---

### DevSecOps Architect (DA)

**Domain:** Technical design, security, architecture, enablement

| Capability | Description |
|---|---|
| `technical-parameter-definition` | Define technical parameters, constraints, and NFRs |
| `enabler-creation` | Create ENABLER items (infrastructure, tooling, platform) |
| `architecture-documentation` | Build and maintain architecture overview (overview.xml) |
| `security-assessment` | Perform threat categorization and security impact assessments |
| `implementation-planning` | Analyze items and create detailed implementation plans |
| `technical-guidance` | Add implementation notes, patterns, and constraints to items |
| `dependency-analysis` | Identify technical dependencies, integration points, and risks |
| `knowledge-base-management` | Extract, categorize, and maintain lessons learned in `ai-docs/lessons-learned.md` |

**Item ownership:** ENABLER, FEATURE (technical side), TECH-DEBT, SECURITY-ITEM
**Gates:** APPROVED → PLANNED (implementation plan attached)

---

### Developer (DEV)

**Domain:** Implementation, unit testing

| Capability | Description |
|---|---|
| `code-implementation` | Write, modify, and refactor code per item specifications |
| `unit-test-creation` | Create unit tests covering the implementation |
| `task-execution` | Execute non-code tasks (config, migration, setup) |
| `self-verification` | Run unit tests locally and confirm basic functionality |
| `result-documentation` | Update item `<r>` block with outcomes, files changed |
| `branch-management` | Create, manage, and merge feature branches |

**Item ownership:** FEATURE (implementation), BUG (fix), ENABLER (build), REFACTORING
**Gates:** PLANNED → IN_PROGRESS → REVIEW (code complete + unit tests pass)

---

### Tester (TST)

**Domain:** Verification, validation, quality assurance

| Capability | Description |
|---|---|
| `unit-test-verification` | Verify unit tests against capability acceptance criteria |
| `integration-testing` | Run integration tests across related capabilities |
| `release-testing` | Execute full test suite on release candidates |
| `bug-creation` | Create BUG items with reproduction steps when tests fail |
| `regression-check` | Verify that fixes don't break existing capabilities |
| `test-result-documentation` | Document test runs, coverage, and pass/fail details |

**Item ownership:** BUG (creation), all items (verification)
**Gates:** REVIEW → DONE (test sign-off), REVIEW → FAILED (regression back to DEV)

---

## Item Type Hierarchy

```
REQUIREMENT (PO)
  └── EPIC (PO + DA)
        ├── FEATURE (PO + DA → DEV → TST)
        │     └── ENABLER (DA → DEV)
        ├── BUG (TST → DEV → TST)
        ├── PROBLEM (TST → SM + DA)
        └── TECH-DEBT (DA → DEV → TST)

RELEASE (SM)
  └── references: FEATURE[], BUG[], ENABLER[]

SPRINT (SM)
  └── references: FEATURE[], BUG[], ENABLER[] (lightweight grouping, no PO gates)

BLOCKER (SM)
  └── blocks: any item
```

| Type | Created By | Primary Handler | Description |
|---|---|---|---|
| `requirement` | PO | PO | Raw user need; decomposed into Epics/Features |
| `epic` | PO | PO, DA | Large capability grouping; parent of Features |
| `feature` | PO, DA | DA (plan), DEV (build), TST (verify) | Deliverable capability |
| `enabler` | DA | DA (plan), DEV (build) | Technical prerequisite mapped to a Feature |
| `bug` | TST, DEV | DEV (fix), TST (verify) | Defect found during testing or development |
| `problem` | TST | SM, DA, PO | Systemic or environmental issue requiring process/architecture change |
| `tech-debt` | DA | DEV (fix), TST (verify) | Known technical compromise to be addressed |
| `refactoring` | DA | DEV (build), TST (verify) | Structural improvement without behavior change |
| `security-item` | DA | DA (plan), DEV (fix), TST (verify) | Security vulnerability or hardening task |
| `release` | SM | SM, TST | Release coordination ticket (formal, with PO gates) |
| `sprint` | SM | SM, TST | Lightweight sprint grouping (2–5 items, no PO gates) |
| `blocker` | SM | SM, DA, PO | Impediment blocking other items |

---

## Enhanced Status Lifecycle

```
PENDING ──→ APPROVED ──→ PLANNED ──→ IN_PROGRESS ──→ REVIEW ──→ DONE ──→ ARCHIVED
   │                                                    │
   └──→ DENIED                               FAILED ──→ IN_PROGRESS
                                           (back to DEV with BUG item)
```

| Status | Gate Owner | Gate Condition |
|---|---|---|
| `PENDING` | PO | Item created, awaiting user/PO approval |
| `APPROVED` | PO + User | User confirmed; ready for planning |
| `PLANNED` | DA | Implementation plan, tasks, and technical guidance attached |
| `IN_PROGRESS` | DEV | Code/task work actively happening |
| `REVIEW` | TST | Code complete, unit tests pass, awaiting verification |
| `FAILED` | TST → DEV | Verification failed; returns to DEV — `/fail` creates a BUG item |
| `DONE` | SM | All tests pass, acceptance criteria met |
| `DENIED` | PO | Rejected at PENDING gate |
| `ARCHIVED` | SM | Moved to archive after DONE with no active dependents |

**Transitions and commands:**

| Transition | Command | Role |
|---|---|---|
| create → PENDING | `/feature`, `/bug`, `/debt`, `/refactor` | PO / DA / TST |
| PENDING → APPROVED | `/approve` | PO |
| PENDING → DENIED | `/deny` | PO |
| APPROVED → PLANNED | `/plan-impl` | DA |
| PLANNED → IN_PROGRESS | `/start` | SM |
| IN_PROGRESS → REVIEW | `/submit` | DEV |
| REVIEW → DONE | `/pass` | TST |
| REVIEW → FAILED | `/fail` | TST |
| FAILED → IN_PROGRESS | `/start` (re-open) | SM |
| DONE → ARCHIVED | `/archive` | SM |

---

## End-to-End Workflow

```
USER          PO              DA              SM            DEV           TST
 │             │               │               │              │             │
 ├─ request ──►│               │               │              │             │
 │             ├─ elicit       │               │              │             │
 │             │   reqs        │               │              │             │
 │             ├─ translate ──►│               │              │             │
 │             │               ├─ define tech  │              │             │
 │             │               │   parameters  │              │             │
 │             ├─ create ◄─────┤               │              │             │
 │             │   items       │               │              │             │
 │             │   [PENDING]   │               │              │             │
 │◄─ review ──┤               │               │              │             │
 ├─ approve ──►│               │               │              │             │
 │             │   [APPROVED]  │               │              │             │
 │             │               ├─ impl. plan   │              │             │
 │             │               │   + security  │              │             │
 │             │               │   [PLANNED]   │              │             │
 │             │               │               ├─ assign ────►│             │
 │             │               │               │   [IN_PROG]  ├─ build      │
 │             │               │               │              ├─ unit tests │
 │             │               │               │              ├─ submit ───►│
 │             │               │               │              │  [REVIEW]   ├─ verify
 │             │               │               │              │         PASS►├─ [DONE]
 │             │               │               │              │◄── FAIL ────┤
 │             │               │               │              │  [FAILED]   ├─ create BUG
 │             │               │               │◄── archive ──┴─────────────┘
 │             │               │               ├─ release?
 │◄─ release ─┤◄─ approval ──┤◄─ arch docs ─┤
```

---

## Role Interaction Matrix

| Stage | PO | DA | SM | DEV | TST |
|---|---|---|---|---|---|
| Requirement Elicitation | **LEAD** | consult | — | — | — |
| Capability Translation | **LEAD** | **LEAD** | — | — | — |
| Backlog Planning | **LEAD** | **LEAD** | inform | — | — |
| User Approval Gate | **LEAD** | — | — | — | — |
| Implementation Planning | review | **LEAD** | — | consult | — |
| Security Assessment | — | **LEAD** | — | — | — |
| Sprint Start | — | — | **LEAD** | inform | inform |
| Development | — | consult | track | **LEAD** | — |
| Verification | — | — | — | — | **LEAD** |
| Bug/Problem Creation | — | — | — | — | **LEAD** |
| Blocker Resolution | consult | **LEAD** | **LEAD** | — | — |
| Release Coordination | approve | docs | **LEAD** | — | **LEAD** |
| Archival | — | docs | **LEAD** | — | — |

**LEAD** = primary responsible · consult = provides input · review = validates · track = monitors · docs = updates docs

---

## Capability Mapping Rules

Capabilities flow through the system in this order:

1. **User Need** → PO translates to **Business Capabilities** (what the system must do)
2. **Business Capability** → DA translates to **Technical Capabilities** (how it's achieved)
3. **Technical Capability** → mapped to **Features** (deliverable units) and **Enablers** (prerequisites)
4. **Each Feature** carries capabilities through to **acceptance criteria** and **test verification**
5. **TST** verifies against **capability acceptance criteria**, not just code behavior

### Capability Types

| Type | Owner | Examples |
|---|---|---|
| `technical` | DA | API endpoint, rendering engine, auth integration |
| `organizational` | PO | Documentation, training, process change |
| `security` | DA | Encryption, access control, audit logging |
| `infrastructure` | DA | Deployment pipeline, monitoring, scaling |

### Mapping Rules

- Every FEATURE must have at least one capability defined
- Every capability must trace back to a REQUIREMENT or EPIC
- Every ENABLER must be mapped to at least one FEATURE via `mapped-to-feature` attribute
- Security capabilities are auto-required for items with `security="true"`

---

## XML Extensions for Role-Aware Items

Items in `overview-features-bugs.xml` can carry the following role-context blocks. These are **optional** but recommended for EPIC, FEATURE, and ENABLER types.

```xml
<!-- Capability traceability -->
<capabilities>
  <capability id="CAP-1" type="technical">PDF rendering engine integration</capability>
  <capability id="CAP-2" type="organizational">User documentation for export</capability>
</capabilities>

<!-- Technical constraints and NFRs (DA-authored) -->
<technical-parameters>
  <constraint>Must use server-side rendering (no client-side PDF libs)</constraint>
  <nfr type="performance">p95 latency under 5s for 50-page reports</nfr>
  <pattern>Use queue-based async processing for large exports</pattern>
</technical-parameters>

<!-- Lifecycle audit trail (auto-populated by transition commands) -->
<workflow-log>
  <entry timestamp="2026-02-21" role="PO" action="approved" from-status="PENDING" to-status="APPROVED" />
  <entry timestamp="2026-02-22" role="DA" action="planned" from-status="APPROVED" to-status="PLANNED" />
  <entry timestamp="2026-02-23" role="DEV" action="started" from-status="PLANNED" to-status="IN_PROGRESS" />
</workflow-log>
```

### Full FEATURE example with role context

```xml
<item id="42" type="feature" status="PLANNED" priority="HIGH"
      complexity="M" parent-epic="10" security="true">

  <title>User can export report as PDF</title>
  <branch>feature/item-42-pdf-export</branch>
  <justification>Enable PDF export from the report dashboard with configurable page layout</justification>
  <depends-on>38, 18</depends-on>

  <acceptance-criteria>
    <criterion id="AC-1">PDF contains all visible report sections</criterion>
    <criterion id="AC-2">Page orientation matches user selection</criterion>
    <criterion id="AC-3">Export completes within 5 seconds for reports under 50 pages</criterion>
  </acceptance-criteria>

  <capabilities>
    <capability id="CAP-1" type="technical">PDF rendering engine integration</capability>
    <capability id="CAP-2" type="infrastructure">Queue-based async processing</capability>
  </capabilities>

  <technical-parameters>
    <constraint>Must use server-side rendering — no client-side PDF libs</constraint>
    <constraint>Maximum memory: 512MB per export job</constraint>
    <nfr type="performance">p95 latency under 5s for 50-page reports</nfr>
    <pattern>Use queue-based async processing for large exports</pattern>
  </technical-parameters>

  <security-impact>
    <category>DATA</category>
    <threat>Report content could be exposed if export endpoint lacks access control</threat>
    <mitigation>Access control check on export endpoint + content sanitization before render</mitigation>
  </security-impact>

  <tasks>
    <task id="42.1">Set up PDF rendering service</task>
    <task id="42.2">Create layout template engine</task>
    <task id="42.3">Wire export endpoint with auth check</task>
    <task id="42.4">Add async queue for large reports</task>
    <task id="42.5">Write unit tests for render service</task>
    <task id="42.6">Write integration test for export endpoint</task>
  </tasks>

  <verification>
    <tests>
      <test type="integration">
        <file>tests/exports/test_pdf_export.py</file>
        <description>PDF export end-to-end</description>
        <assertions>PDF generated, contains all sections, access control enforced</assertions>
      </test>
    </tests>
  </verification>

  <workflow-log>
    <entry timestamp="2026-02-21" role="PO" action="approved" from-status="PENDING" to-status="APPROVED" />
    <entry timestamp="2026-02-22" role="DA" action="planned" from-status="APPROVED" to-status="PLANNED" />
  </workflow-log>

  <r>
    <outcome></outcome>
    <observations></observations>
    <lessons-learned></lessons-learned>
    <files><file></file></files>
  </r>
</item>
```

### RELEASE item

```xml
<release id="REL-1" status="PLANNING" target-date="2026-03-15" type="MINOR">
  <title>v2.4.0 – Report Export and Dashboard Improvements</title>

  <scope>
    <item-ref id="42" type="feature" status="IN_PROGRESS">PDF Export</item-ref>
    <item-ref id="38" type="feature" status="DONE">Report Dashboard Base</item-ref>
    <item-ref id="91" type="bug" status="DONE">Chart rendering fix</item-ref>
  </scope>

  <gates>
    <gate name="scope-freeze" status="PASSED" date="2026-03-01" owner="PO" />
    <gate name="code-complete" status="PENDING" date="" owner="SM" />
    <gate name="full-test-pass" status="PENDING" date="" owner="TST" />
    <gate name="release-approval" status="PENDING" date="" owner="PO" />
  </gates>

  <release-test>
    <run date="" result="">
      <total></total><passed></passed><failed></failed>
    </run>
  </release-test>

  <changelog></changelog>
</release>
```

### SPRINT item

```xml
<sprint id="SPR-1" status="ACTIVE" type="SPRINT" started="2026-02-23">
  <title>Sprint 1 – OAuth integration and session management</title>

  <scope>
    <item-ref id="11" type="feature" status="DONE">OAuth2 Provider Integration</item-ref>
    <item-ref id="12" type="feature" status="IN_PROGRESS">Session Management &amp; Token Refresh</item-ref>
  </scope>

  <gates>
    <gate name="code-complete"  status="PENDING" date="" owner="SM" />
    <gate name="full-test-pass" status="PENDING" date="" owner="TST" />
  </gates>

  <release-test>
    <run date="" result="">
      <total></total><passed></passed><failed></failed>
    </run>
  </release-test>
</sprint>
```

### BLOCKER item

```xml
<blocker id="BLK-1" status="ACTIVE" severity="HIGH" raised-by="DEV" assigned-to="DA,SM">
  <title>PDF library license incompatible with project</title>
  <description>Selected PDF library uses AGPL; conflicts with commercial distribution</description>
  <blocks>
    <item-ref id="42" />
    <item-ref id="18" />
  </blocks>
  <resolution-plan>DA to evaluate alternative libraries (Puppeteer, WeasyPrint)</resolution-plan>
  <resolved-date></resolved-date>
  <resolution></resolution>
</blocker>
```
