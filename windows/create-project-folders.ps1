<#
Create Project Folders (Windows)
Builds the folder layout listed in your folders.txt inside each folder you pass in.
  - Empty folder     -> filled directly
  - Non-empty folder -> a new "Untitled Project" folder is created inside it and filled
Template lookup, first match wins:
  %USERPROFILE%\.project-folders\folders.txt
  %USERPROFILE%\.project-folders\presets\default.txt
  presets\default.txt next to this repo
#>
param(
    [Parameter(Mandatory = $true, ValueFromRemainingArguments = $true)]
    [string[]]$Target
)

$ErrorActionPreference = 'Stop'

$home_dir = Join-Path $env:USERPROFILE '.project-folders'
$template = $null
foreach ($candidate in @(
        (Join-Path $home_dir 'folders.txt'),
        (Join-Path $home_dir 'presets\default.txt'),
        (Join-Path (Split-Path $PSScriptRoot -Parent) 'presets\default.txt'))) {
    if (Test-Path -LiteralPath $candidate) { $template = $candidate; break }
}
if (-not $template) {
    Write-Error 'Could not find a folder template (folders.txt).'
    exit 1
}

function Get-UniquePath([string]$basePath) {
    $candidate = $basePath
    $n = 2
    while (Test-Path -LiteralPath $candidate) {
        $candidate = "$basePath $n"
        $n++
    }
    return $candidate
}

function Build-Tree([string]$dest) {
    foreach ($raw in Get-Content -LiteralPath $template) {
        $line = $raw.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { continue }
        $line = $line -replace '\\', '/'
        # safety: no absolute paths, no parent-folder escapes
        if ($line.StartsWith('/') -or ($line -split '/') -contains '..') {
            Write-Warning "Skipping unsafe line: $line"
            continue
        }
        # names that break on Windows or other systems: < > : " | ? *  and names ending in . or space
        if ($line -match '[<>:"|?*]' -or $line -match '[. ](/|$)') {
            Write-Warning "Skipping line with characters that break on other systems: $line"
            continue
        }
        $relative = $line -replace '/', '\'
        New-Item -ItemType Directory -Force -Path (Join-Path $dest $relative) | Out-Null
    }
}

foreach ($t in $Target) {
    if (-not (Test-Path -LiteralPath $t -PathType Container)) { continue }
    $isEmpty = -not (Get-ChildItem -LiteralPath $t -Force | Select-Object -First 1)
    if ($isEmpty) {
        $dest = $t
    } else {
        $dest = Get-UniquePath (Join-Path $t 'Untitled Project')
        New-Item -ItemType Directory -Path $dest | Out-Null
    }
    Build-Tree $dest
}
