function Install-DSCResourceKit
{
   <#
         .SYNOPSIS
         Install the complete PowerShell DSCResourceKit

         .DESCRIPTION
         Install the complete PowerShell DSCResourceKit from the PowerShell Gallery.
         It only installs the missing resources.

         .PARAMETER Scope
         Specifies the installation scope of the module. The acceptable values for this parameter are: AllUsers and CurrentUser.

         The AllUsers scope lets modules be installed in a location that is accessible to all users of the computer, that is, %systemdrive%:\ProgramFiles\WindowsPowerShell\Modules.

         The CurrentUser scope lets modules be installed only to $home\Documents\WindowsPowerShell\Modules, so that the module is available only to the current user.

         .EXAMPLE
         PS C:\> Install-DSCResourceKit

         Install the complete PowerShell DSCResourceKit

         .EXAMPLE
         PS C:\> Install-DSCResourceKit -verbose

         Install the complete PowerShell DSCResourceKit

         .NOTES
         Releasenotes:
         1.0.0 2019-04-10: Internal Release

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         PowerShellGet

         .LINK
         https://aka.ms/InstallModule

         .LINK
         https://www.powershellgallery.com
   #>
   [CmdletBinding(ConfirmImpact = 'None',
      SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 0)]
      [ValidateSet('AllUsers', 'CurrentUser', IgnoreCase = $true)]
      [Alias('ModuleScope')]
      [String]
      $Scope = 'AllUsers'
   )

   begin
   {
      try
      {
         if (-not ($Scope))
         {
            $Scope = 'AllUsers'
         }

         $AllReSources = ((Find-Module -Tag DSCResourceKit).name)
         $AllInstall = ((Get-Module -ListAvailable).Name)
      }
      catch
      {
         # Get error record
         [Management.Automation.ErrorRecord]$e = $_

         # Retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         $info | Out-String | Write-Verbose

         # Whoops
         Write-Error -Message $info.Exception -ErrorAction Stop
      }
   }

   process
   {
      if ($pscmdlet.ShouldProcess('DSCResourceKit', 'Install'))
      {
         foreach ($DSCResource in $AllReSources)
         {
            if (-not ($AllInstall.Contains($DSCResource)))
            {
               try
               {
                  Write-Verbose -Message ('Try to install {0}' -f $DSCResource)

                  $paramInstallModule = @{
                     Name               = $DSCResource
                     Scope              = $Scope
                     AllowClobber       = $true
                     SkipPublisherCheck = $true
                     Repository         = 'PSGallery'
                     Force              = $true
                     ErrorAction        = 'Stop'
                  }
                  $null = (Install-Module @paramInstallModule)

                  Write-Verbose -Message ('Installed {0}' -f $DSCResource)
               }
               catch
               {
                  # Get error record
                  [Management.Automation.ErrorRecord]$e = $_

                  # Retrieve information about runtime error
                  $info = [PSCustomObject]@{
                     Exception = $e.Exception.Message
                     Reason    = $e.CategoryInfo.Reason
                     Target    = $e.CategoryInfo.TargetName
                     Script    = $e.InvocationInfo.ScriptName
                     Line      = $e.InvocationInfo.ScriptLineNumber
                     Column    = $e.InvocationInfo.OffsetInLine
                  }

                  $info | Out-String | Write-Verbose

                  Write-Warning -Message ('Unable to install {0}' -f $DSCResource) -ErrorAction Continue -WarningAction Continue

                  # Cleanup
                  $e = $null
                  $info = $null
               }
            }
            else
            {
               Write-Verbose -Message ('{0} is already installed' -f $DSCResource)
            }
         }
      }
   }

   end
   {
      # Cleanup
      $AllReSources = $null
      $AllInstall = $null
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
