#requires -Version 4.0

<#
      .SYNOPSIS
      Compare a old and a refactored function to get any Performace differences

      .DESCRIPTION
      This script compares a simple function (That deletes all Windows Eventlog Entries) with an refacored one.
      The request came up during a workshop: I was asked why I use pipes so much and if there is another way, without pipes.

      The refactored version was created during the workshop as a prototype.
      And to make it easier to compare them, I created this test script.

      .EXAMPLE
      PS C:\> .\Clear-EnAllEventLogs_TESTS.ps1

      .NOTES
      Releasenotes:
      1.0.0 2019-07-24 Initial Version

      THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

      Dependencies:
      NONE

      .LINK
      https://www.enatec.io
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([psobject])]
param ()

#region VersionOfJosh
function Clear-EnAllEventLogs
{
   <#
         .SYNOPSIS
         Delete all Windows event log entries

         .DESCRIPTION
         Delete all Windows event log entries, without any further interaction.
         I use this only after I do some tests on a virtual machine.

         Please Note:
         It Might be dangerous! It might delete more than you like.

         Warning:
         All security related will also be removed completely.
         If there were any issues, you might never find any information about it!

         .PARAMETER ComputerName
         Computer Name as String. Multi Value is possible

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogs

         Delete all Windows EventLog Entries on the local Computer.

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogs -ComputerName FRADC01

         Delete all Windows EventLog Entries on the Computer with the name FRADC01.

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogs -ComputerName 'FRADC01', 'FRADC02'

         Delete all Windows EventLog Entries on the Computers with the names FRADC01 and FRADC02.

         .NOTES
          Releasenotes:

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         TNONE

         .LINK
         https://www.enatec.io

         .LINK
         about_foreach

         .LINK
         Foreach-Object

         .LINK
         Get-EventLog

         .LINK
         Clear-EventLog
   #>
   [CmdletBinding(ConfirmImpact = 'Medium',
      SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [string[]]
      $ComputerName = "$env:COMPUTERNAME"
   )

   process
   {

      foreach ($SingleComputerName in $ComputerName)
      {
         if ($pscmdlet.ShouldProcess($SingleComputerName, 'Cleanup All EventLogs'))
         {
            $paramGetEventLog = @{
               ComputerName = $SingleComputerName
               List         = $true
            }
            $null = (Get-EventLog @paramGetEventLog | ForEach-Object -Process {
                  if ($PSItem.Entries)
                  {
                     $paramClearEventLog = @{
                        LogName     = $PSItem.Log
                        Confirm     = $false
                        ErrorAction = 'SilentlyContinue'
                     }
                     $null = (Clear-EventLog @paramClearEventLog)
                  }
               })
         }
      }
   }
}
#endregion VersionOfJosh

#region RefactoredVersion
function Clear-EnAllEventLogsv2
{
   <#
         .SYNOPSIS
         Delete all Windows event log entries

         .DESCRIPTION
         Delete all Windows event log entries, without any further interaction.
         I use this only after I do some tests on a virtual machine.

         Please Note:
         It Might be dangerous! It might delete more than you like.

         Warning:
         All security related will also be removed completely.
         If there were any issues, you might never find any information about it!

         .PARAMETER ComputerName
         Computer Name as String. Multi Value is possible

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogsv2

         Delete all Windows EventLog Entries on the local Computer.

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogsv2 -ComputerName FRADC01

         Delete all Windows EventLog Entries on the Computer with the name FRADC01.

         .EXAMPLE
         PS C:\> Clear-EnAllEventLogsv2 -ComputerName 'FRADC01', 'FRADC02'

         Delete all Windows EventLog Entries on the Computers with the names FRADC01 and FRADC02.

         .NOTES
         Releasenotes:
         2.0.0 2019-07-23: Refactored version

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         NONE

         .LINK
         https://www.enatec.io

         .LINK
         about_foreach

         .LINK
         Foreach-Object

         .LINK
         Get-EventLog

         .LINK
         Clear-EventLog
   #>
   [CmdletBinding(ConfirmImpact = 'Medium',
      SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [string[]]
      $ComputerName = "$env:COMPUTERNAME"
   )

   process
   {

      foreach ($SingleComputerName in $ComputerName)
      {
         if ($pscmdlet.ShouldProcess($SingleComputerName, 'Cleanup All EventLogs'))
         {
            $paramGetEventLog = @{
               ComputerName = $SingleComputerName
               List         = $true
            }
            $null = ((Get-EventLog @paramGetEventLog).Where( {
                     if ($PSItem.Entries)
                     {
                        $_
                     }
                  }).ForEach( {
                     $paramClearEventLog = @{
                        LogName     = $PSItem.Log
                        Confirm     = $false
                        ErrorAction = 'SilentlyContinue'
                     }
                     $null = (Clear-EventLog @paramClearEventLog)
                  }))
         }
      }
   }
}
#endregion RefactoredVersion

#region CreateTestData
function Invoke-CreateTestData
{
   <#
         .SYNOPSIS
         Create 10.000 dummy entries

         .DESCRIPTION
         Create 10.000 dummy entries

         .EXAMPLE
         PS C:\> Invoke-CreateTestData

         .NOTES
         Internal Helper Function to create some useless Test Data

         Releasenotes:
         1.0.1 2019-07-23: Splat the parameters for better radability
         1.0.0 2019-07-23: Initial Version

         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.

         Dependencies:
         NONE

         .LINK
         https://www.enatec.io

         .LINK
         Write-EventLog

         .LINK
         about_foreach

         .LINK
         Foreach-Object
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   param ()

   begin
   {
      # Splat the parameters
      $paramWriteEventLog = @{
         LogName     = 'Application'
         EventId     = 2001
         EntryType   = 'Information'
         Source      = 'HAL9000'
         Message     = 'I think you know what the problem is just as well as I do.'
         ErrorAction = 'SilentlyContinue'
      }
   }

   process
   {
      # Change the number to fit your needs
      1 .. 1000 | ForEach-Object -Process {
         $null = (Write-EventLog @paramWriteEventLog)
      }
   }
}
#endregion CreateTestData

# Initial Cleanup
$null = (Clear-EnAllEventLogs -ErrorAction SilentlyContinue)

# Create a few new objects
$OldWayAverage = @()
$OldWaySum = @()
$NewWayAverage = @()
$NewWaySum = @()

# Create the new Eventlog
$null = (New-EventLog -LogName Application -Source 'HAL9000' -ErrorAction SilentlyContinue)

#region OldWay
$null = (1..10 | ForEach-Object {
      # Create some Test Data
      $null = (Invoke-CreateTestData -ErrorAction SilentlyContinue)

      #region OldWaySingle
      $OldWaySingle = (Measure-Command -Expression {
            $null = (Clear-EnAllEventLogs -ErrorAction SilentlyContinue)
         })
      #endregion OldWaySingle
      $OldWaySum += $OldWaySingle
   })
$OldWayAverage = (($OldWaySum | Measure-Object -Property TotalMilliseconds -Average).Average)
#endregion OldWay

#region NewWay
$null = (1..10 | ForEach-Object {
      # Create some Test Data
      $null = (Invoke-CreateTestData -ErrorAction SilentlyContinue)

      #region NewWaySingle
      $NewWaySingle = (Measure-Command -Expression {
            $null = (Clear-EnAllEventLogsv2 -ErrorAction SilentlyContinue)
         })
      #endregion NewWaySingle
      $NewWaySum += $NewWaySingle
   })
$NewWayAverage = (($NewWaySum | Measure-Object -Property TotalMilliseconds -Average).Average)
#endregion NewWay

#Region DumpData
Write-Verbose -Message 'Time measured in milliseconds' -Verbose

[pscustomobject]@{
   OldWay = $OldWayAverage
   NewWay = $NewWayAverage
}
#endregion DumpData

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
