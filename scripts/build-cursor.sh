#!/usr/bin/env bash
# Generate Cursor Project Rules (.cursor/rules/<name>.mdc) from skills/.
# Each skill becomes an "Agent Requested" rule: Cursor's agent pulls it in
# based on the description, mirroring how Claude selects Agent Skills.
#
#   Default:    dist/cursor/.cursor/rules/<name>.mdc   (self-contained, inspectable)
#   --project:  ./.cursor/rules/<name>.mdc in the current directory
#
# A skill's references/ folder is copied to .cursor/rules/<name>/references/ and
# the body's relative links are rewritten so they still resolve; the agent can
# then open those files with its own tools when it needs the detail.
# Usage: scripts/build-cursor.sh [--project] [skill-name ...]   (no names = all)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$script_dir")"
skills_dir="$root/skills"
awk_lib="$script_dir/lib/frontmatter.awk"

project=0
names=()
for arg in "$@"; do
    case "$arg" in
        --project) project=1 ;;
        -*)        echo "Unknown option: $arg" >&2; exit 1 ;;
        *)         names+=("$arg") ;;
    esac
done

if [ "$project" -eq 1 ]; then
    base="$(pwd)"
else
    base="$root/dist/cursor"
fi
rules_dir="$base/.cursor/rules"
mkdir -p "$rules_dir"

if [ "${#names[@]}" -eq 0 ]; then
    for dir in "$skills_dir"/*/; do
        [ -d "$dir" ] && names+=("$(basename "$dir")")
    done
fi

# Print a SKILL.md body: everything after the closing frontmatter ---.
skill_body() {
    awk '
        /^---[[:space:]]*$/ { fm++; if (fm <= 2) next }
        fm >= 2 { print }
    ' "$1"
}

for name in "${names[@]}"; do
    src="$skills_dir/$name"
    md="$src/SKILL.md"
    if [ ! -f "$md" ]; then
        echo "skip ${name}: no skills/$name/SKILL.md" >&2
        continue
    fi

    desc="$(awk -v want=desc -f "$awk_lib" "$md")"
    body="$(skill_body "$md")"

    # If the skill ships references/, copy them beside the rule and point the
    # body's relative links at the copy (relative to <name>.mdc).
    if [ -d "$src/references" ]; then
        ref_dest="$rules_dir/$name"
        [ -e "$ref_dest" ] && rm -rf "$ref_dest"
        mkdir -p "$ref_dest"
        cp -R "$src/references" "$ref_dest/references"
        body="$(printf '%s' "$body" | sed "s#references/#$name/references/#g")"
    fi

    # Cursor .mdc frontmatter: description drives auto-selection; alwaysApply
    # false + no globs = "Agent Requested" (the model decides when to load it).
    desc_esc="$(printf '%s' "$desc" | sed 's/"/\\"/g')"
    out="$rules_dir/$name.mdc"
    {
        echo '---'
        echo "description: \"$desc_esc\""
        echo 'globs:'
        echo 'alwaysApply: false'
        echo '---'
        echo ''
        printf '%s\n' "$body"
    } > "$out"
    echo "built .cursor/rules/$name.mdc"
done

echo ""
echo "Done. Rules written under $rules_dir"
if [ "$project" -ne 1 ]; then
    echo "Copy dist/cursor/.cursor into a project root, or re-run with --project from that project."
fi
echo "Notion skills also need Cursor MCP configured (Settings -> MCP -> add the Notion server)."
