<#
      .SYNOPSIS
      Prevent the installation of Bing Search extension in Chrome by tweak the registry

      .DESCRIPTION
      Microsoft will install a Bing Search extension in Chrome with Office 365 ProPlus, this script prevents this.

      .EXAMPLE
      PS C:\> .\Set-PreventBingInstallRegistryKey.ps1

      Prevent the installation of Bing Search extension in Chrome by tweak the registry

      .NOTES
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
   if (-not (Test-Path -Path $RegistryPath -ErrorAction SilentlyContinue))
   {
      #region CompareValue
      <#
            Compare to ensure that we have the correct settings
            We compressed this a bit to make this one (long) line!
      #>
      if (((Get-Item -LiteralPath $RegistryPath -ErrorAction SilentlyContinue).GetValue($RegistryName, $null)) -ne ($RegistryValue.Replace('0', '')))
      {
         # Enforce the value to be what we want
         $null = (Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -Force -ErrorAction SilentlyContinue -Confirm:$false)
      }
      #endregion CompareValue
   }
   else
   {
      #region CreateValue
      # Ensure the structure exists
      $null = (New-Item -Path $RegistryPath -Force -ErrorAction SilentlyContinue -Confirm:$false -ItemType 'directory')

      # Set the registry key to the correct value
      $null = (New-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -PropertyType DWORD -Force -ErrorAction SilentlyContinue -Confirm:$false)
      #endregion CreateValue
   }
}
