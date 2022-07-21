# L2TP behind NAT on a Windows 10/11 client + Tweaks

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

#region check
$RegistryPathTwo = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Parameters'
$RegistryPathOne = 'HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent'

try
{
   if (-not (Test-Path -LiteralPath $RegistryPathOne -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not (Test-Path -LiteralPath $RegistryPathTwo -ErrorAction Stop))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPathTwo -Name 'AllowL2TPWeakCrypto' -ErrorAction Stop) -eq 1))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPathTwo -Name 'ProhibitIPSec' -ErrorAction Stop) -eq 0))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPathTwo -Name 'NegotiateDH2048_AES256' -ErrorAction Stop) -eq 2))
   {
      Exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPathOne -Name 'AssumeUDPEncapsulationContextOnSendRule' -ErrorAction Stop) -eq 2))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}

Exit 0
#endregion check
