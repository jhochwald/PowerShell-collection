#requires -Version 2.0 -Modules ADSync

function Export-ADSyncConnectorInformation
{
   <#
      .SYNOPSIS
      Export ADSync Connector Information

      .DESCRIPTION
      Export ADSync Connector Information

      .PARAMETER ExcludeSuffix
      Suffix for the Exclude File.
      Default: 'ExcludedOU'

      .PARAMETER IncludeSuffix
      Suffix for the Include File.
      Default: 'IncludedOU'

      .PARAMETER Path
      Where to store the Data
      Default: 'C:\scripts\PowerShell\logs\'

      .PARAMETER Connector
      Name of the connector

      .PARAMETER All
      Dump the info all connectors

      .EXAMPLE
      PS C:\> Export-ADSyncConnectorInformation -Connector 'BDC-INT'

      Export ADSync Connector Information for the connector with the name 'BDC-INT'
      All configuration will be stored into ADSync_GlobalSettings.csv
      The default path ('C:\scripts\PowerShell\logs\') is used

      .EXAMPLE
      PS C:\> Export-ADSyncConnectorInformation -Connector 'BDC-INT' -Path 'd:\reporting\ADSync'

      Export ADSync Connector Information for the connector with the name 'BDC-INT'
      All configuration will be stored into ADSync_GlobalSettings.csv
      All files are stored in 'd:\reporting\ADSync'

      .EXAMPLE
      PS C:\> Export-ADSyncConnectorInformation -All

      Export ADSync all Connector Information
      All configuration will be stored into ADSync_GlobalSettings.csv
      The default path ('C:\scripts\PowerShell\logs\') is used

      .EXAMPLE
      PS C:\> Export-ADSyncConnectorInformation -All -Path 'd:\reporting\ADSync'

      Export ADSync all Connector Information
      All configuration will be stored into ADSync_GlobalSettings.csv
      All files are stored in 'd:\reporting\ADSync'

      .EXAMPLE
      PS C:\> Export-ADSyncConnectorInformation -Connector 'BDC-INT' -ExcludeSuffix 'Ex' -IncludeSuffix 'In'

      Export ADSync Connector Information for the connector with the name 'BDC-INT' to AADC_BDC-INT_Ex.txt (excluded) and AADC_BDC-INT_In.txt (included)
      All configuration will be stored into ADSync_GlobalSettings.csv
      The default path ('C:\scripts\PowerShell\logs\') is used

      .NOTES
      Initial refactored version
   #>
   [CmdletBinding(DefaultParameterSetName = 'All',
      ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $ExcludeSuffix = 'ExcludedOU',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $IncludeSuffix = 'IncludedOU',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $Path = ($env:HOMEDRIVE + '\scripts\PowerShell\logs\'),
      [Parameter(ParameterSetName = 'Single',
         Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         HelpMessage = 'Name of the connector')]
      [AllowEmptyString()]
      [AllowNull()]
      [Alias('AADConnector')]
      [string]
      $Connector,
      [Parameter(ParameterSetName = 'All',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [switch]
      $All
   )

   begin
   {
      #region InternalFunctions
      function Invoke-ErrorHandler
      {
         <#
            .SYNOPSIS
            Internal Error Handler

            .DESCRIPTION
            Internal Error Handler

            .PARAMETER ErrorRecord
            The Error Record you try to capture and handle

            .EXAMPLE
            try
            {
               Get-Item -Path '.\UnkownFile.txt' -ErrorAction Stop
            }
            catch
            {
               [Management.Automation.ErrorRecord]$e = $_

               $ErrorRecord = [PSCustomObject]@{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
               }
               Invoke-ErrorHandler -ErrorRecord $ErrorRecord -ErrorAction Stop
            }

            .EXAMPLE
            try
            {
               Get-Item -Path '.\UnkownFile.txt' -ErrorAction Stop
            }
            catch
            {
               [Management.Automation.ErrorRecord]$e = $_

               $ErrorRecord = [PSCustomObject]@{
               Exception = $e.Exception.Message
               Reason    = $e.CategoryInfo.Reason
               Target    = $e.CategoryInfo.TargetName
               Script    = $e.InvocationInfo.ScriptName
               Line      = $e.InvocationInfo.ScriptLineNumber
               Column    = $e.InvocationInfo.OffsetInLine
               }
               Invoke-ErrorHandler -ErrorRecord $ErrorRecord -ErrorAction Stop -Verbose
            }

            .NOTES
            Initial version as dedicated helper function
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         param
         (
            [Parameter(Mandatory,
               ValueFromPipelineByPropertyName,
               ValueFromRemainingArguments = $true,
               Position = 0,
               HelpMessage = 'The Error Record you try to capture and handle')]
            [ValidateNotNullOrEmpty()]
            [PSCustomObject]
            $ErrorRecord
         )

         process
         {
            #region ErrorHandler
            # output information. Post-process collected info, and log info (optional)
            $ErrorRecord | Out-String | Write-Verbose

            $paramWriteError = @{
               Message      = $ErrorRecord.Exception.Message
               Exception    = $ErrorRecord.Exception
               TargetObject = $ErrorRecord.CategoryInfo.TargetName
               ErrorAction  = 'Stop'
            }
            Write-Error @paramWriteError

            # This is a dead end here!
            exit 1
            #endregion
         }
      }

      function Invoke-ExportADSyncConnectorInformationProcess
      {
         <#
            .SYNOPSIS
            Internal Helper function

            .DESCRIPTION
            Internal Helper function

            .PARAMETER ExcludeSuffix
            Suffix for the Exclude File.
            Default: 'ExcludedOU'

            .PARAMETER IncludeSuffix
            Suffix for the Include File.
            Default: 'IncludedOU'

            .PARAMETER Path
            Where to store the Data
            Default: 'C:\scripts\PowerShell\logs\'

            .PARAMETER Connector
            Name of the connector

            .EXAMPLE
            PS C:\> Invoke-ExportADSyncConnectorInformationProcess

            .NOTES
            Initial version as dedicated helper function
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         param
         (
            [ValidateNotNullOrEmpty()]
            [string]
            $ExcludeSuffix = 'ExcludedOU',
            [ValidateNotNullOrEmpty()]
            [string]
            $IncludeSuffix = 'IncludedOU',
            [ValidateNotNullOrEmpty()]
            [string]
            $Path = ($env:HOMEDRIVE + '\scripts\PowerShell\logs\'),
            [Parameter(Mandatory,
               HelpMessage = 'Name of the connector')]
            [AllowEmptyString()]
            [AllowNull()]
            [Alias('AADConnector')]
            [string]
            $Connector
         )

         begin
         {
            Write-Verbose -Message ('Start to process: {0}' -f $Connector)

            # Create the filenames
            $ExcludeFilterFile = ($Path + 'AADC_' + ($Connector.Trim() -replace '\.', '-' -replace '\s', '_' -replace '\{', '' -replace '\}', '' -replace '[()]', '' -replace '[[\]]', '') + '_' + $ExcludeSuffix + '.txt')
            $IncludeFilterFile = ($Path + 'AADC_' + ($Connector.Trim() -replace '\.', '-' -replace '\s', '_' -replace '\{', '' -replace '\}', '' -replace '[()]', '' -replace '[[\]]', '') + '_' + $IncludeSuffix + '.txt')
         }

         process
         {
            $paramGetADSyncConnector = @{
               Name        = $Connector
               ErrorAction = 'Stop'
            }

            try
            {
               $AADConn = (Get-ADSyncConnector @paramGetADSyncConnector)
            }
            catch
            {
               [Management.Automation.ErrorRecord]$e = $_
               $ErrorRecord = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }
               Invoke-ErrorHandler -ErrorRecord $ErrorRecord -ErrorAction Stop -Verbose
            }

            $paramGetADSyncConnector = $null

            $paramGetADSyncConnectorPartition = @{
               Connector   = $AADConn[0]
               Identifier  = $AADConn.Partitions.Identifier.Guid
               ErrorAction = 'Stop'
            }

            try
            {
               $AADConPartition = (Get-ADSyncConnectorPartition @paramGetADSyncConnectorPartition)
            }
            catch
            {
               [Management.Automation.ErrorRecord]$e = $_
               $ErrorRecord = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }
               Invoke-ErrorHandler -ErrorRecord $ErrorRecord -ErrorAction Stop -Verbose
            }

            $paramGetADSyncConnectorPartition = $null

            $paramOutFile = @{
               Encoding    = 'utf8'
               Force       = $true
               ErrorAction = 'Continue'
            }

            try
            {
               $null = ($AADConPartition.ConnectorPartitionScope.ContainerInclusionList | Out-File -FilePath $IncludeFilterFile @paramOutFile)
               $null = ($AADConPartition.ConnectorPartitionScope.ContainerExclusionList | Out-File -FilePath $ExcludeFilterFile @paramOutFile)
            }
            catch
            {
               [Management.Automation.ErrorRecord]$e = $_
               $ErrorRecord = [PSCustomObject]@{
                  Exception = $e.Exception.Message
                  Reason    = $e.CategoryInfo.Reason
                  Target    = $e.CategoryInfo.TargetName
                  Script    = $e.InvocationInfo.ScriptName
                  Line      = $e.InvocationInfo.ScriptLineNumber
                  Column    = $e.InvocationInfo.OffsetInLine
               }
               Invoke-ErrorHandler -ErrorRecord $ErrorRecord -ErrorAction Stop -Verbose
            }

            $paramOutFile = $null
         }

         end
         {
            # Cleanup
            $ExcludeFilterFile = $null
            $IncludeFilterFile = $null
            $AADConn = $null
            $AADConPartition = $null
         }
      }
      #endregion InternalFunctions

      #region PathCheck
      if ($Path -notmatch '\\$')
      {
         # Append \
         $Path += '\'
      }
      #endregion PathCheck

      # Check if the output folder exists
      if (-not (Test-Path -Path $Path -ErrorAction SilentlyContinue))
      {
         $null = (New-Item -ItemType Directory -Path $Path -Force -Confirm:$false -ErrorAction Stop)
      }

      #
      $ADSyncGlobalSettings = ($Path + 'ADSync_GlobalSettings.csv')
   }

   process
   {
      if (($Connector) -and (-not ($PSBoundParameters.ContainsKey('All'))))
      {
         Invoke-ExportADSyncConnectorInformationProcess -ExcludeSuffix $ExcludeSuffix -IncludeSuffix $IncludeSuffix -Path $Path -Connector $Connector -ErrorAction Stop
      }
      elseif (($PSBoundParameters.ContainsKey('All')) -and (-not ($Connector)))
      {
         foreach ($Connector in (Get-ADSyncConnector -ErrorAction Stop | Select-Object -ExpandProperty Name))
         {
            Invoke-ExportADSyncConnectorInformationProcess -ExcludeSuffix $ExcludeSuffix -IncludeSuffix $IncludeSuffix -Path $Path -Connector $Connector -ErrorAction Stop
         }
      }
      else
      {
         Write-Error -Message 'Please use -Connector or -all' -Category InvalidOperation -RecommendedAction 'Use Get-Help -Name Export-ADSyncConnectorInformation -Detailed' -ErrorAction Stop

         break
      }

      $paramExportCsv = @{
         Path              = $ADSyncGlobalSettings
         Force             = $true
         Encoding          = 'UTF8'
         NoTypeInformation = $true
         Delimiter         = ';'
         ErrorAction       = 'Continue'
      }

      try
      {
         $null = ((Get-ADSyncGlobalSettings).Parameters | Export-Csv @paramExportCsv)
      }
      catch
      {
         [Management.Automation.ErrorRecord]$e = $_
         $ErrorRecord = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
         Invoke-ErrorHandler -ErrorRecord $ErrorRecord -ErrorAction Stop -Verbose
      }
      $paramExportCsv = $null
   }

   end
   {
      Write-Verbose -Message 'Done'
   }
}
