# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a **template repository** for structured vibe-coding workflows. It provides XML-based implementation plan tooling, slash commands, and prompt files to bring discipline to AI-assisted development. There is no application source code here — the deliverables are the workflow files themselves.

## Repository Structure

All installable template files live under `template/`. The `setup.sh` and `README.md` are repo-level meta-files and are not installed into target projects.

```
template/
  .claude/commands/*.md          — slash command definitions for Claude Code
  .github/
    copilot-instructions.md      — Copilot baseline instructions
    prompts/*.prompt.md          — equivalent prompts for GitHub Copilot
  ai-docs/
    implementation-plan-template.xml  — XML schema reference
  CLAUDE-implementation-plan-chapter.md   — the chapter to embed in CLAUDE.md
setup.sh                         — installer script
README.md                        — project documentation
requirements.md                  — extended role/capability workflow reference
```

## Key Files

- `template/CLAUDE-implementation-plan-chapter.md` — core workflow chapter; this is what gets embedded in users' CLAUDE.md
- `template/ai-docs/implementation-plan-template.xml` — XML schema; read this when writing or validating plan XML
- `template/.claude/commands/*.md` — slash command definitions installed into target projects
- `template/.github/prompts/*.prompt.md` — GitHub Copilot equivalents
- `setup.sh` — idempotent installer; downloads from `template/` on GitHub or copies from local clone

## Item Lifecycle

```
BACKLOG → PENDING → APPROVED → IN_PROGRESS → DONE
                      └──→ DENIED
```

- IDs are unique integers across all items (never reuse)
- Branch naming: `{type}/item-{ID}-{slug}`
- XL complexity items must be decomposed into sub-items with `parent="ID"`
- Every `/implement` invocation produces exactly one changelog entry

## Slash Commands (Claude Code)

| Command | Purpose |
|---|---|
| `/init_overview` | Initial scan → generate both XML files |
| `/update` | Re-scan and sync XML files with current codebase |
| `/implement [ID...]` | Implement APPROVED items (max 5 at once) |
| `/approve <ID...>` | Approve items and generate branch names |
| `/deny <ID> [reason]` | Deny and immediately archive an item |
| `/status <ID>` | Show item status, tasks, and dependencies |
| `/list [filter]` | List items by status, type, or priority |
| `/archive` | Archive eligible DONE/DENIED items |
| `/plan_summary` | Show plan summary with next actionable items |
| `/overview` | Show architecture summary from overview.xml |
| `/security [area]` | Run security audit (full or focused) |
| `/bug <desc>` | Create bug item (default priority: HIGH) |
| `/feature <desc>` | Create feature item (default priority: MEDIUM) |
| `/refactor <desc>` | Create refactoring item (default priority: MEDIUM) |
| `/debt <desc>` | Create tech-debt item (default priority: LOW) |

Copilot users: equivalent prompts are in `.github/prompts/`.

## XML Conventions

- All dates in ISO 8601 (`YYYY-MM-DD`)
- `depends-on` and `parent` reference item IDs (comma-separated)
- Complexity: `S` (< 1 day, single file) · `M` (1–3 days) · `L` (3–7 days) · `XL` (epic, must decompose)
- Security-relevant items carry `security="true"` and a `<security-impact>` block
- `[REF]` items link incomplete/untested features back to `overview.xml` via `ref-feature="CF-ID"`
- Keep XML valid and well-formed at all times — malformed XML breaks the entire workflow
