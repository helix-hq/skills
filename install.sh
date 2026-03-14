#!/usr/bin/env bash
# install.sh — Symlink skills from this repo into agent workspaces
# Usage: ./install.sh [--dry-run]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SCRIPT_DIR/install.json"
DRY_RUN=false

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install with: brew install jq" >&2
  exit 1
fi

if [[ ! -f "$CONFIG" ]]; then
  echo "Error: install.json not found at $CONFIG" >&2
  exit 1
fi

expand_path() {
  echo "${1/#\~/$HOME}"
}

resolve_target() {
  local target_name="$1"
  local raw
  raw=$(jq -r --arg t "$target_name" '.targets[$t] // empty' "$CONFIG")
  if [[ -z "$raw" ]]; then
    echo ""
    return
  fi
  expand_path "$raw"
}

# Process each skill
jq -r '.skills | to_entries[] | .key as $skill | .value[] | "\($skill) \(.)"' "$CONFIG" | while read -r skill agent; do
  skill_src="$SCRIPT_DIR/$skill"
  if [[ ! -d "$skill_src" ]]; then
    echo "⚠️  Skill directory not found: $skill_src (skipping)"
    continue
  fi

  target_dir=$(resolve_target "$agent")
  if [[ -z "$target_dir" ]]; then
    echo "⚠️  Unknown target '$agent' for skill '$skill' (skipping)"
    continue
  fi

  dest="$target_dir/$skill"

  # Already correctly linked
  if [[ -L "$dest" && "$(readlink "$dest")" == "$skill_src" ]]; then
    echo "✓  $skill → $agent (already linked)"
    continue
  fi

  # Remove stale symlink or directory
  if [[ -L "$dest" || -e "$dest" ]]; then
    if $DRY_RUN; then
      echo "🔄 $skill → $agent (would replace existing)"
      continue
    fi
    echo "🔄 $skill → $agent (replacing existing)"
    rm -rf "$dest"
  else
    if $DRY_RUN; then
      echo "🔗 $skill → $agent (would link)"
      continue
    fi
  fi

  mkdir -p "$target_dir"
  ln -s "$skill_src" "$dest"
  echo "🔗 $skill → $agent (linked)"
done

echo ""
if $DRY_RUN; then
  echo "Dry run complete. No changes made."
else
  echo "Install complete."
fi
