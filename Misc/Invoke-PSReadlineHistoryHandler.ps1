function Invoke-PSReadlineHistoryHandler
{
   <#
         .SYNOPSIS
         Backup and/or remove the PSReadline history

         .DESCRIPTION
         Backup and/or remove the PSReadline history
         PSReadline keeps the history across reboots, this is an awesome function!

         But it can also raise security concerns!
         Because everything is kept in human readable plain text e.g. all secrets used on the command-line

         .PARAMETER PSReadlineHistoryBackup
         Path of your endless history file (endless, because all new history data will be appended)
         Can be usefull to crawl your one-liners within the history, after a while.

         If your PSReadline history contains secrets, keep this in a very safe place!!!

         .PARAMETER Clean
         Cleanup your PSReadline History.
         The existing PSReadline History file will be nulled and your history is cleared

         .EXAMPLE
         PS C:\> Invoke-PSReadlineHistoryHandler -PSReadlineHistoryBackup 'c:\temp\PSReadlineHistoryBackup.txt'

         Backup your existing PSReadline history to 'c:\temp\PSReadlineHistoryBackup.txt'

         .EXAMPLE
         PS C:\> Invoke-PSReadlineHistoryHandler -Clean

         Clear the PSReadline history file, no backup

         .EXAMPLE
         PS C:\> Invoke-PSReadlineHistoryHandler -PSReadlineHistoryBackup 'c:\temp\PSReadlineHistoryBackup.txt' -Clean

         Backup your existing PSReadline history to 'c:\temp\PSReadlineHistoryBackup.txt' and clear the PSReadline history

         .NOTES
         Just a small helper!
         To safe the existing PSReadline history to a central file and/or to clean it permanently, because you want to get rid of secrets that you used on the command line

         Please note:
         There can be several history files!

         Here are some of the well known examples:
         "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\Visual Studio Code Host_history.txt"
         "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\Windows PowerShell ISE Host_history.txt"
         "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"

         This function ignores that fact! It will take care of the one matching the environment at runtime!!! Please keep this in mind.

         if you want to see all your PSReadline history files:
         PS C:\> (Get-ChildItem -Path ('{0}\Microsoft\Windows\PowerShell\PSReadLine\' -f $env:APPDATA) -Filter '*history.txt').FullName
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
                 ValueFromPipelineByPropertyName)]
      [AllowNull()]
      [Alias('BackupFile')]
      [string]
      $PSReadlineHistoryBackup,
      [Parameter(ValueFromPipeline,
                 ValueFromPipelineByPropertyName)]
      [Alias('Remove')]
      [switch]
      $Clean
   )

   begin
   {
      $PSReadlineHistory = ((Get-PSReadlineOption -ErrorAction SilentlyContinue).historysavepath)
   }

   process
   {
      if ($PSReadlineHistoryBackup)
      {
         if (Test-Path -Path $PSReadlineHistory -ErrorAction SilentlyContinue)
         {
            $PSReadlineHistoryContent = ([IO.File]::ReadAllText($PSReadlineHistory))
            $null = ([IO.file]::AppendAllText($PSReadlineHistoryBackup, $PSReadlineHistoryContent))

            # Clean-up
            $PSReadlineHistoryContent = $null
         }
         else
         {
            Write-Warning -Message ('Sorry, {0} does NOT exist. No backup in this case' -f $PSReadlineHistory)
         }
      }

      if ($Clean.IsPresent.Equals($true))
      {
         if (Test-Path -Path $PSReadlineHistory -ErrorAction SilentlyContinue)
         {
            $null = (Clear-History -Confirm:$false -ErrorAction SilentlyContinue)
            $null = ([IO.file]::WriteAllText($PSReadlineHistory, $null))
         }
         else
         {
            Write-Warning -Message ('Sorry, {0} does NOT exist. No clean-up in this case' -f $PSReadlineHistory)
         }
      }

      if ((-not ($PSReadlineHistoryBackup)) -and (($Clean.IsPresent.Equals($false))))
      {
         Write-Warning -Message 'No action specified, therefore we do nothing...'
      }
   }

   end
   {
      # Clean-up
      $PSReadlineHistory = $null
   }
}
