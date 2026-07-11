# Validate every skill under skills/ against the Agent Skills basics.
# Usage: scripts/validate.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$skillsDir = Join-Path $root 'skills'
$fail = $false

foreach ($dir in Get-ChildItem -Path $skillsDir -Directory) {
    $name = $dir.Name
    $md = Join-Path $dir.FullName 'SKILL.md'

    if (-not (Test-Path $md)) {
        Write-Host "FAIL ${name}: missing SKILL.md"; $fail = $true; continue
    }

    $lines = Get-Content $md
    # Frontmatter must start on line 1.
    if ($lines[0].Trim() -ne '---') {
        Write-Host "FAIL ${name}: SKILL.md must start with YAML frontmatter (---)"; $fail = $true; continue
    }

    $fmName = ''
    $fmDesc = ''
    foreach ($line in $lines) {
        if ($fmName -eq '' -and $line -match '^name:\s*(.+)$') { $fmName = $Matches[1].Trim() }
        if ($fmDesc -eq '' -and $line -match '^description:\s*(.+)$') { $fmDesc = $Matches[1].Trim() }
    }

    $skillOk = $true
    if ($fmName -ne $name) {
        Write-Host "FAIL ${name}: frontmatter name '$fmName' must equal folder name '$name'"; $fail = $true; $skillOk = $false
    }
    if ($name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
        Write-Host "FAIL ${name}: name must be lowercase alphanumeric with single hyphens"; $fail = $true; $skillOk = $false
    }
    if ([string]::IsNullOrEmpty($fmDesc)) {
        Write-Host "FAIL ${name}: description is required"; $fail = $true; $skillOk = $false
    }
    if ($name.Length -gt 64) {
        Write-Host "FAIL ${name}: name exceeds 64 characters"; $fail = $true; $skillOk = $false
    }

    if ($skillOk) { Write-Host "ok   $name" }
}

if ($fail) {
    Write-Error "Validation failed."
    exit 1
}
Write-Host "All skills valid."
