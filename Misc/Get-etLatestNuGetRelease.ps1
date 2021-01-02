function Get-etLatestNuGetRelease
{
   <#
         .SYNOPSIS
         Get the latest published version of a given Module from a NuGet Repository

         .DESCRIPTION
         Get the latest published version of a given PowerShell Module from a NuGet Repository

         .PARAMETER Project
         Name of the Project, e.g. et.Office365

         .PARAMETER Repository
         NuGet Repository, default is the PowerShell Gallery

         .PARAMETER Version
         Return a PowerShell Version String instead of a String

         .EXAMPLE
         PS C:\> Get-etLatestNuGetRelease -Project 'et.Office365'

         Get the latest published version of a given Module from a NuGet Repository

         .EXAMPLE
         PS C:\> Get-etLatestNuGetRelease -Project 'et.Office365' -version

         Get the latest published version of a given Module from a NuGet Repository, but as Version instead of a String

         .EXAMPLE
         PS C:\> 'et.Office365' | Get-etLatestNuGetRelease

         Get the latest published version of a given Module from a NuGet Repository

         .NOTES
         enabling Technology internal Build helper function

         .LINK
         Get-etModuleVersion

         .LINK
         Compare-enModuleVersions

         .LINK
         Find-Module
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1,
         HelpMessage = 'Name of the Project, e.g. et.Office365')]
      [ValidateNotNullOrEmpty()]
      [Alias('etProject')]
      [string]
      $Project,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('etRepository', 'Gallery', 'NuGetGallery')]
      [string]
      $Repository = 'PSGallery',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 3)]
      [Alias('enVersion')]
      [switch]
      $Version = $false
   )

   begin
   {
      $LatestNuGetRelease = $null
   }

   process
   {
      try
      {
         $paramFindModule = @{
            Name          = $Project
            Repository    = $Repository
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $LatestNuGetRelease = (Find-Module @paramFindModule | Select-Object -ExpandProperty Version)
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

         # Output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         Write-Error -Message ($info.Exception) -TargetObject ($info.Target) -ErrorAction Stop
         break
      }
   }

   end
   {
      if ($Version)
      {
         [version]$LatestNuGetRelease = $LatestNuGetRelease
      }
      else
      {
         [string]$LatestNuGetRelease = $LatestNuGetRelease
      }

      # Dump to the console
      $LatestNuGetRelease
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
