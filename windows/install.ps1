<#
Installs the scripts, the presets, and your editable folder template into
%USERPROFILE%\.project-folders and adds "Create Project Folders" to the right-click menu.
  install.ps1             -> installs with the default layout
  install.ps1 podcast     -> installs and starts with the "podcast" layout
Safe to re-run: it never overwrites a folders.txt you have already edited
(unless you ask for a preset by name, in which case your old one is saved as folders.txt.bak).
No admin rights needed (only touches your own user account).
#>
param([string]$Preset)

$ErrorActionPreference = 'Stop'

$repo = Split-Path $PSScriptRoot -Parent
$dest = Join-Path $env:USERPROFILE '.project-folders'
New-Item -ItemType Directory -Force -Path (Join-Path $dest 'presets') | Out-Null

Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'create-project-folders.ps1') -Destination $dest -Force
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'use-preset.ps1') -Destination $dest -Force
Copy-Item -Path (Join-Path $repo 'presets\*.txt') -Destination (Join-Path $dest 'presets') -Force

$template = Join-Path $dest 'folders.txt'
if ($Preset) {
    & (Join-Path $dest 'use-preset.ps1') $Preset
} elseif (Test-Path -LiteralPath $template) {
    Write-Host "Keeping your existing template: $template"
} else {
    Copy-Item -LiteralPath (Join-Path $repo 'presets\default.txt') -Destination $template
    Write-Host "Installed default template: $template"
}

$script  = Join-Path $dest 'create-project-folders.ps1'
$command = "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$script`" `"%V`""

# Right-click ON a folder, and right-click on the empty background INSIDE a folder
$keys = @(
    'HKCU:\Software\Classes\Directory\shell\CreateProjectFolders',
    'HKCU:\Software\Classes\Directory\Background\shell\CreateProjectFolders'
)
foreach ($key in $keys) {
    New-Item -Path $key -Force | Out-Null
    Set-ItemProperty -Path $key -Name '(default)' -Value 'Create Project Folders'
    New-ItemProperty -Path $key -Name 'Icon' -Value 'imageres.dll,-5303' -PropertyType String -Force | Out-Null
    New-Item -Path "$key\command" -Force | Out-Null
    Set-ItemProperty -Path "$key\command" -Name '(default)' -Value $command
}

Write-Host ''
Write-Host 'Done. Right-click a folder (Windows 11: choose "Show more options") and look for "Create Project Folders".'
Write-Host "To change your layout, edit: $template"
Write-Host "To switch layouts, run: $dest\use-preset.ps1 <name>"
