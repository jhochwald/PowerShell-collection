<#
      .SYNOPSIS
      Get German Holidays via API and export them to CSV for Skype for Business (Online).

      .DESCRIPTION
      Get German Holidays via API and export them to CSV for Skype for Business (Online).
      We use the German service feiertage-api.de to fetch the list, that is a great wrapper for the German Holidays published on Wikipedia.

      .PARAMETER State
      The german state
      https://de.wikipedia.org/wiki/Feiertage_in_Deutschland

      .PARAMETER Year
      The Year to get and export from the API
      Default is a acctual year (2019 while writing this)

      .PARAMETER appendyear
      Append the Year to the Holliday string?
      The Default is YES

      .PARAMETER Path
      Specifies the path to the CSV file to export.
      Default is Holidays.csv in your User Profile Home.

      .EXAMPLE
      .\Convert-HolidayFromApiToCsAutoAttendantHolidays.ps1

      Get German Holidays via API and export them to CSV for Skype for Business (Online). We use all the defaults!

      .EXAMPLE
      .\Convert-HolidayFromApiToCsAutoAttendantHolidays.ps1 -State 'BY' -Year 2019 -path 'C:\Imports\Holidays.csv'
      $bytes = [IO.File]::ReadAllBytes('C:\Imports\Holidays.csv')
      Import-CsAutoAttendantHolidays -Identity 6283d913-8093-4951-8f46-c5912972002b -Input $bytes

      Get German Holidays via API and export them to 'C:\Imports\Holidays.csv'. We then convert it into Bytes (how Skype for Business likes it) and import them into Skype for Business.

      .NOTES
      The Holiday break will begin at 5pm the day before the actual Holiday and will end the following day at 9am.
      Please check if this match with your workflow and requirements!!!

      Only German Holidays are supported by the script and the API
      Only Skype for Business Online is tested! I use it with a native Microsoft Teams environment, but you need to use the Skype for Business Online PowerShell Module to import it.

      If you like this, please support the feiertage-api.de project with a donation!

      I switched from https://www.spiketime.de/feiertagapi to https://feiertage-api.de/api/ with the latest version. The output was a bit better on the other API, but this API seems to be actively maintained.

      .LINK
      https://feiertage-api.de

      .LINK
      https://www.spiketime.de/blog/spiketime-feiertag-api-feiertage-nach-bundeslandern/

      .LINK
      Import-CsAutoAttendantHolidays

      .LINK
      Export-CsAutoAttendantHolidays

      .LINK
      Invoke-RestMethod

      .LINK
      ConvertTo-Csv

      .LINK
      Set-Content
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [ValidateSet('BW', 'BY', 'BE', 'BB', 'HB', 'HH', 'HE', 'MV', 'NI', 'NW', 'RP', 'SL', 'SN', 'ST', 'SH', 'TH', 'Baden-Württemberg', 'Baden-Wuerttemberg', 'Baden Württemberg', 'Baden Wuerttemberg', 'Bayern', 'Berlin', 'Brandenburg', 'Bremen', 'Hamburg', 'Hessen', 'Mecklenburg-Vorpommern', 'Mecklenburg Vorpommern', 'Niedersachsen', 'Nordrhein Westfalen', 'Nordrhein-Westfalen', 'Rheinland-Pfalz', 'Rheinland Pfalz', 'Saarland', 'Sachsen', 'Rheinland PfalzSachen-Anhalt', 'Schleswig-Holstein', 'Schleswig Holstein', 'Thüringen', 'Thueringen', IgnoreCase = $true)]
   [string]
   $State = 'HE',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [int]
   $Year = (Get-Date).ToString('yyyy'),
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [switch]
   $appendyear,
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('Export', 'ExportCSV', 'CsvFile')]
   [string]
   $Path = "$env:USERPROFILE\Holidays.csv"
)

begin
{
   #region Checks
   if (-not $State)
   {
      $State = 'HE'
   }

   if (-not $Year)
   {
      $Year = (Get-Date).ToString('yyyy')
   }

   if (-not $Path)
   {
      $Path = "$env:USERPROFILE\Holidays.csv"
   }
   #endregion Checks

   #region StateHandler
   # More fuzzy state support
   switch ($State)
   {
      'Baden-Württemberg'
      {
         $State = 'BW'
      }
      'Baden-Wuerttemberg'
      {
         $State = 'BW'
      }
      'Baden Württemberg'
      {
         $State = 'BW'
      }
      'Baden Wuerttemberg'
      {
         $State = 'BW'
      }
      'Bayern'
      {
         $State = 'BY'
      }
      'Berlin'
      {
         $State = 'BE'
      }
      'Brandenburg'
      {
         $State = 'BB'
      }
      'Bremen'
      {
         $State = 'HB'
      }
      'Hamburg'
      {
         $State = 'HH'
      }
      'Hessen'
      {
         $State = 'HE'
      }
      'Mecklenburg-Vorpommern'
      {
         $State = 'MV'
      }
      'Mecklenburg Vorpommern'
      {
         $State = 'MV'
      }
      'Niedersachsen'
      {
         $State = 'NI'
      }
      'Nordrhein-Westfalen'
      {
         $State = 'NW'
      }
      'Nordrhein Westfalen'
      {
         $State = 'NW'
      }
      'Rheinland-Pfalz'
      {
         $State = 'RP'
      }
      'Rheinland Pfalz'
      {
         $State = 'RP'
      }
      'Saarland'
      {
         $State = 'SL'
      }
      'Sachsen'
      {
         $State = 'SN'
      }
      'Sachen-Anhalt'
      {
         $State = 'ST'
      }
      'Sachen Anhalt'
      {
         $State = 'ST'
      }
      'Schleswig-Holstein'
      {
         $State = 'SH'
      }
      'Schleswig Holstein'
      {
         $State = 'SH'
      }
      'Thüringen'
      {
         $State = 'TH'
      }
      'Thueringen'
      {
         $State = 'TH'
      }
      default
      {
         # Good luck ;-)
         $State = $State.ToUpper()
      }
   }
   #endregion StateHandler

   # Create a new Object for the CSV
   $CsvDataObject = @()

   # Build the URI
   $FeiertagApiObjectUri = ('https://feiertage-api.de/api/?jahr=' + $Year + '&nur_land=' + ($State.ToUpper()))
}

process
{
   # Splat the Parameters (Change the UserAgent if you want)
   $paramInvokeRestMethod = @{
      Method        = 'Get'
      Uri           = $FeiertagApiObjectUri
      ErrorAction   = 'Stop'
      WarningAction = 'Continue'
      UserAgent     = 'enaTecParser/1.0 (+http://www.enatec.io)'
   }

   # Use the API to get the List
   try
   {
      $FeiertagApiObject = (Invoke-RestMethod @paramInvokeRestMethod)
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

      Write-Error -Message ($info.Exception) -ErrorAction Stop

      # Only here to catch a global ErrorAction overwrite
      exit 1
      #endregion ErrorHandler
   }

   foreach ($SingleFeiertagApiObject in $FeiertagApiObject.PsObject.Properties)
   {
      # Create a new Object
      $MemberObject = (New-Object -TypeName PSObject)

      # Fill in the Values from the API Call

      $MemberObject | Add-Member -NotePropertyName Name -NotePropertyValue $(if ($appendyear)
         {
            ($SingleFeiertagApiObject.Name) + ' 2019'
         }
         else
         {
            ($SingleFeiertagApiObject.Name)
         }
      )
      $MemberObject | Add-Member -NotePropertyName StartDateTime1 -NotePropertyValue ((Get-Date -Date $SingleFeiertagApiObject.Value.datum).AddDays(-1).ToString('MM/dd/yyyy') + ' 17:00')
      $MemberObject | Add-Member -NotePropertyName EndDateTime1 -NotePropertyValue ((Get-Date -Date $SingleFeiertagApiObject.Value.datum).AddDays(+1).ToString('MM/dd/yyyy') + ' 09:00')
      # Add some useless rows to match the CSV object
      $MemberObject | Add-Member -NotePropertyName StartDateTime2 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime2 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime3 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime3 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime4 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime4 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime5 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime5 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime6 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime6 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime7 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime7 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime8 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime8 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime9 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime9 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName StartDateTime10 -NotePropertyValue $null
      $MemberObject | Add-Member -NotePropertyName EndDateTime10 -NotePropertyValue $null

      # Add to the CSV object
      $CsvDataObject += $MemberObject

      # Cleanup
      $MemberObject = $null
   }

   # Create the CSV Object (We remove the Quotes to make it a perfect fit) and save it
   try
   {
      $paramSetContent = @{
         Value       = ($CsvDataObject | ConvertTo-Csv -UseCulture -NoTypeInformation | ForEach-Object {
               $PSItem.Replace('"', '')
            })
         Path        = $Path
         Force       = $true
         Confirm     = $false
         ErrorAction = 'Stop'
      }
      $null = (Set-Content @paramSetContent)
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

      Write-Error -Message ($info.Exception) -ErrorAction Stop

      # Only here to catch a global ErrorAction overwrite
      exit 1
      #endregion ErrorHandler
   }
}

end
{
   Write-Verbose -Message ((Get-Content -Path $Path).ToString())

   #region Cleanup
   $State = $null
   $Year = $null
   $appendyear = $null
   $Path = $null
   $CsvDataObject = $null
   $FeiertagApiObjectUri = $null
   $paramInvokeRestMethod = $null
   $FeiertagApiObject = $null
   $info = $null
   $MemberObject = $null
   $paramSetContent = $null
   #endregion Cleanup
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
