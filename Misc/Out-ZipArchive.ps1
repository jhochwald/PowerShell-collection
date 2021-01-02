function Out-ZipArchive
{
   <#
         .SYNOPSIS
         Creates a ZIP Archive

         .DESCRIPTION
         Creates a ZIP Archive with all given Files (and subdirectories)

         .PARAMETER Path
         Input Path

         .PARAMETER ArchiveName
         Name of the archive to create.

         .PARAMETER force
         Enforce overwrite?

         .PARAMETER fallback
         Use Microsoft .NET Framework API instead of Compress-Archive (Bundled with PowerShell 5.0, or later)

         .EXAMPLE
         PS C:\> Out-ZipArchive -Path 'Value1' -ArchiveName 'Value2'

         Creates a ZIP Archive with all given Files (and subdirectories)

         .EXAMPLE
         PS C:\> Out-ZipArchive -Path 'Value1' -ArchiveName 'Value2' -fallback

         Creates a ZIP Archive with all given Files (and subdirectories) - Use .NET Framework API instead of Compress-Archive internal

         .NOTES
         We now use Compress-Archive by default. It is build upon the Microsoft .NET Framework API System.IO.Compression.ZipArchive and has the same limitation.

         .LINK
         Compress-Archive

         .LINK
         https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory = $true,
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true,
         Position = 0,
         HelpMessage = 'Input Path')]
      [ValidateNotNullOrEmpty()]
      [Alias('Directory')]
      [string]
      $Path,
      [Parameter(Mandatory = $true,
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true,
         Position = 1,
         HelpMessage = 'Name of the archive to create')]
      [ValidateNotNullOrEmpty()]
      [Alias('FileName')]
      [string]
      $ArchiveName,
      [Parameter(ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true,
         Position = 2)]
      [Alias('overwrite')]
      [switch]
      $force,
      [Parameter(ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true,
         Position = 3)]
      [Alias('dotnet')]
      [switch]
      $fallback = $false
   )

   begin
   {
      $null = (Add-Type -AssemblyName System.IO.Compression.FileSystem)

      $compressionLevel = [IO.Compression.CompressionLevel]::Optimal

      Write-Verbose -Message "Compression level for $ArchiveName is $compressionLevel"

      # Safe ProgressPreference and Setup SilentlyContinue for the function
      $ExistingProgressPreference = ($ProgressPreference)
      $ProgressPreference = 'SilentlyContinue'
   }

   process
   {

      if (-not $ArchiveName.EndsWith('.zip'))
      {
         Write-Verbose -Message "Bad filename detected $ArchiveName"

         $ArchiveName += '.zip'

         Write-Verbose -Message "Corrected filename is $ArchiveName"
      }

      if ($force)
      {
         if (Test-Path -Path $ArchiveName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         {
            Write-Verbose -Message "Overwrite old archive $ArchiveName"

            try
            {
               $paramRemoveItem = @{
                  Path          = $ArchiveName
                  Force         = $true
                  Confirm       = $false
                  ErrorAction   = 'Stop'
                  WarningAction = 'Continue'
               }
               $null = (Remove-Item @paramRemoveItem)
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
      }

      try
      {
         Write-Verbose -Message "Try to create archive $ArchiveName"

         if ($fallback)
         {
            Write-Verbose -Message 'Run in fallback mode and using System.IO.Compression.ZipArchive instead of Compress-Archive'
            $zip = ([IO.Compression.ZipFile]::CreateFromDirectory($Path, $ArchiveName, $compressionLevel, $false))
            # And always make sure to close the locks on that file
            $zip.Dispose()
         }
         else
         {
            $paramCompressArchive = @{
               Path             = $Path
               CompressionLevel = $compressionLevel
               DestinationPath  = $ArchiveName
               Force            = $true
               Confirm          = $false
               ErrorAction      = 'Stop'
               WarningAction    = 'SilentlyContinue'
            }
            $null = (Compress-Archive @paramCompressArchive)
         }

         Write-Verbose -Message "Archive $ArchiveName was created"
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
      # Restore ProgressPreference
      $ProgressPreference = $ExistingProgressPreference

      Write-Verbose -Message 'Out-ZipArchive done'
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
