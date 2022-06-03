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
$RegistryPath = 'HKLM:\Software\policies\Microsoft\Windows NT\DNSClient'
$RegistryName = 'EnableMulticast'
$RegistryType = 'DWORD'
$RegistryValue = 0

if (-not (Test-Path -Path $RegistryPath -ErrorAction SilentlyContinue))
{
   $null = (New-Item -Path $RegistryPath -ItemType Directory -Force -Confirm:$false -ErrorAction Stop)
}

$null = (New-ItemProperty -Path $RegistryPath -Name $RegistryName -Type $RegistryType -Value $RegistryValue -ErrorAction Stop)
#endregion Remediation