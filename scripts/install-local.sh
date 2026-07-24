#!/usr/bin/env bash
# Install skills into a Claude Code skills directory without the plugin system,
# by symlinking each skill folder so edits take effect live.
#   Personal (default): ~/.claude/skills/<name>   (all your projects)
#   Project:  --project -> ./.claude/skills/<name> in the current repo
# Uses a symlink. Use --copy to copy instead.
# Usage: scripts/install-local.sh [--project] [--copy] [skill-name ...]
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$script_dir")"
skills_dir="$root/skills"

project=0
copy=0
names=()
for arg in "$@"; do
    case "$arg" in
        --project) project=1 ;;
        --copy)    copy=1 ;;
        -*)        echo "Unknown option: $arg" >&2; exit 1 ;;
        *)         names+=("$arg") ;;
    esac
done

if [ "$project" -eq 1 ]; then
    target_base="$(pwd)/.claude/skills"
else
    target_base="$HOME/.claude/skills"
fi

if [ "${#names[@]}" -eq 0 ]; then
    for dir in "$skills_dir"/*/; do
        [ -d "$dir" ] && names+=("$(basename "$dir")")
    done
fi

mkdir -p "$target_base"

for name in "${names[@]}"; do
    src="$skills_dir/$name"
    if [ ! -f "$src/SKILL.md" ]; then
        echo "skip ${name}: no such skill" >&2
        continue
    fi
    dest="$target_base/$name"
    if [ -L "$dest" ]; then
        # Existing symlink: remove the link only, never its target.
        rm "$dest"
    elif [ -e "$dest" ]; then
        rm -rf "$dest"
    fi
    if [ "$copy" -eq 1 ]; then
        cp -R "$src" "$dest"
        echo "copied   $name -> $dest"
    else
        ln -s "$src" "$dest"
        echo "linked   $name -> $dest"
    fi
done

echo "Done. Restart Claude Code if the skills directory did not exist before."
