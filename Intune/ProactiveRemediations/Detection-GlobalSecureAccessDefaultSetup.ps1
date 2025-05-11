#requires -Version 5.0
<#
      .SYNOPSIS
      Global Secure Access (GSA) Default Setup Detection

      .DESCRIPTION
      Global Secure Access (GSA) Default Setup Detection

      .EXAMPLE
      PS C:\> .\Detection-GlobalSecureAccessDefaultSetup.ps1
      Global Secure Access (GSA) Default Setup Detection

      .LINK
      https://microsoft.github.io/GlobalSecureAccess/How-To/HardenWinGSA/#hiding-gsa-client-context-menu-options

      .NOTES
      Please double check the settings
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

begin
{
   $RegPath = 'HKLM:\SOFTWARE\Microsoft\Global Secure Access Client'
}

process
{
   try
   {
      if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
      {
         exit 1
      }
      
      $paramGetItemPropertyValue = @{
         LiteralPath = $RegPath
         ErrorAction = 'SilentlyContinue'
      }
      
      (Get-ItemPropertyValue @paramGetItemPropertyValue)
      
      if (!((Get-ItemPropertyValue -Name 'HideSignOutButton' @paramGetItemPropertyValue) -eq 0))
      {
         exit 1
      }
      
      if (!((Get-ItemPropertyValue -Name 'HideDisablePrivateAccessButton' @paramGetItemPropertyValue) -eq 0))
      {
         exit 1
      }
      
      if (!((Get-ItemPropertyValue -Name 'HideDisableButton' @paramGetItemPropertyValue) -eq 0))
      {
         exit 1
      }
      
      if (!((Get-ItemPropertyValue -Name 'RestrictNonPrivilegedUsers' -ErrorAction SilentlyContinue) -eq 0))
      {
         exit 1
      }
      
      $paramGetItemPropertyValue = $null
   }
   catch
   {
      exit 1
   }
}

end
{
   exit 0
}
   