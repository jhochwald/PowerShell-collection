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
      Everaything is hardcoded for this wrapper ;-)

      .LINK
      Clear-LogFileDirectory
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

# Files older then 1 day are deleted
$Days = 1

# Exchange Base Directory
$ExchangeBaseDir = 'D:\Exchange Server'

# Exchaneg Version (Directory)
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
         Specifies a path, multivalue or wildcards are not yet supported!
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
