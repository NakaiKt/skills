# Scaffold a new skill from templates/skill-template.
# Usage: scripts/new-skill.ps1 <skill-name>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Name
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

# Validate name against the Agent Skills naming rules.
if ($Name -notmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
    Write-Error "Invalid name '$Name'. Use lowercase letters, numbers, and single hyphens only."
    exit 1
}

$dest = Join-Path $root "skills\$Name"
if (Test-Path $dest) {
    Write-Error "Skill already exists: $dest"
    exit 1
}

$template = Join-Path $root 'templates\skill-template'
Copy-Item -Recurse $template $dest

# Set the name in the frontmatter to match the folder.
$md = Join-Path $dest 'SKILL.md'
$content = (Get-Content $md -Raw) -replace '(?m)^name: skill-template\r?$', "name: $Name"
[System.IO.File]::WriteAllText($md, $content)

Write-Host "Created skills/$Name/SKILL.md"
Write-Host "Next: edit the description and instructions, then run scripts/validate.ps1"
