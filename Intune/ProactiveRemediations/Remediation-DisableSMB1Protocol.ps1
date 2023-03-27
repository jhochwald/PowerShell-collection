<#
.SYNOPSIS
Remediation-DisableSMB1Protocol

.DESCRIPTION
Remediation-DisableSMB1Protocol

.EXAMPLE
PS C:\> .\Remediation-DisableSMB1Protocol.ps1

.LINK
https://github.com/JayRHa/EndpointAnalyticsRemediationScripts

.NOTES
This script contains work from the following authors:
- Joey Verlinden (joeyverlinden.com)
- Andrew Taylor (andrewstaylor.com)
- Florian Slazmann (scloud.work)
- Jannik Reinhard (jannikreinhard.com)
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

process
{
   try
   {
      $paramSetSmbServerConfiguration = @{
         EnableSMB1Protocol = 0
         Force              = $true
         Confirm            = $false
         ErrorAction        = 'Stop'
      }
      $null = (Set-SmbServerConfiguration @paramSetSmbServerConfiguration)
   }
   catch
   {
      # Get error record
      [Management.Automation.ErrorRecord]$e = $_
      
      # Retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
      
      $info | Out-String | Write-Verbose
      
      exit 1
   }
}