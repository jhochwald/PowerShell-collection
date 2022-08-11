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

#region Remediation
if ((Test-Path -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'LidNotifyReliable' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
#endregion Remediation