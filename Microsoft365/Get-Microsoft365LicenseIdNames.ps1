#requires -Version 3.0

function Get-Microsoft365LicenseIdNames
{
   <#
         .SYNOPSIS
         Get Microsoft365 License Friendly Names
   
         .DESCRIPTION
         Get the product names and service plan identifiers online and display the result on the screen
         Downloads and parses the licensing-service-plan-reference.md file from GitHub and converts to a PowerShell object.
   
         .PARAMETER URL
         This is URL path to the the licensing reference table document from GitHub.
   
         .PARAMETER SkuId
         Return only the matching SkuId
   
         .PARAMETER TitleCase
         Force convert license names to title case.
   
         .PARAMETER Force
         Force to download the online version instead of checking table in the current session
   
         .EXAMPLE
         PS C:\> Get-Microsoft365LicenseIdNames
         Get the product names and service plan identifiers online and display the result on the screen
   
         .EXAMPLE
         PS C:\> Get-Microsoft365LicenseIdNames | Export-Csv -NoTypeInformation .\m365-License-Reference.csv
         Get the product names and service plan identifiers online and export to CSV.
   
         .EXAMPLE
         PS C:\> Get-Microsoft365LicenseIdNames -TitleCase
         Get the product names and service plan identifiers online and display the result on the screen. The friendly names will be convered to title case.
   
         .EXAMPLE
         PS C:\> Get-Microsoft365LicenseIdNames -SkuId fc14ec4a-4169-49a4-a51e-2c852931814b
         Get the product names and service plan identifiers that matches the specified SkuId
   
         .EXAMPLE
         PS C:\> Get-Microsoft365LicenseIdNames -Force
         Force to download the SKU table from the online source and ignoring the locally available table version.
   
         .LINK
         https://learn.microsoft.com/en-us/entra/identity/users/licensing-service-plan-reference
   
         .NOTES
         Additional information about the function.
   #>
   
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([pscustomobject])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [string]
      $URL = 'https://raw.githubusercontent.com/MicrosoftDocs/entra-docs/main/docs/identity/users/licensing-service-plan-reference.md',
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [AllowNull()]
      [guid]
      $SkuId,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [switch]
      $TitleCase,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('Online ForceOnline')]
      [switch]
      $Force
   )
   
   begin
   {
      #region InternalFunctions
      function Get-SkuIdResult
      {
         if ($SkuId)
         {
            $script:SkuTable | Where-Object -FilterScript {
               ($_.SkuId -eq $SkuId)
            }
         }
         else
         {
            $script:SkuTable
         }
      }
      #endregion InternalFunctions

      if ($Force)
      {
         $script:SkuTable = @()
      }
   }
   
   process
   {
      # Check first if the SKU table is already available in the session. This ensures that the script only downloads the online table once per session, unless the -ForceOnline switch is used.
      if ($script:SkuTable)
      {
         Write-Verbose -Message 'SKU table exists in session.'

         return Get-SkuIdResult
      }
      else
      {
         Write-Verbose -Message 'Downloading SKU table online...'
         
         # Parse the Markdown Table from the $URL
         try
         {
            [Collections.ArrayList]$raw_Table = ([Net.WebClient]::new()).DownloadString($URL).split("`n")
         }
         catch
         {
            Write-Output -InputObject ('There was an error getting the licensing reference table at [{0}]. Please make sure that the URL is still valid.' -f $URL)
            Write-Output -InputObject $_.Exception.Message

            return $null
         }
         
         # Determine the starting row index of the table
         $startLine = ($raw_Table.IndexOf('| Product name | String ID | GUID | Service plans included | Service plans included (friendly names) |') + 1)
         
         # Determine the ending index of the table
         $endLine = ($raw_Table.IndexOf('## Service plans that cannot be assigned at the same time') - 1)
         
         # Extract the string in between the lines $startLine and $endLine
         $result = for ($i = $startLine; $i -lt $endLine; $i++)
         {
            if ($raw_Table[$i] -notlike '*---*')
            {
               $raw_Table[$i].Substring(1, $raw_Table[$i].Length - 1)
            }
         }
         
         $result = $result -replace '\s*\|\s*', '|' -replace '\s*<br/>\s*', ',' -replace '\(\(', '(' -replace '\)\)', ')' -replace '\)\s*\(', ')('
         
         # Create the result object
         if ($TitleCase)
         {
            $TextInfo = (Get-Culture).TextInfo
            $script:SkuTable = @(
               # This is the magic ;-)
               $result | ConvertFrom-Csv -Delimiter '|' -Header 'SkuName', 'SkuPartNumber', 'SkuID', 'ChildServicePlan', 'ChildServicePlanName' | Select-Object -Property @{
                  n = 'SkuName'
                  e = {
                     $TextInfo.ToTitleCase($_.SkuName)
                  }
               }, 'SkuPartNumber', 'SkuID', 'ChildServicePlan', @{
                  n = 'ChildServicePlanName'
                  e = {
                     $TextInfo.ToTitleCase($_.ChildServicePlanName)
                  }
               }
            )
         }
         else
         {
            $script:SkuTable = @(
               $result | ConvertFrom-Csv -Delimiter '|' -Header 'SkuName', 'SkuPartNumber', 'SkuID', 'ChildServicePlan', 'ChildServicePlanName'
            )
         }
         
         # return the result
         return Get-SkuIdResult
      }
   }
}
Get-Microsoft365LicenseIdNames -SkuId fc14ec4a-4169-49a4-a51e-2c852931814b