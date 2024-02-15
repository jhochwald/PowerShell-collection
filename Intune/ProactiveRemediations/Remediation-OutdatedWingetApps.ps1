# Remediation for outdated WinGet apps

# Config console output encoding
$null = & "$env:ComSpec" /c '' # <- Workaround for Windows PowerShell ISE "Exception setting "OutputEncoding": "The handle is invalid.""
$Script:OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

#region FindWinGetCli
# Find directory
$WingetDirectory = [string](
   $(
      if ([Security.Principal.WindowsIdentity]::GetCurrent().'User'.'Value' -eq 'S-1-5-18')
      {
         ((Get-Item -Path ('{0}\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe' -f $env:ProgramW6432)).'FullName' | Select-Object -First 1)
      }
      else
      {
         ('{0}\Microsoft\WindowsApps' -f $env:LOCALAPPDATA)
      }
   )
)

# Find file name
$WingetCliFileName = ([string](
      $(
         [string[]](
            'AppInstallerCLI.exe',
            'winget.exe'
         )
      ).Where{
         [IO.File]::Exists(
            ('{0}\{1}' -f $WingetDirectory, $_)
         )
      } | Select-Object -First 1
))

# Combine and file name
$WingetCliPath = ([string] '{0}\{1}' -f $WingetDirectory, $WingetCliFileName)


# Check if $WingetCli exists
if (-not ([IO.File]::Exists($WingetCliPath)))
{
   Write-Error -Exception 'WinGet Binary not found' -Message 'Did not find WinGet Binary.' -Category NotInstalled -TargetObject 'winget.exe' -RecommendedAction 'Install WinGet (From the Microsoft Store or GitHub)' -ErrorAction Stop

   Exit 1
}
#endregion FindWinGetCli

try
{
   # upgrade command for ALL
   $null = ([string[]](& "$env:ComSpec" /c ('"{0}" upgrade --source winget --all --accept-source-agreements --silent --force --uninstall-previous' -f $WingetCliPath)))
   exit 0
}
catch
{
   $message = $_
   Write-Error -Message "Error while installing WinGet upgrade: $message"
   exit 1
}
