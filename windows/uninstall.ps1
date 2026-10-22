# Removes the right-click menu entries. Leaves %USERPROFILE%\.project-folders in place
# so your edited folders.txt is not lost (delete that folder by hand if you want it gone).
$keys = @(
    'HKCU:\Software\Classes\Directory\shell\CreateProjectFolders',
    'HKCU:\Software\Classes\Directory\Background\shell\CreateProjectFolders'
)
foreach ($key in $keys) {
    if (Test-Path $key) { Remove-Item -Path $key -Recurse -Force }
}
Write-Host 'Right-click menu entries removed.'
