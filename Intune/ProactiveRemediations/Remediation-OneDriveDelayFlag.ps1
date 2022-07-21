<#
   .SYNOPSIS
   OneDrive for Business Delay Flag (Timerautomount)

   .DESCRIPTION
   OneDrive for Business Delay Flag (Timerautomount)

   .NOTES
   Designed to run in Microsoft Endpoint Manager (Intune)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

#region Defaults
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
   $null = (New-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1' -Name 'Timerautomount' -PropertyType 'QWORD' -Value 1 -Force -Confirm:$false -ErrorAction $STP)
}
catch
{
   Write-Error -Message $_ -ErrorAction $STP

   exit 1
}