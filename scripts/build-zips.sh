#!/usr/bin/env bash
# Package each skill as dist/<name>.zip for upload to the Claude apps
# (Settings -> Capabilities -> Skills -> Upload skill).
# Each archive contains a top-level <name>/ folder with SKILL.md inside.
# Usage: scripts/build-zips.sh [skill-name ...]   (no args = all skills)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$ROOT/skills"
DIST="$ROOT/dist"

mkdir -p "$DIST"

# Zip a skill folder <name> (relative to SKILLS_DIR) into $DIST/<name>.zip,
# preferring the `zip` CLI and falling back to python3's zipfile.
zip_skill() {
  local name="$1" out="$DIST/$1.zip"
  rm -f "$out"
  if command -v zip >/dev/null 2>&1; then
    ( cd "$SKILLS_DIR" && zip -r -q "$out" "$name" -x '*/.DS_Store' )
  elif command -v python3 >/dev/null 2>&1; then
    ( cd "$SKILLS_DIR" && python3 -c '
import os, sys, zipfile
name, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(name):
        for f in files:
            if f == ".DS_Store":
                continue
            z.write(os.path.join(root, f))
' "$name" "$out" )
  else
    echo "Need either the 'zip' CLI or python3 to build archives." >&2
    exit 1
  fi
}

targets=("$@")
if [[ "${#targets[@]}" -eq 0 ]]; then
  for dir in "$SKILLS_DIR"/*/; do targets+=("$(basename "$dir")"); done
fi

for name in "${targets[@]}"; do
  src="$SKILLS_DIR/$name"
  if [[ ! -f "$src/SKILL.md" ]]; then
    echo "skip $name: no skills/$name/SKILL.md" >&2; continue
  fi
  # Archive holds <name>/... at its root so SKILL.md sits under a top folder.
  zip_skill "$name"
  echo "built dist/$name.zip"
done

echo "Done. Upload the .zip files from dist/ in the Claude app or claude.ai."
