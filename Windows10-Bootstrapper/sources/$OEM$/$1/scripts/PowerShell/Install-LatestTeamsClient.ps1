#requires -Version 3.0

<#
   .SYNOPSIS
   Download and install latest version of Microsoft Teams

   .DESCRIPTION
   Force the download and the installation latest version of Microsoft Teams for the used OS architecture

   .NOTES
   Early testing release - Future releases might get some parameters

   Changelog:
   2.0.0: Changed back to the MSI installation
   1.0.4: Reformatted
   1.0.3: Removed the Firewall Rule creation (Now part of Invoke-TweakTeamsClientFirewall.ps1)
   1.0.2: Removed the WMI call to find OS architecture - Replaced with native .Net type System.IntPtr
   1.0.1: Use BitsTransfer instead of Invoke-WebRequest
   1.0.0: Initial Release

   Version 2.0.0

   .LINK
   http://enatec.io

   .LINK
   https://docs.microsoft.com/en-us/microsoftteams/msi-deployment
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   Write-Output -InputObject 'Download and install latest version of the Microsoft Teams MSI package'

   # Default URL (Assume we use 64Bit)
   [string]$Teams64BitUrl = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true'

   #region PossibleParameters
   # Where to Store it
   [string]$Target = ($env:Temp)

   # Install Switch
   [string]$Arguments = 'OPTIONS="noAutoStart=true" ALLUSERS=1 /qn /norestart'
   #endregion PossibleParameters

   #region Defaults
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
   # Processor architecture will set the installer (64Bit is the default)
   switch ([IntPtr]::Size)
   {
      4
      {
         Write-Warning -Message 'You have a 32-bit processor - This is no longer supported by enabling Technology!' -WarningAction Continue

         $Url = 'https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&managedInstaller=true&download=true'
      }
      Default
      {
         Write-Verbose -Message 'Use the default: 64-bit processor'

         $Url = $Teams64BitUrl
      }
   }

   # Get the URL
   $request = (Invoke-WebRequest -Uri $Url -MaximumRedirection 0 -ErrorAction $SCT)

   if ($request.StatusDescription -eq 'found')
   {
      # Get the full path of the downloaded installer
      $paramSplitPath = @{
         Path = $request.Headers.Location
         Leaf = $true
      }
      $Installer = ($Target + '\' + (Split-Path @paramSplitPath))

      Write-Verbose -Message ('Downloading {0} to {1}' -f $request.Headers.Location, $Installer)

      # Use BitsTransfer to download the latest installer
      $paramStartBitsTransfer = @{
         Source         = $request.Headers.Location
         Destination    = $Installer
         Priority       = 'Foreground'
         TransferPolicy = 'Always'
         ErrorAction    = $STP
      }
      $null = (Start-BitsTransfer @paramStartBitsTransfer)
   }
   else
   {
      Write-Verbose -Message ('Answer: {0}' -f $request.StatusDescription)

      Write-Error -Message 'Unable to download the Teams MSI Installer' -ErrorAction $STP

      # We are done
      break
   }

   # Install the Microsoft Teams client
   $paramTestPath = @{
      Path        = $Installer
      ErrorAction = $SCT
   }
   if (Test-Path @paramTestPath)
   {
      Write-Verbose -Message 'Running installer Microsoft Teams'

      $paramStartProcess = @{
         FilePath     = $Installer
         ArgumentList = $Arguments
         Wait         = $true
         PassThru     = $true
         ErrorAction  = $STP
      }
      $InstallerProcess = (Start-Process @paramStartProcess)

      if (($InstallerProcess | Select-Object -ExpandProperty ExitCode) -eq 0)
      {
         Write-Verbose -Message 'Installed Microsoft Teams version'
      }
      else
      {
         Write-Warning -Message ('Installer exit code: {0}.' -f $InstallerProcess.ExitCode)
      }

      Write-Verbose -Message ('Removing file: {0}' -f $Installer)

      $paramRemoveItem = @{
         Path        = $Installer
         Confirm     = $false
         Force       = $true
         ErrorAction = $SCT
      }
      $null = (Remove-Item @paramRemoveItem)
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

   if ($InstallerProcess.ExitCode)
   {
      exit($InstallerProcess.ExitCode)
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
