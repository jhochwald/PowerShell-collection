<#
	.SYNOPSIS
	Get the AzureAD Audit Sign-In Logs

	.DESCRIPTION
	Get the AzureAD Audit Sign-In Logs and create several CSV files

	.PARAMETER Days
	Days to search

	.EXAMPLE
	PS C:\> .\Invoke-GetAzureADAuditSignInLogs.ps1

	Get the AzureAD Audit Sign-In Logs for the last 24 hours

	.EXAMPLE
	PS C:\> .\Invoke-GetAzureADAuditSignInLogs.ps1 -Days 10

	Get the AzureAD Audit Sign-In Logs for the last 10 days

	.LINK
	Get-AzureADAuditSignInLogs

	.NOTES
	Initial Beta Version
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNull()]
   [ValidateNotNullOrEmpty()]
   [Alias('DaysToSearch')]
   [int]
   $Days = 1
)

begin
{
   #region
   if ($Days -lt 1)
   {
      Write-Error -Exception 'Value to low' -Message 'The given Days Value is below 1' -Category InvalidArgument -TargetObject $Days -RecommendedAction 'Select between 1 and 30' -ErrorAction Stop
      Exit 1
   }

   if ($Days -gt 30)
   {
      Write-Error -Exception 'Value to high' -Message 'The given Days Value is above 30' -Category InvalidArgument -TargetObject $Days -RecommendedAction 'Select between 1 and 30' -ErrorAction Stop
      Exit 1
   }
   #endregion

   # You might want to tweak this a bit!
   $null = (Disconnect-AzureAD -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (Remove-Module -Name AzureAD -Force -ErrorAction SilentlyContinue)
   $null = (Import-Module -Name AzureADPreview -Force -ErrorAction SilentlyContinue)
   $null = (Connect-AzureAD)

   # Garbage Collection
   [GC]::Collect()

   # Cleanup
   $filterAll = $null
   $AzureAdSignInAll = $null
   $AzureAdSignInFail = $null
   $AzureAdSignInGood = $null
   $AzureAdSignInAllCAfail = $null
   $AzureAdSignInFailCAfail = $null
   $AzureAdSignInGoodCAfail = $null

   # Define some defaults
   $StartDateRaw = ((Get-Date).addDays(-$Days))
   $StartDate = ('{0}-{1}-{2}' -f $StartDateRaw.Year, $StartDateRaw.Month, $StartDateRaw.Day)
   $StartDateRaw = $null
   $EndDateRaw = (Get-Date)
   $EndDate = ('{0}-{1}-{2}' -f $EndDateRaw.Year, $EndDateRaw.Month, $EndDateRaw.Day)
   $EndDateRaw = $null
}

process
{
   try
   {
      # Filtering
      $filterAll = ('createdDateTime ge {0} and createdDateTime le {1}' -f $StartDate, $EndDate)

      # Get the Logs
      $AzureAdSignInAll = (Get-AzureADAuditSignInLogs -Filter $filterAll)

      # Rest is done with filtering
      $AzureAdSignInFail = ($AzureAdSignInAll | Where-Object -FilterScript {
            $PSItem.status.errorCode -ne 0
         })
      $AzureAdSignInGood = ($AzureAdSignInAll | Where-Object -FilterScript {
            $PSItem.status.errorCode -eq 0
         })

      #region StructureData
      $AzureAdSignInGood = ($AzureAdSignInGood | Select-Object -Property CreatedDateTime, UserPrincipalName, RiskState, AppId, ClientAppUsed, IpAddress, @{
            N = 'City'
            E = {
               $PSItem.Location.City
            }
         }, @{
            N = 'CountryOrRegion'
            E = {
               $PSItem.Location.CountryOrRegion
            }
         }, @{
            N = 'FailureReason'
            E = {
               $PSItem.Status.FailureReason
            }
         }, ConditionalAccessStatus)

      $AzureAdSignInAll = ($AzureAdSignInAll | Select-Object -Property CreatedDateTime, UserPrincipalName, RiskState, AppId, ClientAppUsed, IpAddress, @{
            N = 'City'
            E = {
               $PSItem.Location.City
            }
         }, @{
            N = 'CountryOrRegion'
            E = {
               $PSItem.Location.CountryOrRegion
            }
         }, @{
            N = 'FailureReason'
            E = {
               $PSItem.Status.FailureReason
            }
         }, ConditionalAccessStatus)

      $AzureAdSignInFail = ($AzureAdSignInFail | Select-Object -Property CreatedDateTime, UserPrincipalName, RiskState, AppId, ClientAppUsed, IpAddress, @{
            N = 'City'
            E = {
               $PSItem.Location.City
            }
         }, @{
            N = 'CountryOrRegion'
            E = {
               $PSItem.Location.CountryOrRegion
            }
         }, @{
            N = 'FailureReason'
            E = {
               $PSItem.Status.FailureReason
            }
         }, ConditionalAccessStatus)
      #endregion StructureData

      #region ConditionalAccessFilter
      # BUG: Does not work as expected
      $AzureAdSignInAllCAfail = ($AzureAdSignInAll | Where-Object -FilterScript {
            (($PSItem.ConditionalAccessStatus -ne 'success') -and ($PSItem.ConditionalAccessStatus -ne 'notApplied'))
         })

      $AzureAdSignInFailCAfail = ($AzureAdSignInFail | Where-Object -FilterScript {
            (($PSItem.ConditionalAccessStatus -ne 'success') -and ($PSItem.ConditionalAccessStatus -ne 'notApplied'))
         })

      $AzureAdSignInGoodCAfail = ($AzureAdSignInGood | Where-Object -FilterScript {
            (($PSItem.ConditionalAccessStatus -ne 'success') -and ($PSItem.ConditionalAccessStatus -ne 'notApplied'))
         })
      #endregion ConditionalAccessFilter

      $TimeStamp = Get-Date -Format yyyyMMdd_HHmmss

      # TODO: Make it a parameter
      $ExportPath = ('C:\scripts\PowerShell\exports\AzureADSignInAudit')

      if (-not (Test-Path -Path $ExportPath))
      {
         $null = (New-Item -Path $ExportPath -ItemType Directory -Force)
      }

      #region Export
      $null = ($AzureAdSignInAll | Export-Csv -Path ($ExportPath + '\AllSignInAuditLogs_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8)

      $null = ($AzureAdSignInFail | Export-Csv -Path ($ExportPath + '\FailSignInAuditLogs_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8)

      $null = ($AzureAdSignInGood | Export-Csv -Path ($ExportPath + '\GoodSignInAuditLogs_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8)

      if ($AzureAdSignInAllCAfail)
      {
         $null = ($AzureAdSignInAllCAfail | Export-Csv -Path ($ExportPath + '\AllSignInAuditLogs_CAFAIL_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8)
      }

      if ($AzureAdSignInFailCAfail)
      {
         $null = ($AzureAdSignInFailCAfail | Export-Csv -Path ($ExportPath + '\FailSignInAuditLogs_CAFAIL_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8)
      }

      if ($AzureAdSignInGoodCAfail)
      {
         $null = ($AzureAdSignInGoodCAfail | Export-Csv -Path ($ExportPath + '\GoodSignInAuditLogs_CAFAIL_' + $TimeStamp + '.csv') -NoTypeInformation -Force -Encoding UTF8)
      }
      #endregion Export
   }
   catch
   {
      #region ErrorHandler
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # Only here to catch a global ErrorAction overwrite
      exit 1
      #endregion ErrorHandler
   }
   finally
   {
      # Cleanup
      $filterAll = $null
      $AzureAdSignInAll = $null
      $AzureAdSignInFail = $null
      $AzureAdSignInGood = $null
      $AzureAdSignInAllCAfail = $null
      $AzureAdSignInFailCAfail = $null
      $AzureAdSignInGoodCAfail = $null

      # Garbage Collection
      [GC]::Collect()
   }
}
