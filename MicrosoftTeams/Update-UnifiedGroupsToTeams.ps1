#requires -Version 3.0 -Modules MicrosoftTeams
function Update-UnifiedGroupsToTeams
{
   <#
         .SYNOPSIS
         Converts all Microsoft Office 365 Groups into a new Microsoft Teams Team
	
         .DESCRIPTION
         Converts all Microsoft Office 365 Groups into a new Microsoft Teams Team
         Microsoft Office 365 Groups are also known as Unified Office 365 Groups
	
         .PARAMETER ReportOnly
         Shows a list of Microsoft Office 365 Groups that would be migrated to a new Microsoft Teams Team.
         This is a DryRun only!
	
         .EXAMPLE
         PS C:\> Update-UnifiedGroupsToTeams

         Converting all Microsoft Office 365 Groups into a new Microsoft Teams Team

         .EXAMPLE
         PS C:\> Update-UnifiedGroupsToTeams -ReportOnly

         Do a DryRun (Just get a List of Unified Groups that do NOT have a Microsoft Teams Team)

         .EXAMPLE
         PS C:\> Compare-Object -ReferenceObject ((Get-Team | Select-Object -ExpandProperty GroupId)) -DifferenceObject ((Get-UnifiedGroup -ResultSize Unlimited | Select-Object -ExpandProperty ExternalDirectoryObjectId)) -PassThru

         Get a short difference list (this function is not required to do so)

         .NOTES
         Version: 1.0.1
 
         GUID: 9ff3e101-1197-4243-a132-32ba33a5341c
 
         Author: Joerg Hochwald
 
         Companyname: Alright IT GmbH
 
         Copyright: Copyright (c) 2019, Alright IT GmbH - All rights reserved.
 
         License: https://opensource.org/licenses/BSD-3-Clause
 
         Releasenotes:
         1.0.1 2019-04-21: Add a bit more error handling
         1.0.0 2018-04-14: Internal Release

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         The script depends on Microsoft's Version 0.9.6, or newer, of the MicrosoftTeams PowerShell Module
         
         Install it with PowerShellGet:
         PS C:\> Install-Module MicrosoftTeams

         You need to be connected to Office 365 (Exchange Online). The function will check that.

         .LINK
         https://www.alright-it.com

         .LINK
         https://www.powershellgallery.com/packages/MicrosoftTeams/0.9.6

         .LINK
         https://aka.ms/InstallModule
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [Alias('DryRun')]
      [switch]
      $ReportOnly
   )
	
   begin
   {
      #region Defaults
      $CNT = 'Continue'
      $STP = 'Stop'
      #endregion Defaults

      try 
      {
         #region ConnectionCheck
         if (-not (Get-Command -Name Get-UnifiedGroup -ErrorAction SilentlyContinue)) 
         {
            $ErrorParameter = @{
               Message           = 'Please connect to Office 365/Exchange Online before using this function!'
               Category          = 'ResourceUnavailable'
               RecommendedAction = 'Connect to Office 365/Exchange Online before using this function'
               ErrorAction       = $STP
            }
            Write-Error @ErrorParameter
         }
         #endregion ConnectionCheck
         
         #region GetUnifiedGroups
         $GetUnifiedGroupParameter = @{
            ResultSize    = 'Unlimited'
            ErrorAction   = $STP
            WarningAction = $CNT
         }
         $AllOffice365UnifiedGroups = (Get-UnifiedGroup @GetUnifiedGroupParameter | Select-Object -Property DisplayName, ExternalDirectoryObjectId)
         #endregion GetUnifiedGroups
      
         #region GetMicrosoftTeams
         $GetTeamParameter = @{
            ErrorAction   = $STP
            WarningAction = $CNT
         }
         $AllMicrosoftTeams = (Get-Team @GetTeamParameter | Select-Object -ExpandProperty GroupId)
         #endregion GetMicrosoftTeams
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
             
         # Dump the FULL error record
         Write-Warning -Message ($info | Out-String)
         
         Write-Error -Message $info.Exception -Exception $info.Exception -ErrorAction $STP
         
         break
      }
   }
	
   process
   {
      if ($AllOffice365UnifiedGroups) 
      {
         #region Loop
         foreach ($Office365UnifiedGroup in $AllOffice365UnifiedGroups)
         {
            if (-not ($AllMicrosoftTeams -match $Office365UnifiedGroup.ExternalDirectoryObjectId))
            {
               if ($ReportOnly) 
               {
                  #region ReportOnly
                  $SingleOffice365UnifiedGroup = $Office365UnifiedGroup.DisplayName
                  Write-Output -InputObject ('Microsoft Teams for Unified Group {0} is missing' -f $SingleOffice365UnifiedGroup)
                  #endregion ReportOnly
               }
               else 
               {
                  #region CreateMissingTeam
                  Write-Verbose -Message ('Create Microsoft Teams Team for Unified Group {0}' -f $SingleOffice365UnifiedGroup)
                  
                  try 
                  {
                     $NewTeamParameter = @{
                        Group         = $Office365UnifiedGroup
                        ErrorAction   = $STP
                        WarningAction = $CNT
                     }
                     $NewTeam = (New-Team @NewTeamParameter)

                     Write-Debug -Message $NewTeam
                     
                     Write-Verbose -Message ('Created Microsoft Teams Team for Unified Group {0}' -f $SingleOffice365UnifiedGroup)
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
                       
                     $TheException = $info.Exception

                     Write-Warning -Message ('Microsoft Teams creation for {0} failed with {1} ' -f $SingleOffice365UnifiedGroup, $TheException) 

                     # Dump the FULL error record
                     Write-Verbose -Message ($info | Out-String)
                  }
                  #endregion CreateMissingTeam
               }
            }
         }
         #endregion Loop
      }
      else 
      {
         Write-Warning -Message 'No Unified Groups found in your Tenant...'
      }
   }
	
   end
   {
      Write-Verbose -Message 'Done.'
   }
}
