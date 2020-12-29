#Requires -Version 3.0 -Modules PowerShellGet -RunAsAdministrator

<#
   .SYNOPSIS
   PowerShell Module maintenance

   .DESCRIPTION
   Quick and dirty script that removes all older versions of all installed PowerShell Modules.

   .EXAMPLE
   PS C:\> .\invoke-ModuleMaint.ps1

   # Removes all old versions for all installed PowerShell Modules.

   .NOTES
   Why:
   I do an automated update of my Modules, this process just updates straight to the latest and
   greatest version of each installed module. I ended up with a bunch of older version for most
   Modules, and I needed something to clean this up.

   I found several stuff that does the same thing, but they all use "Get-InstalledModule" and the
   performance of this command is terrible! I have to use "Uninstall-Module" that is slow enough,
   so I needed something that runs faster on my system, where I have a lot of Modules installed.

   Please note:
   This will try to remove all older versions of all installed powerShell versions.
   There might be issues with newer versions, so be aware of that.
   There is no check, just a simple removal off all older versions.
#>
[CmdletBinding()]
param ()

begin
{
   # Get all Modules with every Version that the system knows about.
   $AllModules = (Get-Module -ListAvailable -Refresh)
}

process
{
   # Now we initiate a loop over the information we have.
   foreach ($SingleModule in $AllModules)
   {
      # Get the detailed information for the Module
      $paramGetModule = @{
         ListAvailable = $true
         Name          = $SingleModule.name
      }
      $SingleInstance = (Get-Module @paramGetModule)

      # Do we have more than one installed version?
      if ($SingleInstance -is [array])
      {
         # What is the latest and greatest?
         $latest = (($SingleInstance | Sort-Object -Property Version -Descending)[0]).Version

         # Now loop over all older versions
         foreach ($VersionToRemove in $SingleInstance)
         {
            if (($VersionToRemove.Version -lt $latest))
            {
               try
               {
                  # This is damn slow, but it is the safest way to do it!
                  $paramUninstallModule = @{
                     Name            = $VersionToRemove.Name
                     RequiredVersion = $VersionToRemove.Version
                     Force           = $true
                     ErrorAction     = 'Stop'
                     WarningAction   = 'SilentlyContinue'
                     Confirm         = $false
                  }
                  $null = (Uninstall-Module @paramUninstallModule)
               }
               catch
               {
                  # TODO: Check if we need something here. Or do we just want to catch it?
                  Write-Verbose -Message 'Whoops'
               }
            }
         }
      }
   }
}

end
{
   # TODO: Check if we need something here.
   Write-Verbose -Message 'We are done, have a nice day!'
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, enabling Technology
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
