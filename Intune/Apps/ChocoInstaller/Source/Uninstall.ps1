#requires -Version 1.0

$VerbosePreference = 'Continue'

if (-not $env:ChocolateyInstall) 
{
   $message = @(
      'The ChocolateyInstall environment variable was not found.'
      'Chocolatey is not detected as installed. Nothing to do.'
   ) -join "`n"

   Write-Warning -Message $message
   return
}

if (-not (Test-Path -Path $env:ChocolateyInstall)) 
{
   $message = @(
      "No Chocolatey installation detected at '$env:ChocolateyInstall'."
      'Nothing to do.'
   ) -join "`n"

   Write-Warning -Message $message
   return
}

<#
      Using the .NET registry calls is necessary here in order to preserve environment variables embedded in PATH values;
      Powershell's registry provider doesn't provide a method of preserving variable references, and we don't want to
      accidentally overwrite them with absolute path values. Where the registry allows us to see "%SystemRoot%" in a PATH
      entry, PowerShell's registry provider only sees "C:\Windows", for example.
#>
$userKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Environment')
$userPath = $userKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

$machineKey = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SYSTEM\ControlSet001\Control\Session Manager\Environment\')
$machinePath = $machineKey.GetValue('PATH', [string]::Empty, 'DoNotExpandEnvironmentNames').ToString()

$backupPATHs = @(
   ('User PATH: {0}' -f $userPath)
   ('Machine PATH: {0}' -f $machinePath)
)
$backupFile = "$env:HOMEDRIVE\temp\PATH_backups_ChocolateyUninstall.txt"
$backupPATHs | Set-Content -Path $backupFile -Encoding UTF8 -Force

$warningMessage = (@"
    This could cause issues after reboot where nothing is found if something goes wrong.
    In that case, look at the backup file for the original PATH values in '{0}'.
"@ -f $backupFile)

if ($userPath -like "*$env:ChocolateyInstall*") 
{
   Write-Verbose -Message 'Chocolatey Install location found in User Path. Removing...'
   Write-Warning -Message $warningMessage

   $newUserPATH = @(
      $userPath -split [IO.Path]::PathSeparator |
      Where-Object -FilterScript {
         $_ -and $_ -ne "$env:ChocolateyInstall\bin" 
      }
   ) -join [IO.Path]::PathSeparator

   # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
   # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
   $userKey.SetValue('PATH', $newUserPATH, 'ExpandString')
}

if ($machinePath -like "*$env:ChocolateyInstall*") 
{
   Write-Verbose -Message 'Chocolatey Install location found in Machine Path. Removing...'
   Write-Warning -Message $warningMessage

   $newMachinePATH = @(
      $machinePath -split [IO.Path]::PathSeparator |
      Where-Object -FilterScript {
         $_ -and $_ -ne "$env:ChocolateyInstall\bin" 
      }
   ) -join [IO.Path]::PathSeparator

   # NEVER use [Environment]::SetEnvironmentVariable() for PATH values; see https://github.com/dotnet/corefx/issues/36449
   # This issue exists in ALL released versions of .NET and .NET Core as of 12/19/2019
   $machineKey.SetValue('PATH', $newMachinePATH, 'ExpandString')
}

# Adapt for any services running in subfolders of ChocolateyInstall
$agentService = Get-Service -Name chocolatey-agent -ErrorAction SilentlyContinue

if ($agentService -and $agentService.Status -eq 'Running') 
{
   $agentService.Stop()
}
# TODO: add other services here

Remove-Item -Path $env:ChocolateyInstall -Recurse -Force

'ChocolateyInstall', 'ChocolateyLastPathUpdate' | ForEach-Object -Process {
   foreach ($scope in 'User', 'Machine') 
   {
      [Environment]::SetEnvironmentVariable($_, [string]::Empty, $scope)
   }
}

$machineKey.Close()
$userKey.Close()

# Additionally, the below code will remove the environment variables pointing to the tools directory that was managed by Chocolatey. 
if ($env:ChocolateyToolsLocation -and (Test-Path $env:ChocolateyToolsLocation)) 
{
   Remove-Item -Path $env:ChocolateyToolsLocation -Recurse -Force
}

foreach ($scope in 'User', 'Machine') 
{
   [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, $scope)
}

