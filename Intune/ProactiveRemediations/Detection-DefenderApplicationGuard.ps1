<#
   .SYNOPSIS
   Microsoft Defender Application Guard

   .DESCRIPTION
   Microsoft Defender Application Guard

   .NOTES
   Designed to run in Microsoft Endpoint Manager (Intune)
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

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
   #LLSA protection
   $REG_CREDG = 'HKLM:SYSTEM\CurrentControlSet\Control\Lsa'
   $REG_CREDG_value = ((Get-ItemProperty -Path $REG_CREDG).RunAsPPL)

   # Set 'Account lockout threshold' to 1-10 invalid login attempts
   $NetAccounts = (& "$env:windir\system32\net.exe" accounts | Select-String -Pattern 'lockout threshold')

   if ($netaccounts -like '*Never')
   {
      $netaccounts_Value = '0'
   }

   # Turn on Microsoft Defender Application Guard managed mode
   if (((Get-ComputerInfo).OsTotalVisibleMemorySize / 1024000) -gt '8')
   {
      $DeviceGuard = ((Get-WindowsOptionalFeature -Online -FeatureName Windows-Defender-ApplicationGuard).state)
   }
   else
   {
      Write-Output -InputObject 'Not enough memory'

      exit 0
   }

   if (($REG_CREDG_value -ne '1') -or ($netaccounts_Value -eq '0') -or ($DeviceGuard -eq 'Disabled'))
   {
      exit 1
   }
}
catch
{
   Write-Error -Message $_ -ErrorAction Stop

   exit 1
}

exit 0