#requires -Version 3.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Configure Storage Sense for Windows 10

   .DESCRIPTION
   Configure Storage Sense for Windows 10

   .EXAMPLE
   PS C:\> .\Set-StorageSense.ps1

   .NOTES
   Version 1.0.3

   Use Set-StorageSense Version 1.0 from Jaap Brasser

   .LINK
   https://github.com/jaapbrasser/SharedScripts/blob/master/Set-StorageSense/Set-StorageSense.ps1
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   Write-Output -InputObject 'Configure Storage Sense for Windows 10'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   function Set-StorageSense
   {
      <#
         .SYNOPSIS
         Configures the Storage Sense options in Windows 10

         .DESCRIPTION
         This function can configure Storage Sense options in Windows 10. It allows to enable/disable this feature

         .PARAMETER EnableStorageSense
         Enables storage sense setting, automatically cleaning up space on your system

         .PARAMETER DisableStorageSense
         Disables storage sense setting, not automatically cleaning up space on your system

         .PARAMETER RemoveAppFiles
         Configures the 'Delete temporary files that my apps aren't using' to either true or false

         .PARAMETER ClearRecycleBin
         Configures the 'Delete files that have been in the recycle bin for over 30 days' to either true or false

         .NOTES
         Name:        Set-StorageSense
         Author:      Jaap Brasser
         DateCreated: 2017-01-26
         DateUpdated: 2017-01-26
         Version:     1.0.0
         Blog:        http://www.jaapbrasser.com

         .LINK
         http://www.jaapbrasser.com

         .EXAMPLE
         Set-StorageSense -DisableStorageSense

         Description
         -----------
         Disables Storage Sense on the system

         .EXAMPLE
         Set-StorageSense -EnableStorageSense -RemoveAppFiles $true

         Description
         -----------
         Enables Storage Sense on the system and sets the 'Delete temporary files that my apps aren't using' to enabled

         .EXAMPLE
         Set-StorageSense -DisableStorageSense -RemoveAppFiles $true -ClearRecycleBin $true -Verbose

         Description
         -----------
         Disables Storage Sense on the system and sets both the 'Delete temporary files that my apps aren't using' and the 'Delete files that have been in the recycle bin for over 30 days' to enabled
      #>
      [cmdletbinding(SupportsShouldProcess)]
      param (
         [Parameter(
            Mandatory, HelpMessage = 'Add help message for user',
            ParameterSetName = 'StorageSense On'
         )]
         [switch]
         $EnableStorageSense,
         [Parameter(
            Mandatory, HelpMessage = 'Add help message for user',
            ParameterSetName = 'StorageSense Off'
         )]
         [switch]
         $DisableStorageSense,
         [Parameter(
            ParameterSetName = 'StorageSense On'
         )]
         [Parameter(
            ParameterSetName = 'StorageSense Off'
         )]
         [Parameter(
            ParameterSetName = 'Configure StorageSense'
         )]
         [bool]
         $RemoveAppFiles,
         [Parameter(
            ParameterSetName = 'StorageSense On'
         )]
         [Parameter(
            ParameterSetName = 'StorageSense Off'
         )]
         [Parameter(
            ParameterSetName = 'Configure StorageSense'
         )]
         [bool]
         $ClearRecycleBin
      )

      begin
      {
         $RegPath = @{
            StorageSense = '01'
            TemporaryApp = '04'
            RecycleBin   = '08'
         }
         $SetRegistrySplat = @{
            Path  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\'
            Name  = $null
            Value = $null
         }

         function Set-RegistryValue
         {
            <#
               .SYNOPSIS
               Describe purpose of "Set-RegistryValue" in 1-2 sentences.

               .DESCRIPTION
               Add a more complete description of what the function does.

               .PARAMETER Path
               Describe parameter -Path.

               .PARAMETER Name
               Describe parameter -Name.

               .PARAMETER Value
               Describe parameter -Value.

               .EXAMPLE
               Set-RegistryValue -Path Value -Name Value -Value Value
               Describe what this call does

               .NOTES
               Place additional notes here.

               .LINK
               URLs to related sites
               The first link is opened by Get-Help -Online Set-RegistryValue

               .INPUTS
               List of input types that are accepted by this function.

               .OUTPUTS
               List of output types produced by this function.
            #>
            [CmdletBinding()]
            param (
               [string]
               $Path,
               [string]
               $Name,
               [string]
               $Value
            )

            if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue))
            {
               if ($PSCmdlet.ShouldProcess("$Path$Name : $Value", 'Creating registry key'))
               {
                  $null = New-Item -Path $Path -Force -ErrorAction SilentlyContinue
               }
            }

            if ($PSCmdlet.ShouldProcess("$Path$Name : $Value", 'Updating registry value'))
            {
               $null = Set-ItemProperty @PSBoundParameters -Force -ErrorAction SilentlyContinue
            }
         }
      }

      process
      {
         switch (1)
         {
            {
               $PSCmdlet.ParameterSetName -eq 'StorageSense On'
            }
            {
               $SetRegistrySplat.Name = $RegPath.StorageSense
               $SetRegistrySplat.Value = 1
               Set-RegistryValue @SetRegistrySplat
            }
            {
               $PSCmdlet.ParameterSetName -eq 'StorageSense Off'
            }
            {
               $SetRegistrySplat.Name = $RegPath.StorageSense
               $SetRegistrySplat.Value = 0
               Set-RegistryValue @SetRegistrySplat
            }
            {
               $PSBoundParameters.Keys -contains 'RemoveAppFiles'
            }
            {
               $SetRegistrySplat.Name = $RegPath.TemporaryApp
               $SetRegistrySplat.Value = [int]$RemoveAppFiles
               Set-RegistryValue @SetRegistrySplat
            }
            {
               $PSBoundParameters.Keys -contains 'ClearRecycleBin'
            }
            {
               $SetRegistrySplat.Name = $RegPath.RecycleBin
               $SetRegistrySplat.Value = [int]$ClearRecycleBin
               Set-RegistryValue @SetRegistrySplat
            }
         }
      }
   }
}

process
{
   $paramSetStorageSense = @{
      EnableStorageSense = $true
      RemoveAppFiles     = $true
      ClearRecycleBin    = $true
      Verbose            = $true
      ErrorAction        = $SCT
   }
   $null = (Set-StorageSense @paramSetStorageSense)
}

end
{
   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
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
   - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
