function Get-O365MailboxServerDatacenterLocation
{
   <#
      .SYNOPSIS
      Determines the datacenter and location of an Exchange Online Server by name

      .DESCRIPTION
      Determines the datacenter and location of an Exchange Online Server by name
      Multiple Servers are supported.

      The Following info is returned:
      ServerName = The server name you used
      Location   = City (if known) or country
      Region     = Region (e.g. EUR for Europe, or NAM for North America)
      GDPR       = Is the Region EUR (Europe) or not

      .PARAMETER ServerName
      Server Name to check

      .EXAMPLE
      PS C:\> Get-O365MailboxServerDatacenterLocation -ServerName AM3PR1001MB1421

      Sample Result:
      ServerName      Location               Region     GDPR
      ----------      --------               ------     ----
      AM3PR1001MB1421 Amsterdam, Netherlands EUR        True

      The Server seems to be in Amsterdam, Netherlands (Europe)

      .EXAMPLE
      PS C:\> Get-O365MailboxServerDatacenterLocation -ServerName 'AM3PR1001MB1421 (15.20.3890.032)'

      Sample Result:
      ServerName      Location               Region     GDPR
      ----------      --------               ------     ----
      AM3PR1001MB1421 Amsterdam, Netherlands EUR        True

      The Server seems to be in Amsterdam, Netherlands (Europe)
      The Server name needs to be the first word in the string, the rest is ignored!

      .EXAMPLE
      PS C:\> Get-O365MailboxServerDatacenterLocation -ServerName AZ3PR1001MB1421

      Sample Result:
      ServerName      Location               Region     GDPR
      ----------      --------               ------     ----
      AZ3PR1001MB1421 Unknown                Unknown Unknown

      This is the result if the server location is unknown

      .EXAMPLE
      PS C:\> Get-O365MailboxServerDatacenterLocation -ServerName 'AM3PR1001MB1421', 'AZ3PR1001MB1421'

      Sample Result:
      ServerName      Location               Region     GDPR
      ----------      --------               ------     ----
      AM3PR1001MB1421 Amsterdam, Netherlands EUR        True
      AZ3PR1001MB1421 Unknown                Unknown Unknown

      Query multiple servers at the same time

      .NOTES
      This is something I wrote for myself: I want to get detailed informations about Exchange servers that I find in some of the Microsoft Office 365 Logs

      Limitation:
      - Table of data-centers is static and may need to be expanded as Microsoft brings additional data-centers online
      - If Microsoft decide to change the naming convention, the table of data-centers will become useless instantly
      - The script works offline and does not check any plausibility (e.g. none existing servers, like in the examples above)

      The Following info is returned:
      ServerName = The server name you used
      Location   = City (if known) or country
      Region     = Region (e.g. EUR for Europe, or NAM for North America)
      GDPR       = Is the Region EUR (Europe) or not - This is one of the key functions for me!

      Inspired by this blog post: https://adameyob.com/2018/03/30/exchange-online-woes
      But my solution is slightly different: I use the server name I have from the logs to get the info
	#>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory,
         ValueFromPipelineByPropertyName,
         Position = 0,
         HelpMessage = 'Server Name')]
      [Alias('M365ServerName', 'MailboxServer', 'O365MailboxServerName')]
      [string[]]
      $ServerName
   )

   begin
   {
      # Run Garbage Collection
      [gc]::Collect()

      # Create a new Hash-table
      $Datacenter = (New-Object -TypeName Hashtable)

      # Fill the Hash-table
      $Datacenter['AM'] = @('EUR', 'Amsterdam, Netherlands')
      $Datacenter['BL'] = @('NAM', 'Virginia, USA')
      $Datacenter['BN'] = @('NAM', 'Virginia, USA')
      $Datacenter['BY'] = @('NAM', 'San Francisco, California, USA')
      $Datacenter['CH'] = @('NAM', 'Chicago, Illinois, USA')
      $Datacenter['CO'] = @('NAM', 'Quincy, Washington, USA')
      $Datacenter['CP'] = @('LAM', 'Brazil')
      $Datacenter['CY'] = @('NAM', 'Cheyenne, Wyoming, USA')
      $Datacenter['DB'] = @('EUR', 'Dublin, Ireland')
      $Datacenter['DM'] = @('NAM', 'Des Moines, Iowa, USA')
      $Datacenter['GR'] = @('LAM', 'Brazil')
      $Datacenter['HE'] = @('EUR', 'Finland')
      $Datacenter['HK'] = @('APC', 'Hong Kong')
      $Datacenter['KA'] = @('JPN', 'Japan')
      $Datacenter['KL'] = @('APC', 'Kuala Lumpur, Malaysia')
      $Datacenter['LO'] = @('GBR', 'London, England')
      $Datacenter['ME'] = @('APC', 'Melbourne, Victoria, Australia')
      $Datacenter['MM'] = @('GBR', 'Durham, England')
      $Datacenter['MW'] = @('NAM', 'Quincy, Washington, USA')
      $Datacenter['OS'] = @('JPN', 'Japan')
      $Datacenter['PS'] = @('APC', 'Busan, South Korea')
      $Datacenter['SG'] = @('APC', 'Singapore')
      $Datacenter['SI'] = @('APC', 'Singapore')
      $Datacenter['SN'] = @('NAM', 'San Antonio, Texas, USA')
      $Datacenter['SY'] = @('APC', 'Sydney, New South Wales, Australia')
      $Datacenter['TY'] = @('JPN', 'Japan')
      $Datacenter['VI'] = @('EUR', 'Austria')
      $Datacenter['YQ'] = @('CAN', 'Quebec City, Canada')
      $Datacenter['YT'] = @('CAN', 'Toronto, Canada')
   }

   process
   {
      $Result = (New-Object -TypeName System.Collections.Generic.List[System.Object])

      foreach ($SingleServerName in $ServerName)
      {
         # Cleanup the Server name (Remove everything after the 1st word)
         $SingleServerName = ($SingleServerName -split ' ')[0]

         # This is a bit nasty, but unknown cause errors (null pointer)
         try
         {
            $ObjectRegion = $Datacenter[$($SingleServerName.SubString(0, 2))][0]
         }
         catch
         {
            # If you know the info, please let me know!
            $ObjectRegion = 'Unknown'
         }

         # This is a bit nasty, but unknown cause errors (null pointer)
         try
         {
            $ObjectLocation = $Datacenter[$($SingleServerName.SubString(0, 2))][1]
         }
         catch
         {
            # If you know the info, please let me know!
            $ObjectLocation = 'Unknown'
         }

         switch ($ObjectRegion)
         {
            'EUR'
            {
               $ObjectGDPR = $true
            }
            'Unknown'
            {
               # Unknown triggers an internal investigation (find the location Info ASAP)
               $ObjectGDPR = 'Unknown'
            }
            default
            {
               # That triggers an Alarm in my SIEM
               $ObjectGDPR = $false
            }
         }

         # Keep the object in order!
         $Object = [PSCustomObject][ordered]@{
            ServerName = $SingleServerName
            Location   = $ObjectLocation
            Region     = $ObjectRegion
            GDPR       = $ObjectGDPR
         }

         # Add to the Output
         $Result.Add($Object)

         # Cleanup
         $Object = $null
         $ObjectLocation = $null
         $ObjectRegion = $null
         $ObjectGDPR = $null
      }
   }

   end
   {
      # Dump to the Terminal
      $Result

      # Cleanup
      $Result = $null
      $Datacenter = $null

      # Run Garbage Collection
      [gc]::Collect()
   }
}
