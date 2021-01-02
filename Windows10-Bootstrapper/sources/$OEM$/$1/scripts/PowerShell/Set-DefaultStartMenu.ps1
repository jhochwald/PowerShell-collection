#requires -Version 2.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Configure the Windows 10 Start Menu

   .DESCRIPTION
   Configure the Windows 10 Start Menu

   .NOTES
   Version 1.0.3

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Configure the Windows 10 Start Menu'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }

   $StartMenuContent = @'
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
<LayoutOptions StartTileGroupCellWidth="6" />
<DefaultLayoutOverride>
<StartLayoutCollection>
<defaultlayout:StartLayout GroupCellWidth="6">
<start:Group Name="Office">
<start:DesktopApplicationTile Size="2x2" Column="4" Row="2" DesktopApplicationID="Microsoft.Office.POWERPNT.EXE.15" />
<start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationID="com.squirrel.Teams.Teams" />
<start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationID="Microsoft.Office.WINWORD.EXE.15" />
<start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationID="Microsoft.Office.OUTLOOK.EXE.15" />
<start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationID="Microsoft.Office.EXCEL.EXE.15" />
<start:Tile Size="2x2" Column="2" Row="0" AppUserModelID="Microsoft.Office.OneNote_8wekyb3d8bbwe!microsoft.onenoteim" />
</start:Group>
<start:Group Name="Misc">
<start:DesktopApplicationTile Size="1x1" Column="0" Row="0" DesktopApplicationID="Microsoft.VisualStudioCode" />
<start:DesktopApplicationTile Size="1x1" Column="1" Row="1" DesktopApplicationID="{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe" />
<start:DesktopApplicationTile Size="1x1" Column="1" Row="0" DesktopApplicationID="{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\PowerShell_ISE.exe" />
<start:DesktopApplicationTile Size="1x1" Column="3" Row="1" DesktopApplicationID="Microsoft.Windows.Computer" />
<start:Tile Size="1x1" Column="0" Row="1" AppUserModelID="Microsoft.WindowsTerminal_8wekyb3d8bbwe!App" />
<start:DesktopApplicationTile Size="1x1" Column="2" Row="1" DesktopApplicationID="MSEdge" />
<start:Tile Size="1x1" Column="2" Row="0" AppUserModelID="Microsoft.WindowsStore_8wekyb3d8bbwe!App" />
<start:DesktopApplicationTile Size="1x1" Column="3" Row="0" DesktopApplicationID="Microsoft.Windows.Explorer" />
</start:Group>
</defaultlayout:StartLayout>
</StartLayoutCollection>
</DefaultLayoutOverride>
</LayoutModificationTemplate>
'@

   $StartMenuFile = "$env:windir\StartMenuLayout.xml"
}

process
{
   # Stop Search - Gain performance
   $null = (Get-Service -Name 'WSearch' -ErrorAction $SCT | Where-Object -FilterScript {
         $_.Status -eq 'Running'
      } | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)

   # Delete layout file if it already exists
   $paramTestPath = @{
      Path        = $StartMenuFile
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramRemoveItem = @{
         Path        = $StartMenuFile
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
   }

   # Creates the blank layout file
   $paramOutFile = @{
      FilePath    = $StartMenuFile
      Encoding    = 'ASCII'
      Force       = $true
      ErrorAction = $SCT
   }
   $null = ($StartMenuContent | Out-File @paramOutFile)

   $RegistryAliases = @('HKLM', 'HKCU')

   # Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
   foreach ($RegistryAlias in $RegistryAliases)
   {
      $RegistryBasePath = ($RegistryAlias + ':\SOFTWARE\Policies\Microsoft\Windows')
      $RegistryKeyPath = ($RegistryBasePath + '\Explorer')

      $paramTestPath = @{
         Path        = $RegistryKeyPath
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path        = $RegistryBasePath
            Name        = 'Explorer'
            Force       = $true
            Confirm     = $false
            ErrorAction = $SCT
         }
         $null = (New-Item @paramNewItem)
      }

      $paramSetItemProperty = @{
         Path        = $RegistryKeyPath
         Name        = 'LockedStartLayout'
         Value       = 1
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (Set-ItemProperty @paramSetItemProperty)
      $paramSetItemProperty = @{
         Path        = $RegistryKeyPath
         Name        = 'StartLayoutFile'
         Value       = $StartMenuFile
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (Set-ItemProperty @paramSetItemProperty)
   }

   # Restart Explorer, open the start menu (necessary to load the new layout)
   $null = (Stop-Process -Name explorer)

   # Give it a few seconds to process
   Start-Sleep -Seconds 5

   $paramNewObject = @{
      ComObject = 'wscript.shell'
   }
   $WScriptShell = (New-Object @paramNewObject)
   $WScriptShell.SendKeys('^{ESCAPE}')

   # Give it a few seconds to process
   Start-Sleep -Seconds 5

   # Enable the ability to pin items again by disabling "LockedStartLayout"
   foreach ($RegistryAlias in $RegistryAliases)
   {
      $RegistryBasePath = $RegistryAlias + ':\SOFTWARE\Policies\Microsoft\Windows'
      $RegistryKeyPath = $RegistryBasePath + '\Explorer'
      $paramSetItemProperty = @{
         Path        = $RegistryKeyPath
         Name        = 'LockedStartLayout'
         Value       = 0
         Force       = $true
         Confirm     = $false
         ErrorAction = $SCT
      }
      $null = (Set-ItemProperty @paramSetItemProperty)
   }

   # Restart Explorer and delete the layout file
   Stop-Process -Name explorer

   # Uncomment the next line to make clean start menu default for all new users
   # Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\
   $paramRemoveItem = @{
      Path        = $StartMenuFile
      Force       = $true
      Confirm     = $false
      ErrorAction = $SCT
   }
   $null = (Remove-Item @paramRemoveItem)
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
