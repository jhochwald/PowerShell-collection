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

#region
$STP = 'Stop'
$SCT = 'SilentlyContinue'
#endregion

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
   # LLSA protection
   $REG_CREDG = 'HKLM:SYSTEM\CurrentControlSet\Control\Lsa'
   $REG_CREDG_value = ((Get-ItemProperty -Path $REG_CREDG).RunAsPPL)

   # Set 'Account lockout threshold' to 1-10 invalid login attempts
   $NetAccounts = net accounts | Select-String -Pattern 'lockout threshold'

   if ($netaccounts -like '*Never')
   {
      $netaccounts_Value = '0'
   }

   #Turn on Microsoft Defender Application Guard managed mode
   if (((Get-ComputerInfo).OsTotalVisibleMemorySize / 1024000) -gt '8')
   {
      $DeviceGuard = ((Get-WindowsOptionalFeature -Online -FeatureName Windows-Defender-ApplicationGuard).state)
   }
   else
   {
      Write-Output -InputObject 'Not enough memory'

      Exit 0
   }

   if (($REG_CREDG_value -ne '1') -or ($netaccounts_Value -eq '0') -or ($DeviceGuard -eq 'Disabled'))
   {
      # LSA protection
      $null = (Remove-ItemProperty -Path $REG_CREDG -Name 'RunAsPPL' -Force -Confirm:$false -ErrorAction $SCT)
      $null = (New-ItemProperty -Path $REG_CREDG -Name 'RunAsPPL' -Value '1' -PropertyType Dword -Force -Confirm:$false -ErrorAction $STP)

      # Set lockout threshold to 10
      $null = (net accounts /lockoutthreshold:10)

      #Enable Application guard if meet the minimum specs
      if ((((Get-ComputerInfo).OsTotalVisibleMemorySize) / 1024000) -gt '8')
      {
         $null = (Enable-WindowsOptionalFeature -Online -FeatureName 'Windows-Defender-ApplicationGuard' -NoRestart -ErrorAction $STP -WarningAction $SCT)
      }
      else
      {
         Write-Output -InputObject 'Not enough memory'

         Exit 0
      }
   }
   else
   {
      exit 0
   }
}
catch
{
   Write-Error -Message $_ -ErrorAction $STP

   Exit 1
}

Exit 0