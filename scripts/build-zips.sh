#!/usr/bin/env bash
# Package each skill as dist/<name>.zip for upload to the Claude apps
# (Settings -> Capabilities -> Skills -> Upload skill).
# Each archive contains a top-level <name>/ folder with SKILL.md inside.
# Usage: scripts/build-zips.sh [skill-name ...]   (no args = all skills)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(dirname "$script_dir")"
skills_dir="$root/skills"
dist="$root/dist"

mkdir -p "$dist"

names=("$@")
if [ "${#names[@]}" -eq 0 ]; then
    for dir in "$skills_dir"/*/; do
        [ -d "$dir" ] && names+=("$(basename "$dir")")
    done
fi

for name in "${names[@]}"; do
    src="$skills_dir/$name"
    if [ ! -f "$src/SKILL.md" ]; then
        echo "skip ${name}: no skills/$name/SKILL.md" >&2
        continue
    fi
    out="$dist/$name.zip"
    [ -f "$out" ] && rm -f "$out"
    # zip from skills/ so every entry sits under a top-level <name>/ folder with
    # forward-slash paths. Exclude .DS_Store.
    ( cd "$skills_dir" && zip -r -q -X "$out" "$name" -x '*.DS_Store' )
    echo "built dist/$name.zip"
done

echo "Done. Upload the .zip files from dist/ in the Claude app or claude.ai."
