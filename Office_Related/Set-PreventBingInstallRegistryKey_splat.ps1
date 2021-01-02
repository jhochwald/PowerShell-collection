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

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2021, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
