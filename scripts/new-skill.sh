#!/usr/bin/env bash
# Scaffold a new skill from templates/skill-template.
# Usage: scripts/new-skill.sh <skill-name>
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="${1:-}"

if [[ -z "$NAME" ]]; then
  echo "Usage: scripts/new-skill.sh <skill-name>" >&2
  exit 1
fi

# Validate name against the Agent Skills naming rules.
if ! [[ "$NAME" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
  echo "Invalid name '$NAME'. Use lowercase letters, numbers, and single hyphens only." >&2
  exit 1
fi

DEST="$ROOT/skills/$NAME"
if [[ -e "$DEST" ]]; then
  echo "Skill already exists: $DEST" >&2
  exit 1
fi

cp -r "$ROOT/templates/skill-template" "$DEST"
# Set the name in the frontmatter to match the folder.
sed -i "s/^name: skill-template$/name: $NAME/" "$DEST/SKILL.md"

echo "Created skills/$NAME/SKILL.md"
echo "Next: edit the description and instructions, then run scripts/validate.sh"
