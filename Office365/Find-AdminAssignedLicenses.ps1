#requires -Version 3.0 -Modules MSOnline
<#
      .SYNOPSIS
      Find all direct assigned Microsoft 365 licenses

      .DESCRIPTION
      Find all direct assigned Microsoft 365 licenses.
      you can display the licenses or export the info to a CSV file

      .PARAMETER Export
      Export the information to CSV.

      .PARAMETER Display
      Use Out-GridView to display the information.

      .PARAMETER Path
      Path to the CSV

      .PARAMETER MsolName
      The MSOL short name.
      e.g. contoso

      .EXAMPLE
      PS C:\> .\Find-AdminAssignedLicenses.ps1 -MsolName 'contoso' -Display

      Find all direct assigned Microsoft 365 licenses and show it via Out-GridView

      .EXAMPLE
      PS C:\> .\Find-AdminAssignedLicenses.ps1 -MsolName 'contoso' -Export

      Find all direct assigned Microsoft 365 licenses and export it to the default CSV

      .EXAMPLE
      PS C:\> .\Find-AdminAssignedLicenses.ps1 -MsolName 'contoso' -Export -Path 'C:\scripts\PowerShell\export\AdminAssignedLicenses.csv'

      Find all direct assigned Microsoft 365 licenses and export it to a given CSV

      .NOTES
      The next version will bring another switch to dump the info to the console. Based on a request of a customer.

      This script based on the idea of Joachim of powershell24.de - It replaced my old crappy self developed approach.

      .LINK
      https://powershell24.de/en/2020/08/25/direkt-zugewiesene-plane-auslesen/
#>
[CmdletBinding(DefaultParameterSetName = 'Display',
   ConfirmImpact = 'None')]
param
(
   [Parameter(ParameterSetName = 'Export',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('ExportInfo', 'ExportCSV')]
   [switch]
   $Export,
   [Parameter(ParameterSetName = 'Display',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('OutGridView', 'GridView', 'Info')]
   [switch]
   $Display,
   [Parameter(ParameterSetName = 'Export',
      ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('CSVPath', 'CSVFile')]
   [string]
   $Path = '.\M365_admin_assignes_licenses.csv',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('MsolShortName')]
   [string]
   $MsolName = 'contoso'
)

begin
{
   #region RunVerbose
   if ($PSCmdlet.MyInvocation.BoundParameters['Verbose'].IsPresent)
   {
      $RunVerbose = $true
   }
   else
   {
      $RunVerbose = $false
   }
   #endregion RunVerbose

   #region DryRun
   if ($PSCmdlet.MyInvocation.BoundParameters['Whatif'].IsPresent)
   {
      $IsDryRun = $true
   }
   else
   {
      $IsDryRun = $false
   }
   #endregion DryRun

   #region GetUserInfo
   $paramGetMsolUser = @{
      All         = $true
      ErrorAction = 'Stop'
      Verbose     = $RunVerbose
   }
   $AllUsers = (Get-MsolUser @paramGetMsolUser)

   # Filter the licensed users
   $AllUsers = ($AllUsers | Where-Object {
         $PSItem.isLicensed -eq $true
      })
   #endregion GetUserInfo

   #region CreateObjects
   $paramNewObject = @{
      TypeName = 'System.Collections.Generic.List[System.Object]'
      Verbose  = $RunVerbose
   }
   $DirectAssignments = (New-Object @paramNewObject)
   $SkuFilter = (New-Object @paramNewObject)
   $FilterSku = (New-Object @paramNewObject)
   #endregion CreateObjects

   #region LicenseFilters
   [String[]]$FilterSku = @(
      'POWER_BI_STANDARD'
      'POWERAPPS_VIRAL'
      'POWERAPPS_INDIVIDUAL_USER'
      'FLOW_FREE'
      'MCOMEETADV'
      'PROJECTPROFESSIONAL'
   )
   #endregion LicenseFilters

   #region FilterSku
   foreach ($SkuFilterItem in $FilterSku)
   {
      $SkuFilterSingleItem = $null
      $SkuFilterSingleItem = ($MsolName + ':' + $SkuFilterItem)
      $SkuFilter.Add($SkuFilterSingleItem)
   }
   #endregion FilterSku
}

process
{
   #region UserLoop
   foreach ($User in $AllUsers)
   {
      # Be verbose
      Write-Verbose -Message ('Gathering information for {0}' -f $User.UserPrincipalName)

      # Store the object information
      $UserObjectID = ($User.ObjectId)
      $AllUserLicenses = ($User.Licenses)

      #region LicenseLoop
      foreach ($License in $AllUserLicenses)
      {
         # Store the object information
         $Assignments = ($License.GroupsAssigningLicense)

         #region IsLicenseAssigned
         if ($License.GroupsAssigningLicense.Count -eq 0)
         {
            Write-Verbose -Message 'No direct assigned licenses found.'
         }
         else
         {
            # OK, now loop over the assigned licenses
            foreach ($Assignment in $Assignments)
            {
               # Is it assigned to the user?
               if ($Assignment -ieq $UserObjectID)
               {
                  # Apply the Filter
                  if ($SkuFilter -match $License.AccountSkuId)
                  {
                     Write-Verbose -Message ('The License {0} was filtered.' -f $License.AccountSkuId)
                  }
                  else
                  {
                     # OK, we found something
                     $DirectAssignment = ('' | Select-Object -Property UserPrincipalName, AccountSkuId -Verbose:$RunVerbose)
                     $DirectAssignment.UserPrincipalName = ($User.UserPrincipalName)
                     $DirectAssignment.AccountSkuId = ($License.AccountSkuId.Replace(($MsolName + ':'), ''))

                     # Add to the list
                     $DirectAssignments.Add($DirectAssignment)
                  }

                  # Done
                  break
               }
            }
         }
         #endregion IsLicenseAssigned
      }
      #endregion LicenseLoop
   }
   #endregion UserLoop
}

end
{
   #region SwitchHandler
   switch ($PSCmdlet.ParameterSetName)
   {
      'Display'
      {
         # OK, dump the info
         ($DirectAssignments | Out-GridView -PassThru -Verbose:$RunVerbose)
      }
      'Export'
      {
         # export logic
         $paramExportCsv = @{
            Path              = $Path
            Force             = $true
            Encoding          = 'UTF8'
            NoTypeInformation = $true
            Delimiter         = ';'
            Confirm           = $false
            Verbose           = $RunVerbose
            WhatIf            = $IsDryRun
            ErrorAction       = 'Continue'
         }
         $null = ($DirectAssignments | Export-Csv @paramExportCsv)
      }
   }
   #endregion SwitchHandler
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
