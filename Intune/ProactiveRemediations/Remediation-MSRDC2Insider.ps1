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

#region RemediationScript
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\MSRDC\Policies'

try
{
   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true) 
   {
      $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction Stop)
   }

   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'ReleaseRing' -Value 'insider' -PropertyType String -Force -Confirm:$false -ErrorAction Stop)
}
catch
{
   Throw $_
   Exit 1
}
#endregion RemediationScript