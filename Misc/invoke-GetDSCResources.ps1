#requires -Modules PowerShellGet -Version 2.0 -RunAsAdministrator

<#
    .SYNOPSIS
    Install some DSC Resources
	
    .DESCRIPTION
    Getting, install, or update DSC Resources I want to have. 
    It could be used to install every Module from the Gallery. 
    However, this is something I do with DSC afterwards!
	
    .EXAMPLE
    PS C:\> .\invoke-GetDSCResources.ps1

    .EXAMPLE
    PS C:\> .\invoke-GetDSCResources.ps1 -verbose
    VERBOSE: Populating RepositorySourceLocation property for module PSDscResources.
    VERBOSE: Try to update PSDscResources
    VERBOSE: Updated PSDscResources
	
    .NOTES
    Small script I created for myself.
    I have to prepare DSC systems from time to time, and I want to have the same set of DSC resources on all of them.
    Mainly because I'm lazy, but I'm an old-school Unix guy: Never type something more than two times: AUTOMATE.

    I install the resources system wide!
    That is why we have the Elevated Shell requirement (#Requires -RunAsAdministrator).
    If you want to use it just for the current user, change the Scope in $paramInstallModule from 'AllUsers' to 'CurrentUser'.

    TODO: Pester Test is missing
    DONE: Make it more robust

    Disclaimer: The code is provided 'as is,' with all possible faults, defects or errors, and without warranty of any kind.

    Author: Joerg Hochwald

    .LINK
    Author http://jhochwald.com
#>
[CmdletBinding()]
param ()

BEGIN
{
  # Define some defaults
  $STP = 'Stop'
  $SC = 'SilentlyContinue'

  # Suppressing the PowerShell Progress Bar
  $script:ProgressPreference = $SC

  # Create a list of the DSC Resources I want
  $NewDSCModules = @(
    'PSDscResources', 
    'xNetworking', 
    'xPSDesiredStateConfiguration', 
    'xWebAdministration', 
    'xCertificate', 
    'xComputerManagement', 
    'xActiveDirectory', 
    'SystemLocaleDsc', 
    'xRemoteDesktopAdmin', 
    'xPendingReboot', 
    'xSmbShare', 
    'xWindowsUpdate', 
    'xDscDiagnostics', 
    'xCredSSP', 
    'xDnsServer', 
    'xWinEventLog', 
    'xDhcpServer', 
    'xHyper-V', 
    'xStorage', 
    'xWebDeploy'
    'xRemoteDesktopSessionHost', 
    'xDismFeature', 
    'xSystemSecurity', 
    'WebAdministrationDsc', 
    'OfficeOnlineServerDsc', 
    'AuditPolicyDsc', 
    'xDFS', 
    'SecurityPolicyDsc', 
    'xReleaseManagement', 
    'xExchange', 
    'xDefender', 
    'xWindowsEventForwarding', 
    'cHyper-V'
  )
}

PROCESS
{
  foreach ($NewDSCModule in $NewDSCModules)
  {
    # Cleanup
    $ModuleIsAvailable = $null

    # Check: Do I have the resource?
    $paramGetModule = @{
      ListAvailable = $true
      Name          = $NewDSCModule
      ErrorAction   = $SC
      WarningAction = $SC
    }
    $ModuleIsAvailable = (Get-Module @paramGetModule)
		
    if (-not ($ModuleIsAvailable))
    {
      # Nope: Install the resource
      try
      {
        Write-Verbose -Message ('Try to install {0}' -f $NewDSCModule)

        $paramInstallModule = @{
          Name          = $NewDSCModule
          Scope         = AllUsers
          Force         = $true
          ErrorAction   = $STP
          WarningAction = $SC
        }
        $null = (Install-Module @paramInstallModule)

        Write-Verbose -Message ('Installed {0}' -f $NewDSCModule)
      }
      catch
      {
        # Whoopsie
        $paramWriteWarning = @{
          Message     = ('Sorry, unable to install {0}' -f $NewDSCModule)
          ErrorAction = $SC
        }
        Write-Warning @paramWriteWarning
      }
    }
    else
    {
      try
      {
        Write-Verbose -Message ('Try to update {0}' -f $NewDSCModule)

        # TODO: Implement the check from invoke-ModuleUpdates.ps1 to prevent the unneeded update tries.
        $paramUpdateModule = @{
          Name          = $NewDSCModule
          Confirm       = $false
          ErrorAction   = $STP
          WarningAction = $SC
        }
        $null = (Update-Module @paramUpdateModule)

        Write-Verbose -Message ('Updated {0}' -f $NewDSCModule)
      }
      catch
      {
        # Whoopsie
        $paramWriteWarning = @{
          Message     = ('Sorry, unable to update {0}' -f $NewDSCModule)
          ErrorAction = $SC
        }
        Write-Warning @paramWriteWarning
      }
    }
  }
}

END {
  # No longer suppressing the PowerShell Progress Bar
  $script:ProgressPreference = 'Continue'
}

#region License
<#
    BSD 3-Clause License

    Copyright (c) 2018, enabling Technology <http://enatec.io>
    All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion License

#region Hints
<#
    This is a third-party Software!

    The developer(s) of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way

    The Software is not supported by Microsoft Corp (MSFT)!
#>
#endregion Hints