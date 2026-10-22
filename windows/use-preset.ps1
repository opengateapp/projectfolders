<#
Switch your folder layout to a preset.
  use-preset.ps1            -> lists the presets
  use-preset.ps1 podcast    -> makes "podcast" your active layout
Your previous folders.txt is saved as folders.txt.bak first.
#>
param([string]$Name)

$ErrorActionPreference = 'Stop'

$dest = Join-Path $env:USERPROFILE '.project-folders'
$presets = Join-Path $dest 'presets'
if (-not (Test-Path -LiteralPath $presets)) {
    $presets = Join-Path (Split-Path $PSScriptRoot -Parent) 'presets'
}

if (-not $Name) {
    Write-Host 'Available presets:'
    Get-ChildItem -LiteralPath $presets -Filter '*.txt' | ForEach-Object { Write-Host "  $($_.BaseName)" }
    Write-Host ''
    Write-Host 'Switch with:  use-preset.ps1 <name>'
    exit 0
}

if ($Name -notmatch '^[A-Za-z0-9_-]+$') {
    Write-Error 'Preset names use only letters, numbers, dashes and underscores.'
    exit 1
}
$src = Join-Path $presets "$Name.txt"
if (-not (Test-Path -LiteralPath $src)) {
    Write-Error "No preset called '$Name'. Run without a name to see the list."
    exit 1
}

New-Item -ItemType Directory -Force -Path $dest | Out-Null
$live = Join-Path $dest 'folders.txt'
if ((Test-Path -LiteralPath $live) -and
    ((Get-FileHash -LiteralPath $live).Hash -ne (Get-FileHash -LiteralPath $src).Hash)) {
    Copy-Item -LiteralPath $live -Destination (Join-Path $dest 'folders.txt.bak') -Force
    Write-Host 'Saved your previous layout as folders.txt.bak'
}
Copy-Item -LiteralPath $src -Destination $live -Force
Write-Host "Layout is now: $Name"
