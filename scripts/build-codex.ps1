# Generate an AGENTS.md index (for OpenAI Codex) from skills/.
# Codex has no description-based skill selection, so AGENTS.md stays a light,
# always-on index: it lists each skill's trigger and tells the agent to read
# that skill's full SKILL.md before acting. The skill sources are copied to
# .codex/skills/ so the pointers resolve.
#
#   Default:  dist/codex/AGENTS.md + dist/codex/.codex/skills/  (inspectable)
#   -Project: ./AGENTS.md + ./.codex/skills/ in the current directory
#
# Usage: scripts/build-codex.ps1 [-Project] [skill-name ...]   (no names = all)
param(
    [switch]$Project,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Names
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$skillsDir = Join-Path $root 'skills'

if ($Project) {
    $base = (Get-Location).Path
} else {
    $base = Join-Path $root 'dist\codex'
}
$skillsCopy = Join-Path $base '.codex\skills'
New-Item -ItemType Directory -Force -Path $skillsCopy | Out-Null

# Parse SKILL.md frontmatter (name, description). Handles an inline
# `description:` and a YAML block scalar (`description: |`).
function Get-Skill {
    param([string]$Path)
    $lines = [System.IO.File]::ReadAllLines($Path)
    if ($lines[0].Trim() -ne '---') { throw "missing frontmatter: $Path" }
    $i = 1; $name = ''; $desc = ''
    while ($i -lt $lines.Count -and $lines[$i].Trim() -ne '---') {
        if ($lines[$i] -match '^name:\s*(.+)$') { $name = $Matches[1].Trim(); $i++; continue }
        if ($lines[$i] -match '^description:\s*(.*)$') {
            $rest = $Matches[1].Trim()
            if ($rest -match '^[|>][-+]?$') {
                $i++; $blk = @()
                while ($i -lt $lines.Count -and $lines[$i].Trim() -ne '---') {
                    if ($lines[$i] -match '^\S') { break }
                    $blk += $lines[$i].Trim(); $i++
                }
                $desc = ($blk -join ' ')
            } else {
                $desc = $rest.Trim('"').Trim("'"); $i++
            }
            continue
        }
        $i++
    }
    $desc = ($desc -replace '\s+', ' ').Trim()
    return [pscustomobject]@{ Name = $name; Description = $desc }
}

if (-not $Names -or $Names.Count -eq 0) {
    $Names = Get-ChildItem -Path $skillsDir -Directory | ForEach-Object { $_.Name }
}

$sections = @()
$sections += '# Agent Skills (Codex)'
$sections += ''
$sections += 'このファイルは `skills/` から自動生成した索引。以下のスキルのどれかの発動'
$sections += '条件に当てはまる作業に入ったら、まず該当スキルの SKILL.md 全文を読み、'
$sections += 'その手順・基準に従って進める。索引の説明だけで判断しない。'
$sections += ''
$sections += 'Notion 系スキル（notion-*）は Notion への読み書きを前提とする。Codex の'
$sections += 'MCP 設定（`~/.codex/config.toml` の `[mcp_servers.*]`）で Notion サーバーを'
$sections += '繋いでから使うこと。'
$sections += ''
$sections += '| スキル | 発動条件 / 用途 | 全文 |'
$sections += '|---|---|---|'

foreach ($name in $Names) {
    $src = Join-Path $skillsDir $name
    $md = Join-Path $src 'SKILL.md'
    if (-not (Test-Path $md)) { Write-Warning "skip ${name}: no skills/$name/SKILL.md"; continue }

    $skill = Get-Skill $md
    # Copy the whole skill folder so references/ and scripts/ come along.
    $dest = Join-Path $skillsCopy $name
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    Copy-Item -Recurse $src $dest

    # Keep the table cell single-line and pipe-safe.
    $desc = $skill.Description -replace '\|', '\|'
    $sections += "| $name | $desc | ``.codex/skills/$name/SKILL.md`` |"
    Write-Host "indexed $name"
}

$sections += ''
$out = Join-Path $base 'AGENTS.md'
[System.IO.File]::WriteAllText($out, (($sections -join "`n") + "`n"))

Write-Host ""
Write-Host "Done. Wrote $out and copied skills to $skillsCopy"
if (-not $Project) {
    Write-Host "Copy dist/codex/AGENTS.md and dist/codex/.codex into a project root,"
    Write-Host "or re-run with -Project from that project."
}
