# Usage Guide

This guide walks through real-world usage patterns for the vibe-coding workflow — from first install to daily development cycles.

For installation instructions see [README.md](README.md).
For the full command reference see [template/SKILL.md](template/SKILL.md).
For the XML schema and workflow rules see [template/CLAUDE-implementation-plan-chapter.md](template/CLAUDE-implementation-plan-chapter.md).

---

## Table of Contents

1. [Starting on a new project](#1-starting-on-a-new-project)
2. [Starting on an existing project](#2-starting-on-an-existing-project)
3. [Core workflows](#3-core-workflows)
   - [Fast path: create and run immediately](#fast-path-create-and-run-immediately)
   - [Normal path: review then run](#normal-path-review-then-run)
   - [Manual path: step by step](#manual-path-step-by-step)
4. [Item types and when to use them](#4-item-types-and-when-to-use-them)
5. [Inline modifiers](#5-inline-modifiers)
6. [Checking status and the board](#6-checking-status-and-the-board)
7. [Sprints and releases](#7-sprints-and-releases)
8. [Security auditing](#8-security-auditing)
9. [Archiving and lessons learned](#9-archiving-and-lessons-learned)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Starting on a new project

After installing the template (see README), open your project in Claude Code and run:

```
/init_overview
```

This performs a full codebase scan and generates two files:

- `ai-docs/overview.xml` — architecture baseline (patterns, dependencies, security, existing features)
- `ai-docs/overview-features-bugs.xml` — active work items (starts empty or pre-populated with discovered issues)

**What to expect:**

```
/init_overview
→ Scanning codebase...
→ Generated overview.xml: 2 patterns, 4 dependencies, 6 features (4 FULL, 2 PARTIAL)
→ Generated overview-features-bugs.xml: 3 [REF] items, 1 security concern (all PENDING)
→ Tip: review PENDING items, /approve to start, or /board for an overview
```

If any discovered features are PARTIAL or have no tests, the agent creates `[REF]` items for them automatically. These are refactoring items that track completing the analysis and adding tests — approve them when you want that coverage work done.

**On a brand-new empty project** with no code yet, `/init_overview` still creates both files with a minimal baseline. Then start adding features normally.

---

## 2. Starting on an existing project

Same as a new project — run `/init_overview` once. The scan reads your existing codebase, maps what exists, and identifies gaps and risks.

After the initial scan, check what was found:

```
/board
```

This shows a Kanban-style view of all items grouped by status. Review the auto-created PENDING items and decide which to approve.

**Keeping the analysis current:**

When your codebase changes significantly (new dependencies, deleted files, renamed modules), re-sync:

```
/update
```

This runs a verification pass — it detects drift between the XML files and the current code, flags stale references, and creates new `[REF]` items for newly discovered features.

---

## 3. Core workflows

### Fast path: create and run immediately

Use this when you know exactly what you want and trust the DA enrichment to plan it well. The `!run` modifier combines create + approve + implement into a single command.

```
/feature Add CSV export to the reports page !run
```

```
/bug Users can't log in with SSO when 2FA is enabled !run
```

```
/refactor Extract auth token logic into a dedicated service !run
```

What happens:
1. Item created with full DA enrichment (tasks, technical constraints, tests, security check)
2. Auto-approved (your command invocation IS the approval)
3. SM starts it, DEV implements, TST verifies — automatically
4. Stops only if: a test fails twice, a blocker is hit, or the item is XL complexity

`!run` is blocked on XL items (too large — decompose first) and PROBLEM items (require human diagnosis).

---

### Normal path: review then run

Use this when you want to inspect the DA's plan before committing to implementation.

**Step 1 — Create the item:**

```
/feature Add password strength indicator to the signup form
```

The agent creates a PENDING item and shows you the full enriched plan: tasks, NFRs, security assessment, and test specifications. Review it.

**Step 2 — Approve (optionally multiple at once):**

```
/approve 14
```

or

```
/approve 14 15 16
```

This sets status to APPROVED and generates the branch name (e.g. `feature/item-14-password-strength`).

**Step 3 — Run:**

```
/run
```

With no arguments, `/run` processes all APPROVED items (up to 5). Or target specific ones:

```
/run 14
```

**Step 4 — Archive completed work:**

```
/archive
```

Moves DONE items to the archive file, extracts lessons learned, and rotates the changelog.

---

### Manual path: step by step

Use this for debugging, learning the workflow, or when you want fine-grained control between each gate.

```
# Create
/feature Add webhook retry logic

# Approve (after reviewing the plan)
/approve 18

# Optionally re-plan with DA before starting
/plan-impl 18

# SM starts the item
/start 18

# DEV implements and submits
/submit 18

# TST verifies
/pass 18
# or if it fails:
/fail 18 "Retry counter not resetting after success"

# Archive when done
/archive
```

---

## 4. Item types and when to use them

| Command | Type | Default priority | When to use |
|---|---|---|---|
| `/feature` | `feature` | MEDIUM | New capability, user-facing or internal |
| `/bug` | `bug` | HIGH | Something is broken; has steps-to-reproduce |
| `/refactor` | `refactoring` | MEDIUM | Structural improvement, no behavior change |
| `/debt` | `tech-debt` | LOW | Known compromise to address later |

**Epics** (XL items grouping multiple features):

```
/feature User authentication system --epic
```

Then decompose it:

```
/translate 20
```

This creates EPIC sub-items (features + enablers) that can be approved and run individually.

**Requirements** (raw business need, not yet designed):

```
/feature Allow customers to manage their own subscriptions --requirement
```

Use `/translate` to break it into epics and features when ready.

**Enablers** (technical prerequisites):

```
/feature Set up Redis session store --enabler ^20
```

The `^20` links it as a sub-item of epic 20.

---

## 5. Inline modifiers

Modifiers are appended to any creation command after the description.

### Priority override

```
/bug Payment gateway returns 500 on retry !critical
/feature Add dark mode support !low
/debt Migrate from deprecated crypto library !high
```

### Security flag

Marks the item as security-relevant and adds a `<security-impact>` block with threat and mitigation details.

```
/feature Add OAuth2 login !security
/bug API returns stack traces in production !security
```

### Dependencies

```
# This feature depends on item 12 being DONE first
/feature Add refresh token rotation @12

# This feature is a sub-item of epic 10
/feature OAuth callback handler ^10

# Both at once
/feature Session revocation ^10 @12
```

### Short-path execution

```
# Create, enrich, approve, and implement in one command
/feature Add loading spinner to the dashboard !run
/bug Password reset email not sent when username has uppercase !run !critical
/refactor Remove duplicate validation logic in user forms !run
```

Modifiers can be combined:

```
/feature Add audit logging for admin actions !high !security !run
```

---

## 6. Checking status and the board

**Single item:**

```
/status 14
→ Item 14 "Password strength indicator" | APPROVED | priority MEDIUM | branch: feature/item-14-password-strength | 4 tasks (0 done)
```

**List items with filters:**

```
/list pending          # all PENDING items
/list approved         # ready to run
/list bug high         # high priority bugs
/list security         # all items with security="true"
/list in_progress      # currently being worked
```

**Kanban board:**

```
/board
→ Shows columns: PENDING | APPROVED | IN_PROGRESS | REVIEW | DONE
```

**Dependency check:**

```
/check-deps 18
→ Shows which items block item 18, and which items 18 blocks
```

**Summary with next actions:**

```
/plan_summary
→ Counts by status/type/priority
→ "Next actionable: items 14, 15 (APPROVED, no blockers)"
```

**Architecture overview:**

```
/overview
→ Patterns, dependencies, environments, security posture from overview.xml
```

---

## 7. Sprints and releases

### Sprints (lightweight grouping, no PO gates)

```
# Group approved items into a sprint
/sprint create 14 15 16

# Check active sprint status
/sprint

# Close sprint when all items are done
/sprint close
```

Sprints auto-create when `/run` is called with 2 or more APPROVED items.

### Releases (formal, with PO approval gates)

```
# Create a release item
/release v2.1.0 --target 2026-03-15
```

A RELEASE item tracks scope, gates (scope-freeze → code-complete → full-test-pass → release-approval), and test results. The PO must approve each gate.

### Blockers

```
# List active blockers
/blockers

# Create a blocker
/blockers "PDF library license incompatible" --blocks 42 43

# Resolve it
/blockers resolve BLK-1
```

---

## 8. Security auditing

**Full audit:**

```
/security
→ Scans all 7 categories: AUTH, INPUT, DATA, NETWORK, CRYPTO, ACCESS, DISCLOSURE
→ Creates PENDING bug items for each finding
→ Updates security section in overview.xml
```

**Focused audit:**

```
/security auth
/security api
/security input
```

**Current posture:**

```
/security status
→ Open concerns, security bugs by status, coverage gaps
```

Security findings are created as HIGH priority bugs (CRITICAL if exploitable without auth). Approve and run them like any other bug:

```
/approve 25 26
/run 25 26
```

---

## 9. Archiving and lessons learned

Run `/archive` periodically to clean up completed work:

```
/archive
→ Moves DONE/DENIED items to overview-features-bugs-archive.xml
→ Registers completed features in overview.xml
→ Extracts non-trivial lessons to ai-docs/lessons-learned.md
→ Rotates changelog if > 30 entries
→ "8 items archived since last full test (last: 2026-02-10). Recommendation: run /full-test."
```

**Lessons learned** are stored by category (Technology, Architecture, Security, Testing, Process) and referenced by the DA in future `/plan-impl` calls to avoid repeating past mistakes.

```
/lessons                    # all lessons
/lessons security           # security category only
/lessons architecture
```

---

## 10. Troubleshooting

### `/run` stops with a PROBLEM

```
⛔ Item 18 blocked — manual intervention needed.
Outcome: PROBLEM — redis connection string missing in staging config
```

Fix the environment issue, then resume:

```
/start 18
```

### `/run` stops after two failed test attempts

```
⛔ Item 14 "Password strength indicator" failed verification after 2 fix attempts.
Bugs created: 15 (attempt 1), 16 (attempt 2).
Please review the failures manually before continuing.
```

Review items 15 and 16, fix manually or adjust the plan:

```
/status 15
/plan-impl 14    # re-plan item 14 with updated approach
/run 14
```

### Blockers preventing `/run` from starting

```
/blockers resolve BLK-2
/run 18
```

### Item has wrong priority or scope after creation

Modify the XML directly (the agent can do this for you) or deny and recreate:

```
/deny 14 "Scope too broad — splitting into sub-features"
/feature Add password strength meter !medium ^10
/feature Add password policy enforcement !high ^10
```

### XML is out of sync with the codebase

```
/update
```

This re-scans and flags any drift — stale file references, missing dependencies, newly discovered features.
