<#
   .SYNOPSIS
   Tweak Windows Explorer Settings

   .DESCRIPTION
   Tweak Windows Explorer Settings

   .NOTES
   Designed to run in Microsoft Endpoint Manager (Intune)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

#region Defaults
$RegistryPath = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
$SCT = 'SilentlyContinue'
$STOP = 'Stop'
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
   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction $STOP))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'AddSearchInternetLinkInStartMenu' -ErrorAction $SCT) -eq 0))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'GoToDesktopOnSignIn' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'NoStartMenuHomegroup' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'NoStartMenuRecordedTV' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'ShowRunAsDifferentUserInStart' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'DisableSearchBoxSuggestions' -ErrorAction $SCT) -eq 1))
   {
      exit 1
   }
}
catch
{
   Write-Error -Message $_ -ErrorAction $STOP

   exit 1
}

exit 0