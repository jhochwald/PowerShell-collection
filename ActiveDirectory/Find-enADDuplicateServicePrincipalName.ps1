function Find-enADDuplicateServicePrincipalName
{
   <#
         .SYNOPSIS
         Find all dumplicate Service Principal Names (SPNs)
	
         .DESCRIPTION
         Find all dumplicate Service Principal Names (SPNs) in the Active Directory

         .INPUTS
         NONE
	
         .OUTPUTS
         Boolean
	
         .EXAMPLE
         PS C:\> Find-enADDuplicateServicePrincipalName
	
         .NOTES
         Version: 1.0.1
		
         GUID: 41c3b1e1-3433-4061-8497-5d6b65976d18
		
         Author: Joerg Hochwald
		
         Companyname: enabling Technology
		
         Copyright: Copyright (c) 2ß18-2019, enabling Technology - All rights reserved.
		
         License: https://opensource.org/licenses/BSD-3-Clause
		
         Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version
		
         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
		
         Dependencies:
         Active Directory PowerShell Module
	
         .LINK
         https://www.enatec.io

         .LINK
         Get-ADObject
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([bool])]
   param ()
	
   begin
   {
      # Create a new Object
      $AllObject = @()
   }
	
   process
   {
      try
      {
         # We use Get-ADObject because this seems to be fast enough
         $paramGetADObject = @{
            Filter        = "(objectClass -eq 'user') -or (objectClass -eq 'computer') -and (servicePrincipalName -like '*')"
            Properties    = 'SamAccountName', 'servicePrincipalName'
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
         }
         $AllServicePrincipalNames = (Get-ADObject @paramGetADObject)
			
         # Loop over the List we got from Get-ADObject
         foreach ($SPNObject in $AllServicePrincipalNames)
         {
            $SamAccountName = $SPNObject.SamAccountName
            $ServicePrincipalNames = $SPNObject.ServicePrincipalName
				
				
            foreach ($ServicePrincipalName in $ServicePrincipalNames)
            {
               if ($AllObject.ServicePrincipalName -like $ServicePrincipalName)
               {
                  $MatchedSPNs = ($AllObject.ServicePrincipalName -like $ServicePrincipalName)
						
                  # Loop over the matching list og SPNs
                  foreach ($MatchSPN in $MatchedSPNs)
                  {
                     $MatchSamAccountName = $MatchSPN.SamAccountName
							
                     # Ding. ding, we have a winner
                     if ($MatchSamAccountName -ne $SamAccountName)
                     {
                        $paramWriteWarning = @{
                           Message       = ('Duplicated SPN has been found for {0}!!!' -f $ServicePrincipalName)
                           ErrorAction   = 'Continue'
                           WarningAction = 'Continue'
                        }
                        Write-Warning @paramWriteWarning
                     }
                  }
               }
               else
               {
                  # Create a new Object
                  $SingleObject = (New-Object -TypeName PSObject -Property @{
                        SamAccountName       = $SamAccountName
                        ServicePrincipalName = $ServicePrincipalName
                  })
						
                  # Add the Values to the List
                  $AllObject += $SingleObject
						
                  # Cleanup
                  $SingleObject = $null
               }
            }
         }
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
			
         $info | Out-String | Write-Verbose
			
         Write-Error -Message ($info.Exception) -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }
	
   end
   {
      # Dump all SPNs, if verbose
      $AllObject | Out-String | Write-Verbose
		
      # Cleanup
      $AllObject = $null
   }
}
Find-enADDuplicateServicePrincipalName -Verbose