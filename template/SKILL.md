# Skills Reference

This chapter defines all user-invocable skills (slash commands) in the vibe-coding workflow, their owning agents, and how they connect to the lifecycle.

Read this alongside `AGENT.md` (agent definitions) and `CLAUDE-implementation-plan-chapter.md` (full command specifications).

Skills are implemented as slash command files in `.claude/commands/`. Each skill file contains the full execution logic for that command.

---

## Skill Registry

### Item Creation Skills

These skills create items with `status="PENDING"` **and immediately enrich them** with a full implementation plan (DA inline enrichment: tasks, technical-parameters, verification, security assessment). The user sees a fully-planned item and only needs `/approve` to proceed — no separate `/plan-impl` step required for standard items.

| Skill | Command file | Agent | Default type | Default priority |
|---|---|---|---|---|
| `/feature <desc>` | `feature.md` | PO | `feature` | MEDIUM |
| `/bug <desc>` | `bug.md` | PO / TST | `bug` | HIGH |
| `/refactor <desc>` | `refactor.md` | DA | `refactoring` | MEDIUM |
| `/debt <desc>` | `debt.md` | DA | `tech-debt` | LOW |

**Inline modifiers** (append after description):

| Modifier | Effect |
|---|---|
| `!critical`, `!high`, `!medium`, `!low` | Override priority |
| `!security` | Mark `security="true"`, add `<security-impact>` block |
| `@<ID>` | Set `depends-on` to item ID |
| `^<ID>` | Set `parent` (sub-item of epic) |
| `--requirement` | Create as REQUIREMENT type |
| `--epic` | Create as EPIC type (XL, requires decomposition) |
| `--enabler` | Create as ENABLER type |
| `--problem` | Create as PROBLEM type |

---

### Lifecycle Transition Skills

These skills move items through the workflow. Each is owned by a specific agent.

**Normal (auto-pilot) flow:**
```
/feature (+ inline DA plan)
        │
        ▼
   PENDING ──[/approve]──► APPROVED ──[/run ►──────────────────────────────────────────┐
      │                                   auto: start → implement → submit → pass/fail  │
   [/deny]                                         └─[if fail]──► BUG fix cycle ────────┘
      │                                                                    │
   DENIED                                                              DONE → /archive
```

**Manual (step-by-step) flow** (for debugging or fine-grained control):
```
APPROVED ──[/plan-impl]──► re-plan ──[/start]──► IN_PROGRESS ──[/submit]──► REVIEW
                                                                         ┌──────┴──────┐
                                                                      [/pass]       [/fail]
                                                                         │             │
                                                                        DONE         FAILED + BUG
```

| Skill | Command file | Agent | Transition | Gate condition |
|---|---|---|---|---|
| `/approve <ID...>` | `approve.md` | PO | PENDING → APPROVED | User confirms; branch name generated |
| `/deny <ID> [reason]` | `deny.md` | PO | PENDING → DENIED | Rejected at gate; archived immediately |
| `/run [IDs]` | `run.md` | Orchestrator | APPROVED → DONE (auto) | Full lifecycle; stops only on escalation |
| `/plan-impl <ID>` | `plan-impl.md` | DA | PENDING/APPROVED → re-plan | Re-plan or manually plan bare items |
| `/start <ID>` | `start.md` | SM | APPROVED → IN_PROGRESS | No active blockers; deps resolved |
| `/submit <ID>` | `submit.md` | DEV | IN_PROGRESS → REVIEW | Unit tests pass; tasks complete |
| `/pass <ID>` | `pass.md` | TST | REVIEW → DONE | All tests pass; acceptance criteria met |
| `/fail <ID> [reason]` | `fail.md` | TST | REVIEW → FAILED | Verification failed; BUG item created |

---

### Item Management Skills

| Skill | Command file | Agent | Effect |
|---|---|---|---|
| `/run [IDs]` | `run.md` | Orchestrator | Auto-pilot: start → implement → test → fix → done; stops only on escalation |
| `/implement [IDs]` | `implement.md` | DEV | Manual single-step implementation; no TST cycle |
| `/archive` | `archive.md` | SM | Move DONE/DENIED items to archive file; extract lessons; rotate changelog; trigger full-test check |
| `/sprint` | `sprint.md` | SM | Show active sprint status |
| `/sprint create [ID...]` | `sprint.md` | SM | Group 2–5 APPROVED items into a lightweight SPRINT |
| `/sprint close` | `sprint.md` | SM | Close sprint when all scope items DONE; trigger full-test recommendation |
| `/release <version> [--target <date>]` | `release.md` | SM | Create formal RELEASE item (PO gates required) |
| `/blockers` | `blockers.md` | SM | List active BLOCKER items |
| `/blockers <title> --blocks <ID,...>` | `blockers.md` | SM | Create new BLOCKER item |
| `/blockers resolve <ID>` | `blockers.md` | SM | Resolve BLOCKER, unblock dependent items |
| `/translate <ID>` | `translate.md` | DA | Decompose REQUIREMENT → EPIC + FEATUREs + ENABLERs |
| `/lessons [category]` | `lessons.md` | DA (read) | Show lessons-learned knowledge base; optional category filter |

---

### Query Skills (orchestrator, no delegation)

These are read-only. No agent delegation required; the orchestrator handles them directly.

| Skill | Command file | Effect |
|---|---|---|
| `/status <ID>` | `status.md` | Show item status, tasks, and dependencies |
| `/list [filter]` | `list.md` | List items filtered by status, type, or priority |
| `/board` | `board.md` | Kanban-style view of all items by status column |
| `/check-deps <ID>` | `check-deps.md` | Show dependency tree and blocking items |
| `/plan_summary` | `plan_summary.md` | Counts by status/type/priority + next actionable items |
| `/overview` | `overview.md` | Architecture summary from overview.xml |

---

### Analysis Skills

| Skill | Command file | Agent | Effect |
|---|---|---|---|
| `/init_overview` | `init_overview.md` | DA | Full codebase scan; generate both XML files |
| `/update` | `update.md` | DA | Verify + sync XMLs against current codebase |

---

### Security Skills

| Skill | Command file | Agent | Effect |
|---|---|---|---|
| `/security` | `security.md` | DA | Full security audit across all 7 categories |
| `/security <area>` | `security.md` | DA | Focused audit (e.g., `/security auth`, `/security api`) |
| `/security status` | `security.md` | DA | Current security posture: open concerns, coverage |

---

## Capability Matrix

Agent capabilities are not user-invocable skills — they are the internal competencies that agents use when executing skills. This table maps capabilities to the skills that exercise them.

| Capability | Agent | Exercised by skills |
|---|---|---|
| `requirement-elicitation` | PO | `/feature --requirement`, conversational requests |
| `priority-assignment` | PO | `/feature`, `/approve`, modifiers |
| `capability-translation` | PO + DA | `/feature`, `/plan-impl` |
| `backlog-planning` | PO | `/feature`, `/bug`, `/refactor`, `/debt` |
| `acceptance-definition` | PO | `/feature`, `/approve` |
| `stakeholder-approval` | PO | `/approve`, `/deny` |
| `scope-negotiation` | PO | `/deny`, conversational |
| `status-management` | SM | `/start`, `/archive` |
| `process-sync` | SM | `/start`, `/blockers` |
| `blocker-resolution` | SM | `/blockers`, `/blockers resolve` |
| `release-management` | SM | `/release` |
| `sprint-management` | SM | `/sprint`, `/sprint create`, `/sprint close` |
| `archive-management` | SM | `/archive` |
| `dependency-tracking` | SM | `/start`, `/check-deps` |
| `technical-parameter-definition` | DA | `/plan-impl` |
| `enabler-creation` | DA | `/plan-impl`, `/translate` |
| `architecture-documentation` | DA | `/init_overview`, `/update`, `/archive` |
| `security-assessment` | DA | `/security`, `/plan-impl`, `/approve` |
| `implementation-planning` | DA | `/plan-impl`, `/feature`, `/bug`, `/refactor`, `/debt` (inline enrichment) |
| `technical-guidance` | DA | `/plan-impl`, `/translate`, `/feature`, `/bug`, `/refactor`, `/debt` |
| `dependency-analysis` | DA | `/plan-impl`, `/update`, `/check-deps` |
| `knowledge-base-management` | DA | `/archive` (extraction), `/plan-impl` (consultation), `/lessons` (display) |
| `code-implementation` | DEV | `/submit`, `/run`, `/implement` |
| `unit-test-creation` | DEV | `/submit`, `/run`, `/implement` |
| `task-execution` | DEV | `/submit`, `/run`, `/implement` |
| `self-verification` | DEV | `/submit`, `/run`, `/implement` |
| `result-documentation` | DEV | `/submit`, `/run`, `/implement` |
| `branch-management` | DEV | `/approve` (branch generated by PO, used by DEV) |
| `unit-test-verification` | TST | `/pass`, `/fail`, `/run` |
| `integration-testing` | TST | `/pass`, `/run`, release testing |
| `release-testing` | TST | `/release` gate: full-test-pass |
| `bug-creation` | TST | `/fail`, `/run` (auto bug-fix cycle) |
| `regression-check` | TST | `/pass`, `/run` |
| `test-result-documentation` | TST | `/pass`, `/fail`, `/run` |

---

## Delegation Rules

1. **Query skills** (`/status`, `/list`, `/board`, `/check-deps`, `/plan_summary`, `/overview`) → orchestrator handles directly, no agent needed.

2. **Item creation** (`/feature`, `/bug`, `/refactor`, `/debt`) → orchestrator handles Phase 1 + DA enrichment (Phase 2) inline; delegate to `po` for complex requirement decomposition.

3. **`/run`** → orchestrator handles directly; it chains DEV + TST logic inline without spawning sub-agents per step.

4. **`/approve`, `/deny`** → delegate to `po`.

5. **`/start`, `/archive`, `/sprint`, `/release`, `/blockers`** → delegate to `sm`.

6. **`/plan-impl`, `/security`, `/init_overview`, `/update`, `/translate`, `/lessons`** → delegate to `da`.

7. **`/submit`** → delegate to `dev`.

8. **`/pass`, `/fail`** → delegate to `tst`.

9. **Unknown commands** → list available skills from this registry; do not guess.

---

## Skill Processing Rules (applies to all skills)

1. **Always read both XML files first** — even for creation commands
2. **Check for duplicates before creating** — search existing items by title, description, and affected area
3. **Respect the 5-item limit** — if a command would create/update more than 5 items, process the first 5 and ask for confirmation
4. **Update changelog once per interaction** — one grouped entry, never per item
5. **Confirm after processing** — show: item ID, title, type, status, priority
6. **Keep XML valid** — malformed XML breaks the entire workflow
