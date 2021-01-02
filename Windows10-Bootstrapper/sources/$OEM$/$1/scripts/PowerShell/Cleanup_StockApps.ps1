#requires -Version 2.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Remove Windows 10 Stock Applications

   .DESCRIPTION
   Remove Windows 10 Stock Applications

   .NOTES
   Version 1.0.2

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Remove Windows 10 Stock Applications'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   #region AppList
   $AllPackages = @(
      'Microsoft.Windows.Cortana',
      '*Cortana*', 'Microsoft.Bing*',
      'Microsoft.Xbox*',
      'Microsoft.WindowsPhone',
      '*Solitaire*',
      'Microsoft.People',
      'Microsoft.Zune*',
      'Microsoft.WindowsSoundRecorder',
      'microsoft.windowscommunicationsapps',
      'Microsoft.SkypeApp',
      'officehub',
      '3dbuilder',
      'windowscamera',
      '*Dell*',
      '*Dropbox*',
      '*Facebook*',
      'Microsoft.WindowsFeedbackHub',
      'Microsoft.Getstarted',
      '*Autodesk*',
      '*Keeper*',
      '*McAfee*',
      '*Minecraft*',
      '*Netflix*',
      'Microsoft.MicrosoftOfficeHub',
      'Microsoft.OneConnect',
      '*Plex*',
      'Microsoft.SkypeApp',
      '*Solitaire*',
      'Microsoft.Office.Sway',
      '*Twitter*',
      '*DisneyMagicKingdom*',
      '*Disney*',
      '*HiddenCityMysteryofShadows*',
      '*HiddenCity*',
      'Microsoft.YourPhone',
      'Microsoft.WindowsMaps',
      'Microsoft.Print3D',
      'Microsoft.MixedReality.Portal',
      'Microsoft.Microsoft3DViewer',
      'Microsoft.GetHelp',
      'Microsoft.MicrosoftStickyNotes',
      'Microsoft.Windows.Photos'
      'Microsoft.MSPaint'
   )
   #endregion AppList
}

process
{
   #region AppListLoop
   foreach ($item in $AllPackages)
   {
      try
      {
         # Stop Search - Gain performance
         $paramStopService = @{
            Force       = $true
            Confirm     = $false
            ErrorAction = $SCT
         }
         $paramGetService = @{
            Name        = 'WSearch'
            ErrorAction = $SCT
         }
         $null = (Get-Service @paramGetService | Where-Object {
               $_.Status -eq 'Running'
            } | Stop-Service @paramStopService)
         $paramRemoveAppxPackage = @{
            Confirm                 = $false
            PreserveApplicationData = $false
            ErrorAction             = $SCT
            WarningAction           = $SCT
         }
         $paramGetAppxPackage = @{
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Get-AppxPackage @paramGetAppxPackage | Where-Object -FilterScript {
               $_.name -like '*' + $item + '*'
            } | Remove-AppxPackage @paramRemoveAppxPackage)
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }

      try
      {
         # Stop Search - Gain performance
         $paramStopService = @{
            Force       = $true
            Confirm     = $false
            ErrorAction = $SCT
         }
         $paramGetService = @{
            Name        = 'WSearch'
            ErrorAction = $SCT
         }
         $null = (Get-Service @paramGetService | Where-Object {
               $_.Status -eq 'Running'
            } | Stop-Service @paramStopService)

         $paramRemoveAppxPackage = @{
            AllUsers      = $true
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $paramGetAppxPackage = @{
            AllUsers      = $true
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Get-AppxPackage @paramGetAppxPackage | Where-Object -FilterScript {
               $_.name -like '*' + $item + '*'
            } | Remove-AppxPackage @paramRemoveAppxPackage)
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }

      try
      {
         $paramRemoveAppxProvisionedPackage = @{
            Online        = $true
            AllUsers      = $true
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $paramGetAppxProvisionedPackage = @{
            Online        = $true
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         $null = (Get-AppxProvisionedPackage @paramGetAppxProvisionedPackage | Where-Object -FilterScript {
               $_.DisplayName -like '*' + $item + '*'
            } | Remove-AppxProvisionedPackage @paramRemoveAppxProvisionedPackage)
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }
   }
   #endregion AppListLoop

   #region UninstallMcAfeeSecurity
   $McAfeeSecurityApp = $null

   $paramGetChildItem = @{
      Path          = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
      ErrorAction   = $SCT
      WarningAction = $SCT
   }

   $McAfeeSecurityApp = (Get-ChildItem @paramGetChildItem | ForEach-Object -Process {
         $paramGetItemProperty = @{
            Path          = $_.PSPath
            ErrorAction   = $SCT
            WarningAction = $SCT
         }
         Get-ItemProperty @paramGetItemProperty
      } | Where-Object -FilterScript {
         $_ -match 'McAfee Security'
      } | Select-Object -ExpandProperty UninstallString)

   if ($McAfeeSecurityApp)
   {
      $McAfeeSecurityApp = $McAfeeSecurityApp -Replace "$env:ProgramW6432\McAfee\MSC\mcuihost.exe", ''

      $paramStartProcess = @{
         FilePath      = "$env:ProgramW6432\McAfee\MSC\mcuihost.exe"
         ArgumentList  = $McAfeeSecurityApp
         Wait          = $true
         ErrorAction   = $SCT
         WarningAction = $SCT
      }
      $null = (Start-Process @paramStartProcess)
   }
   #endregion UninstallMcAfeeSecurity
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
