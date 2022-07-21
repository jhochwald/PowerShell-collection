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

#region Remediation
$RegistryPathTwo = 'HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent'
$RegistryPathOne = 'HKLM:\SYSTEM\CurrentControlSet\Services\RasMan\Parameters'

if ((Test-Path -LiteralPath $RegistryPathOne -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPathOne -Force -Confirm:$false -ErrorAction SilentlyContinue )
}

if ((Test-Path -LiteralPath $RegistryPathTwo -ErrorAction SilentlyContinue) -ne $true)
{
   $null = (New-Item -Path $RegistryPathTwo -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

# Allows weak encryption algorithms, for L2TP/IPSec the MD5 and DES algorithms are used
$null = (New-ItemProperty -LiteralPath $RegistryPathOne -Name 'AllowL2TPWeakCrypto' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

# Enables IPsec encryption, which is often disabled by some VPN clients or system tools
$null = (New-ItemProperty -LiteralPath $RegistryPathOne -Name 'ProhibitIPSec' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

# Enable Diffie-Hellman 2048 and AES 256 for IKEv2 VPN clients
$null = (New-ItemProperty -LiteralPath $RegistryPathOne -Name 'NegotiateDH2048_AES256' -Value 2 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

# L2TP behind NAT on a Windows 10/11 client
$null = (New-ItemProperty -LiteralPath $RegistryPathTwo -Name 'AssumeUDPEncapsulationContextOnSendRule' -Value 2 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
#endregion Remediation