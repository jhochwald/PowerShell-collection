<#
   .SYNOPSIS
   Windows Lock Screen

   .DESCRIPTION
   Windows Lock Screen

   .NOTES
   Designed to run in Microsoft Endpoint Manager (Intune)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

#region Defaults
$STP = 'Stop'
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
#endregion Defaults

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
      throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

try
{
   if ((Test-Path -LiteralPath $RegistryPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $null = (New-Item -Path $RegistryPath -Force -Confirm:$false -ErrorAction $STP)
   }

   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'LockScreenOverlaysDisabled' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'NoLockScreen' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'NoLockScreenSlideshow' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
}
catch
{
   Write-Error -Message $_ -ErrorAction $STP

   exit 1
}