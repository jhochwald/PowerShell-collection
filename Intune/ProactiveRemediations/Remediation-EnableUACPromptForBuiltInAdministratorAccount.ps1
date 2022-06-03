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
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue))
{
   $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction Stop)
}

$null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'FilterAdministratorToken' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction Stop)

exit 0
#endregion Remediation
