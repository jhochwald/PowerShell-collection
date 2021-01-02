#requires -Version 3.0 -Modules BitsTransfer -RunAsAdministrator

<#
   .SYNOPSIS
   Download, install, and Tweak System and Apps for Terminal Server use

   .DESCRIPTION
   Download, install, and Tweak System and Apps for Terminal Server (WVD/VDI/WDS) use

   .NOTES
   Early testing release - Future releases might get some parameters

   Changelog:
   1.0.1: Reformatted
   1.0.0: Initial Release

   Version 1.0.1

   .LINK
   http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   Write-Output -InputObject 'Download, install, and Tweak System and Apps for Terminal Server use'

   # Default URL (Assume we use 64Bit)
   [string]$FSLogixUrl = 'https://aka.ms/fslogix_download'

   #region PossibleParameters
   # Where to Store it
   [string]$Target = ($env:Temp)

   # File Name
   [string]$TargetName = 'fslogix.zip'

   # Install Switch
   [string]$Arguments = '/install /quiet /norestart'
   #endregion PossibleParameters

   #region Defaults
   # Set the full path of the downloaded installer
   [string]$InstallerPackage = ($Target + '\' + $TargetName)

   [string]$InstallerDestination = (($InstallerPackage).Replace('.zip', ''))
   [string]$InstallerExecutable = ($InstallerDestination + '\x64\Release\FSLogixAppsSetup.exe')
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'
   #endregion Defaults

   if (Get-Command -Name 'Set-MpPreference' -ErrorAction $SCT)
   {
      $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
   }
}

process
{
   Write-Verbose -Message ('Downloading {0} to {1}' -f $TargetName, $InstallerPackage)

   # Use BitsTransfer to download the latest installer
   $paramStartBitsTransfer = @{
      Source         = $FSLogixUrl
      Destination    = $InstallerPackage
      Priority       = 'Foreground'
      TransferPolicy = 'Always'
      ErrorAction    = $STP
   }
   $null = (Start-BitsTransfer @paramStartBitsTransfer)

   # Expand FSLogix Installer
   $paramTestPath = @{
      Path        = $InstallerPackage
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramTestPath = @{
         Path        = $InstallerDestination
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path        = $InstallerDestination
            Force       = $true
            Confirm     = $false
            ItemType    = 'Directory'
            ErrorAction = $SCT
         }
         $null = (New-Item @paramNewItem)
      }

      try
      {
         # Expand-Archive is to buggy!
         $paramAddType = @{
            AssemblyName = 'System.IO.Compression.FileSystem'
            ErrorAction  = $STP
         }
         $null = (Add-Type @paramAddType)
         $null = ([IO.Compression.ZipFile]::ExtractToDirectory($InstallerPackage, $InstallerDestination))
      }
      catch
      {
         # OK! That is crappy, but it still works well as a fallback.
         $paramNewObject = @{
            ComObject   = 'Shell.Application'
            ErrorAction = $STP
         }
         $shellApp = (New-Object @paramNewObject)
         $shellZip = $shellApp.NameSpace([String]$InstallerPackage)
         $shellDest = $shellApp.NameSpace($InstallerDestination)
         $shellDest.CopyHere($shellZip.items())
      }
   }
   else
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = $STP
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # We are done
      break
   }

   # Install FSLogix
   $paramTestPath = @{
      Path        = $InstallerExecutable
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      $paramGetItemProperty = @{
         Path        = $InstallerExecutable
         ErrorAction = $SCT
      }
      $InstallerVersion = ((Get-ItemProperty @paramGetItemProperty).VersionInfo.ProductVersion)

      Write-Verbose -Message ('Running FSLogix installer version  {0}' -f $InstallerVersion)

      $paramStartProcess = @{
         FilePath     = $InstallerExecutable
         ArgumentList = $Arguments
         Wait         = $true
         PassThru     = $true
         ErrorAction  = $STP
      }
      $InstallerProcess = (Start-Process @paramStartProcess)

      if (($InstallerProcess | Select-Object -ExpandProperty ExitCode) -eq 0)
      {
         Write-Verbose -Message ('Installed FSLogix version  {0}' -f $InstallerVersion)
      }
      else
      {
         Write-Warning -Message ('Installer exit code  {0}.' -f $InstallerProcess.ExitCode)
      }

      Write-Verbose -Message ('Removing file: {0}' -f $InstallerPackage)

      # Remove the downloaded Installaer Package
      $paramRemoveItem = @{
         Path        = $InstallerPackage
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      # Install the expanded stuff
      $paramRemoveItem = @{
         Path        = $InstallerDestination
         Recurse     = $true
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)

      # Legacy HKLM Path for WVD/VDI/WDS Environment
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Citrix\PortICA'
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)

      # Ensure that the registry path exists
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Microsoft\Teams'
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)

      # Tell Microsoft Teams that it runs in an WVD/VDI/WDS Environment
      # Source: https://docs.microsoft.com/en-us/azure/virtual-desktop/teams-on-wvd
      $paramNewItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Teams'
         Name         = 'IsWVDEnvironment'
         PropertyType = 'DWORD'
         Value        = 1
         Confirm      = $false
         Force        = $true
         ErrorAction  = $SCT
      }
      $null = (New-ItemProperty @paramNewItemProperty)

      # Ensure that the registry path exists
      $paramNewItem = @{
         Path        = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32'
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (New-Item @paramNewItem)

      # Do not start Microsoft Teams after Login
      $paramNewItemProperty = @{
         Path         = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run32'
         Name         = 'Teams'
         PropertyType = 'Binary'
         Value        = ([byte[]](0x01, 0x00, 0x00, 0x00, 0x1a, 0x19, 0xc3, 0xb9, 0x62, 0x69, 0xd5, 0x01))
         Confirm      = $false
         Force        = $true
         ErrorAction  = $SCT
      }
      $null = (New-ItemProperty @paramNewItemProperty)
   }
   else
   {
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = $STP
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # We are done
      break
   }
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
