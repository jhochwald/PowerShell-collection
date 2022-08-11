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

#region Check
try 
{
   if (-not (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\F15576E8-98B7-4186-B944-EAFA664402D9'))
   {
      Exit 1
   }

   if (-not (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power'))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\F15576E8-98B7-4186-B944-EAFA664402D9' -Name 'Attributes' -ErrorAction SilentlyContinue) -eq 1)) 
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'EnforceDisconnectedStandby' -ErrorAction SilentlyContinue) -eq 0)) 
   {
      Exit 1
   }
}
catch 
{
   Exit 1
}

Exit 0
#endregion Check