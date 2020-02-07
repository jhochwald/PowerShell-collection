<#
      .SYNOPSIS
      Prevent the installation of Bing Search extension in Chrome by tweak the registry

      .DESCRIPTION
      Microsoft will install a Bing Search extension in Chrome with Office 365 ProPlus, this script prevents this.

      .EXAMPLE
      PS C:\> .\Set-PreventBingInstallRegistryKey_splat.ps1

      Prevent the installation of Bing Search extension in Chrome by tweak the registry

      .NOTES
      In this version all commands are splatted to make it better readable (e.g. no long lines)

      If you have a fully Domain managed Client, of the client is managed by Azure AD/Intune, you can handle this there.
      If not (remote users?), you might want to tweak your Registry to prevent the installation of the Bing Search extension in Chrome
      This script will create the matching registry value, if the registry entry exists it also ensures that it is set to prevent the installation.

      .LINK
      https://docs.microsoft.com/en-us/deployoffice/microsoft-search-bing#how-to-exclude-the-extension-for-microsoft-search-in-bing-from-being-installed

      .LINK
      https://github.com/MicrosoftDocs/OfficeDocs-DeployOffice/issues/659

      .LINK
      https://o365reports.com/2020/01/22/using-office-365-proplus-chrome-youll-soon-be-binged/
#>
[CmdletBinding(ConfirmImpact = 'None',
SupportsShouldProcess = $true)]
param ()

begin
{
   #region Defaults
   $RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Office\16.0\Common\Officeupdate'
   $RegistryName = 'preventbinginstall'
   $RegistryValue = '00000001'
   #endregion Defaults
}

process
{
   $paramTestPath = @{
      Path        = $RegistryPath
      ErrorAction = 'SilentlyContinue'
   }
   if (-not (Test-Path @paramTestPath))
   {
      #region CompareValue
      <#
            Compare to ensure that we have the correct settings
            We compressed this a bit to make this one (long) line!
      #>
      $paramGetItem = @{
         LiteralPath = $RegistryPath
         ErrorAction = 'SilentlyContinue'
      }
      if (((Get-Item @paramGetItem ).GetValue($RegistryName, $null)) -ne ($RegistryValue.Replace('0', '')))
      {
         # Enforce the value to be what we want
         $paramSetItemProperty = @{
            Path        = $RegistryPath
            Name        = $RegistryName
            Value       = $RegistryValue
            Force       = $true
            ErrorAction = 'SilentlyContinue'
            Confirm     = $false
         }
         $null = (Set-ItemProperty @paramSetItemProperty)
      }
      #endregion CompareValue
   }
   else
   {
      #region CreateValue
      # Ensure the structure exists
      $paramNewItem = @{
         Path        = $RegistryPath
         Force       = $true
         ErrorAction = 'SilentlyContinue'
         Confirm     = $false
         ItemType    = 'directory'
      }
      $null = (New-Item @paramNewItem)

      # Set the registry key to the correct value
      $paramNewItemProperty = @{
         Path         = $RegistryPath
         Name         = $RegistryName
         Value        = $RegistryValue
         PropertyType = 'DWORD'
         Force        = $true
         ErrorAction  = 'SilentlyContinue'
         Confirm      = $false
      }
      $null = (New-ItemProperty @paramNewItemProperty)
      #endregion CreateValue
   }
}
