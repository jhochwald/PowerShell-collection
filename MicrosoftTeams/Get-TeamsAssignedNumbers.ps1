#requires -Version 3.0 -Modules MicrosoftTeams
<#
      .SYNOPSIS
      Collects assigned phone numbers from Microsoft Teams

      .DESCRIPTION
      This script queries Microsoft Teams for assigned numbers and displays in a formatted table with the option to export the report in several formats
      During processing LineURI's are run against a regex pattern to extract the DDI/DID and the extension to a separate column

      This script collects Microsoft Teams objects including:
      Users, Meeting Rooms, Online Application Instances (Resource Accounts)

      .PARAMETER OutputType
      Define the Script Output

      Valid values are:
      CONSOLE - Dump a formatted list into the console
      HTML    - Create a simple HTML report with Tables. Only here to be compatible to our older version
      XML     - Create a simple Extensible Markup Language (XML) report
      YAML    - Create a simple YAML Ain't Markup Language (YAML) report
      JSON    - Create a simple JavaScript Object Notation (JSON) report. Handy if you need to upload the data via WebServices/APIs
      CSV     - Create a simple comma-separated values (CSV) report. This is perfect for re-use within Excel, or other applications

      If you leave it empty (this is the default), the object will be dumped to the console!
      This can become handy, if you use this script to generate the report and re-use it in the pipe or your own application

      .PARAMETER Path
      Where to store the Report File

      Default is 'C:\scripts\PowerShell\logs\'

      .PARAMETER DateFormat
      Use the format for Get-Date

      Default is 'yyyyMMdd-HHmmUTC'

      .PARAMETER UTC
      Use ToUniversalTime for the Date Strings

      Default is $true

      .PARAMETER Report
      Define what to report.

      Valid values are:
      Users            - Report numbers assigned to users
      MeetingRooms     - Report numbers assigned to Meetings Room accounts
      ResourceAccounts - Report numbers assigned to Applications. (Auto Attendants (AA) and/or Call Queues (CQ) are supported)
      All              - All assigned numbers (all above merged into one report)

      Default is 'All'

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1

      The Report will be dumped to the console (unformatted)

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CONSOLE -Report MeetingRooms

      Dump a formatted report for numbers assigned to Meeting Rooms into the console

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CONSOLE -Report ResourceAccounts

      Dump a formatted report for numbers assigned to Resource Accounts into the console

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CONSOLE -Report Users

      Dump a formatted report for numbers assigned to Resource Accounts into the console
      This will contain function users for Resource Accounts and Meeting Rooms, but they will be shown as user object!

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CONSOLE -Report all

      Dump a formatted report for every assigned number into the console

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType HTML

      Create a simple HTML report with Tables.

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType XML

      Create a simple Extensible Markup Language (XML) report

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType YAML

      Create a simple YAML Ain't Markup Language (YAML) report

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType JSON

      Create a simple JavaScript Object Notation (JSON) report.

      .EXAMPLE
      PS C:\> .\Get-TeamsAssignedNumbers.ps1 -OutputType CSV

      Create a simple comma-separated values (CSV) report.

      .LINK
      https://github.com/ucgeek/Get-TeamsAssignedNumbers

      .LINK
      https://github.com/ucgeek/Get-TeamsAssignedNumbers/blob/master/LICENSE

      .NOTES
      Based on the work off Andrew Morpeth (@ucgeek and https://ucgeek.co/)
      Licensed under the GNU General Public License v3.0 terms (by @ucgeek)

      REQUIREMENTS:
      If you haven't already, you will need to install the MicrosoftTeams PowerShell module
      The script assumes, you are connect to the Teams/Skype for Business Online Service of Microsoft Office 365
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [AllowNull()]
   [AllowEmptyString()]
   [AllowEmptyCollection()]
   [ValidateSet('CONSOLE', 'HTML', 'XML', 'YAML', 'JSON', 'CSV', IgnoreCase = $true)]
   [Alias('ReportFormat')]
   [string]
   $OutputType = $null,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [AllowNull()]
   [AllowEmptyString()]
   [AllowEmptyCollection()]
   [string]
   $Path = 'C:\scripts\PowerShell\logs',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [AllowNull()]
   [AllowEmptyString()]
   [AllowEmptyCollection()]
   [string]
   $DateFormat = 'yyyyMMdd-HHmmUTC',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('UseUTC')]
   [switch]
   $UTC,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [AllowEmptyCollection()]
   [AllowEmptyString()]
   [AllowNull()]
   [ValidateSet('Users', 'MeetingRooms', 'ResourceAccounts', 'All', IgnoreCase = $true)]
   [Alias('ReportType')]
   [string[]]
   $Report = 'All'
)

begin
{
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
   #endregion BoundParameters

   #region DateToUTC
   if (-not ($UTC))
   {
      $UTC = $true
   }
   #endregion DateToUTC

   #region UseDateUTC
   if (($UTC -eq $true) -and ($DateFormat))
   {
      $FileName = ('MicrosoftTeamsAssignedNumbers_' + ((Get-Date).ToUniversalTime()).ToString($DateFormat))
   }
   #endregion UseDateUTC

   #region UseDateFormat
   if ($DateFormat)
   {
      $FileName = ('MicrosoftTeamsAssignedNumbers_' + ((Get-Date).ToString($DateFormat)))
   }
   else
   {
      # This is the default
      $FileName = ('MicrosoftTeamsAssignedNumbers_' + (Get-Date -Format s).replace(':', '-'))
   }
   #endregion UseDateFormat

   #region PathMangle
   if ($Path)
   {
      # Save to a given PATH
      $FilePath = ($Path + '\' + $FileName)
   }
   else
   {
      # Save here (where the script was started)
      $FilePath = ('.\' + $FileName)
   }
   #endregion PathMangle

   #region Regex
   # Regex values
   $LineURIRegex = '^(?:tel:)?(?:\+)?(\d+)(?:;ext=(\d+))?(?:;([\w-]+))?$'
   #endregion Regex

   #region ReportType
   if (-not ($Report))
   {
      $Report = 'All'
   }
   #endregion ReportType

   # Cleanup
   $ReportData = @()
}

process
{
   #region Users
   if (($Report -eq 'Users') -or ($Report -eq 'All'))
   {
      # Get Users with LineURI
      $UsersLineURI = $null
      $paramGetCsOnlineUser = @{
         ResultSize    = 30000
         Verbose       = $VerboseValue
         Debug         = $DebugValue
         Filter        = {
            (LineURI -ne $null)
         }
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $paramSelectObject = @{
         Property = 'UserPrincipalName', 'LineURI', 'DisplayName', 'FirstName', 'LastName', 'Enabled', 'SipAddress'
         Verbose  = $VerboseValue
         Debug    = $DebugValue
      }
      $UsersLineURI = (Get-CsOnlineUser @paramGetCsOnlineUser | Select-Object @paramSelectObject)

      if ($UsersLineURI)
      {
         Write-Verbose -Message 'Processing User Numbers'

         foreach ($ReportingItem in $UsersLineURI)
         {
            $Matches = @()

            ($ReportingItem.PhoneNumber -match $LineURIRegex | Out-Null)

            $ReportingObject = (New-Object -TypeName System.Object)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $ReportingItem.UserPrincipalName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LineURI' -Value $ReportingItem.LineURI)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DDI' -Value $Matches[1])
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Ext' -Value $Matches[2])
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $ReportingItem.DisplayName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'FirstName' -Value $ReportingItem.FirstName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LastName' -Value $ReportingItem.LastName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'SipAddress' -Value $($ReportingItem.SipAddress -replace 'sip:', ''))
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Enabled' -Value $ReportingItem.Enabled)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'User')

            # Add to array
            $null = ($ReportData += $ReportingObject)
         }
      }
   }
   #endregion Users

   #region MeetingRooms
   if (($Report -eq 'MeetingRooms') -or ($Report -eq 'All'))
   {
      # Get meeting room numbers
      $MeetingRoomLineURI = $null

      $paramGetCsMeetingRoom = @{
         ResultSize    = 10000
         Verbose       = $VerboseValue
         Debug         = $DebugValue
         Filter        = {
            LineURI -ne $null
         }
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $paramSelectObject = @{
         Property = 'UserPrincipalName', 'LineURI', 'DisplayName', 'Enabled', 'SipAddress'
         Verbose  = $VerboseValue
         Debug    = $DebugValue
      }
      $MeetingRoomLineURI = (Get-CsMeetingRoom @paramGetCsMeetingRoom | Select-Object @paramSelectObject)

      if ($MeetingRoomLineURI)
      {
         Write-Verbose -Message 'Processing Meeting Room Numbers'

         foreach ($ReportingItem in $MeetingRoomLineURI)
         {
            $Matches = @()

            ($ReportingItem.PhoneNumber -match $LineURIRegex | Out-Null)

            $ReportingObject = (New-Object -TypeName System.Object)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $ReportingItem.UserPrincipalName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LineURI' -Value $ReportingItem.LineURI)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DDI' -Value $Matches[1])
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Ext' -Value $Matches[2])
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $ReportingItem.DisplayName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'SipAddress' -Value $($ReportingItem.SipAddress -replace 'sip:', ''))
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Enabled' -Value $ReportingItem.Enabled)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'Meeting Room')

            # Remove existing User entry (Rooms have an user object as well)
            if ($ReportData.UserPrincipalName -contains $ReportingItem.UserPrincipalName)
            {
               $ReportData = ($ReportData | Where-Object -FilterScript {
                     ($PSItem.UserPrincipalName -ne $ReportingItem.UserPrincipalName)
                  })
            }

            # Add to array
            $null = ($ReportData += $ReportingObject)
         }
      }
   }
   #endregion MeetingRooms

   #region ResourceAccounts
   if (($Report -eq 'ResourceAccounts') -or ($Report -eq 'All'))
   {
      # Get online resource accounts
      $OnlineApplicationInstanceLineURI = $null

      $paramGetCsOnlineApplicationInstance = @{
         Force         = $true
         ResultSize    = 10000
         Verbose       = $VerboseValue
         Debug         = $DebugValue
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      $paramSelectObject = @{
         Property = 'UserPrincipalName', 'DisplayName', 'PhoneNumber', 'ApplicationId', 'Enabled'
         Verbose  = $VerboseValue
         Debug    = $DebugValue
      }
      $OnlineApplicationInstanceLineURI = (Get-CsOnlineApplicationInstance @paramGetCsOnlineApplicationInstance | Where-Object -FilterScript {
            ($PSItem.PhoneNumber -ne $null)
         } -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Select-Object @paramSelectObject)

      if ($OnlineApplicationInstanceLineURI)
      {
         Write-Verbose -Message 'Processing Online Application Instances (Resource Accounts) Numbers'

         foreach ($ReportingItem in $OnlineApplicationInstanceLineURI)
         {
            $Matches = @()

            ($ReportingItem.PhoneNumber -match $LineURIRegex | Out-Null)

            <#
               Workaround:

               Get-CsOnlineApplicationInstance does not return an "Enabled" and "SipAddress" field,
               so we try to re-use any existing object information

               Will not work all the time, only if regular users are reported as well!
            #>
            if ($ReportData.UserPrincipalName -contains $ReportingItem.UserPrincipalName)
            {
               # Cleanup
               $WorkaroundInfo = $null

               $WorkaroundInfo = ($ReportData | Where-Object -FilterScript {
                     ($PSItem.UserPrincipalName -eq $ReportingItem.UserPrincipalName)
                  } | Select-Object -Property 'Enabled', 'SipAddress')

               if (($WorkaroundInfo).Enabled)
               {
                  $isAppEnabled = (($WorkaroundInfo).Enabled)
               }
               else
               {
                  $isAppEnabled = 'unknown'
               }

               if (($WorkaroundInfo).SipAddress)
               {
                  $isSipAddress = (($WorkaroundInfo).SipAddress)
               }
               else
               {
                  $isSipAddress = 'unknown'
               }
            }

            $ReportingObject = (New-Object -TypeName System.Object)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $ReportingItem.UserPrincipalName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'LineURI' -Value $ReportingItem.PhoneNumber)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DDI' -Value $Matches[1])
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Ext' -Value $Matches[2])
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'DisplayName' -Value $ReportingItem.DisplayName)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'SipAddress' -Value $isSipAddress)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Enabled' -Value $isAppEnabled)
            $null = ($ReportingObject | Add-Member -MemberType NoteProperty -Name 'Type' -Value $(
                  if ($ReportingItem.ApplicationId -eq 'ce933385-9390-45d1-9512-c8d228074e07')
                  {
                     'Auto Attendant Resource Account'
                  }
                  elseif ($ReportingItem.ApplicationId -eq '11cd3e2e-fccb-42ad-ad00-878b93575e07')
                  {
                     'Call Queue Resource Account'
                  }
                  else
                  {
                     'Unknown Resource Account'
                  }
               ))

            # Remove existing User entry (Apps have an user object as well)
            if ($ReportData.UserPrincipalName -contains $ReportingItem.UserPrincipalName)
            {
               $ReportData = ($ReportData | Where-Object -FilterScript {
                     ($PSItem.UserPrincipalName -ne $ReportingItem.UserPrincipalName)
                  })
            }

            # Add to array
            $null = ($ReportData += $ReportingObject)
         }
      }
   }
   #endregion ResourceAccounts

   # Sort the Array data, based on the LineURI object
   $paramSortObject = @{
      Property = 'LineURI'
      Verbose  = $VerboseValue
      Debug    = $DebugValue
   }
   $ReportData = ($ReportData | Sort-Object @paramSortObject)

   #region Output
   switch ($OutputType)
   {
      CSV
      {
         $FilePath = ($FilePath + '.csv')

         $paramConvertToCsv = @{
            Delimiter         = ','
            NoTypeInformation = $true
            Verbose           = $VerboseValue
            Debug             = $DebugValue
            ErrorAction       = 'Continue'
            WarningAction     = 'Continue'
         }
         $PsCsv = ($ReportData | ConvertTo-Csv @paramConvertToCsv)

         $paramOutFile = @{
            FilePath      = $FilePath
            Force         = $true
            Append        = $false
            Encoding      = 'utf8'
            ErrorAction   = 'Continue'
            WarningAction = 'Continue'
            Verbose       = $VerboseValue
            Debug         = $DebugValue
         }
         ($PsCsv | Out-File @paramOutFile)

         Write-Verbose -Message ('Your CSV report was saved to: {0}' -f $FilePath)
      }
      JSON
      {
         $FilePath = ($FilePath + '.json')

         $paramConvertToJson = @{
            Depth         = 5
            ErrorAction   = 'Continue'
            WarningAction = 'Continue'
            Verbose       = $VerboseValue
            Debug         = $DebugValue
         }
         $PsJson = @($ReportData | ConvertTo-Json @paramConvertToJson)

         $paramOutFile = @{
            FilePath      = $FilePath
            Force         = $true
            Append        = $false
            Encoding      = 'utf8'
            ErrorAction   = 'Continue'
            WarningAction = 'Continue'
            Verbose       = $VerboseValue
            Debug         = $DebugValue
         }
         ($PsJson | Out-File @paramOutFile)

         Write-Verbose -Message ('Your JSON report was saved to: {0}' -f $FilePath)
      }
      YAML
      {
         if (Get-Command -Name 'ConvertTo-Yaml' -ErrorAction SilentlyContinue)
         {
            $FilePath = ($FilePath + '.yml')

            <#
                  Workaround for ConvertTo-Yaml
            #>
            $paramJsonWorkaround = @{
               ErrorAction   = 'Continue'
               WarningAction = 'Continue'
               Verbose       = $VerboseValue
               Debug         = $DebugValue
            }
            $ReportData = @($ReportData | ConvertTo-Json @paramJsonWorkaround | ConvertFrom-Json @paramJsonWorkaround)

            $paramConvertToYaml = @{
               Data          = $ReportData
               Force         = $true
               ErrorAction   = 'Continue'
               WarningAction = 'Continue'
               Verbose       = $VerboseValue
               Debug         = $DebugValue
            }
            $PsYaml = (ConvertTo-Yaml @paramConvertToYaml)

            $paramOutFile = @{
               FilePath      = $FilePath
               Force         = $true
               Append        = $false
               Encoding      = 'utf8'
               ErrorAction   = 'Continue'
               WarningAction = 'Continue'
               Verbose       = $VerboseValue
               Debug         = $DebugValue
            }
            ($PsYaml | Out-File @paramOutFile)

            Write-Verbose -Message ('Your YAML report was saved to: {0}' -f $FilePath)
         }
         else
         {
            $paramWriteError = @{
               Exception         = 'The ConvertTo-Yaml command was not found'
               Message           = 'Please ensure, that the ''powershell-yaml'' module is installed.'
               Category          = 'NotInstalled'
               RecommendedAction = 'Please use ''Install-Module -Name powershell-yaml'' to install the required module!'
               ErrorAction       = 'Stop'
            }
            Write-Error @paramWriteError
         }
      }
      XML
      {
         $FilePath = ($FilePath + '.xml')

         $paramConvertToXml = @{
            As                = 'Stream'
            InputObject       = $ReportData
            NoTypeInformation = $true
            ErrorAction       = 'Continue'
            WarningAction     = 'Continue'
            Verbose           = $VerboseValue
            Debug             = $DebugValue
         }
         $PsXML = (ConvertTo-Xml @paramConvertToXml)

         $paramOutFile = @{
            FilePath      = $FilePath
            Force         = $true
            Append        = $false
            Encoding      = 'utf8'
            ErrorAction   = 'Continue'
            WarningAction = 'Continue'
            Verbose       = $VerboseValue
            Debug         = $DebugValue
         }
         ($PsXML | Out-File @paramOutFile)

         Write-Verbose -Message ('Your XML report was saved to: {0}' -f $FilePath)
      }
      HTML
      {
         $FilePath = ($FilePath + '.html')

         $Header = @'
<title>Microsoft Teams assigned phone number report</title>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1'>
<style>
   table {
      border-width: 1px;
      border-style: solid;
      border-color: black;
      border-collapse: collapse;
   }

   th {
      border-width: 1px;
      padding: 3px;
      border-style: solid;
      border-color: black;
      background-color: #6495ED;
   }

   td {
      border-width: 1px;
      padding: 3px;
      border-style: solid;
      border-color: black;
   }
</style>
'@

         $htmlParams = @{
            Title       = 'Microsoft Teams assigned phone number report'
            Head        = $Header
            body        = '<h3>Microsoft Teams assigned phone number report</h3>'
            PreContent  = '<p>The following Phone numbers are assigned in Microsoft Teams:</p>'
            PostContent = '<p><i>Last updated: ' + ((Get-Date).ToUniversalTime()).ToString('HH:MM dd.MM.yyyy (UTC)') + '</i></p>'
            Verbose     = $VerboseValue
            Debug       = $DebugValue
         }
         $PsHtml = ($ReportData | ConvertTo-Html @htmlParams)

         $paramOutFile = @{
            FilePath      = $FilePath
            Force         = $true
            Append        = $false
            Encoding      = 'utf8'
            ErrorAction   = 'Continue'
            WarningAction = 'Continue'
            Verbose       = $VerboseValue
            Debug         = $DebugValue
         }
         ($PsHtml | Out-File @paramOutFile)

         Write-Verbose -Message ('Your HTML report was saved to: {0}' -f $FilePath)
      }
      CONSOLE
      {
         $paramFormatTable = @{
            AutoSize = $true
            Property = 'UserPrincipalName', 'LineURI', 'DDI', 'Ext', 'DisplayName', 'Type'
            Verbose  = $VerboseValue
            Debug    = $DebugValue
         }
         ($ReportData | Format-Table @paramFormatTable)

         Write-Verbose -Message 'Formated Object was dumped'
      }
      default
      {
         $ReportData

         Write-Verbose -Message 'Unformated Object was dumped'
      }
   }
   #endregion Output
}

end
{
   # Cleanup
   $ReportData = $null
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
