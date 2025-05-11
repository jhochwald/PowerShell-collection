#requires -Version 1.0
<#
      .SYNOPSIS
      Global Secure Access (GSA) Default Setup Remediation

      .DESCRIPTION
      Global Secure Access (GSA) Default Setup Remediation

      .EXAMPLE
      PS C:\> .\Remediation-GlobalSecureAccessDefaultSetup.ps1
      Global Secure Access (GSA) Default Setup Remediation

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
   if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
   {
      $paramNewItem = @{
         Path        = $RegPath
         Force       = $true
         Confirm     = $false
         ErrorAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
      $paramNewItem = $null
   }
   
   $paramNewItemProperty = @{
      LiteralPath = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty -Name 'HideSignOutButton' -Value 0 -PropertyType DWord @paramNewItemProperty)
   $null = (New-ItemProperty -Name 'HideDisablePrivateAccessButton' -Value 0 -PropertyType DWord @paramNewItemProperty)
   $null = (New-ItemProperty -Name 'HideDisableButton' -Value 0 -PropertyType DWord @paramNewItemProperty)
   $null = (New-ItemProperty -Name 'RestrictNonPrivilegedUsers' -Value 0 -PropertyType DWord @paramNewItemProperty)
   $paramNewItemProperty = $null
}
