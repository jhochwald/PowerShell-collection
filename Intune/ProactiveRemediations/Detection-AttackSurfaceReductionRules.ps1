#requires -Version 2.0

<#
      .SYNOPSIS
      Intune detection script for Attack surface reduction rules

      .DESCRIPTION
      Intune detection script for Attack surface reduction rules

      .EXAMPLE
      PS C:\> .\Detection-Windows10ASR.ps1

      .LINK
      http://jhochwald.com

      .LINK
      https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules-reference

      .NOTES
      Simple Intune detection script
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
      Throw ('Failed to start {0}' -f $PSCOMMANDPATH)
   }

   exit
}
#endregion ARM64Handling

#region IntuneWorkaround
# We do NOT have the CSV for Intune Check/Remediation, so we simulate it

<#
      I reuse this as much as possible, so I try to keep it generic!
      This is the source for my DSC setup, my regular Intune, the Intune Check/Remediation, and some plain PowerShell scripts

      Source: https://docs.microsoft.com/en-us/microsoft-365/security/defender-endpoint/attack-surface-reduction-rules-reference

      2022-03-19 - Joerg Hochwald - http://jhochwald.com
#>
$AttackSurfaceReductionRulesList = '
   "Block abuse of exploited vulnerable signed drivers","lock abuse of exploited vulnerable signed drivers (not yet available)","56a863a9-875e-4185-98a7-b882c64b5ce5","Enabled"
   "Block Adobe Reader from creating child processes","Process creation from Adobe Reader (beta)","7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c","Enabled"
   "Block all Office applications from creating child processes","Office apps launching child processes","d4f940ab-401b-4efc-aadc-ad5f3c50688a","Enabled"
   "Block credential stealing from the Windows local security authority subsystem","Flag credential stealing from the Windows local security authority subsystem","9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2","Enabled"
   "Block executable content from email client and webmail","Block executable content from email client and webmail","be9ba2d9-53ea-4cdc-84e5-9b1eeee46550","Enabled"
   "Block executable files from running unless they meet a prevalence, age, or trusted list criterion","Executables that don''t meet a prevalence, age, or trusted list criteria","01443614-cd74-433a-b99e-2ecdc07bfc25","Enabled"
   "Block execution of potentially obfuscated scripts","Obfuscated js/vbs/ps/macro code","5beb7efe-fd9a-4556-801d-275e5ffc04cc","Enabled"
   "Block JavaScript or VBScript from launching downloaded executable content","js/vbs executing payload downloaded from Internet (no exceptions)","d3e037e1-3eb8-44c8-a917-57927947596d","Enabled"
   "Block Office applications from creating executable content","Office apps/macros creating executable content","3b576869-a4ec-4529-8536-b80a7769e899","Enabled"
   "Block Office applications from injecting code into other processes","Office apps injecting code into other processes (no exceptions)","75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84","Enabled"
   "Block Office communication application from creating child processes","Process creation from Office communication products (beta)","26190899-1602-49e8-8b27-eb1d0a1ce869","Enabled"
   "Block persistence through WMI event subscription","Not available","e6db77e5-3df2-4cf1-b95a-636979351e5b","Enabled"
   "Block process creations originating from PSExec and WMI commands","Process creation from PSExec and WMI commands","d1e49aac-8f56-4280-b9ba-993a6d77406c","AuditMode"
   "Block untrusted and unsigned processes that run from USB","Untrusted and unsigned processes that run from USB","b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4","Enabled"
   "Block Win32 API calls from Office macros","Win32 imports from Office macro code","92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b","Enabled"
   "Use advanced protection against ransomware","Advanced ransomware protection","c1db55ab-c21a-4637-bb3f-a12568109d35","Enabled"
'
$AttackSurfaceReductionRules = ($AttackSurfaceReductionRulesList | ConvertFrom-Csv -Delimiter ',' -Header 'Name', 'IntuneName', 'GUID', 'Action' -ErrorAction SilentlyContinue | Select-Object -Property 'Name', 'GUID', 'Action', @{
      Label      = 'AttackSurfaceReductionRules_Actions'
      Expression = {
         switch ($PSItem.Action)
         {
            AuditMode
            {
               2
            }
            Disabled
            {
               0
            }
            Enabled
            {
               1
            }
            NotConfigured
            {
               5
            }
            Warn
            {
               6
            }
            default
            {
               5
            }
         }
      }
   })
#endregion IntuneWorkaround

# Get the configured Rules
$RulesIds = (Get-MpPreference -ErrorAction SilentlyContinue | Select-Object -ExpandProperty AttackSurfaceReductionRules_Ids)

# Get the configured Rules Actions
$RulesActions = (Get-MpPreference -ErrorAction SilentlyContinue | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions)

# Check if we have them all - More local rules are OK!
if ($RulesIds.Count -lt $AttackSurfaceReductionRules.Count)
{
   exit 1
}

# Start the counter
$RuleCounter = 0

# Loop over them all
foreach ($RulesId in $RulesIds)
{
   if ($AttackSurfaceReductionRules.GUID -contains $RulesId)
   {
      if ($RulesActions[$RuleCounter] -ne ($AttackSurfaceReductionRules | Where-Object -FilterScript {
               $PSItem.GUID -eq $RulesId
            }).AttackSurfaceReductionRules_Actions)
      {
         # This rule does NOT match the desired state
         exit 1
      }

      # Count up
      $RuleCounter++
   }
   else
   {
      Write-Verbose -Message ('{0} is not handled yet!' -f $RulesId)
   }
}

# We are good to go
exit 0
