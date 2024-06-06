# 1.17.0
# https://folge.me/help/guide/hints/windows-installer-flags.html

# Restart Process using PowerShell 64-bit
If ($ENV:PROCESSOR_ARCHITEW6432 -eq 'AMD64')
{
   Try
   {
      &"$ENV:WINDIR\SysNative\WindowsPowershell\v1.0\PowerShell.exe" -File $PSCOMMANDPATH
   }
   Catch
   {
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   Exit
}

# Stop Folge Process
$null = (Stop-Process -Name Folge -Force -Confirm:$false -ErrorAction SilentlyContinue)

# Uninstall Folge
$null = (Start-Process -FilePath "$env:ProgramW6432\Folge\Uninstall Folge.exe" -Wait -ArgumentList '/allusers /S' -ErrorAction Stop)

# Cleanup
$DesktopIcon = "$env:PUBLIC\Desktop\Folge.lnk"

if (Test-Path -Path $DesktopIcon -ErrorAction SilentlyContinue)
{
   $null = (Remove-Item -Path $DesktopIcon -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$FolgeProgramPath = "$env:ProgramW6432\Folge"

if (Test-Path -Path $FolgeProgramPath -ErrorAction SilentlyContinue)
{
   $null = (Remove-Item -Path $FolgeProgramPath -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue)
}
