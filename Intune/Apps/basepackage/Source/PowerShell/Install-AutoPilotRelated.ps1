#requires -Version 2.0 -Modules PackageManagement, PowerShellGet -RunAsAdministrator

<#
   .SYNOPSIS
   Check and install all prerequisites and dependencies, if they are needed

   .DESCRIPTION
   Check and install all prerequisites and dependencies, if they are needed

   .EXAMPLE
   PS C:\> .\Install-AutoPilotRelated.ps1

   # Check and install all prerequisites and dependencies, if they are needed

   .NOTES
   Version 1.0.1

   Additional information about the file.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   #region Global
   $IGN = 'Ignore'
   $SCT = 'SilentlyContinue'

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   $paramFindPackageProvider = @{
      Name                = 'NuGet'
      ForceBootstrap      = $true
      IncludeDependencies = $true
      Force               = $true
      ErrorAction         = $SCT
   }

   $paramInstallModule = @{
      Force              = $true
      Scope              = 'AllUsers'
      AllowClobber       = $true
      SkipPublisherCheck = $true
      Confirm            = $false
      ErrorAction        = $SCT
   }

   $paramSetPSRepository = @{
      Name               = 'PSGallery'
      InstallationPolicy = 'Trusted'
      ErrorAction        = $SCT
   }

   $paramInstallScript = @{
      Name        = 'Get-WindowsAutoPilotInfo'
      Scope       = 'AllUsers'
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   #endregion Global

   #region Cleanup
   $NuGetProvider = $null
   $WindowsAutopilotIntuneModule = $null
   $AzureADModule = $null
   $ScriptInfo = $null
   #endregion Cleanup

   #region GatherInfo
   $paramGetPackageProvider = @{
      Name        = 'NuGet'
      ErrorAction = $IGN
   }
   $NuGetProvider = (Get-PackageProvider @paramGetPackageProvider)

   $paramImportModule = @{
      NoClobber           = $true
      DisableNameChecking = $true
      PassThru            = $true
      ErrorAction         = $IGN
   }

   # Get the module info
   $WindowsAutopilotIntuneModule = (Import-Module -Name WindowsAutopilotIntune @paramImportModule)
   $AzureADModule = (Import-Module -Name AzureAD @paramImportModule)

   # Get the repository info
   $PSRepositoryInfo = (Get-PSRepository -Name PSGallery -ErrorAction $SCT)
   #endregion GatherInfo

   #region
   $paramGetInstalledScript = @{
      Name        = 'Get-WindowsAutoPilotInfo'
      ErrorAction = $SCT
   }
   $ScriptInfo = (Get-InstalledScript @paramGetInstalledScript)
   #endregion
}

process
{
   #region PackageProvider
   # Get the NuGet PackageProvider for the PowerShell Gallery, if needed
   if (-not $NuGetProvider)
   {
      $null = (Find-PackageProvider @paramFindPackageProvider)
   }
   #endregion PackageProvider

   #region PSRepository
   if (($PSRepositoryInfo | Select-Object -ExpandProperty InstallationPolicy) -ne $true)
   {
      $null = (Set-PSRepository @paramSetPSRepository)
   }
   #endregion PSRepository

   #region ModuleHandler
   # Get Azure AD module, if needed
   if (-not $AzureADModule)
   {
      $null = (Install-Module -Name AzureAD @paramInstallModule)
   }

   # Get WindowsAutopilotIntune module, if needed
   if (-not $WindowsAutopilotIntuneModule)
   {
      $null = (Install-Module -Name WindowsAutopilotIntune @paramInstallModule)
   }
   #endregion ModuleHandler

   #region ScriptHandler
   # Install the Helper script from the Gallery
   if (-not $ScriptInfo)
   {
      $null = (Install-Script @paramInstallScript)
   }
   #endregion ScriptHandler
}

end
{
   #region Cleanup
   $NuGetProvider = $null
   $WindowsAutopilotIntuneModule = $null
   $AzureADModule = $null
   $ScriptInfo = $null
   #endregion Cleanup

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
   }
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2020, Beyond Datacenter
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
   - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER

