#requires -Version 3.0 -Modules @{ ModuleName="PowerShellGet"; ModuleVersion="2.0.0" } -RunAsAdministrator

<#
		.SYNOPSIS
		Remove older versions of a installed PowerShell module

		.DESCRIPTION
		Remove older versions of a installed PowerShell module

		.EXAMPLE
		PS C:\> .\Invoke-CleanupOldGalleryModuleVersions.ps1

		.EXAMPLE
		PS C:\> .\Invoke-CleanupOldGalleryModuleVersions.ps1 -Verbose

		.EXAMPLE
		PS C:\> .\Invoke-CleanupOldGalleryModuleVersions.ps1 -Verbose

		.EXAMPLE
		PS C:\> .\Invoke-CleanupOldGalleryModuleVersions.ps1 -debug

		.NOTES
		This is a replacement for some older functions

		.LINK
		Invoke-UpdateAllGalleryModules.ps1
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param ()

begin
{
   #region Defaults
   $STP = 'Stop'
   $CNT = 'Continue'
   $SCT = 'SilentlyContinue'
   #endregion Defaults

   #region Cleanup
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
}

process
{
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
      } | Select-Object -ExpandProperty Name)

   $AllModules = ($AllModules | Sort-Object -Unique)

   foreach ($ModuleName in $AllModules)
   {
      Write-Verbose -Message ('Get all existing versions of {0}' -f $ModuleName)

      $AllModuleVersions = $null
      $AllModuleVersions = (Get-InstalledModule -Name $ModuleName -AllVersions -ErrorAction $SCT -WarningAction $CNT)

      if (((($AllModuleVersions).Version).count) -gt 1)
      {
         $LatestModuleVersion = $null

         $LatestModuleVersion = (($AllModuleVersions | Sort-Object -Property $AllModuleVersions.Version)[1])

         try
         {
            $output = $null
            $output = ($AllModuleVersions | Where-Object {
                  (($PSItem.Version) -lt ($LatestModuleVersion.Version))
               } | ForEach-Object -Process {
                  Write-Verbose -Message ('Start to process {0}' -f ($_).Name)

                  try
                  {
                     $paramUninstallModule = @{
                        Name          = $_
                        Force         = $true
                        Confirm       = $false
                        WhatIf        = $WhatIfValue
                        Verbose       = $VerboseValue
                        Debug         = $DebugValue
                        ErrorAction   = $STP
                        WarningAction = $CNT
                     }
                     Uninstall-Module @paramUninstallModule
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

                     $paramWriteError = @{
                        Message      = $e.Exception.Message
                        ErrorAction  = $CNT
                        Exception    = $e.Exception
                        TargetObject = $e.CategoryInfo.TargetName
                     }
                     Write-Error @paramWriteError
                  }
                  finally
                  {
                     if (Test-Path -Path $PSItem.InstalledLocation -ErrorAction $SCT -WarningAction $SCT)
                     {
                        Write-Verbose -Message ('Try to remove {0}' -f ($_).InstalledLocation)

                        try
                        {
                           $paramRemoveItem = @{
                              Path          = $PSItem.InstalledLocation
                              Recurse       = $true
                              Force         = $true
                              Confirm       = $false
                              ErrorAction   = $STP
                              WarningAction = $CNT
                              WhatIf        = $WhatIfValue
                              Verbose       = $VerboseValue
                              Debug         = $DebugValue
                           }
                           Remove-Item @paramRemoveItem

                           Write-Verbose -Message ('Removed {0}' -f ($_).InstalledLocation)
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

                           $paramWriteError = @{
                              Message      = $e.Exception.Message
                              ErrorAction  = $STP
                              Exception    = $e.Exception
                              TargetObject = $e.CategoryInfo.TargetName
                           }
                           Write-Error @paramWriteError
                        }
                     }
                  }

                  Write-Verbose -Message ('Removed old versions off {0}' -f ($_).Name)
               })
            $output
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

            Write-Warning -Message ('Failed to process {0}' -f ($_).Name)
         }
      }
      else
      {
         Write-Verbose -Message ('Skip {0}' -f ($AllModuleVersions).Name)
      }
   }
}

end
{
   $AllModules = $null
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
