$ChocoPackage = 'postman'

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

#region SetExecutionPolicy
$null = (Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force -ErrorAction $SCT)
$null = (Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass  -Force -ErrorAction $SCT)
#endregion SetExecutionPolicy

#region ChocoCacheLocation
$ChocoCacheLocation = "$env:LOCALAPPDATA\temp\choco\"
$paramTestPath = @{
   Path          = $ChocoCacheLocation
   ErrorAction   = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path          = $ChocoCacheLocation
      ItemType      = 'directory'
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
   }
   $null = (New-Item @paramNewItem)
}
#endregion ChocoCacheLocation

#region ChocolateyInstallPath
# Use the User Profile
$env:ChocolateyInstall = ($env:LOCALAPPDATA + '\chocoportable')
#endregion ChocolateyInstallPath

$null = (& 'C:\ProgramData\chocolatey\bin\choco.exe' uninstall $ChocoPackage --acceptlicense --limitoutput --no-progress --yes --force)
