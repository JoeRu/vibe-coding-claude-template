#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# setup.sh — Install vibe-coding-claude-template into a project
#
# Usage:
#   ./setup.sh [TARGET_DIR] [--dry-run]
#   curl -fsSL https://raw.githubusercontent.com/JoeRu/vibe-coding-claude-template/main/setup.sh | bash -s -- [TARGET_DIR] [--dry-run]
# ============================================================

GITHUB_REPO="JoeRu/vibe-coding-claude-template"
GITHUB_BRANCH="main"
GITHUB_RAW="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}/template"

# All files to install (relative to repo root)
FILES=(
  .claude/commands/approve.md
  .claude/commands/archive.md
  .claude/commands/bug.md
  .claude/commands/debt.md
  .claude/commands/deny.md
  .claude/commands/feature.md
  .claude/commands/implement.md
  .claude/commands/init_overview.md
  .claude/commands/list.md
  .claude/commands/overview.md
  .claude/commands/plan_summary.md
  .claude/commands/refactor.md
  .claude/commands/security.md
  .claude/commands/status.md
  .claude/commands/update.md
  .github/prompts/approve.prompt.md
  .github/prompts/archive.prompt.md
  .github/prompts/bug.prompt.md
  .github/prompts/debt.prompt.md
  .github/prompts/deny.prompt.md
  .github/prompts/feature.prompt.md
  .github/prompts/full-test.prompt.md
  .github/prompts/implement.prompt.md
  .github/prompts/init_overview.prompt.md
  .github/prompts/list.prompt.md
  .github/prompts/overview.prompt.md
  .github/prompts/plan_summary.prompt.md
  .github/prompts/refactor.prompt.md
  .github/prompts/security.prompt.md
  .github/prompts/status.prompt.md
  .github/prompts/update.prompt.md
  .github/prompts/update-item.prompt.md
  ai-docs/implementation-plan-template-v3.1.xml
  CLAUDE-implementation-plan-chapter.md
)

# ── Snippets ────────────────────────────────────────────────

CLAUDE_MD_SECTION='
## Implementation Plan Workflow

**IMPORTANT:** Read `CLAUDE-implementation-plan-chapter.md` for the XML-based implementation plan workflow.
All feature requests, bugs, and changes must be tracked in `ai-docs/overview-features-bugs.xml`.

On first encounter with a codebase, run `/init_overview` to generate `ai-docs/overview.xml` and
`ai-docs/overview-features-bugs.xml`. After updating CLAUDE.md or command files, restart Claude Code.
'

COPILOT_SECTION='
## AI Workflow (vibe-coding-claude-template)

AI plan/overview workflows follow prompt files in `.github/prompts/`.
- Use `init_overview.prompt.md` for baseline project scans (generates `ai-docs/overview.xml` and `ai-docs/overview-features-bugs.xml`)
- Use `implement.prompt.md` to execute plan items end-to-end
- Plan artifacts live under `ai-docs/` with schema at `ai-docs/implementation-plan-template-v3.1.xml`
'

# ── Helpers ─────────────────────────────────────────────────

DRY_RUN=false
TARGET_DIR="."
INSTALLED=0
SKIPPED=0
BACKED_UP=0

log()  { echo "[setup] $*"; }
info() { echo "[setup] $*"; }
dry()  { echo "[dry-run] $*"; }

parse_args() {
  for arg in "$@"; do
    case "$arg" in
      --dry-run) DRY_RUN=true ;;
      -*) echo "Unknown option: $arg" >&2; exit 1 ;;
      *)  TARGET_DIR="$arg" ;;
    esac
  done
}

# Detect whether we are running from a local clone or via curl | bash
detect_mode() {
  local script_dir
  # BASH_SOURCE[0] is empty or /dev/stdin when piped through bash
  if [[ -n "${BASH_SOURCE[0]:-}" && "${BASH_SOURCE[0]}" != "/dev/stdin" ]]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -d "${script_dir}/template/.claude/commands" ]]; then
      echo "local:${script_dir}"
      return
    fi
  fi
  echo "curl"
}

backup_file() {
  local dest="$1"
  if [[ -f "$dest" ]]; then
    if $DRY_RUN; then
      dry "Would backup: $dest -> ${dest}.bak"
    else
      cp "$dest" "${dest}.bak"
      log "Backed up: ${dest}.bak"
      (( BACKED_UP++ )) || true
    fi
  fi
}

install_file_local() {
  local src="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  if $DRY_RUN; then
    dry "Would install: $src -> $dest"
    return
  fi

  mkdir -p "$dest_dir"
  backup_file "$dest"
  cp "$src" "$dest"
  log "Installed: $dest"
  (( INSTALLED++ )) || true
}

install_file_curl() {
  local rel_path="$1"
  local dest="$2"
  local dest_dir
  dest_dir="$(dirname "$dest")"
  local url="${GITHUB_RAW}/${rel_path}"

  if $DRY_RUN; then
    dry "Would download: $url -> $dest"
    return
  fi

  mkdir -p "$dest_dir"
  backup_file "$dest"

  if command -v curl &>/dev/null; then
    curl -fsSL "$url" -o "$dest"
  elif command -v wget &>/dev/null; then
    wget -q "$url" -O "$dest"
  else
    echo "Error: neither curl nor wget found. Cannot download files." >&2
    exit 1
  fi

  log "Downloaded: $dest"
  (( INSTALLED++ )) || true
}

append_if_absent() {
  local file="$1"
  local marker="$2"
  local content="$3"

  if $DRY_RUN; then
    if [[ -f "$file" ]] && grep -qF "$marker" "$file"; then
      dry "Skip append (marker present): $file"
    else
      dry "Would append section to: $file"
    fi
    return
  fi

  if [[ -f "$file" ]]; then
    if grep -qF "$marker" "$file"; then
      log "Section already present, skipping: $file"
      (( SKIPPED++ )) || true
      return
    fi
    # Ensure file ends with a newline before appending
    [[ -z "$(tail -c1 "$file")" ]] || echo "" >> "$file"
    printf '%s\n' "$content" >> "$file"
    log "Appended section to: $file"
  else
    log "Creating: $file"
    printf '%s\n' "$content" > "$file"
  fi
}

# ── Main ─────────────────────────────────────────────────────

main() {
  parse_args "$@"

  # Resolve target directory
  TARGET_DIR="${TARGET_DIR%/}"  # strip trailing slash
  if [[ ! -d "$TARGET_DIR" ]] && ! $DRY_RUN; then
    log "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
  fi

  local mode
  mode="$(detect_mode)"

  if [[ "$mode" == curl ]]; then
    info "Mode: curl (downloading from GitHub: ${GITHUB_REPO}@${GITHUB_BRANCH})"
  else
    local src_dir="${mode#local:}"
    info "Mode: local (source: $src_dir)"
  fi

  info "Target: $(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")"
  $DRY_RUN && info "DRY RUN — no files will be written"
  echo ""

  # ── Install files ──────────────────────────────────────────
  for rel in "${FILES[@]}"; do
    local dest="${TARGET_DIR}/${rel}"
    if [[ "$mode" == curl ]]; then
      install_file_curl "$rel" "$dest"
    else
      local src_dir="${mode#local:}"
      local src="${src_dir}/template/${rel}"
      if [[ ! -f "$src" ]]; then
        echo "Warning: source file not found, skipping: $src" >&2
        (( SKIPPED++ )) || true
        continue
      fi
      install_file_local "$src" "$dest"
    fi
  done

  # ── Update CLAUDE.md ───────────────────────────────────────
  local claude_md="${TARGET_DIR}/CLAUDE.md"
  append_if_absent \
    "$claude_md" \
    "## Implementation Plan Workflow" \
    "$CLAUDE_MD_SECTION"

  # ── Update .github/copilot-instructions.md ─────────────────
  local copilot_file="${TARGET_DIR}/.github/copilot-instructions.md"
  if $DRY_RUN; then
    dry "Would ensure directory: ${TARGET_DIR}/.github/"
  else
    mkdir -p "${TARGET_DIR}/.github"
  fi
  append_if_absent \
    "$copilot_file" \
    "vibe-coding-claude-template" \
    "$COPILOT_SECTION"

  # ── Summary ────────────────────────────────────────────────
  echo ""
  if $DRY_RUN; then
    info "Dry run complete. No files were modified."
  else
    info "Done! Installed: ${INSTALLED}  Backed up: ${BACKED_UP}  Skipped: ${SKIPPED}"
    echo ""
    echo "Next steps:"
    echo "  1. Open your project in Claude Code"
    echo "  2. Run /init_overview to generate ai-docs/overview.xml and ai-docs/overview-features-bugs.xml"
    echo "  3. Restart Claude Code if you modified CLAUDE.md"
  fi
}

main "$@"
