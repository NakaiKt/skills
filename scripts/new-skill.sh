#!/usr/bin/env bash
# Scaffold a new skill from templates/skill-template.
# Usage: scripts/new-skill.sh <skill-name>
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$script_dir")"

name="${1:-}"
if [ -z "$name" ]; then
    echo "Usage: scripts/new-skill.sh <skill-name>" >&2
    exit 1
fi

# Validate name against the Agent Skills naming rules.
if ! printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    echo "Invalid name '$name'. Use lowercase letters, numbers, and single hyphens only." >&2
    exit 1
fi

dest="$root/skills/$name"
if [ -e "$dest" ]; then
    echo "Skill already exists: $dest" >&2
    exit 1
fi

template="$root/templates/skill-template"
cp -R "$template" "$dest"

# Set the name in the frontmatter to match the folder.
md="$dest/SKILL.md"
# Portable in-place edit (GNU and BSD/macOS sed differ on -i).
tmp="$(mktemp)"
sed 's/^name: skill-template$/name: '"$name"'/' "$md" > "$tmp"
mv "$tmp" "$md"

echo "Created skills/$name/SKILL.md"
echo "Next: edit the description and instructions, then run scripts/validate.sh"
