#requires -Version 3.0 -Modules PowerShellGet

function Update-ModuleFromPSGallery
{
   <#
         .SYNOPSIS
         Update a given PowerShell Module with the latest version from the Gallery

         .DESCRIPTION
         Update a given PowerShell Module with the latest version from the Gallery, if needed

         .PARAMETER ModuleName
         Name of the PowerShell Module

         .EXAMPLE
         PS C:\> Update-ModuleFromPSGallery -ModuleName 'PowerShellGet'

         Check if an update for 'PowerShellGet' is needed, if a newer version is available it will install it

         .EXAMPLE
         PS C:\> 'PowerShellGet' | Update-ModuleFromPSGallery

         Check if an update for 'PowerShellGet' is needed, if a newer version is available it will install it

         .EXAMPLE
         PS C:\> Get-InstalledModule -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Update-ModuleFromPSGallery -ErrorAction Continue -WarningAction SilentlyContinue

         Check if an update for for any Gallery Module is needed, if a newer version is available it will install it

         .NOTES
         Just a quick an dirty function to keep a given Module up-to-date

         If you want to update any system-wide installed module, you need to start this elevated (Run as admin)
   #>
   [CmdletBinding(ConfirmImpact = 'Low')]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'Name of the PowerShell Module')]
      [ValidateNotNullOrEmpty()]
      [Alias('Module', 'Name')]
      [string[]]
      $ModuleName
   )

   begin
   {
      $InstalledModuleInfo = $null
      $InstalledVersion = $null
      $OnlineVersion = $null
      $ModuleScope = $null
   }

   process
   {
      foreach ($SingleModuleName in $ModuleName)
      {
         if (Get-InstalledModule -Name $SingleModuleName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         {
            # unload the module
            $null = (Remove-Module -Name $SingleModuleName -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

            # Get the Info about the module (local)
            $InstalledModuleInfo = (Get-Module -Name $SingleModuleName -ListAvailable -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object -Property Version, ModuleBase)

            # Save the Version Info
            [Version]$InstalledVersion = (($InstalledModuleInfo).Version)

            # Get the Info about the module from the Gallery
            [Version]$OnlineVersion = (Find-Module -Name $SingleModuleName -Repository PSGallery -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object -ExpandProperty Version)

            if ($InstalledVersion -lt $OnlineVersion)
            {
               if ((($InstalledModuleInfo).ModuleBase) -like ((($InstalledModuleInfo).ModuleBase) + '*'))
               {
                  $ModuleScope = 'AllUsers'
               }
               else
               {
                  $ModuleScope = 'CurrentUser'
               }

               try
               {
                  Write-Verbose -Message ('[TRY] Update: {0}' -f $SingleModuleName)

                  $null = (Update-Module -Name $SingleModuleName -Scope $ModuleScope -ErrorAction Stop -WarningAction Continue -Force)

                  Write-Verbose -Message ('[SUCCESS] Update: {0}' -f $SingleModuleName)
               }
               catch
               {
                  # Get error record
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

                  Write-Warning -Message ('[FAILED] Update: {0}' -f $SingleModuleName)
               }
            }
         }
      }
   }

   end
   {
      $InstalledModuleInfo = $null
      $InstalledVersion = $null
      $OnlineVersion = $null
      $ModuleScope = $null
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
