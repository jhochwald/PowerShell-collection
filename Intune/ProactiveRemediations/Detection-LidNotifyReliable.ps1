# Use external Camera with Windows Hello/Windows Hello for Business

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
   if (-not (Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'LidNotifyReliable' -ErrorAction SilentlyContinue) -eq 0))
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