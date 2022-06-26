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
$STP = 'Stop'
$RegistryPath = 'HKCU:\Software\Policies\Microsoft\Windows\Explorer'
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
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
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

   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'AddSearchInternetLinkInStartMenu' -Value 0 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'GoToDesktopOnSignIn' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'NoStartMenuHomegroup' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'NoStartMenuRecordedTV' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'ShowRunAsDifferentUserInStart' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
   $null = (New-ItemProperty -LiteralPath $RegistryPath -Name 'DisableSearchBoxSuggestions' -Value 1 -PropertyType DWord -Force -Confirm:$false -ErrorAction $STP)
}
catch
{
   Write-Error -Message $_ -ErrorAction $STP

   Exit 1
}