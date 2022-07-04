# %LOCALAPPDATA%\Postman\Postman.exe

# BUG: Desktop Icon removal is not working
# TODO: Check if post install script works better in dedicated PowerShell Session

$ChocoPackage = 'postman'
$ChocoParams = $null
$LinkFilter = '*postman*.lnk'

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

#region SetExecutionPolicy
$null = (Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force -ErrorAction $SCT)
$null = (Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass  -Force -ErrorAction $SCT)
#endregion SetExecutionPolicy

#region
if (-not $env:ChocolateyInstall)
{
   #$env:ChocolateyInstall = 'C:\ProgramData\chocolatey'
}
#endregion

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

#region
$paramGetCommand = @{
   Name          = 'Update-SessionEnvironment'
   WarningAction = $SCT
   ErrorAction   = $SCT
}
$paramTestPath = @{
   Path          = "$env:ChocolateyInstall\bin\refreshenv.cmd"
   WarningAction = $SCT
   ErrorAction   = $SCT
}
if (Get-Command @paramGetCommand)
{
   $null = (Update-SessionEnvironment -WarningAction $SCT -ErrorAction $SCT)
} elseif (Test-Path @paramTestPath)
{
   $null = (& "$env:ChocolateyInstall\bin\refreshenv.cmd")
}
#endregion

#region
try
{
   $null = ([Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072)
}
catch
{
   Write-Verbose -Message 'Unable to set PowerShell to use TLS 1.2.'
}
#endregion

#region chocolateyUseWindowsCompression
if (-not ($env:chocolateyUseWindowsCompression -eq $true))
{
   $env:chocolateyUseWindowsCompression = 'true'
}
#endregion chocolateyUseWindowsCompression

#region Installer
# Default Parameter
$InstallerParams = 'ALLUSERS=0'

if ($ChocoParams)
{
   $InstallerParams = ($InstallerParams + ' ' + $ChocoParams)
   $ChocoParams = $null
}

#region ChocolateyInstallPath
# Use the User Profile
$env:ChocolateyInstall = ($env:LOCALAPPDATA + '\chocoportable')
#endregion ChocolateyInstallPath

$null = (& 'C:\ProgramData\chocolatey\bin\choco.exe' install $ChocoPackage --acceptlicense --limitoutput --no-progress --yes --force --params `"`'$InstallerParams`'`")
#endregion Installer

#region Cleanup
if ($LinkFilter) {
   $paramGetChildItem = @{
      Path          = [Environment]::GetFolderPath('Desktop')
      Filter        = $LinkFilter
      Force         = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramRemoveItem = @{
      Force         = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-ChildItem @paramGetChildItem | Remove-Item @paramRemoveItem)
   $paramGetChildItem = $null
   $paramRemoveItem = $null
}
#endregion Cleanup

if (Test-Path -Path '.\postInstall.ps1' -ErrorAction $SCT)
{
   $null = (C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -InputFormat None -ExecutionPolicy Bypass -WindowStyle Hidden -NonInteractive -Command ".\postInstall.ps1")
}
