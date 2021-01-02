#requires -Version 1.0 -RunAsAdministrator

<#
   .SYNOPSIS
   Create plain PowerShell Profiles, if needed

   .DESCRIPTION
   Create plain PowerShell Profiles, if needed

   .NOTES
   Changelog:
   1.0.5: Reformatted:
   1.0.1: First real release
   1.0.0: Initial beta version

   Version 1.0.1

   .LINK
   http://beyend-datacenter.com

   .LINK
   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-7

   .LINK
   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-5.1
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Create plain PowerShell Profiles, if needed'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
}

process
{
   # Stop Search - Gain performance
   $null = (Get-Service -Name 'WSearch' -ErrorAction $SCT | Where-Object { $_.Status -eq 'Running' } | Stop-Service -Force -Confirm:$false -ErrorAction $SCT)

   # Splat the parameters
   $paramNewItem = @{
      type          = 'file'
      force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }

   # Splat the parameters
   $paramTestPath = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }

   if (-not (Test-Path -Path $PROFILE @paramTestPath))
   {
      $null = (New-Item -Path $PROFILE @paramNewItem)
   }

   if (-not (Test-Path -Path $PROFILE.AllUsersAllHosts @paramTestPath))
   {
      $null = (New-Item -Path $PROFILE.AllUsersAllHosts @paramNewItem)
   }

   if (-not (Test-Path -Path $PROFILE.AllUsersCurrentHost @paramTestPath))
   {
      $null = (New-Item -Path $PROFILE.AllUsersCurrentHost @paramNewItem)
   }

   if (-not (Test-Path -Path $PROFILE.CurrentUserAllHosts @paramTestPath))
   {
      $null = (New-Item -Path $PROFILE.CurrentUserAllHosts @paramNewItem)
   }

   if (-not (Test-Path -Path $PROFILE.CurrentUserCurrentHost @paramTestPath))
   {
      $null = (New-Item -Path $PROFILE.CurrentUserCurrentHost @paramNewItem)
   }

   #region ISE
   $ISEProfileAllUsersCurrentHost = ($PsHome + '\Microsoft.PowerShellISE_profile.ps1')
   if (-not (Test-Path -Path $ISEProfileAllUsersCurrentHost @paramTestPath))
   {
      $null = (New-Item -Path $ISEProfileAllUsersCurrentHost @paramNewItem)
   }

   $ISEProfileCurrentUserAllHosts = ($Home + '\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1')
   if (-not (Test-Path -Path $ISEProfileCurrentUserAllHosts @paramTestPath))
   {
      $null = (New-Item -Path $ISEProfileCurrentUserAllHosts @paramNewItem)
   }
   #endregion ISE

   #region VSCode
   $VSCodeProfileAllUsersCurrentHost = ($PSHOME + '\Microsoft.VSCode_profile.ps1')
   if (-not (Test-Path -Path $VSCodeProfileAllUsersCurrentHost @paramTestPath))
   {
      $null = (New-Item -Path $VSCodeProfileAllUsersCurrentHost @paramNewItem)
   }

   $VSCodeProfileCurrentUserAllHosts = ($Home + '\Documents\PowerShell\Microsoft.VSCode_profile.ps1')
   if (-not (Test-Path -Path $VSCodeProfileCurrentUserAllHosts @paramTestPath))
   {
      $null = (New-Item -Path $VSCodeProfileCurrentUserAllHosts @paramNewItem)
   }
   #endregion VSCode

   #region PowerShellCore
   $PSCoreCurrentUserAllHosts = ($Home + '\Documents\PowerShell\profile.ps1')
   if (-not (Test-Path -Path $PSCoreCurrentUserAllHosts @paramTestPath))
   {
      $null = (New-Item -Path $PSCoreCurrentUserAllHosts @paramNewItem)
   }

   $PSCoreCurrentUserCurrentHost = ($Home + '\Documents\PowerShell\Microsoft.PowerShell_profile.ps1')
   if (-not (Test-Path -Path $PSCoreCurrentUserCurrentHost @paramTestPath))
   {
      $null = (New-Item -Path $PSCoreCurrentUserCurrentHost @paramNewItem)
   }
   #endregion PowerShellCore
}

end
{
   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
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
