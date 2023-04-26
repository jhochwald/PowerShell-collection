function Add-LocalDeviceAdmin
{
   <#
         .SYNOPSIS
         Add a given AzureAD Account to the local Device Admin Group

         .DESCRIPTION
         Add a given AzureAD Account to the local Device Admin Group

         .PARAMETER Identity
         The identity of the user that should be added to the local admin group
         No special AzureAD group membership or role is required.
         The user does not even need a licence assigned

         .EXAMPLE
         PS C:\> Add-LocalDeviceAdmin -Identity 'john.doe@contoso.com'

         Add a given AzureAD Account to the local Device Admin Group

         .EXAMPLE
         PS C:\> Add-LocalDeviceAdmin -Identity 'john.doe@contoso.com' -WhatIf

         Simmulate to add a given AzureAD Account to the local Device Admin Group

         .NOTES
         Quick hack to handle local device admins, I prefer to use the new AzureAD based LAPS (whenever possible)
   #>
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   [OutputType([bool])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      HelpMessage = 'The identity of the user that should be added to the local admin group')]
      [ValidateNotNullOrEmpty()]
      [Alias('UserPrincipalName', 'Email', 'User', 'Login')]
      [string]
      $Identity
   )

   begin
   {
      try
      {
         # Get the name of the local administrators group
         [string]$LocalAdminGroupName = ((Get-LocalGroup -SID 'S-1-5-32-544' -ErrorAction Stop).Name)
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

         # For debug issues
         $info | Out-String | Write-Verbose

         $paramWriteError = @{
            Exception         = 'Local Admin Group not found'
            Message           = 'Unable to find the local admin group by SID'
            Category          = 'ObjectNotFound'
            RecommendedAction = 'Please check the SID of the local admin group'
            TargetObject      = $LocalAdminGroupName
            ErrorAction       = 'Stop'
         }
         Write-Error @paramWriteError

         # Ensure we go away
         Exit 1
      }
   }

   process
   {
      <#
            The user needs to start with 'AzureAD\', followed by the UserPrincipalName
            e.g. DavidChew@contoso.com will be 'AzureAD\DavidChew@contoso.com'

            Microsoft Accounts (MSA) needs to start with 'MicrosoftAccount\', followed by the mail address
            e.g., username@Outlook.com will be 'MicrosoftAccount\username@Outlook.com'

            Microsoft Accounts (MSA) are not supported by this cmdlet, it will not work on AzureAD joined devices (AFAIK)
            All accounts needs to come from the tenant where the device is joined (or it needs to be known and trusted in any way)
      #>
      [string]$Identity = ('AzureAD\{0}' -f $Identity)

      if ($pscmdlet.ShouldProcess($LocalAdminGroupName, ('Add ''{0}'' as a member' -f $Identity)))
      {
         try
         {
            # Add the user to the local Administrators group
            $paramAddLocalGroupMember = @{
               Group       = $LocalAdminGroupName
               Member      = $Identity
               Confirm     = $false
               ErrorAction = 'Stop'
            }
            $null = (Add-LocalGroupMember @paramAddLocalGroupMember)
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

            # For debug issues
            $info | Out-String | Write-Verbose

            # Re-Throw the original error
            $_ | Write-Error -ErrorAction Stop

            # Ensure we go away
            Exit 1
         }
      }
   }
}
