function Get-DirectorySize
{
   <#
         .SYNOPSIS
         Get the size of a given folder in a human readable format

         .DESCRIPTION
         Get the size of a given folder in a human readable format

         .PARAMETER Path
         Folder to check

         .PARAMETER Type
         Type of the Return,
         Valid values are: GB, MB, KB, B
         The default is MB (Megabyte)

         .EXAMPLE
         PS C:\> Get-DirectorySize -Path 'C:\scripts'

         .EXAMPLE
         PS C:\> Get-DirectorySize -Path 'C:\scripts' -Type GB

         .NOTES
         PowerShell function to emulate the wel known Linux DU command

         Releasenotes:
         1.0.0 2019-05-09: Initial Release

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Directory', 'Folder')]
      [string]
      $Path = '.',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('GB', 'MB', 'KB', 'B', IgnoreCase = $true)]
      [Alias('InType')]
      [string]
      $Type = 'MB'
   )

   process
   {
      try
      {
         $AllFolderItems = (Get-ChildItem -Path $Path -Recurse -ErrorAction Stop | Measure-Object -Property length -Sum)

         switch ($Type)
         {
            'GB'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum / 1GB) + ' GB'
            }
            'MB'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum / 1MB) + ' MB'
            }
            'KB'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum / 1KB) + ' KB'
            }
            'B'
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum) + ' B'
            }
            Default
            {
               $FolderSize = '{0:N2}' -f ($AllFolderItems.sum) + ' MB'
            }
         }

         return $FolderSize
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

         Write-Error -Message $e.Exception.Message -ErrorAction Continue -Exception $e.Exception -TargetObject $e.CategoryInfo.TargetName
      }
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
