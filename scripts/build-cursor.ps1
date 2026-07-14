# Generate Cursor Project Rules (.cursor/rules/<name>.mdc) from skills/.
# Each skill becomes an "Agent Requested" rule: Cursor's agent pulls it in
# based on the description, mirroring how Claude selects Agent Skills.
#
#   Default:  dist/cursor/.cursor/rules/<name>.mdc   (self-contained, inspectable)
#   -Project: ./.cursor/rules/<name>.mdc in the current directory
#
# A skill's references/ folder is copied to .cursor/rules/<name>/references/ and
# the body's relative links are rewritten so they still resolve; the agent can
# then open those files with its own tools when it needs the detail.
# Usage: scripts/build-cursor.ps1 [-Project] [skill-name ...]   (no names = all)
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
    $base = Join-Path $root 'dist\cursor'
}
$rulesDir = Join-Path $base '.cursor\rules'
New-Item -ItemType Directory -Force -Path $rulesDir | Out-Null

# Parse SKILL.md frontmatter (name, description) and body. Handles both an
# inline `description:` and a YAML block scalar (`description: |`).
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
                # Block scalar: collect the indented lines that follow.
                $i++; $blk = @()
                while ($i -lt $lines.Count -and $lines[$i].Trim() -ne '---') {
                    if ($lines[$i] -match '^\S') { break }   # next top-level key
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
    while ($i -lt $lines.Count -and $lines[$i].Trim() -ne '---') { $i++ }
    $i++  # skip closing ---
    $body = if ($i -lt $lines.Count) { ($lines[$i..($lines.Count - 1)] -join "`n").Trim() } else { '' }
    $desc = ($desc -replace '\s+', ' ').Trim()
    return [pscustomobject]@{ Name = $name; Description = $desc; Body = $body }
}

if (-not $Names -or $Names.Count -eq 0) {
    $Names = Get-ChildItem -Path $skillsDir -Directory | ForEach-Object { $_.Name }
}

foreach ($name in $Names) {
    $src = Join-Path $skillsDir $name
    $md = Join-Path $src 'SKILL.md'
    if (-not (Test-Path $md)) { Write-Warning "skip ${name}: no skills/$name/SKILL.md"; continue }

    $skill = Get-Skill $md
    $body = $skill.Body

    # If the skill ships references/, copy them beside the rule and point the
    # body's relative links at the copy (relative to <name>.mdc).
    $refs = Join-Path $src 'references'
    if (Test-Path $refs) {
        $refDest = Join-Path $rulesDir $name
        if (Test-Path $refDest) { Remove-Item $refDest -Recurse -Force }
        New-Item -ItemType Directory -Force -Path $refDest | Out-Null
        Copy-Item -Recurse $refs (Join-Path $refDest 'references')
        $body = $body -replace 'references/', "$name/references/"
    }

    # Cursor .mdc frontmatter: description drives auto-selection; alwaysApply
    # false + no globs = "Agent Requested" (the model decides when to load it).
    $descEsc = $skill.Description -replace '\\', '\\' -replace '"', '\"'
    $mdc = @()
    $mdc += '---'
    $mdc += "description: `"$descEsc`""
    $mdc += 'globs:'
    $mdc += 'alwaysApply: false'
    $mdc += '---'
    $mdc += ''
    $mdc += $body
    $mdc += ''

    $out = Join-Path $rulesDir "$name.mdc"
    [System.IO.File]::WriteAllText($out, ($mdc -join "`n"))
    Write-Host "built .cursor/rules/$name.mdc"
}

Write-Host ""
Write-Host "Done. Rules written under $rulesDir"
if (-not $Project) {
    Write-Host "Copy dist/cursor/.cursor into a project root, or re-run with -Project from that project."
}
Write-Host "Notion skills also need Cursor MCP configured (Settings -> MCP -> add the Notion server)."
