# L2TP behind NAT on a Windows 10/11 client

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
$RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AssumeUDPEncapsulationContextOnSendRule' -ErrorAction Stop) -eq 2))
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
