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
$RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization'
$SCT = 'SilentlyContinue'
$STP = 'Stop'
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
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction $STP))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'LockScreenOverlaysDisabled' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'NoLockScreen' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'NoLockScreenSlideshow' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }
}
catch
{
   Write-Error -Message $_ -ErrorAction $STP

   exit 1
}

exit 0