# C:\Program Files\Git\cmd\git.exe
 
$ChocoPackage = 'Audacity'
$ChocoParams = $null

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

#region
if (-not $env:ChocolateyInstall)
{
   $env:ChocolateyInstall = 'C:\ProgramData\chocolatey'
}
#endregion

#region ChocoCacheLocation
$ChocoCacheLocation = "$env:HOMEDRIVE\temp\choco\"
$paramTestPath = @{
   Path          = $ChocoCacheLocation
   ErrorAction   = $SCT
   WarningAction = $SCT
}
if (-not (Test-Path @paramTestPath))
{
   $paramNewItem = @{
      Path          = $ChocoCacheLocation
      ItemType      = 'directory'
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = '-'
      Value         = $SCT
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
}
elseif (Test-Path @paramTestPath)
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
$InstallerParams = 'ALLUSERS=1'

if ($ChocoParams)
{
   $InstallerParams = ($InstallerParams + ' ' + $ChocoParams)
   $ChocoParams = $null
}

$null = (& "$env:ChocolateyInstall\bin\choco.exe" install $ChocoPackage --acceptlicense --limitoutput --no-progress --yes --force --params $InstallerParams)
#endregion Installer

