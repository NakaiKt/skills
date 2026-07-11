# Package each skill as dist/<name>.zip for upload to the Claude apps
# (Settings -> Capabilities -> Skills -> Upload skill).
# Each archive contains a top-level <name>/ folder with SKILL.md inside.
# Usage: scripts/build-zips.ps1 [skill-name ...]   (no args = all skills)
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Names
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = Split-Path -Parent $PSScriptRoot
$skillsDir = Join-Path $root 'skills'
$dist = Join-Path $root 'dist'

New-Item -ItemType Directory -Force -Path $dist | Out-Null

if (-not $Names -or $Names.Count -eq 0) {
    $Names = Get-ChildItem -Path $skillsDir -Directory | ForEach-Object { $_.Name }
}

foreach ($name in $Names) {
    $src = Join-Path $skillsDir $name
    if (-not (Test-Path (Join-Path $src 'SKILL.md'))) {
        Write-Warning "skip ${name}: no skills/$name/SKILL.md"
        continue
    }
    $out = Join-Path $dist "$name.zip"
    if (Test-Path $out) { Remove-Item $out -Force }
    # Build entries by hand with forward-slash paths (Compress-Archive writes
    # backslashes, which some unzip tools — including uploads — mishandle).
    # Every entry sits under a top-level <name>/ folder.
    $zip = [System.IO.Compression.ZipFile]::Open($out, 'Create')
    try {
        foreach ($f in Get-ChildItem -Path $src -Recurse -File | Where-Object { $_.Name -ne '.DS_Store' }) {
            $rel = $f.FullName.Substring($skillsDir.Length + 1) -replace '\\', '/'
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $f.FullName, $rel) | Out-Null
        }
    } finally {
        $zip.Dispose()
    }
    Write-Host "built dist/$name.zip"
}

Write-Host "Done. Upload the .zip files from dist/ in the Claude app or claude.ai."
