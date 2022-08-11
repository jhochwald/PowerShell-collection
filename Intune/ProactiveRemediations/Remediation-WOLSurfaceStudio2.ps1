# Enable Wake On LAN (WOL) on Microsoft Surface Studio 2

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

#region Remediation
#  Set CONNECTIVITYINSTANDBY to 1:
if ((Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\F15576E8-98B7-4186-B944-EAFA664402D9') -ne $true) 
{
   $null = (New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\F15576E8-98B7-4186-B944-EAFA664402D9' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\F15576E8-98B7-4186-B944-EAFA664402D9' -Name 'Attributes' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

#  Set EnforceDisconnectedStandby to 0:
if ((Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power') -ne $true) 
{
   $null = (New-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'EnforceDisconnectedStandby' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
#endregion Remediation