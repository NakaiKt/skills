#!/usr/bin/env bash
# Validate every skill under skills/ against the Agent Skills basics.
# Usage: scripts/validate.sh
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$script_dir")"
skills_dir="$root/skills"
awk_lib="$script_dir/lib/frontmatter.awk"
fail=0

for dir in "$skills_dir"/*/; do
    [ -d "$dir" ] || continue
    name="$(basename "$dir")"
    md="$dir/SKILL.md"

    if [ ! -f "$md" ]; then
        echo "FAIL ${name}: missing SKILL.md"; fail=1; continue
    fi

    # Frontmatter must start on line 1.
    if ! head -n 1 "$md" | grep -qE '^---[[:space:]]*$'; then
        echo "FAIL ${name}: SKILL.md must start with YAML frontmatter (---)"; fail=1; continue
    fi

    fm_name="$(awk -v want=name -f "$awk_lib" "$md")"
    fm_desc="$(awk -v want=desc -f "$awk_lib" "$md")"

    skill_ok=1
    if [ "$fm_name" != "$name" ]; then
        echo "FAIL ${name}: frontmatter name '$fm_name' must equal folder name '$name'"; fail=1; skill_ok=0
    fi
    if ! printf '%s' "$name" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
        echo "FAIL ${name}: name must be lowercase alphanumeric with single hyphens"; fail=1; skill_ok=0
    fi
    if [ -z "$fm_desc" ]; then
        echo "FAIL ${name}: description is required"; fail=1; skill_ok=0
    fi
    if [ "${#name}" -gt 64 ]; then
        echo "FAIL ${name}: name exceeds 64 characters"; fail=1; skill_ok=0
    fi

    if [ "$skill_ok" -eq 1 ]; then echo "ok   $name"; fi
done

if [ "$fail" -ne 0 ]; then
    echo "Validation failed." >&2
    exit 1
fi
echo "All skills valid."
