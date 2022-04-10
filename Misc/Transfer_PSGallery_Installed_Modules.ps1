#requires -Version 2.0 -Modules PowerShellGet -RunAsAdministrator

<#
      .SYNOPSIS
      Import/export all Modules installed from a repository

      .DESCRIPTION
      Import/export all Modules installed from a repository
      The Import option itries to install the modules.
      Perfect for clones of existing existing systems.

      .PARAMETER Export
      Export the List of Modules installed via given repository

      .PARAMETER Import
      Import the List and installs all Modules via given repository

      .PARAMETER Path
      File used to handle the Import/Export

      .PARAMETER Repository
      The repository to use. The default is the PowerShell Gallery

      .EXAMPLE
      PS C:\> .\Transfer_Repository_Installed_Modules.ps1 -Export -Path 'C:\Temp\list.txt'

      .EXAMPLE
      PS C:\> .\Transfer_Repository_Installed_Modules.ps1 -Export -Path 'C:\Temp\list.txt' -Repository 'Internal'

      .EXAMPLE
      PS C:\> .\Transfer_Repository_Installed_Modules.ps1 -Import -Path 'C:\Temp\list.txt'

      .EXAMPLE
      PS C:\> .\Transfer_Repository_Installed_Modules.ps1 -Import -Path 'C:\Temp\list.txt' -Repository 'Internal'

      .NOTES
      Releasenotes:
      1.0.0 2019-03-07: Internal Release
      1.0.1 2019-03-10: Initial Version with Repository Support

      THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

      Dependencies:
      PowerShellGet
      Elevated Shell

      .LINK
      https://aka.ms/InstallModule
#>
[CmdletBinding(DefaultParameterSetName = 'Import',
   ConfirmImpact = 'None')]
param
(
   [Parameter(ParameterSetName = 'Export',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0)]
   [switch]
   $Export,
   [Parameter(ParameterSetName = 'Import',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 0)]
   [switch]
   $Import,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1)]
   [ValidateNotNullOrEmpty()]
   [string]
   $Path = 'C:\Tools\list.txt',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 2)]
   [ValidateNotNullOrEmpty()]
   [string]
   $Repository = 'PSGallery'
)

begin
{
   # Set some defaults
   $STP = 'Stop'
   $CNT = 'Continue'

   if (-not $Repository)
   {
      $Repository = 'PSGallery'
   }

   if (-not $Path)
   {
      $Path = 'C:\Tools\list.txt'
   }
}

process
{
   if ($Export)
   {
      Write-Verbose -Message 'Start the export job'

      try
      {
         # Some Modules throw an error!
         Write-Verbose -Message 'Get a list of modules'

         $AllInstalledModule = (Get-InstalledModule -ErrorAction SilentlyContinue -WarningAction $CNT | Where-Object -FilterScript {
               $PSItem.Repository -eq $Repository
            } | Select-Object -ExpandProperty name)

         # Export the List to a given File
         Write-Verbose -Message 'Export the Module information'

         $paramSetContent = @{
            Value         = $AllInstalledModule
            Path          = $Path
            Force         = $true
            Confirm       = $false
            ErrorAction   = $STP
            WarningAction = $CNT
         }
         $null = (Set-Content @paramSetContent)
      }
      catch
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

         Write-Error -Message $info.Exception -ErrorAction $STP

         return
      }
   }
   elseif ($Import)
   {
      Write-Verbose -Message 'Start the import job'

      try
      {
         Write-Verbose -Message 'Read the list of modules'

         $paramGetContent = @{
            Path          = $Path
            Force         = $true
            ErrorAction   = $STP
            WarningAction = $CNT
         }
         $AllInstalledModule = (Get-Content @paramGetContent)

         Write-Verbose -Message 'Try to install the Modules'

         foreach ($SingleInstalledModule in $AllInstalledModule)
         {
            Write-Verbose -Message ('Try to find {0} on {1}' -f $SingleInstalledModule, $Repository)

            $FindTheModule = $null

            try
            {
               # It a bit slower if we search for it first, but this should make the installation more robust
               $paramFindModule = @{
                  Name          = $SingleInstalledModule
                  Repository    = $Repository
                  ErrorAction   = $STP
                  WarningAction = $CNT
               }
               $FindTheModule = (Find-Module @paramFindModule)

               if ($FindTheModule)
               {
                  Write-Verbose -Message ('Try to install {0} from {1}' -f $SingleInstalledModule, $Repository)

                  try
                  {
                     $paramInstallModule = @{
                        Name               = $SingleInstalledModule
                        Repository         = $Repository
                        SkipPublisherCheck = $true
                        AllowClobber       = $true
                        Force              = $true
                        Confirm            = $false
                        ErrorAction        = $STP
                        WarningAction      = $CNT
                     }
                     $null = (Install-Module @paramInstallModule)
                  }
                  catch
                  {
                     Write-Warning -Message ('Found {0} in {1}, but could NOT install it!' -f $SingleInstalledModule, $Repository) -ErrorAction $CNT -WarningAction $CNT
                  }
               }
               else
               {
                  Write-Warning -Message ('Unable to find {0} in {1}?' -f $SingleInstalledModule, $Repository) -ErrorAction $CNT -WarningAction $CNT
               }
            }
            catch
            {
               Write-Warning -Message ('Something went wrong with {0} in {1}?' -f $SingleInstalledModule, $Repository) -ErrorAction $CNT -WarningAction $CNT
            }
         }
      }
      catch
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

         Write-Error -Message $info.Exception -ErrorAction $STP

         return
      }
   }
   else
   {
      Write-Error -Message 'Unknown action specified.' -Category InvalidArgument -RecommendedAction 'Check parameter' -ErrorAction $STP

      return
   }
}

end
{
   Write-Verbose -Message 'Have a great day!'
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
