#!/usr/bin/env bash
# Install skills into a Claude Code skills directory without using the plugin
# system, by symlinking each skill folder. Edits then take effect live.
#   Personal (default): ~/.claude/skills/<name>   (all your projects)
#   Project:  --project  -> ./.claude/skills/<name> in the current repo
# Use --copy to copy instead of symlink.
# Usage: scripts/install-local.sh [--project] [--copy] [skill-name ...]
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"

target_base="$HOME/.claude/skills"
mode="symlink"
names=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) target_base="$PWD/.claude/skills" ;;
    --copy) mode="copy" ;;
    -*) echo "Unknown option: $1" >&2; exit 1 ;;
    *) names+=("$1") ;;
  esac
  shift
done

if [[ "${#names[@]}" -eq 0 ]]; then
  for dir in "$SKILLS_DIR"/*/; do names+=("$(basename "$dir")"); done
fi

mkdir -p "$target_base"

for name in "${names[@]}"; do
  src="$SKILLS_DIR/$name"
  [[ -f "$src/SKILL.md" ]] || { echo "skip $name: no such skill" >&2; continue; }
  dest="$target_base/$name"
  rm -rf "$dest"
  if [[ "$mode" == "copy" ]]; then
    cp -r "$src" "$dest"; echo "copied   $name -> $dest"
  else
    ln -s "$src" "$dest"; echo "linked   $name -> $dest"
  fi
done

echo "Done. Restart Claude Code if the skills directory did not exist before."
