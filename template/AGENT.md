# Agent Orchestration

This chapter defines the five role-based sub-agents used in the vibe-coding workflow and explains how the main Claude instance orchestrates them.

Read this alongside `CLAUDE-roles-chapter.md` (role definitions and lifecycle rules) and `SKILL.md` (skill-to-agent mapping).

---

## Overview

Five specialized agents implement the workflow roles. The main Claude instance acts as **orchestrator**: it reads the XML plan, routes commands to the correct agent, coordinates handoffs, and reports back to the user.

| Agent file | Role | Domain |
|---|---|---|
| `.claude/agents/po.md` | Product Owner (PO) | Business value, requirements, approval gates |
| `.claude/agents/sm.md` | Scrum Master (SM) | Process, flow, blockers, releases, archival |
| `.claude/agents/da.md` | DevSecOps Architect (DA) | Technical design, security, architecture |
| `.claude/agents/dev.md` | Developer (DEV) | Implementation, unit testing |
| `.claude/agents/tst.md` | Tester (TST) | Verification, quality gates, bug creation |

---

## Invocation Model

### Command routing

When a slash command arrives, route to the owning agent:

| Command | Agent |
|---|---|
| `/feature`, `/bug`, `/approve`, `/deny` | `po` (or orchestrator inline for simple items) |
| `/refactor`, `/debt` | `da` (or orchestrator inline for simple items) |
| `/run [IDs]` | orchestrator (inline; chains DEV + TST logic) |
| `/start`, `/archive`, `/release`, `/blockers`, `/sprint` | `sm` |
| `/plan-impl`, `/security`, `/init_overview`, `/update`, `/translate`, `/lessons` | `da` |
| `/submit` + implementation work | `dev` |
| `/pass`, `/fail` | `tst` |
| `/status`, `/list`, `/board`, `/check-deps`, `/plan_summary`, `/overview` | orchestrator (no delegation) |

### Explicit delegation

The user or orchestrator can explicitly invoke a role for specialized work:

```
"Act as the DA and assess the security impact of item 15"
→ spawn `da` agent with the item context

"Act as TST and write a test plan for item 22"
→ spawn `tst` agent with the item context
```

### Orchestrator responsibilities

The main Claude instance:
- Reads and maintains `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml` (active items only); loads `ai-docs/overview-features-bugs-archive.xml` only on demand
- Routes slash commands to the correct agent
- Handles read-only queries directly (`/status`, `/list`, `/board`)
- Coordinates handoffs between agents at lifecycle gates
- Reports status and results back to the user
- Enforces the 5-item-per-interaction limit
- Writes changelog entries when no agent is delegated

---

## Lifecycle and Handoffs

The full lifecycle with agent ownership at each gate:

**Auto-pilot flow (recommended):**
```
USER        PO + DA (inline)   PO           ORCHESTRATOR (/run)
 │               │               │                │
 ├─ /feature ───►│               │                │
 │               ├─ create item  │                │
 │               ├─ DA enrich ───┤ [PENDING]      │
 │◄── review ───┤               │                │
 ├─ /approve ───►│               │                │
 │               │          [APPROVED]            │
 ├──────────────────────────── /run ─────────────►│
 │                                                ├─ SM: start  [IN_PROGRESS]
 │                                                ├─ DEV: implement + submit  [REVIEW]
 │                                                ├─ TST: verify
 │                                                │   PASS → [DONE] → next item
 │                                                │   FAIL → BUG → fix → retest
 │                                                │   FAIL×2 → STOP → report to user
 │◄── results ────────────────────────────────────┤
 ├─ /archive ────────────────────────────────────►SM
```

**Manual (step-by-step) flow:**
```
USER        PO + DA (inline)   PO           SM          DEV         TST
 ├─ /feature ───►│               │            │            │           │
 │               ├─ DA enrich ───┤ [PENDING]  │            │           │
 ├─ /approve ───►│               │            │            │           │
 │               │          [APPROVED]        │            │           │
 │ /plan-impl (optional re-plan) ────────────►│            │           │
 │                                            ├─ /start ──►│           │
 │                                            │ [IN_PROG]  ├─ build    │
 │                                            │            ├─ /submit ►│
 │                                            │            │ [REVIEW]  ├─ verify
 │                                            │            │   PASS ───► [DONE]
 │                                            │            │   FAIL ───► [FAILED] + BUG
 │                                            │◄─ /archive ────────────┘
```

### Workflow-log protocol

Every agent adds a `<workflow-log>` entry when it executes a gate transition:

```xml
<workflow-log>
  <entry timestamp="2026-02-21" role="PO"  action="approved"  from-status="PENDING"     to-status="APPROVED" />
  <entry timestamp="2026-02-22" role="DA"  action="planned"   from-status="APPROVED"    to-status="PLANNED" />
  <entry timestamp="2026-02-23" role="SM"  action="started"   from-status="PLANNED"     to-status="IN_PROGRESS" />
  <entry timestamp="2026-02-24" role="DEV" action="submitted" from-status="IN_PROGRESS" to-status="REVIEW" />
  <entry timestamp="2026-02-24" role="TST" action="passed"    from-status="REVIEW"      to-status="DONE" />
</workflow-log>
```

---

## When to Delegate vs. Handle Inline

| Situation | Approach |
|---|---|
| `/status`, `/list`, `/board`, `/plan_summary`, `/overview` | Orchestrator handles directly |
| `/feature`, `/bug`, `/refactor`, `/debt` | Orchestrator handles (Phase 1 + DA enrichment inline) |
| `/run [IDs]` | Orchestrator handles directly (chains SM/DEV/TST inline) |
| `/approve`, `/deny` | Delegate to `po` |
| `/plan-impl` (re-planning or manual plan) | Delegate to `da` |
| `/start`, `/archive`, `/sprint`, `/release`, `/blockers` | Delegate to `sm` |
| `/submit` + full implementation | Delegate to `dev` |
| `/pass` or `/fail` (verification) | Delegate to `tst` |
| `/security`, `/init_overview`, `/update`, `/translate`, `/lessons` | Delegate to `da` |
| Complex backlog grooming or scope negotiation | Delegate to `po` |
| Release testing | Delegate to `tst` |

---

## Agent Tool Permissions

Each agent is scoped to the tools it needs for its role:

| Agent | Tools |
|---|---|
| `po` | Read, Write, Edit, Glob, Grep |
| `sm` | Read, Write, Edit, Glob, Grep |
| `da` | Read, Write, Edit, Glob, Grep, Bash |
| `dev` | Read, Write, Edit, Glob, Grep, Bash |
| `tst` | Read, Write, Edit, Glob, Grep, Bash |

DA, DEV, and TST have Bash access because they need to scan code, run tests, or execute build tools. PO and SM only need to read and update the XML plan.

---

## Installing Agents into a Project

The agent files in `template/.claude/agents/` are installed by `setup.sh` into the target project's `.claude/agents/` directory. No manual setup is required beyond running the installer.

After installation, Claude Code automatically discovers and can spawn the agents. Reference them in `AGENT.md` (this file, embedded in the project's `CLAUDE.md`) and in the slash command definitions in `.claude/commands/`.
