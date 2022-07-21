# Enable Secure Sign-in (Ctrl+Alt+Del) for all users

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
$RegistryPathTwo = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
$RegistryPathOne = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon'

if ((Test-Path -LiteralPath $RegistryPathOne) -ne $true)
{
   $null = (New-Item -Path $RegistryPathOne -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

if ((Test-Path -LiteralPath $RegistryPathTwo) -ne $true)
{
   $null = (New-Item -Path $RegistryPathTwo -Force -Confirm:$false -ErrorAction SilentlyContinue)
}

$null = (New-ItemProperty -LiteralPath $RegistryPathOne -Name 'DisableCAD' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)

$null = (New-ItemProperty -LiteralPath $RegistryPathTwo -Name 'DisableCAD' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction SilentlyContinue)
#endregion Remediation
