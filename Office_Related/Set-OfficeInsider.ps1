#requires -Version 1.0

<#
   .SYNOPSIS
   This script will set the Office Channel info in the Registry

   .DESCRIPTION
   This script will add the Office Insider Channel Information in the Registry.
   It is a Quick and Dirty Solution.

   .PARAMETER Channel
   The Office Release Channel

   Possible Values for the Channel Variable are:
   Insiderfast - With weekly builds, not generally supported
   FirstReleaseCurrent - Office Insider Slow aka First Release Channel
   Current - Current Channel (Default)
   Validation - First Release for Deferred Channel
   Business - Also known as Current Branch for Business

   .EXAMPLE
   # Set the Distribution Channel to Insiderfast - Weekly builds
   PS> .\Set-OfficeInsider.ps1 -Channel 'Insiderfast'

   .EXAMPLE
   # Set the Distribution Channel to Business - Slow updates
   PS> .\Set-OfficeInsider.ps1 -Channel 'Business'

   .NOTES
   This will work with Windows based Office 365 (Click to Run) installations only!

   Change the Release Channel might cause issues! Do this at your own risk.
   Not all Channels are supported by Microsoft.

   Author: Joerg Hochwald - http://hochwald.net
#>
param
(
   [Parameter(ValueFromPipeline = $true,
      Position = 1)]
   [ValidateSet('Insiderfast', 'FirstReleaseCurrent', 'Current', 'Validation', 'Business', IgnoreCase = $true)]
   [ValidateNotNullOrEmpty()]
   [string]
   $Channel = 'Current'
)

begin
{
   # Constants
   $SC = 'SilentlyContinue'

   try
   {
      $paramNewItem = @{
         Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\'
         Name          = 'officeupdate'
         Force         = $true
         ErrorAction   = $SC
         WarningAction = $SC
         Confirm       = $false
      }
      $null = (New-Item @paramNewItem)

      Write-Verbose -Message 'The Registry Structure was created.'
   }
   catch
   {
      Write-Verbose -Message 'The Registry Structure exists...'
   }
}

process
{
   try
   {
      $paramNewItemProperty = @{
         Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate'
         Name          = 'updatebranch'
         PropertyType  = 'String'
         Value         = $Channel
         Force         = $true
         ErrorAction   = $SC
         WarningAction = $SC
         Confirm       = $false
      }
      $null = (New-ItemProperty @paramNewItemProperty)

      Write-Verbose -Message 'Registry Entry was created.'
   }
   catch
   {
      $paramSetItem = @{
         Path          = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate\updatebranch'
         Value         = $Channel
         Force         = $true
         ErrorAction   = $SC
         WarningAction = $SC
         Confirm       = $false
      }
      $null = (Set-Item @paramSetItem)

      Write-Verbose -Message 'Registry Entry was changed.'
   }
}

end
{
   Write-Output -InputObject "Office Release Channel Set to $Channel"
}
