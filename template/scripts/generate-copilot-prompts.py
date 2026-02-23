#!/usr/bin/env python3
"""
generate-copilot-prompts.py
===========================
Generates GitHub Copilot equivalent files from Claude Code sources.

  Prompts:
    .claude/commands/*.md  +  scripts/copilot-headers.json
    → .github/prompts/*.prompt.md

  Agents:
    .claude/agents/*.md  +  scripts/copilot-agent-headers.json
    → .github/agents/*.md
    Agent descriptions are auto-extracted from the Claude frontmatter unless
    overridden in copilot-agent-headers.json.

Usage:
  python3 scripts/generate-copilot-prompts.py [--check] [--prompts-only] [--agents-only]

  --check          Dry-run: report stale files, exit 1 if any differ. (CI-safe)
  --prompts-only   Only process prompt files.
  --agents-only    Only process agent files.
"""

import json
import sys
from pathlib import Path


# ── constants ─────────────────────────────────────────────────────────────────

AGENT_VALUE = "agent"

PROMPT_BANNER = (
    "<!-- GENERATED FILE — do not edit directly.\n"
    "     Source:   .claude/commands/{stem}.md\n"
    "     Metadata: scripts/copilot-headers.json\n"
    "     Regenerate: python3 scripts/generate-copilot-prompts.py -->\n"
)

AGENT_BANNER = (
    "<!-- GENERATED FILE — do not edit directly.\n"
    "     Source:   .claude/agents/{stem}.md\n"
    "     Metadata: scripts/copilot-agent-headers.json\n"
    "     Regenerate: python3 scripts/generate-copilot-prompts.py -->\n"
)


# ── YAML helpers ──────────────────────────────────────────────────────────────

def yaml_str(s: str) -> str:
    """Single-quoted YAML string with internal single-quote escaping."""
    return "'" + s.replace("'", "''") + "'"


def build_prompt_frontmatter(meta: dict) -> str:
    lines = ["---"]
    lines.append(f"description: {yaml_str(meta['description'])}")
    lines.append(f"name: {yaml_str(meta['name'])}")
    if "argument-hint" in meta:
        lines.append(f"argument-hint: {yaml_str(meta['argument-hint'])}")
    lines.append(f"agent: {yaml_str(AGENT_VALUE)}")
    lines.append("---")
    return "\n".join(lines) + "\n"


def build_agent_frontmatter(name: str, description: str) -> str:
    lines = ["---"]
    lines.append(f"name: {yaml_str(name)}")
    lines.append(f"description: {yaml_str(description)}")
    lines.append("---")
    return "\n".join(lines) + "\n"


def parse_claude_frontmatter(content: str) -> tuple[dict, str]:
    """Strip the leading YAML frontmatter from a Claude agent file.

    Returns (fields_dict, body_text).
    Handles multi-line description values by joining continuation lines.
    """
    if not content.startswith("---"):
        return {}, content

    end = content.find("---", 3)
    if end == -1:
        return {}, content

    fm_text = content[3:end]
    body    = content[end + 3:].lstrip("\n")

    fields: dict[str, str] = {}
    current_key = None
    for raw_line in fm_text.splitlines():
        if ":" in raw_line and not raw_line.startswith(" "):
            key, _, value = raw_line.partition(":")
            current_key = key.strip()
            fields[current_key] = value.strip()
        elif current_key and raw_line.startswith(" "):
            fields[current_key] += " " + raw_line.strip()

    return fields, body


# ── content builders ──────────────────────────────────────────────────────────

def make_prompt_content(stem: str, meta: dict, source_text: str) -> str:
    return (
        build_prompt_frontmatter(meta)
        + PROMPT_BANNER.format(stem=stem)
        + "\n"
        + source_text
    )


def make_agent_content(stem: str, copilot_name: str, description: str, body: str) -> str:
    return (
        build_agent_frontmatter(copilot_name, description)
        + AGENT_BANNER.format(stem=stem)
        + "\n"
        + body
    )


# ── generic file processor ────────────────────────────────────────────────────

def process(
    entries:      dict,          # stem → metadata dict
    src_dir:      Path,
    dst_dir:      Path,
    src_suffix:   str,
    dst_suffix:   str,
    build_fn,                    # (stem, src_path, entry) → str
    check_mode:   bool,
    label:        str,
) -> tuple[int, int, int]:
    """Process a set of source→destination file pairs.

    Returns (ok_count, stale_count, missing_count).
    """
    ok = stale = missing = 0

    for stem, entry in entries.items():
        src = src_dir / f"{stem}{src_suffix}"
        dst = dst_dir / f"{stem}{dst_suffix}"

        if not src.exists():
            print(f"  WARNING [{label}]: source not found — {src}", file=sys.stderr)
            missing += 1
            continue

        new_content = build_fn(stem, src, entry)

        if check_mode:
            if dst.exists() and dst.read_text(encoding="utf-8") == new_content:
                print(f"  OK:     {dst.name}")
                ok += 1
            else:
                tag = "STALE  " if dst.exists() else "MISSING"
                print(f"  {tag}: {dst.name}")
                stale += 1
        else:
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_text(new_content, encoding="utf-8")
            print(f"  Generated: {dst.name}")
            ok += 1

    return ok, stale, missing


# ── top-level runners ─────────────────────────────────────────────────────────

def run_prompts(template_dir: Path, check_mode: bool) -> tuple[int, int, int]:
    headers_file = template_dir / "scripts" / "copilot-headers.json"
    with open(headers_file, encoding="utf-8") as f:
        headers: dict = json.load(f)
    headers.pop("_comment", None)

    def build(stem: str, src: Path, meta: dict) -> str:
        return make_prompt_content(stem, meta, src.read_text(encoding="utf-8"))

    print(f"\nPrompts ({len(headers)}):")
    return process(
        entries    = headers,
        src_dir    = template_dir / ".claude" / "commands",
        dst_dir    = template_dir / ".github" / "prompts",
        src_suffix = ".md",
        dst_suffix = ".prompt.md",
        build_fn   = build,
        check_mode = check_mode,
        label      = "prompt",
    )


def run_agents(template_dir: Path, check_mode: bool) -> tuple[int, int, int]:
    headers_file = template_dir / "scripts" / "copilot-agent-headers.json"
    with open(headers_file, encoding="utf-8") as f:
        agent_headers: dict = json.load(f)
    agent_headers.pop("_comment", None)

    def build(stem: str, src: Path, entry: dict) -> str:
        source_text       = src.read_text(encoding="utf-8")
        claude_fm, body   = parse_claude_frontmatter(source_text)
        copilot_name      = entry.get("name", stem)
        # Use explicit description from JSON; fall back to the one in the Claude frontmatter
        description       = entry.get("description") or claude_fm.get("description", "")
        return make_agent_content(stem, copilot_name, description, body)

    print(f"\nAgents ({len(agent_headers)}):")
    return process(
        entries    = agent_headers,
        src_dir    = template_dir / ".claude" / "agents",
        dst_dir    = template_dir / ".github" / "agents",
        src_suffix = ".md",
        dst_suffix = ".md",
        build_fn   = build,
        check_mode = check_mode,
        label      = "agent",
    )


# ── main ──────────────────────────────────────────────────────────────────────

def main(argv: list[str]) -> int:
    check_mode   = "--check"        in argv
    prompts_only = "--prompts-only" in argv
    agents_only  = "--agents-only"  in argv

    do_prompts = not agents_only
    do_agents  = not prompts_only

    template_dir = Path(__file__).resolve().parent.parent

    total_ok = total_stale = total_missing = 0

    if do_prompts:
        ok, stale, missing = run_prompts(template_dir, check_mode)
        total_ok += ok; total_stale += stale; total_missing += missing

    if do_agents:
        ok, stale, missing = run_agents(template_dir, check_mode)
        total_ok += ok; total_stale += stale; total_missing += missing

    print()
    if check_mode:
        if total_stale:
            print(f"{total_stale} file(s) out of date. Run: python3 scripts/generate-copilot-prompts.py")
            return 1
        print(f"All {total_ok} generated files are up-to-date.")
        return 0
    else:
        print(f"Done. Generated {total_ok} file(s).")
        if total_missing:
            print(f"Skipped {total_missing} entries with no source file.")
        return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
