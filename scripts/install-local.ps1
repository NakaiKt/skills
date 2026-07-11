# Install skills into a Claude Code skills directory without the plugin system,
# by linking each skill folder so edits take effect live.
#   Personal (default): ~/.claude/skills/<name>   (all your projects)
#   Project:  -Project  -> ./.claude/skills/<name> in the current repo
# Uses a directory junction (no admin rights needed). Use -Copy to copy instead.
# Usage: scripts/install-local.ps1 [-Project] [-Copy] [skill-name ...]
param(
    [switch]$Project,
    [switch]$Copy,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Names
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$skillsDir = Join-Path $root 'skills'

if ($Project) {
    $targetBase = Join-Path (Get-Location).Path '.claude\skills'
} else {
    $targetBase = Join-Path $HOME '.claude\skills'
}

if (-not $Names -or $Names.Count -eq 0) {
    $Names = Get-ChildItem -Path $skillsDir -Directory | ForEach-Object { $_.Name }
}

New-Item -ItemType Directory -Force -Path $targetBase | Out-Null

foreach ($name in $Names) {
    $src = Join-Path $skillsDir $name
    if (-not (Test-Path (Join-Path $src 'SKILL.md'))) {
        Write-Warning "skip ${name}: no such skill"
        continue
    }
    $dest = Join-Path $targetBase $name
    if (Test-Path $dest) {
        $item = Get-Item $dest -Force
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            # Existing junction/symlink: delete the link only, never its target.
            [System.IO.Directory]::Delete($dest, $false)
        } else {
            Remove-Item $dest -Recurse -Force
        }
    }
    if ($Copy) {
        Copy-Item -Recurse $src $dest
        Write-Host "copied   $name -> $dest"
    } else {
        New-Item -ItemType Junction -Path $dest -Target $src | Out-Null
        Write-Host "linked   $name -> $dest"
    }
}

Write-Host "Done. Restart Claude Code if the skills directory did not exist before."
