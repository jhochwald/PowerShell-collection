# Install missing WinGet

#region ARM64Handling
# Restart Process using PowerShell 64-bit
if ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

#region Check
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
   Write-Output -InputObject 'Did not find Winget.'

   Exit 1
}
else
{
   Exit 0
}


#endregion Check