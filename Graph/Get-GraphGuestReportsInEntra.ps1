#requires -Version 3.0 -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Users

<#
      .SYNOPSIS
      Report the Sponsors of Entra ID Guest Accounts

      .DESCRIPTION
      Report the Sponsors of Entra ID Guest Accounts

      .EXAMPLE
      PS C:\> .\Get-GraphGuestReportsInEntra.ps1

      .NOTES
      Intitial internal PoC.
      Future versions might drop the external modules!
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([pscustomobject])]
param ()

begin
{
   # Cleanup
   $Report = $null
   $AllGuestUser = $null
}

process
{
   Write-Verbose -Message 'connect (interactive) to a an entra tenant.'
   
   try
   {
      $paramConnectMgGraph = @{
         Scopes    = 'AuditLog.Read.All', 'Directory.Read.All'
         NoWelcome = $true
      }
      Connect-MgGraph @paramConnectMgGraph
      $paramConnectMgGraph = $null
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
      
      # output information
      $info
      
      exit 1
   }
   
   Write-Verbose -Message 'Get all guest accounts in the connected tenant.'
   
   $paramGetMgUser = @{
      Filter         = "userType eq 'Guest'"
      All            = $true
      Property       = 'Id', 'DisplayName', 'Sponsors', 'CreatedDateTime', 'SignInActivity', 'Mail'
      ExpandProperty = 'Sponsors'
   }
   [array]$AllGuestUser = (Get-MgUser @paramGetMgUser | Sort-Object -Property DisplayName)
   $paramGetMgUser = $null
   
   # Loop over the list of guest users
   if (!($AllGuestUser))
   {
      Write-Warning -Message 'No guest accounts found.'
      exit 1
   }
   else
   {
      Write-Verbose -Message ('Checking {0} guest accounts...' -f $AllGuestUser.Count)
      
      # Create a new and empty product
      $Report = [Collections.Generic.List[Object]]::new()
      
      # Loop over all known users in this entra tenant
      foreach ($GuestUser in $AllGuestUser)
      {
         # Ensure the object is empty
         $SponsorNames = $null
         
         if ($null -eq $GuestUser.Sponsors.Id)
         {
            # A guest without a sponsor is bad!
            $SponsorNames = 'No sponsor assigned'
         }
         else
         {
            $SponsorNames = $GuestUser.Sponsors.additionalProperties.displayName -join ', '
         }
         
         # Cleanup
         $SignInDate = $null
         
         # Last login info
         if ([string]::IsNullOrEmpty($GuestUser.SignInActivity.LastSuccessfulSignInDateTime))
         {
            $SignInDate = 'No sign-in activity'
            
            [int]$DaysSinceSignIn = ((New-TimeSpan -Start $GuestUser.CreatedDateTime).Days)
         }
         else
         {
            $SignInDate = (Get-Date -Date ($GuestUser.SignInActivity.LastSuccessfulSignInDateTime) -Format 'dd-MMM-yyyy HH:mm')
            
            [int]$DaysSinceSignIn = ((New-TimeSpan -Start $SignInDate).Days)
         }
         
         # Cleanup
         $ReportLine = $null
         
         # One entry at the time
         $ReportLine = [PSCustomObject] @{
            'Name'             = $GuestUser.DisplayName
            'Email'            = $GuestUser.Mail
            'Sponsor Names'    = $SponsorNames
            'Created'          = (Get-Date -Date ($GuestUser.CreatedDateTime) -Format 'dd-MMM-yyyy HH:mm')
            'Last Sign In'     = $SignInDate
            'Days Since Sign In' = $DaysSinceSignIn.ToString()
         }
         
         # Add the entry to the report
         $Report.Add($ReportLine)
         
         # Cleanup
         $ReportLine = $null
         $SponsorNames = $null
         $SignInDate = $null
         $DaysSinceSignIn = $null
      }
      
      # Dump the Info
      $Report
      #$Report | Out-GridView -Title 'Entra ID Guest Account Sponsors'
   }
}

end
{
   # Cleanup
   $Report = $null
   $AllGuestUser = $null
   
   # Close the connection to the entra tenant
   $null = (Disconnect-MgGraph -ErrorAction SilentlyContinue)
}
