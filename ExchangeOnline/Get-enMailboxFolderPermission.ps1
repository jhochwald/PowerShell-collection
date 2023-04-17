function Get-enMailboxFolderPermission
{
   <#
         .SYNOPSIS
         This function retrieves the permissions of all calendar folders in a mailbox.

         .DESCRIPTION
         This function retrieves the permissions of all calendar folders in a mailbox, including subfolders.

         .PARAMETER EmailAddress
         Defines the mailbox you want to check

         .EXAMPLE
         PS C:\> Get-enMailboxFolderPermission -EmailAddress 'john.doe@contoso.com'

         Retrieves the permissions of all calendar folders in a mailbox, including subfolders.
         In this case it's the mailbox of John Doe.

         .NOTES
         You need to have the modern Exchange Online PowerShell module installed.
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([PSCustomObject])]
   param
   (
      [Parameter(Mandatory,HelpMessage = 'Defines the mailbox you want to check',
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Identity', 'Maibox', 'Mail', 'Address')]
      [string]
      $EmailAddress
   )
   
   begin
   {
      # Disconnect from Exchange Online
      $paramDisconnectExchangeOnline = @{
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (Disconnect-ExchangeOnline @paramDisconnectExchangeOnline)
      
      # Establishes a connection to Exchange Online.
      $paramConnectExchangeOnline = @{
         UseMultithreading = $true
         ShowProgress      = $false
         ShowBanner        = $false
         ErrorAction       = 'Stop'
      }
      $null = (Connect-ExchangeOnline @paramConnectExchangeOnline)
   }
   
   process
   {
      # Get the statistics for the mailbox you specified in the first line. The statistics are stored in the variable $CalendarStats.
      $paramGetMailboxFolderStatistics = @{
         Identity    = $EmailAddress
         FolderScope = 'Calendar'
         ErrorAction = 'Stop'
      }
      $CalendarStats = (Get-MailboxFolderStatistics @paramGetMailboxFolderStatistics | Select-Object -Property FolderId, FolderPath)

      # Create a new variable $CalendarFoldersPermission and initializes it as an array.
      $CalendarFoldersPermission = @()
      
      # Loop over the List the we found
      foreach ($SingleCalendarStats in $CalendarStats)
      {
         # Create a new object with the string of the Mailbox and FolderID
         [string]$CalendarFolderIdentity = (('{0}:{1}' -f $EmailAddress, $SingleCalendarStats.FolderId))
         
         [PSCustomObject]$CalendarFoldersPermission += (Get-EXOMailboxFolderPermission -Identity $CalendarFolderIdentity -ErrorAction SilentlyContinue | Select-Object -Property @{
               Name       = 'Mailbox'
               Expression = {
                  $EmailAddress
               }
            }, FolderName, @{
               Name       = 'FolderPath'
               Expression = {
                  $SingleCalendarStats.FolderPath
               }
            }, User, @{
               Name       = 'AccessRights'
               Expression = {
                  $_.AccessRights
               }
         }, SharingPermissionFlags)
         
         $CalendarFolderIdentity = $null
      }
   }
   
   end
   {
      # Dump everything to the Terminal
      $CalendarFoldersPermission
      
      # Disconnect from Exchange Online
      $null = (Disconnect-ExchangeOnline @paramDisconnectExchangeOnline)
      
      #region Clean-up
      $CalendarStats = $null
      $CalendarFolderIdentity = $null
      $CalendarFoldersPermission = $null
      #endregion Clean-up
      
      #region GarbageCollection
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      #endregion GarbageCollection
   }
}
