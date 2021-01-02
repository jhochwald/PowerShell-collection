#requires -Version 3.0 -RunAsAdministrator
<#
      .SYNOPSIS
      Cleanup some of the Exchange Logs

      .DESCRIPTION
      Cleanup some of the Exchange Logs

      .EXAMPLE
      PS C:\> .\Clear-LogFileDirectory.ps1

      .NOTES
      Wrapper for the Clear-LogFileDirectory function
      Everything is hardcoded for this wrapper ;-)

      .LINK
      Clear-LogFileDirectory
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

# Files older then 1 day are deleted
$Days = 1

# Exchange Base Directory
$ExchangeBaseDir = 'D:\Exchange Server'

# Exchange Version (Directory)
$ExchangeVersion = 'V15'

# Where to find the IIS stuff
$IISBaseDir = "$env:HOMEDRIVE\inetpub"


#region IIS
# Append the Log Stuff for the Call below
$IISLogPath = $IISBaseDir + '\logs\LogFiles\'
#endregion IIS

#region Exchange
# Combine the values
$ExchangeDirectoryPath = $ExchangeBaseDir + '\' + $ExchangeVersion

# Append the Log Stuff for the Call below
$ExchangeLoggingPath = $ExchangeDirectoryPath + '\Logging\'
$ExchangeETLTraces = $ExchangeDirectoryPath + '\Bin\Search\Ceres\Diagnostics\ETLTraces\'
$ExchangeETLLogs = $ExchangeDirectoryPath + '\Bin\Search\Ceres\Diagnostics\Logs'
#endregion Exchange

#region HelperFunction
function Clear-LogFileDirectory
{
   <#
         .SYNOPSIS
         Cleanup Files in a given Directory

         .DESCRIPTION
         Cleanup Files in a given Directory

         .PARAMETER Path
         Specifies a path, multi-value or wildcards are not yet supported!
         No default so far!

         .PARAMETER Days
         Age of the Files to Delete.
         Default is 7

         .EXAMPLE
         PS C:\> Clear-LogFileDirectory -Path "c:\inetpub\logs\LogFiles\"

         .NOTES
         Mind the Gap:
         Everything within the given directory will be deleted, without any further interaction!
   #>

   [CmdletBinding(ConfirmImpact = 'Low',
      SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'Specifies a path, multivalue or wildcards are not yet supported!')]
      [ValidateNotNullOrEmpty()]
      [Alias('Folder', 'TargetFolder')]
      [string]
      $Path,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('Age', 'FileAge')]
      [int]
      $Days = 7
   )

   begin
   {
      #region Defaults
      $CNT = 'Continue'
      $SCT = 'SilentlyContinue'
      #endregion Defaults

      Write-Verbose -Message ('START: Processing of {0}' -f $Path)
   }

   process
   {
      if (Test-Path -Path $Path -ErrorAction $SCT)
      {
         $Now = (Get-Date)
         $LastWrite = $Now.AddDays(-$Days)

         #region FindAndFilterFiles
         # Splat the Parameters
         $paramFindAndFilterFiles = @{
            Path        = $Path
            Recurse     = $true
            ErrorAction = $SCT
         }
         $Files = (Get-ChildItem @paramFindAndFilterFiles | Where-Object -FilterScript {
               ($_.Name -like '*.log') -or ($_.Name -like '*.blg') -or ($_.Name -like '*.etl')
            } | Where-Object -FilterScript {
               $_.lastWriteTime -le $LastWrite
            } | Select-Object -ExpandProperty FullName)
         #endregion FindAndFilterFiles

         #region FileLooper
         foreach ($File in $Files)
         {
            Write-Verbose -Message ('Deleting file {0}' -f $File)
            try
            {
               if ($pscmdlet.ShouldProcess($File, 'Delete'))
               {
                  #region DeleteFilesFound
                  # Splat the Parameters
                  $paramDeleteFilesFound = @{
                     Path        = $File
                     Force       = $true
                     Confirm     = $false
                     ErrorAction = 'Stop'
                  }
                  $null = (Remove-Item @paramDeleteFilesFound)
                  #endregion DeleteFilesFound
               }
            }
            catch
            {
               #region ErrorHandler
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

               $info | Out-String | Write-Verbose

               Write-Warning -Message ($info.Exception) -ErrorAction $CNT -WarningAction $CNT
               #endregion ErrorHandler
            }
         }
         #endregion FileLooper
      }
      else
      {
         Write-Error -Message ("The folder {0} doesn't exist! Check the folder path!" -f $Path)
      }
   }

   end
   {
      Write-Verbose -Message ('DONE: Processed {0}' -f $Path)
   }
}
#endregion HelperFunction

#region FunctionWrapper
Clear-LogFileDirectory -Path $IISLogPath -Days $Days
Clear-LogFileDirectory -Path $ExchangeLoggingPath -Days $Days
Clear-LogFileDirectory -Path $ExchangeETLTraces -Days $Days
Clear-LogFileDirectory -Path $ExchangeETLLogs -Days $Days
#endregion FunctionWrapper

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
