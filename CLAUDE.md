# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a **template repository** for structured vibe-coding workflows. It provides XML-based implementation plan tooling, slash commands, and prompt files to bring discipline to AI-assisted development. There is no application source code here — the deliverables are the workflow files themselves.

## Repository Structure

All installable template files live under `template/`. The `setup.sh` and `README.md` are repo-level meta-files and are not installed into target projects.

```
template/
  .claude/
    agents/
      po.md     — Product Owner sub-agent
      sm.md     — Scrum Master sub-agent
      da.md     — DevSecOps Architect sub-agent
      dev.md    — Developer sub-agent
      tst.md    — Tester sub-agent
    commands/
      *.md      — slash command definitions for Claude Code
  .github/
    copilot-instructions.md      — Copilot baseline instructions
    prompts/*.prompt.md          — equivalent prompts for GitHub Copilot
  ai-docs/
    implementation-plan-template.xml  — XML schema reference
  AGENT.md                            — agent orchestration guide (embed in CLAUDE.md)
  SKILL.md                            — skills reference and capability matrix (embed in CLAUDE.md)
  CLAUDE-roles-chapter.md             — role definitions, lifecycle gates, swimlane
  CLAUDE-implementation-plan-chapter.md — XML workflow rules and full command reference
setup.sh                         — installer script
README.md                        — project documentation
```

## Key Files

- `template/AGENT.md` — agent orchestration guide; explains how to route commands to role agents via the Task tool
- `template/SKILL.md` — skills reference; maps all slash commands to agents and capabilities
- `template/CLAUDE-roles-chapter.md` — role definitions (PO, SM, DA, DEV, TST), lifecycle gates, swimlane diagram
- `template/CLAUDE-implementation-plan-chapter.md` — XML workflow rules, item types, full command specifications
- `template/.claude/agents/*.md` — sub-agent definitions installed into target projects (used by Task tool)
- `template/.claude/commands/*.md` — slash command definitions installed into target projects
- `template/ai-docs/implementation-plan-template.xml` — XML schema; read this when writing or validating plan XML
- `template/.github/prompts/*.prompt.md` — GitHub Copilot equivalents
- `setup.sh` — idempotent installer; downloads from `template/` on GitHub or copies from local clone

## Agent Orchestration

This repository uses **role-based sub-agents** that the main Claude instance spawns via the Task tool. Each agent implements one workflow role.

| Agent | Role | Commands it handles |
|---|---|---|
| `po` | Product Owner | `/feature`, `/approve`, `/deny` |
| `sm` | Scrum Master | `/start`, `/archive`, `/release`, `/blockers`, `/sprint` |
| `da` | DevSecOps Architect | `/plan-impl`, `/security`, `/init_overview`, `/update`, `/translate`, `/lessons` (extraction) |
| `dev` | Developer | `/submit` + implementation |
| `tst` | Tester | `/pass`, `/fail` |

Query commands (`/status`, `/list`, `/board`, `/plan_summary`, `/overview`) are handled directly by the orchestrator without delegation.

See `template/AGENT.md` for the full orchestration guide and `template/SKILL.md` for the complete skill-to-agent mapping.

## Item Lifecycle

```
PENDING ──[/approve]──► APPROVED ──[/plan-impl]──► PLANNED ──[/start]──► IN_PROGRESS
   │                                                                           │
[/deny]                                                                   [/submit]
   │                                                                           ▼
DENIED                                                                      REVIEW
                                                                        ┌──────┴──────┐
                                                                     [/pass]       [/fail]
                                                                        ▼             ▼
                                                                  DONE → [/archive] FAILED + BUG
                                                                    ▼
                                                                ARCHIVED
```

- IDs are unique integers across all items (never reuse)
- Branch naming: `{type}/item-{ID}-{slug}` — generated at APPROVED gate by PO
- XL complexity items must be decomposed into sub-items with `parent="ID"`
- PLANNED and REVIEW are optional for simple items (S/M complexity)
- Every lifecycle transition adds a `<workflow-log>` entry with the owning role

## Slash Commands (Claude Code)

**Item creation** (→ PENDING, delegate to `po` or `da`):

| Command | Agent | Purpose |
|---|---|---|
| `/feature <desc>` | PO | Create feature item (default priority: MEDIUM) |
| `/bug <desc>` | PO / TST | Create bug item (default priority: HIGH) |
| `/refactor <desc>` | DA | Create refactoring item (default priority: MEDIUM) |
| `/debt <desc>` | DA | Create tech-debt item (default priority: LOW) |

**Lifecycle transitions** (delegate to owning agent):

| Command | Agent | Transition |
|---|---|---|
| `/approve <ID...>` | PO | PENDING → APPROVED + branch name |
| `/deny <ID> [reason]` | PO | PENDING → DENIED + archive |
| `/plan-impl <ID>` | DA | APPROVED → PLANNED + impl plan |
| `/start <ID>` | SM | PLANNED → IN_PROGRESS |
| `/submit <ID>` | DEV | IN_PROGRESS → REVIEW |
| `/pass <ID>` | TST | REVIEW → DONE |
| `/fail <ID> [reason]` | TST | REVIEW → FAILED + new BUG |

**Management** (delegate to agent):

| Command | Agent | Purpose |
|---|---|---|
| `/archive` | SM | Archive eligible DONE/DENIED items to archive file; extract lessons; rotate changelog |
| `/sprint [create\|close] [IDs]` | SM | Create / view / close sprint groupings (2–5 items, lightweight) |
| `/release <version>` | SM | Create formal release coordination item (PO gates) |
| `/blockers [...]` | SM | List / create / resolve blockers |
| `/translate <ID>` | DA | Decompose REQUIREMENT → EPICs + FEATUREs |
| `/security [area]` | DA | Run security audit (full or focused) |
| `/init_overview` | DA | Initial scan → generate both XML files |
| `/update` | DA | Re-scan and sync XML files with current codebase |
| `/lessons [category]` | DA | Show lessons learned knowledge base (read-only) |

**Queries** (orchestrator, no delegation):

| Command | Purpose |
|---|---|
| `/status <ID>` | Show item status (checks archive file if not in active plan) |
| `/list [filter]` | List items by status, type, or priority |
| `/board` | Kanban view of all items by status |
| `/check-deps <ID>` | Show dependency tree |
| `/plan_summary` | Summary with next actionable items |
| `/overview` | Architecture summary from overview.xml |

Copilot users: equivalent prompts are in `.github/prompts/`.

For the full skill specification including inline modifiers and processing rules, see `template/SKILL.md`.

## Copilot Prompt and Agent Generation

`.github/prompts/*.prompt.md` and `.github/agents/*.md` are **generated** — do not edit them directly.

| Source (edit here) | Config (metadata) | Generated output |
|---|---|---|
| `.claude/commands/*.md` | `scripts/copilot-headers.json` | `.github/prompts/*.prompt.md` |
| `.claude/agents/*.md` | `scripts/copilot-agent-headers.json` | `.github/agents/*.md` |

The generator strips the Claude-specific frontmatter from agent files (`tools:` etc.) and replaces it with Copilot-compatible frontmatter (`name`, `description`). Agent descriptions are auto-extracted from the Claude source unless overridden in the JSON config.

**After editing any command or agent file:**
```bash
python3 template/scripts/generate-copilot-prompts.py
# then commit source + generated files together
```

**Targeted regeneration:**
```bash
python3 template/scripts/generate-copilot-prompts.py --prompts-only
python3 template/scripts/generate-copilot-prompts.py --agents-only
```

**Verify nothing is stale (CI-safe):**
```bash
python3 template/scripts/generate-copilot-prompts.py --check   # exits 1 if stale
```

**Standalone prompts** (no command counterpart — edit directly, never overwritten):
- `template/.github/prompts/full-test.prompt.md`
- `template/.github/prompts/update-item.prompt.md`

**To add a new command:**
1. Create `template/.claude/commands/{name}.md`
2. Add entry to `template/scripts/copilot-headers.json`
3. Run the generator

**To add a new agent:**
1. Create `template/.claude/agents/{name}.md` (with Claude frontmatter: `name`, `description`, `tools`)
2. Add entry to `template/scripts/copilot-agent-headers.json`
3. Run the generator

## XML Conventions

- All dates in ISO 8601 (`YYYY-MM-DD`)
- `depends-on` and `parent` reference item IDs (comma-separated)
- Complexity: `S` (< 1 day, single file) · `M` (1–3 days) · `L` (3–7 days) · `XL` (epic, must decompose)
- Security-relevant items carry `security="true"` and a `<security-impact>` block
- `[REF]` items link incomplete/untested features back to `overview.xml` via `ref-feature="CF-ID"`
- Keep XML valid and well-formed at all times — malformed XML breaks the entire workflow
- `overview-features-bugs.xml` holds only **active** items and the **last 30** changelog entries
- Archived items live in `overview-features-bugs-archive.xml` (loaded on demand, not at session start)
- SPRINT items use `<sprint id="SPR-N" ...>` (not `<item>`); only one may be ACTIVE at a time
- `<done-since-last-fulltest>` in metadata tracks items archived since the last full test run
