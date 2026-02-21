# Enhanced Role-Capability-Ticket Workflow Framework

## 1. Roles & Capabilities

Each role has defined **capabilities** — the actions they are authorized to perform within the workflow. Capabilities map directly to ticket handling permissions.

---

### Product Owner (PO)

**Domain:** Business value, requirements, prioritization

| Capability ID | Capability | Description |
|---|---|---|
| `PO-CAP-01` | `requirement-elicitation` | Extract, clarify, and document requirements from user conversations |
| `PO-CAP-02` | `priority-assignment` | Assign and adjust priority levels (CRITICAL / HIGH / MEDIUM / LOW) |
| `PO-CAP-03` | `capability-translation` | Translate business needs into capability descriptions (technical or organizational) with DA |
| `PO-CAP-04` | `business-process-mapping` | Document and validate the business process the system supports |
| `PO-CAP-05` | `backlog-planning` | Create and groom backlog items (Epics, Features, Issues) with DA |
| `PO-CAP-06` | `acceptance-definition` | Define acceptance criteria for features and epics |
| `PO-CAP-07` | `stakeholder-approval` | Approve or deny items at PENDING gates; approve release scope |
| `PO-CAP-08` | `scope-negotiation` | Negotiate scope changes, deferrals, and trade-offs with user |

**Handles:** `REQUIREMENT` → `EPIC` → `FEATURE` (business side), `ISSUE` (validation)  
**Gates:** PENDING → APPROVED (with user confirmation)

---

### Scrum Master (SM)

**Domain:** Process governance, flow optimization, impediment removal

| Capability ID | Capability | Description |
|---|---|---|
| `SM-CAP-01` | `status-management` | Transition item statuses according to lifecycle rules |
| `SM-CAP-02` | `process-sync` | Synchronize work across roles; ensure handoffs happen |
| `SM-CAP-03` | `blocker-resolution` | Identify, escalate, and track blockers (with DA and PO) |
| `SM-CAP-04` | `process-capability-decision` | Decide on process-level capabilities (tooling, ceremonies, workflow changes) |
| `SM-CAP-05` | `release-management` | Initiate, coordinate, and track release cycles |
| `SM-CAP-06` | `velocity-tracking` | Track throughput, cycle time, and identify bottlenecks |
| `SM-CAP-07` | `archive-management` | Move DONE/DENIED items to archive; maintain changelog |
| `SM-CAP-08` | `dependency-tracking` | Track and flag cross-item dependencies and sequencing |

**Handles:** All item types (status transitions only), `RELEASE`, `BLOCKER`  
**Gates:** IN_PROGRESS → REVIEW, REVIEW → DONE (with Tester sign-off)

---

### DevSecOps Architect (DA)

**Domain:** Technical design, security, architecture, enablement

| Capability ID | Capability | Description |
|---|---|---|
| `DA-CAP-01` | `technical-parameter-definition` | Define technical parameters, constraints, and NFRs for capabilities |
| `DA-CAP-02` | `enabler-creation` | Create Enabler items (infrastructure, tooling, platform) mapped to features |
| `DA-CAP-03` | `architecture-documentation` | Build and maintain architecture overview (overview.xml) |
| `DA-CAP-04` | `security-assessment` | Perform threat categorization and security impact assessments |
| `DA-CAP-05` | `implementation-planning` | Analyze items and create detailed implementation plans with task breakdowns |
| `DA-CAP-06` | `technical-guidance` | Add implementation notes, patterns, and technical constraints to items |
| `DA-CAP-07` | `archive-rebuild` | Clear archive, rebuild architecture docs, and ensure overview consistency |
| `DA-CAP-08` | `dependency-analysis` | Identify technical dependencies, integration points, and risks |
| `DA-CAP-09` | `code-review-architecture` | Review implementations for architectural compliance and security |

**Handles:** `ENABLER`, `FEATURE` (technical side), `TECH-DEBT`, `SECURITY-ITEM`  
**Gates:** APPROVED → PLANNED (implementation plan ready)

---

### Developer (DEV)

**Domain:** Implementation, unit testing

| Capability ID | Capability | Description |
|---|---|---|
| `DEV-CAP-01` | `code-implementation` | Write, modify, and refactor code according to item specifications |
| `DEV-CAP-02` | `unit-test-creation` | Create unit tests covering the implementation |
| `DEV-CAP-03` | `task-execution` | Execute non-code tasks defined in items (config, migration, setup) |
| `DEV-CAP-04` | `self-verification` | Run unit tests locally and confirm basic functionality |
| `DEV-CAP-05` | `result-documentation` | Update item `<r>` block with outcomes, observations, files changed |
| `DEV-CAP-06` | `branch-management` | Create, manage, and merge feature branches |

**Handles:** `FEATURE` (implementation), `BUG` (fix), `ENABLER` (build), `REFACTORING`  
**Gates:** PLANNED → IN_PROGRESS → REVIEW (code complete + unit tests pass)

---

### Tester (TST)

**Domain:** Verification, validation, quality assurance

| Capability ID | Capability | Description |
|---|---|---|
| `TST-CAP-01` | `unit-test-verification` | Verify unit tests against capability acceptance criteria |
| `TST-CAP-02` | `integration-testing` | Run integration tests across related capabilities |
| `TST-CAP-03` | `release-testing` | Execute full test suite on release candidates |
| `TST-CAP-04` | `bug-creation` | Create BUG items with reproduction steps when tests fail |
| `TST-CAP-05` | `problem-creation` | Create PROBLEM items for systemic or environmental issues |
| `TST-CAP-06` | `regression-check` | Verify that fixes don't break existing capabilities |
| `TST-CAP-07` | `test-result-documentation` | Document test runs, coverage, and pass/fail details |

**Handles:** `BUG` (creation), `PROBLEM` (creation), all items (verification)  
**Gates:** REVIEW → DONE (test sign-off), REVIEW → FAILED (regression to DEV)

---

## 2. Item Types (Handler-Items / Tickets)

Items flow through roles based on their type and the capabilities required at each stage.

### Item Type Hierarchy

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

BLOCKER (SM)
  └── blocks: any item
```

### Item Type Definitions

| Type | Created By | Handled By | Description |
|---|---|---|---|
| `REQUIREMENT` | PO | PO | Raw user need; decomposed into Epics/Features |
| `EPIC` | PO | PO, DA | Large capability grouping; parent of Features |
| `FEATURE` | PO, DA | DA (plan), DEV (build), TST (verify) | Deliverable capability mapped to an Epic |
| `ENABLER` | DA | DA (plan), DEV (build) | Technical prerequisite mapped to a Feature |
| `BUG` | TST, DEV | DEV (fix), TST (verify) | Defect found during testing or development |
| `PROBLEM` | TST | SM, DA, PO | Systemic/environmental issue requiring process or architecture change |
| `TECH-DEBT` | DA | DEV (fix), TST (verify) | Known technical compromise to be addressed |
| `REFACTORING` | DA | DEV (build), TST (verify) | Structural improvement without behavior change |
| `SECURITY-ITEM` | DA | DA (plan), DEV (fix), TST (verify) | Security vulnerability or hardening task |
| `RELEASE` | SM | SM, TST | Release coordination ticket |
| `BLOCKER` | SM | SM, DA, PO | Impediment blocking other items |

---

## 3. Enhanced Status Lifecycle

```
                    ┌──────────────────────────────────────┐
                    │                                      │
 PENDING ──→ APPROVED ──→ PLANNED ──→ IN_PROGRESS ──→ REVIEW ──→ DONE
    │                                                   │         │
    └──→ DENIED                                    FAILED ────┘   │
                                                   (back to       │
                                                    IN_PROGRESS)  ▼
                                                              ARCHIVED
```

| Status | Owner | Gate Condition |
|---|---|---|
| `PENDING` | PO | Item created, awaiting user/PO approval |
| `APPROVED` | PO + User | User confirmed; ready for planning |
| `PLANNED` | DA | Implementation plan, tasks, and technical guidance attached |
| `IN_PROGRESS` | DEV | Code/task work actively happening |
| `REVIEW` | TST | Code complete, unit tests pass, awaiting verification |
| `FAILED` | TST → DEV | Verification failed; returns to DEV with bug/problem details |
| `DONE` | SM | All tests pass, acceptance criteria met |
| `DENIED` | PO | Rejected at PENDING gate |
| `ARCHIVED` | SM | Moved to archive after DONE with no active dependents |

---

## 4. Capability-Based Item Structure (XML)

### Item Template with Role Assignments

```xml
<item id="F-042"
      type="feature"
      status="PENDING"
      priority="HIGH"
      parent-epic="E-007"
      security-impact="MEDIUM">

  <!-- PO-CAP-01, PO-CAP-06: Requirements & Acceptance -->
  <title>User can export report as PDF</title>
  <description>Enable PDF export from the report dashboard with configurable page layout</description>
  <business-process>Report Generation → Export → Delivery</business-process>
  <acceptance-criteria>
    <criterion id="AC-1">PDF contains all visible report sections</criterion>
    <criterion id="AC-2">Page orientation matches user selection</criterion>
    <criterion id="AC-3">Export completes within 5 seconds for reports under 50 pages</criterion>
  </acceptance-criteria>

  <!-- PO-CAP-03: Capability Translation -->
  <capabilities>
    <capability id="CAP-F042-1" type="technical">PDF rendering engine integration</capability>
    <capability id="CAP-F042-2" type="technical">Layout template system</capability>
    <capability id="CAP-F042-3" type="organizational">User documentation for export feature</capability>
  </capabilities>

  <!-- DA-CAP-01, DA-CAP-06: Technical Parameters & Guidance -->
  <technical-parameters>
    <constraint>Must use server-side rendering (no client-side PDF libs)</constraint>
    <constraint>Maximum memory: 512MB per export job</constraint>
    <nfr type="performance">p95 latency under 5s for 50-page reports</nfr>
    <nfr type="security">Sanitize all user content before rendering</nfr>
    <pattern>Use queue-based async processing for large exports</pattern>
  </technical-parameters>

  <!-- DA-CAP-04: Security Assessment -->
  <security>
    <threat-category>DATA_EXPOSURE</threat-category>
    <impact>MEDIUM</impact>
    <mitigation>Content sanitization + access control on export endpoint</mitigation>
  </security>

  <!-- DA-CAP-05: Implementation Plan -->
  <implementation-plan>
    <tasks>
      <task id="T-1" role="DEV" depends-on="">Set up PDF rendering service</task>
      <task id="T-2" role="DEV" depends-on="">Create layout template engine</task>
      <task id="T-3" role="DEV" depends-on="T-1,T-2">Wire export endpoint with auth</task>
      <task id="T-4" role="DEV" depends-on="T-3">Add async queue for large reports</task>
      <task id="T-5" role="TST" depends-on="T-3">Write capability verification tests</task>
      <task id="T-6" role="TST" depends-on="T-4">Load test with 50-page reports</task>
    </tasks>
    <enablers>
      <enabler-ref id="EN-018">PDF rendering library setup</enabler-ref>
    </enablers>
  </implementation-plan>

  <!-- SM-CAP-08: Dependencies -->
  <depends-on>
    <item-ref id="EN-018" type="enabler">PDF rendering library</item-ref>
    <item-ref id="F-038" type="feature">Report dashboard base</item-ref>
  </depends-on>

  <!-- DEV-CAP-05, TST-CAP-07: Results -->
  <r status="PENDING">
    <outcome></outcome>
    <observations></observations>
    <lessons-learned></lessons-learned>
    <files></files>
    <test-run>
      <total></total>
      <passed></passed>
      <failed></failed>
    </test-run>
  </r>

  <!-- SM-CAP-01: Workflow Tracking -->
  <workflow-log>
    <!-- Auto-populated as item moves through gates -->
    <entry timestamp="" role="" action="" from-status="" to-status="" note="" />
  </workflow-log>
</item>
```

### Enabler Template (DA-created)

```xml
<item id="EN-018"
      type="enabler"
      status="PENDING"
      priority="HIGH"
      mapped-to-feature="F-042"
      security-impact="LOW">

  <title>PDF rendering library setup</title>
  <description>Install, configure, and secure PDF rendering service for server-side use</description>

  <capabilities>
    <capability id="CAP-EN018-1" type="technical">Headless PDF rendering</capability>
    <capability id="CAP-EN018-2" type="technical">Template-to-PDF pipeline</capability>
  </capabilities>

  <technical-parameters>
    <constraint>Isolated container execution for untrusted content</constraint>
    <constraint>No external network access from renderer</constraint>
    <pattern>Puppeteer/Chromium in sandbox mode</pattern>
  </technical-parameters>

  <security>
    <threat-category>REMOTE_CODE_EXECUTION</threat-category>
    <impact>HIGH</impact>
    <mitigation>Sandboxed container + no-network policy + content sanitization</mitigation>
  </security>

  <implementation-plan>
    <tasks>
      <task id="T-1" role="DA">Select and evaluate rendering library</task>
      <task id="T-2" role="DEV" depends-on="T-1">Install and configure in dev environment</task>
      <task id="T-3" role="DEV" depends-on="T-2">Create base rendering wrapper with security hardening</task>
      <task id="T-4" role="TST" depends-on="T-3">Security scan + basic render tests</task>
    </tasks>
  </implementation-plan>

  <r status="PENDING">
    <outcome></outcome>
    <observations></observations>
    <files></files>
  </r>
</item>
```

### Release Template (SM-managed)

```xml
<release id="REL-003"
         status="PLANNING"
         target-date="2026-03-15"
         type="MINOR">

  <title>v2.4.0 – Report Export & Dashboard Improvements</title>

  <!-- SM-CAP-05: Release Scope -->
  <scope>
    <item-ref id="E-007" type="epic">Report Export Capability</item-ref>
    <item-ref id="F-042" type="feature" status="IN_PROGRESS">PDF Export</item-ref>
    <item-ref id="F-038" type="feature" status="DONE">Report Dashboard Base</item-ref>
    <item-ref id="EN-018" type="enabler" status="REVIEW">PDF Library Setup</item-ref>
    <item-ref id="B-091" type="bug" status="DONE">Chart rendering fix</item-ref>
  </scope>

  <!-- Release Gates -->
  <gates>
    <gate name="scope-freeze" status="PASSED" date="2026-03-01" owner="PO" />
    <gate name="code-complete" status="PENDING" date="" owner="SM" />
    <gate name="full-test-pass" status="PENDING" date="" owner="TST" />
    <gate name="release-approval" status="PENDING" date="" owner="PO" />
  </gates>

  <!-- TST-CAP-03: Release Test Results -->
  <release-test>
    <run date="" result="">
      <total></total>
      <passed></passed>
      <failed></failed>
      <blocked></blocked>
    </run>
  </release-test>

  <changelog></changelog>
</release>
```

### Blocker Template (SM-managed)

```xml
<blocker id="BLK-005"
         status="ACTIVE"
         severity="HIGH"
         raised-by="DEV"
         assigned-to="DA,SM">

  <title>PDF library license incompatible with project</title>
  <description>Selected PDF library uses AGPL; conflicts with commercial distribution</description>
  <blocks>
    <item-ref id="EN-018" />
    <item-ref id="F-042" />
  </blocks>
  <resolution-plan>DA to evaluate alternative libraries (Puppeteer, WeasyPrint)</resolution-plan>
  <resolved-date></resolved-date>
  <resolution></resolution>
</blocker>
```

---

## 5. Workflow: End-to-End Item Flow

```
USER                PO                  DA                  SM                DEV               TST
 │                   │                   │                   │                  │                  │
 ├── request ──────► │                   │                   │                  │                  │
 │                   ├── elicit reqs     │                   │                  │                  │
 │                   │   (PO-CAP-01)     │                   │                  │                  │
 │                   │                   │                   │                  │                  │
 │                   ├── translate to ──►│                   │                  │                  │
 │                   │   capabilities    │                   │                  │                  │
 │                   │   (PO-CAP-03)     ├── define tech     │                  │                  │
 │                   │                   │   parameters      │                  │                  │
 │                   │                   │   (DA-CAP-01)     │                  │                  │
 │                   │                   │                   │                  │                  │
 │                   ├── create items ◄──┤                   │                  │                  │
 │                   │   (PO-CAP-05)     │                   │                  │                  │
 │                   │   [PENDING]       │                   │                  │                  │
 │                   │                   │                   │                  │                  │
 │◄── review plan ──┤                   │                   │                  │                  │
 │                   │                   │                   │                  │                  │
 ├── approve ──────►│                   │                   │                  │                  │
 │                   │   [APPROVED]      │                   │                  │                  │
 │                   │                   │                   │                  │                  │
 │                   │                   ├── impl. plan      │                  │                  │
 │                   │                   │   (DA-CAP-05)     │                  │                  │
 │                   │                   │   + security      │                  │                  │
 │                   │                   │   (DA-CAP-04)     │                  │                  │
 │                   │                   │   [PLANNED]       │                  │                  │
 │                   │                   │                   │                  │                  │
 │                   │                   │                   ├── assign + ─────►│                  │
 │                   │                   │                   │   track          │                  │
 │                   │                   │                   │   (SM-CAP-01)    ├── build          │
 │                   │                   │                   │   [IN_PROGRESS]  │   (DEV-CAP-01)   │
 │                   │                   │                   │                  │                  │
 │                   │                   │                   │                  ├── unit test      │
 │                   │                   │                   │                  │   (DEV-CAP-02)   │
 │                   │                   │                   │                  │                  │
 │                   │                   │                   │                  ├── submit ───────►│
 │                   │                   │                   │                  │   [REVIEW]       │
 │                   │                   │                   │                  │                  ├── verify
 │                   │                   │                   │                  │                  │   (TST-CAP-01)
 │                   │                   │                   │                  │                  │
 │                   │                   │                   │                  │          PASS ──►├── [DONE]
 │                   │                   │                   │                  │                  │
 │                   │                   │                   │                  │◄── FAIL ────────┤
 │                   │                   │                   │                  │   [FAILED]       ├── create BUG
 │                   │                   │                   │                  │   + BUG item     │   (TST-CAP-04)
 │                   │                   │                   │                  │                  │
 │                   │                   │                   │                  │                  │
 │                   │                   │                   │  ◄── DONE items  │                  │
 │                   │                   │                   ├── archive ───────┴──────────────────┘
 │                   │                   │                   │   (SM-CAP-07)
 │                   │                   │                   │                  
 │                   │                   │                   ├── release?       
 │◄── release ──────┤◄─ approval ──────┤◄─ arch docs ─────┤   (SM-CAP-05)    
 │    notification   │   (PO-CAP-07)    │   (DA-CAP-03)     │                  
 │                   │                   │                   │                  
```

---

## 6. Slash Commands (Enhanced with Role Context)

### Item Creation

| Command | Role | Action |
|---|---|---|
| `/new-requirement <title>` | PO | Create REQUIREMENT item in PENDING |
| `/new-epic <title>` | PO | Create EPIC item in PENDING |
| `/new-feature <title> [--epic E-xxx]` | PO | Create FEATURE mapped to Epic in PENDING |
| `/new-enabler <title> --feature F-xxx` | DA | Create ENABLER mapped to Feature in PENDING |
| `/new-bug <title> [--blocks F-xxx]` | TST | Create BUG item in PENDING |
| `/new-problem <title>` | TST | Create PROBLEM item in PENDING |
| `/new-tech-debt <title>` | DA | Create TECH-DEBT item in PENDING |
| `/new-security <title> --threat <category>` | DA | Create SECURITY-ITEM in PENDING |
| `/new-blocker <title> --blocks <id,...>` | SM | Create BLOCKER in ACTIVE |
| `/new-release <version> --target <date>` | SM | Create RELEASE in PLANNING |

### Status Management (SM)

| Command | Action |
|---|---|
| `/approve <id>` | PENDING → APPROVED (requires PO confirmation) |
| `/plan <id>` | APPROVED → PLANNED (DA attaches implementation plan) |
| `/start <id>` | PLANNED → IN_PROGRESS (DEV begins work) |
| `/submit <id>` | IN_PROGRESS → REVIEW (DEV submits for testing) |
| `/pass <id>` | REVIEW → DONE (TST verifies) |
| `/fail <id> [--bug B-xxx]` | REVIEW → FAILED (TST rejects, creates/links BUG) |
| `/deny <id>` | PENDING → DENIED |
| `/archive <id>` | DONE → ARCHIVED |
| `/resolve-blocker <id>` | BLOCKER → RESOLVED |

### Planning & Analysis

| Command | Action |
|---|---|
| `/translate <requirement-id>` | PO+DA: Decompose REQUIREMENT into capabilities → Features/Enablers |
| `/plan-impl <id>` | DA: Generate implementation plan with tasks and security assessment |
| `/security-audit [scope]` | DA: Run security assessment across items |
| `/update-item <id>` | Replan existing item with new knowledge |
| `/check-deps <id>` | SM: Show dependency tree and blockers |

### Testing & Release

| Command | Action |
|---|---|
| `/run-unit-tests [scope]` | DEV: Execute unit tests, map failures to items |
| `/run-full-test` | TST: Full test cycle on release candidate, auto-map failures |
| `/release-gate <release-id> <gate-name>` | SM: Check/update release gate status |
| `/release-go <release-id>` | SM: Mark release as approved after all gates pass |

### Queries

| Command | Action |
|---|---|
| `/board` | Show current sprint/iteration board by status columns |
| `/my-items <role>` | Show items assigned to a role |
| `/blockers` | List all active blockers |
| `/release-status <release-id>` | Show release progress and gate status |
| `/capability-map [epic-id]` | Show capability tree for an epic |

---

## 7. Capability Mapping Rules

### How Capabilities Flow Through the System

1. **User Need** → PO translates to **Business Capabilities** (what the system must do)
2. **Business Capability** → DA translates to **Technical Capabilities** (how it's achieved)
3. **Technical Capability** → mapped to **Features** (deliverable units) and **Enablers** (prerequisites)
4. **Each Feature** carries its capabilities through to **acceptance criteria** and **test verification**
5. **Tester** verifies against **capability acceptance criteria**, not just code behavior

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
- Every ENABLER must be mapped to at least one FEATURE
- Capabilities without a parent REQUIREMENT are flagged as orphans
- Security capabilities are auto-required for items with `security-impact` ≥ MEDIUM

---

## 8. Role Interaction Matrix

This matrix shows which roles interact at each workflow stage:

| Stage | PO | DA | SM | DEV | TST |
|---|---|---|---|---|---|
| Requirement Elicitation | **LEAD** | consult | — | — | — |
| Capability Translation | **LEAD** | **LEAD** | — | — | — |
| Backlog Planning | **LEAD** | **LEAD** | inform | — | — |
| User Approval Gate | **LEAD** | — | — | — | — |
| Implementation Planning | review | **LEAD** | — | consult | — |
| Security Assessment | — | **LEAD** | — | — | — |
| Sprint/Iteration Start | — | — | **LEAD** | inform | inform |
| Development | — | consult | track | **LEAD** | — |
| Code Review | — | review | — | **LEAD** | — |
| Verification | — | — | — | — | **LEAD** |
| Bug/Problem Creation | — | — | — | — | **LEAD** |
| Blocker Resolution | consult | **LEAD** | **LEAD** | — | — |
| Release Coordination | approve | docs | **LEAD** | — | **LEAD** |
| Archival | — | docs | **LEAD** | — | — |

**LEAD** = primary responsible  |  consult = provides input  |  review = validates  |  inform = notified  |  track = monitors  |  docs = updates documentation