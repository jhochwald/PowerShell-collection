#requires -Version 1.0

<#
      .SYNOPSIS
      Configure and enhance Endpont Manager (Intune) Agent logging

      .DESCRIPTION
      Configure and enhance Endpont Manager (Intune) Agent logging

      .NOTES
      Version 1.0.0

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Configure and enhance Endpont Manager (Intune) Agent logging'

   #region Defaults
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   #region Variables
   # Cleanup
   $logMaxSize = $null

   # Size in MB
   $logMaxSize = 4

   # Logic From MB to Bytes
   $logMaxSize = ($logMaxSize * 1024 * 1024)

   # Define log files to keep
   $logMaxHistory = 4

   # Main Registry Path
   $regKeyFullPath = 'HKLM:\SOFTWARE\Microsoft\IntuneWindowsAgent\Logging'
   #endregion Variables
}

process
{
   # Create the registry key path for the Endpont Manager (Intune) agent
   $paramNewItem = @{
      Path          = $regKeyFullPath
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (New-Item @paramNewItem)

   # Set value to define new size instead of the default 2 MB
   $paramSetItemProperty = @{
      Path          = $regKeyFullPath
      Name          = 'LogMaxSize'
      Value         = $logMaxSize
      Type          = 'String'
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Set-ItemProperty @paramSetItemProperty)

   # Set value to define new amount of logfiles to keep
   $paramSetItemProperty = @{
      Path          = $regKeyFullPath
      Name          = 'LogMaxHistory'
      Value         = $logMaxHistory
      Type          = 'String'
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Set-ItemProperty @paramSetItemProperty)
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

