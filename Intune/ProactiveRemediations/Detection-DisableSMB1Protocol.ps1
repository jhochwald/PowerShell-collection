<#
.SYNOPSIS
Detection-DisableSMB1Protocol

.DESCRIPTION
Detection-DisableSMB1Protocol

.EXAMPLE
PS C:\> .\Detection-DisableSMB1Protocol.ps1

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
      $smbv1 = (Get-SmbServerConfiguration -ErrorAction Stop | Select-Object -ExpandProperty EnableSMB1Protocol)
      
      if ($smbv1 -eq $false)
      {
         exit 0
      }
      else
      {
         exit 1
      }
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