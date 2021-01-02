function Get-TeamsServiceNumbers
{
   <#
         .SYNOPSIS
         Get the Phone numbers assigned to Teams/SfB Services

         .DESCRIPTION
         Get the Phone numbers assigned to Teams/SfB Services
         Supported are AutoAttendant and/or CallQueue

         .PARAMETER AutoAttendant
         Get the numbers assigned to AutoAttendant(s)

         .PARAMETER CallQueue
         Get the numbers assigned to CallQueue(s)

         .PARAMETER All
         Get all Numbers, assignee to AutoAttendant(s) and CallQueue(s)

         .PARAMETER LeaveTel
         Normally the function dumps phone numbers with a stripped tel:
			With this switch the function will dump it with the leading tel:

         .PARAMETER Export
         Export the result to a CSV

         .PARAMETER Path
         Path for the CSV Export

         .EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and dump them to the terminal

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All -Export -Path '.\TeamsServiceNumbers.csv'

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and export them to the given CSV file '.\TeamsServiceNumbers.csv'
			TeamsServiceNumbers.csv is in the directory where the user is right now (and calls the function)

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All -Export -Path 'c:\temp\TeamsServiceNumbers.csv'

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and export them to the given CSV file 'c:\temp\TeamsServiceNumbers.csv'

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -All -Export

			Get all Services numbers, AutoAttendant(s) and CallQueue(s), and export them to a CSV
			The funtion will ask for the Path to the CSV File

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -AutoAttendant

			Get all AutoAttendant(s) Services numbers and dump them to the terminal

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -AA

			Get all AutoAttendant(s) Services numbers and dump them to the terminal
			Same as above, but use the Alias (Shorter)

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -CallQueue

			Get all CallQueue(s) Services numbers and dump them to the terminal

			.EXAMPLE
         PS C:\> Get-TeamsServiceNumbers -CQ

			Get all CallQueue(s) Services numbers and dump them to the terminal
			Same as above, but use the Alias (Shorter)

         .NOTES
         Additional information about the function.
   #>

   [CmdletBinding(DefaultParameterSetName = 'AllNumbers',
						ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ParameterSetName = 'AANumbers',
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true)]
      [Alias('AA')]
      [switch]
      $AutoAttendant = $null,
      [Parameter(ParameterSetName = 'CQNumbers',
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true)]
      [Alias('CQ')]
      [switch]
      $CallQueue = $null,
      [Parameter(ParameterSetName = 'AllNumbers',
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true)]
      [Alias('Any')]
      [switch]
      $All,
      [Parameter(ParameterSetName = '__AllParameterSets',
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true)]
      [switch]
      $LeaveTel = $null,
      [Parameter(ParameterSetName = '__AllParameterSets',
         ValueFromPipeline = $true,
         ValueFromPipelineByPropertyName = $true)]
      [Alias('ExportCsv', 'CSV')]
      [switch]
      $Export = $false
   )

   dynamicparam
   {
      if ($PSBoundParameters['Export'])
      {
         # The PATH parameter is only needed if -Export is given
         $PathAttribute = New-Object System.Management.Automation.ParameterAttribute
         $PathAttribute.Mandatory = $true
         $PathAttribute.HelpMessage = "Path for the CSV Export:"
         $PathAttribute.ValueFromPipeline = $true
         $PathAttribute.ValueFromPipelineByPropertyName = $true
         $PathAttribute.ParameterSetName = '__AllParameterSets'
         $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
         $attributeCollection.Add($PathAttribute)
         $PathParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Path', [String], $attributeCollection)
         $paramDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
         $paramDictionary.Add('Path', $PathParam)
         $paramDictionary
      }
   }

   begin
   {
      switch ($PsCmdlet.ParameterSetName)
      {
         'AANumbers'
         {
            $AutoAttendant = $true
         }
         'CQNumbers'
         {
            $CallQueue = $true
         }
         'AllNumbers'
         {
            $All = $true
         }
         default
         {
            $All = $true
         }
      }

      if ($PSBoundParameters.Path)
      {
         $Path = $PSBoundParameters.Path
      }

      $NumberReport = @()
   }

   process
   {
      if (($AutoAttendant) -or ($All))
      {
         foreach ($AA in (Get-CsAutoAttendant -ErrorAction Continue))
         {
            foreach ($AppInstance in $AA.ApplicationInstances)
            {
               $AAName = $AA.Name
               $AppPhoneNum = $null

               if ($LeaveTel)
               {
                  $AppPhoneNum = ((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber)
               }
               else
               {
                  $AppPhoneNum = (((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber).replace('tel:', ''))
               }

               Write-Verbose ('AutoAttendant ' + $AA.Name + ' has ' + $AppPhoneNum + ' assigned')

               $NewRow = $null
               $NewRow = [PSCustomObject][ordered]@{
                  Name   = ($AA.Name)
                  Number = ($AppPhoneNum)
                  Type   = 'AutoAttendant'
               }

               $NumberReport += $newrow
            }
         }
      }

      if (($CallQueue) -or ($All))
      {
         foreach ($CQ in (Get-CsCallQueue -ErrorAction Continue))
         {
            foreach ($AppInstance in $CQ.ApplicationInstances)
            {
               $CQName = $null
               $CQName = $CQ.Name

               $AppPhoneNum = $null

               if ($LeaveTel)
               {
                  $AppPhoneNum = ((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber)
               }
               else
               {
                  $AppPhoneNum = (((Get-CsOnlineApplicationInstance -Identity $AppInstance -ErrorAction Continue).PhoneNumber).replace('tel:', ''))
               }

               Write-Verbose ('CallQueue ' + $CQ.Name + ' has ' + $AppPhoneNum + ' assigned')

               $NewRow = $null
               $NewRow = [PSCustomObject][ordered]@{
                  Name   = ($CQ.Name)
                  Number = ($AppPhoneNum)
                  Type   = 'CallQueue'
               }

               $NumberReport += $newrow
            }
         }
      }
   }

   end
   {
      if (($PSBoundParameters['Export']) -or ($Path))
      {
         $NumberReport | Export-Csv -Path $Path -NoTypeInformation -Encoding UTF8 -ErrorAction Stop -WarningAction Continue

         Write-Verbose -Message $NumberReport
      }
      else
      {
         $NumberReport
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
