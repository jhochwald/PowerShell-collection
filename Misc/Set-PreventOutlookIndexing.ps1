#requires -Version 1.0

function Set-PreventOutlookIndexing
{
   <#
         .SYNOPSIS
         Prevent indexing Microsoft Office Outlook

         .DESCRIPTION
         Prevent indexing Microsoft Office Outlook

         .EXAMPLE
         PS C:\> .\Set-PreventOutlookIndexing

         Prevent indexing Microsoft Office Outlook

         .NOTES
         KB5008212 Windows security update breaks Outlook search

         .LINK
         https://www.catalog.update.microsoft.com/Search.aspx?q=KB5008212
   #>

   try
   {
      $null = (New-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows\Windows Search' -Name PreventIndexingOutlook -PropertyType DWord -Value 1 -ErrorAction Stop)

      Write-Verbose -Message 'Success... Prevent-OutlookIndexing'
   }
   catch
   {
      $errorMessage = $PSItem.Exception.Message
      Write-Warning -Message ('Exception thrown in Set-PreventOutlookIndexing; {0}' -f $errorMessage)
      $errorMessage = $null
   }
}

Set-PreventOutlookIndexing
