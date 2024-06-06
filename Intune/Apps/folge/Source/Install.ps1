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

# Install Folge
$null = (Start-Process -FilePath .\Folge-1.17.0.exe -Wait -ArgumentList '/S /allusers' -ErrorAction Stop)

$DesktopIcon = "$env:PUBLIC\Desktop\Folge.lnk"

if (Test-Path -Path $DesktopIcon -ErrorAction SilentlyContinue)
{
   $null = (Remove-Item -Path $DesktopIcon -Force -Confirm:$false -ErrorAction SilentlyContinue)
}
