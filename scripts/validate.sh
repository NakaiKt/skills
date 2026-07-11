#!/usr/bin/env bash
# Validate every skill under skills/ against the Agent Skills basics.
# Prefers the official `skills-ref` validator if installed; otherwise runs
# a lightweight built-in check.
# Usage: scripts/validate.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
fail=0

for dir in "$SKILLS_DIR"/*/; do
  [[ -d "$dir" ]] || continue
  name="$(basename "$dir")"
  md="$dir/SKILL.md"

  if [[ ! -f "$md" ]]; then
    echo "FAIL $name: missing SKILL.md"; fail=1; continue
  fi

  if command -v skills-ref >/dev/null 2>&1; then
    skills-ref validate "$dir" || fail=1
    continue
  fi

  # Built-in checks -------------------------------------------------------
  # Frontmatter must start on line 1.
  if [[ "$(head -n1 "$md")" != "---" ]]; then
    echo "FAIL $name: SKILL.md must start with YAML frontmatter (---)"; fail=1; continue
  fi

  fm_name="$(sed -n 's/^name:[[:space:]]*//p' "$md" | head -n1)"
  fm_desc="$(sed -n 's/^description:[[:space:]]*//p' "$md" | head -n1)"

  if [[ "$fm_name" != "$name" ]]; then
    echo "FAIL $name: frontmatter name '$fm_name' must equal folder name '$name'"; fail=1
  fi
  if ! [[ "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "FAIL $name: name must be lowercase alphanumeric with single hyphens"; fail=1
  fi
  if [[ -z "$fm_desc" ]]; then
    echo "FAIL $name: description is required"; fail=1
  fi
  if [[ "${#name}" -gt 64 ]]; then
    echo "FAIL $name: name exceeds 64 characters"; fail=1
  fi

  [[ "$fail" -eq 0 ]] && echo "ok   $name"
done

if [[ "$fail" -ne 0 ]]; then
  echo "Validation failed." >&2
  exit 1
fi
echo "All skills valid."
