#!/usr/bin/env bash
# Generate an AGENTS.md index (for OpenAI Codex) from skills/.
# Codex has no description-based skill selection, so AGENTS.md stays a light,
# always-on index: it lists each skill's trigger and tells the agent to read
# that skill's full SKILL.md before acting. The skill sources are copied to
# .codex/skills/ so the pointers resolve.
#
#   Default:    dist/codex/AGENTS.md + dist/codex/.codex/skills/  (inspectable)
#   --project:  ./AGENTS.md + ./.codex/skills/ in the current directory
#
# Usage: scripts/build-codex.sh [--project] [skill-name ...]   (no names = all)
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
    base="$root/dist/codex"
fi
skills_copy="$base/.codex/skills"
mkdir -p "$skills_copy"

if [ "${#names[@]}" -eq 0 ]; then
    for dir in "$skills_dir"/*/; do
        [ -d "$dir" ] && names+=("$(basename "$dir")")
    done
fi

out="$base/AGENTS.md"
{
    echo '# Agent Skills (Codex)'
    echo ''
    echo 'このファイルは `skills/` から自動生成した索引。以下のスキルのどれかの発動'
    echo '条件に当てはまる作業に入ったら、まず該当スキルの SKILL.md 全文を読み、'
    echo 'その手順・基準に従って進める。索引の説明だけで判断しない。'
    echo ''
    echo 'Notion 系スキル（notion-*）は Notion への読み書きを前提とする。Codex の'
    echo 'MCP 設定（`~/.codex/config.toml` の `[mcp_servers.*]`）で Notion サーバーを'
    echo '繋いでから使うこと。'
    echo ''
    echo '| スキル | 発動条件 / 用途 | 全文 |'
    echo '|---|---|---|'
} > "$out"

for name in "${names[@]}"; do
    src="$skills_dir/$name"
    md="$src/SKILL.md"
    if [ ! -f "$md" ]; then
        echo "skip ${name}: no skills/$name/SKILL.md" >&2
        continue
    fi

    desc="$(awk -v want=desc -f "$awk_lib" "$md")"

    # Copy the whole skill folder so references/ and scripts/ come along.
    dest="$skills_copy/$name"
    [ -e "$dest" ] && rm -rf "$dest"
    cp -R "$src" "$dest"

    # Keep the table cell single-line and pipe-safe.
    desc="$(printf '%s' "$desc" | sed 's/|/\\|/g')"
    echo "| $name | $desc | \`.codex/skills/$name/SKILL.md\` |" >> "$out"
    echo "indexed $name"
done

echo '' >> "$out"

echo ""
echo "Done. Wrote $out and copied skills to $skills_copy"
if [ "$project" -ne 1 ]; then
    echo "Copy dist/codex/AGENTS.md and dist/codex/.codex into a project root,"
    echo "or re-run with --project from that project."
fi
