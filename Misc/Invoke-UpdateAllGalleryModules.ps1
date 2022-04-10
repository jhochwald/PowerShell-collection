#requires -Version 3.0 -Modules @{ ModuleName="PowerShellGet"; ModuleVersion="2.0.0" } -RunAsAdministrator

<#
		.SYNOPSIS
		Update all PowerShell Modules to the latest PowerShell Gallery version

		.DESCRIPTION
		Update all PowerShell Modules to the latest PowerShell Gallery version

		.PARAMETER Silent
		Hide the PowerShell Progress Bars

		.EXAMPLE
		PS C:\> .\Invoke-UpdateAllGalleryModules.ps1
		Update all PowerShell Modules to the latest PowerShell Gallery version

		.EXAMPLE
		PS C:\> .\Invoke-UpdateAllGalleryModules.ps1 -Silent

		Update all PowerShell Modules to the latest PowerShell Gallery version and hide the PowerShell Progress Bars

		.EXAMPLE
		PS C:\> .\Invoke-UpdateAllGalleryModules.ps1 -WhatIf

		Dry run the update all PowerShell Modules to the latest PowerShell Gallery version

		.EXAMPLE
		PS C:\> .\Invoke-UpdateAllGalleryModules.ps1 -verbose

		Update all PowerShell Modules to the latest PowerShell Gallery version in verbose mode

		.EXAMPLE
		PS C:\> .\Invoke-UpdateAllGalleryModules.ps1 -verbose

		Update all PowerShell Modules to the latest PowerShell Gallery version in debug mode

		.NOTES
		This is a replacement for some older functions

		.LINK
		Invoke-CleanupOldGalleryModuleVersions.ps1
#>
[CmdletBinding(ConfirmImpact = 'None',
   SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('NoProgressBars')]
   [switch]
   $Silent
)

begin
{
   #region Defaults
   $STP = 'Stop'
   $CNT = 'Continue'
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   #region Cleanup
   $OriginalProgressPreference = $null
   $AllModules = $null
   #endregion Cleanup

   #region BoundParameters
   if (($PSCmdlet.MyInvocation.BoundParameters['Verbose']).IsPresent)
   {
      $VerboseValue = $true
   }
   else
   {
      $VerboseValue = $false
   }

   if (($PSCmdlet.MyInvocation.BoundParameters['Debug']).IsPresent)
   {
      $DebugValue = $true
   }
   else
   {
      $DebugValue = $false
   }

   if (($PSCmdlet.MyInvocation.BoundParameters['WhatIf']).IsPresent)
   {
      $WhatIfValue = $true
   }
   else
   {
      $WhatIfValue = $false
   }
   #endregion BoundParameters

   if (($PSCmdlet.MyInvocation.BoundParameters['Silent']).IsPresent)
   {
      # Save the original value
      $OriginalProgressPreference = $ProgressPreference

      # Silence is golden...
      $ProgressPreference = $SCT
   }

   # Get the Module information
   $paramGetModule = @{
      ListAvailable = $true
      Refresh       = $true
      ErrorAction   = $CNT
      WarningAction = $CNT
      Verbose       = $VerboseValue
      Debug         = $DebugValue
   }
   $AllModules = (Get-Module @paramGetModule | Where-Object -FilterScript {
         $PSItem.RepositorySourceLocation -like '*powershellgallery*'
      } | Select-Object -Property Name, Version, Path)
}

process
{
   foreach ($SingleModule in $AllModules)
   {
      # Cleanup
      $RepositoryInfo = $null

      <#
				The AllowPrerelease is needed here
				Find-Module ignored the ErrorAction setting, try/catch will not work
		#>
      $paramFindModule = @{
         Name            = (($SingleModule).Name)
         Repository      = 'PSGallery'
         AllowPrerelease = $true
         ErrorAction     = $SCT
         WarningAction   = $CNT
         Verbose         = $VerboseValue
         Debug           = $DebugValue
      }
      $RepositoryInfo = (Find-Module @paramFindModule | Select-Object -Property Name, Version)

      #region CleanVersions
      <#
				Remove everything from the version string that violates the System.Version class
				https://docs.microsoft.com/en-us/dotnet/api/system.version

				e.g. -beta4 or -preview
		#>
      # Character that we use as a slipt
      $SlipPointer = '-'

      # Create the Wildcard to search for
      $SplitSearch = ('*' + $SlipPointer + '*')

      if (($SingleModule.Version) -like $SplitSearch)
      {
         $SingleModule.Version = (($SingleModule.Version).split($SlipPointer)[0])
      }

      if (($RepositoryInfo.Version) -like $SplitSearch)
      {
         $RepositoryInfo.Version = (($RepositoryInfo.Version).split($SlipPointer)[0])
      }
      #endregion CleanVersions

      # Is the online version newer?
      if ((($SingleModule).Version) -lt (($RepositoryInfo).Version))
      {
         # Cleanup
         $ModuleScope = $null

         # try to figure out the scope
         if ((($SingleModule).Path) -like ($env:ProgramW6432 + '\*'))
         {
            $ModuleScope = 'AllUsers'
         }
         else
         {
            $ModuleScope = 'CurrentUser'
         }

         try
         {
            Write-Verbose -Message ('Try to update {0}' -f ($SingleModule).Name)

            # Cleanup
            $paramUpdateModule = $null

            # Try the Update
            $paramUpdateModule = @{
               Name          = (($SingleModule).Name)
               Scope         = $ModuleScope
               Force         = $true
               AcceptLicense = $true
               Confirm       = $false
               Verbose       = $VerboseValue
               Debug         = $DebugValue
               WhatIf        = $WhatIfValue
               ErrorAction   = $STP
               WarningAction = $CNT
            }
            $null = (Update-Module @paramUpdateModule)
         }
         catch
         {
            try
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

               Write-Verbose -Message ('Retry to update {0}' -f ($SingleModule).Name)

               # Cleanup
               $paramUpdateModule = $null

               # Re-Try the update by allowing prereleases
               $paramUpdateModule = @{
                  Name            = (($SingleModule).Name)
                  AllowPrerelease = $true
                  Scope           = $ModuleScope
                  Force           = $true
                  AcceptLicense   = $true
                  Confirm         = $false
                  Verbose         = $VerboseValue
                  Debug           = $DebugValue
                  WhatIf          = $WhatIfValue
                  ErrorAction     = $STP
                  WarningAction   = $CNT
               }
               $null = (Update-Module @paramUpdateModule)
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

               Write-Warning -Message ('Update of {0} failed' -f ($SingleModule).Name)
            }
         }
      }
      else
      {
         Write-Verbose -Message ('No update for {0} found' -f ($SingleModule).Name)
      }
   }
}

end
{
   if ($OriginalProgressPreference)
   {
      # Restore the old value
      $ProgressPreference = $OriginalProgressPreference
   }

   # Cleanup
   $AllModules = $null

   # Have a great day!
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
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
