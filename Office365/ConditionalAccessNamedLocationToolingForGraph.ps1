#requires -Version 3.0
<#
      .SYNOPSIS
      Update a Conditional access named location with the new external (public) IP address

      .DESCRIPTION
      Update a Conditional access named location with the new external (public) IP address.
      Since my router disconnects from time to time, this was something I needed badly!

      .EXAMPLE
      PS C:\> .\ConditionalAccessNamedLocationToolingForGraph.ps1

      .NOTES
      Additional information about the file.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
   #region Configuration
   # Where to store the cache file
   $ToolPath = 'c:\temp\'

   # The application (client) ID for your AzureAD app, e.g. b7ca6bb8-4a3f-465d-ace2-8e8aae841162
   $ClientId = '<YourAppID>'

   # The application (client) secret (password) for your AzureAD app, e.g. Mnq(eL9Wd83(8w^roBu4
   $ClientSecret = '<TheSuperSecretPassword>'

   # Your AzureAD Domain
   # Valid is:
   # contoso.onmicrosoft.com
   # contoso.com
   # The ID (e.g. 09f89b81-0707-4f46-a6d2-c1989d515067)
   $TenantName = '<YourTenantID>'

   # The ID of the location you want to check/update, e.g. 5a28f1e1-7b97-4b0c-8f08-793a4fec7ea5
   $LocationID = '<TheLocationID>'

   # Cache the Location info on the local disk? (this is highly recommended)
   $CacheLocationInfo = $true

   # Cache File name (Json)
   $CacheLocationInfoFile = '<LocationInfoCacheFile>'

   # To you want to store the token in a global varable?
   $CacheToken = $true
   #endregion Configuration

   #region HelperFunctions
   function Compare-LocationInformation
   {
      <#
            .SYNOPSIS
            Compare the external address with the existing location information

            .DESCRIPTION
            Compare the external address with the existing location information

            .PARAMETER ReferenceObject
            The location IP Address

            .PARAMETER DifferenceObject
            The new IP external IP address

            .EXAMPLE
            PS C:\> Compare-LocationInformation -ReferenceObject $value1 -DifferenceObject $value2
            True

            Compare the external address with the existing location information and they match

            .EXAMPLE
            PS C:\> Compare-LocationInformation -ReferenceObject $value1 -DifferenceObject $value2
            False

            Compare the external address with the existing location information and they do NOT match

            .NOTES
            Only the .net ipaddress class is supported. So not use any other format here (e.g. String)
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([bool])]
      param
      (
         [Parameter(Mandatory, HelpMessage = 'The location IP Address',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0)]
         [ValidateNotNullOrEmpty()]
         [Alias('ExistingIP')]
         [ipaddress]
         $ReferenceObject,
         [Parameter(Mandatory, HelpMessage = 'The new IP external IP address',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1)]
         [ValidateNotNullOrEmpty()]
         [Alias('ExternalIP')]
         [ipaddress]
         $DifferenceObject
      )

      begin
      {
         # The default
         [bool]$Result = $false
      }

      process
      {
         if ($ReferenceObject -eq $DifferenceObject)
         {
            [bool]$Result = $true
         }
         else
         {
            [bool]$Result = $false
         }
      }

      end
      {
         # Dump the info to the console
         $Result
      }
   }

   function Get-MSGraphAuthenticationToken
   {
      <#
            .SYNOPSIS
            This function is used to get an authentication token for the Graph API REST interface

            .DESCRIPTION
            This function uses the application (client) ID and application secret to get an authentication token for the Microsoft Graph API REST interface

            .PARAMETER ClientId
            The application (client) ID that you will get in the AzureAD Application Center

            .PARAMETER ClientSecret
            The Client Secret that you will get in the AzureAD Application Center

            .PARAMETER TenantName
            The Directory (tenant) ID, Domain, or Tenant Name.

            Valid input is:
            The tenant name: contoso.onmicrosoft.com
            The directory (tenant) ID: 8076c776-6780-4e95-b62a-7e5581d159e7
            Any registered tenant domain: contoso.com

            .EXAMPLE
            PS C:\> Get-MSGraphAuthenticationToken -ClientId '8076c776-6780-4e95-b62a-7e5581d159e7' -ClientSecret 'U975D^o9iv5()(4*' -TenantName 'c24d4a92-a38f-433f-807f-5d2a1a20bd49'

            Get the access token

            .EXAMPLE
            $paramGetMSGraphAuthenticationToken = @{
            ClientId	    = '8076c776-6780-4e95-b62a-7e5581d159e7'
            ClientSecret = 'U975D^o9iv5()(4*'
            TenantName   = 'c24d4a92-a38f-433f-807f-5d2a1a20bd49'
            }
            PS C:\> $GraphAccessToken = (Get-MSGraphAuthenticationToken @paramGetMSGraphAuthenticationToken)

            Get the Access Token, same as above with splated parameters

            .NOTES
            Only application (client) ID and application secret are supported here!
            If you want to use any other method to get the token, please modify or replace the function.
            I prefer to use a certificate, but in this special case, I decided to go with application (client) ID and application secret!
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([psobject])]
      param
      (
         [Parameter(Mandatory, HelpMessage = 'The Application (client) ID that you will get in the AzureAD Application Center',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('ApplicationID')]
         [string]
         $ClientId,
         [Parameter(Mandatory, HelpMessage = 'The Client Secret that you will get in the AzureAD Application Center',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [string]
         $ClientSecret,
         [Parameter(Mandatory, HelpMessage = 'The Directory (tenant) ID, Domain, or Tenant Name.',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('TenantID', 'DirectoryID')]
         [string]
         $TenantName
      )

      begin
      {
         # Purpose of the access token
         $ResourceValue = 'https://graph.microsoft.com/'

         # Splat the request body element
         $AuthRequestBody = @{
            Grant_Type    = 'client_credentials'
            Scope         = ($ResourceValue + '.default')
            client_Id     = $ClientId
            Client_Secret = $ClientSecret
         }

         # Cleanup
         $AccessToken = $null
      }

      process
      {
         try
         {
            $paramInvokeRestMethod = @{
               Uri         = ('https://login.microsoftonline.com/' + $TenantName + '/oauth2/v2.0/token')
               Method      = 'POST'
               Body        = $AuthRequestBody
               ErrorAction = 'Stop'
            }
            $AccessToken = (Invoke-RestMethod @paramInvokeRestMethod)
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
            break
            #endregion ErrorHandler
         }
      }

      end
      {
         # Dump the info to the console
         $AccessToken
      }
   }

   function Get-MSGraphconditionalAccessNamedLocation
   {
      <#
            .SYNOPSIS
            Get the conditional access named location, all or single

            .DESCRIPTION
            Get the conditional access named location, all or single via Microsoft Graph Call

            .PARAMETER GraphAccessToken
            The access token for the Microsoft Graph API Call

            .PARAMETER Location
            Get one location instead of all locations?
            If you want just one, you have to specify the ID of the location here, Names are not (yet) supported.
            This might come in a future version of the function.

            .EXAMPLE
            PS C:\> Get-MSGraphconditionalAccessNamedLocation -GraphAccessToken $GraphAccessToken

            Get all conditional access named location

            .EXAMPLE
            PS C:\> Get-MSGraphconditionalAccessNamedLocation -GraphAccessToken $GraphAccessToken - Location $LocationID

            Get one conditional access named location

            .EXAMPLE
            PS C:\> Get-MSGraphconditionalAccessNamedLocation -GraphAccessToken $GraphAccessToken - Location '06abccd1-7ed4-4b63-894e-c2b323345b72'

            Get one conditional access named location

            .EXAMPLE
            $paramGetMSGraphconditionalAccessNamedLocation = @{
            GraphAccessToken = $GraphAccessToken
            Location		     = $LocationID
            }
            PS C:\> Get-MSGraphconditionalAccessNamedLocation @paramGetMSGraphconditionalAccessNamedLocation

            Get one conditional access named location

            .NOTES
            Maybe the next verion work with a filter to get locations by name
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([psobject])]
      param
      (
         [Parameter(Mandatory, HelpMessage = 'The Access Token for the Graph Call',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('MsGraphAccessToken', 'AccessToken')]
         [psobject]
         $GraphAccessToken,
         [Parameter(ParameterSetName = 'SingleLocation',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('SingleLocation')]
         [string]
         $Location
      )

      begin
      {
         if (-not ($GraphAccessToken))
         {
            $paramWriteError = @{
               Message      = 'The Access Token is missing'
               Exception    = 'The Access Token is missing'
               Category     = 'ObjectNotFound'
               TargetObject = $GraphAccessToken
               ErrorAction  = 'Stop'
            }
            Write-Error @paramWriteError
         }

         $BaseURI = 'https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/'

         switch ($PsCmdlet.ParameterSetName)
         {
            'SingleLocation'
            {
               $BaseURI = $BaseURI + $Location
            }
         }
      }

      process
      {
         # Cleanup
         $Result = $null

         # Splat the parameters
         $paramInvokeRestMethod = @{
            Headers = @{
               Authorization = ('Bearer ' + $GraphAccessToken.access_token)
            }
            Uri     = $BaseURI
            Method  = 'Get'
         }

         $Result = (Invoke-RestMethod @paramInvokeRestMethod)
      }

      end
      {
         # Dump the info to the console
         $Result
      }
   }

   function Start-WaitLoop
   {
      <#
            .SYNOPSIS
            Wrapper for Start-Sleep that use minutes instead of seconds

            .DESCRIPTION
            Simple wrapper for the regular Start-Sleep cmdlet that use minutes instead of seconds.

            .PARAMETER Minutes
            The Number of minutes to wait

            .PARAMETER Hours
            The number of hours to wait

            .EXAMPLE
            PS C:\> Start-WaitLoop

            Waits 5 minutes, this is the default

            .EXAMPLE
            PS C:\> Start-WaitLoop -Hours 1

            Waits one hour

            .EXAMPLE
            PS C:\> Start-WaitLoop -Minutes

            Waits 15 minutes

            .NOTES
            If you do not pass any parameter, it will wait 5 minutes!
      #>
      [CmdletBinding(DefaultParameterSetName = 'MinutesToWait',
         ConfirmImpact = 'None')]
      param
      (
         [Parameter(ParameterSetName = 'MinutesToWait',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('min')]
         [int]
         $Minutes = 5,
         [Parameter(ParameterSetName = 'HoursToWait',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('hrs')]
         [int]
         $Hours = 1
      )

      begin
      {
         # Cleanup
         $SleepTimer = $null

         # Any parameters?
         switch ($PsCmdlet.ParameterSetName)
         {
            'MinutesToWait'
            {
               if (-not ($Minutes))
               {
                  [int]$Minutes = 5
               }
               [int]$SleepTimer = $Minutes * 60
            }
            'HoursToWait'
            {
               if (-not ($Hours))
               {
                  $paramWriteError = @{
                     Message      = 'Sorry, with the Hours value you have to specify something!'
                     TargetObject = $Hours
                     ErrorAction  = 'Stop'
                     Exception    = 'Sorry, with the Hours value you have to specify something!'
                     Category     = 'ObjectNotFound'
                  }
                  Write-Error @paramWriteError
               }
               [int]$SleepTimer = $Hours * 3600
            }
            default
            {
               [int]$SleepTimer = 300
            }
         }
      }

      process
      {
         $paramStartSleep = @{
            Seconds = $SleepTimer
         }
         $null = (Start-Sleep @paramStartSleep)
      }

      end
      {
         # Cleanup
         $SleepTimer = $null
      }
   }

   function Start-HandleCacheLocationInfo
   {
      <#
            .SYNOPSIS
            Check if the location info is cached and get it if it exists

            .DESCRIPTION
            Check if the location info is cached and get it if it exists

            .PARAMETER Path
            Where to find the location Info

            .EXAMPLE
            PS C:\> Start-HandleCacheLocationInfo -Path '.\CacheObject.json'

            Check if the location info is cached and get it if it exists

            .NOTES
            The warning will be removed in the next version
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([psobject])]
      param
      (
         [Parameter(Mandatory, HelpMessage = 'Where to find the location Info',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('LocationInfoFile')]
         [string]
         $Path
      )

      begin
      {
         # Cleanup
         $Result = $null
      }

      process
      {
         $paramTestPath = @{
            Path        = $Path
            ErrorAction = 'SilentlyContinue'
         }
         if (-not (Test-Path @paramTestPath))
         {
            # Cleanup
            $Result = $null

            # This will be removed in the next version
            Write-Warning -Message 'Given Cache File does NOT exist!'
         }
         else
         {
            try
            {
               # Get the cache file content
               $paramGetContent = @{
                  Path        = $Path
                  Force       = $true
                  Encoding    = 'UTF8'
                  ErrorAction = 'Stop'
               }
               $RawJson = (Get-Content @paramGetContent)

               # convert the json content to a PSObject
               $paramConvertFromJson = @{
                  ErrorAction = 'Stop'
               }
               $Result = ($RawJson | ConvertFrom-Json @paramConvertFromJson)
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
               break
               #endregion ErrorHandler
            }
         }
      }

      end
      {
         # Dump the info to the console
         $Result
      }
   }

   function Get-ExternalIpAddress
   {
      <#
            .SYNOPSIS
            Return your external IP address from a given service

            .DESCRIPTION
            Return your external IP address from a given service

            .PARAMETER Service
            Service to use to get your external IP address

            .EXAMPLE
            PS C:\> Get-ExternalIpAddress

            Return your external IP address from 'https://ip.enatec.net/ip'

            .EXAMPLE
            PS C:\> Get-ExternalIpAddress -Service 'https://ipinfo.io/ip'

            Return your external IP address from a given service

            .NOTES
            Helper function to get the external ip address via a given web service
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([ipaddress])]
      param
      (
         [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0)]
         [ValidateNotNullOrEmpty()]
         [ValidateSet('https://ipinfo.io/ip', 'https://ifconfig.me/ip', 'https://ip.enatec.net/ip', IgnoreCase = $true)]
         [Alias('ServiceURI', 'ServiceURL')]
         [string]
         $Service = 'https://ip.enatec.net/ip'
      )

      begin
      {
         # Cleanup
         $Result = $null
      }

      process
      {
         try
         {
            # Request the info from the given service / We also extract the IP only
            $paramInvokeWebRequest = @{
               Uri         = $Service
               ErrorAction = 'Stop'
            }
            [IPAddress]$Result = ((Invoke-WebRequest @paramInvokeWebRequest).Content).Trim()
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
            break
            #endregion ErrorHandler
         }
      }

      end
      {
         # Dump the info to the console
         $Result
      }
   }

   function Get-AcctualConditionalAccessNamedLocationIp
   {
      <#
            .SYNOPSIS
            Extract the IP address from the conditional access named location object

            .DESCRIPTION
            Extract the IP address from the conditional access named location object

            .PARAMETER Object
            The conditional access named location object from the Microsoft Graph call or from the local cache.

            .EXAMPLE
            PS C:\> Get-AcctualConditionalAccessNamedLocationIp -Object $ConditionalAccessNamedLocationOject

            Extract the IP address from the conditional access named location object $ConditionalAccessNamedLocationOject

            .NOTES
            Helper function
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([ipaddress])]
      param
      (
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'The conditional access named location object from the Microsoft Graph call or from the local cache.')]
         [ValidateNotNullOrEmpty()]
         [Alias('ConditionalAccessNamedLocationInfo')]
         [pscustomobject]
         $Object
      )

      begin
      {
         # Cleanup
         $Result = $null
      }
      process
      {
         # Exctract the IP address
         [String]$Result = ($Object.ipRanges | Select-Object -ExpandProperty cidrAddress)

         # Mangle the object to remove the CIDR part (should be /32)
         [IPAddress]$Result = (($Result -split '/')[0])
      }

      end
      {
         # Dump the info to the console
         $Result
      }
   }

   function Set-MSGraphConditionalAccessNamedLocation
   {
      <#
            .SYNOPSIS
            Modify the conditional access named location via Microsoft Graph

            .DESCRIPTION
            Modify the conditional access named location via Microsoft Graph.
            It will update the IP Address

            .PARAMETER GraphAccessToken
            The access token for the Graph Call

            .PARAMETER Location
            The location obect (cached or from the API call

            .PARAMETER UpdatedIP
            The new external IP Address

            .PARAMETER
            A description of the parameter.

            .EXAMPLE
            PS C:\> Set-MSGraphConditionalAccessNamedLocation -GraphAccessToken $GraphAccessToken -Location $CachedLocationInfoData -UpdatedIP $ActIP

            Modify the conditional access named location via Microsoft Graph, the Token is stored in the $GraphAccessToken,
            the location in $CachedLocationInfoData, and the new ip in $ActIP

            .EXAMPLE
            $paramSetMSGraphConditionalAccessNamedLocation = @{
            GraphAccessToken = $GraphAccessToken
            Location         = $CachedLocationInfoData
            UpdatedIP	        = $ActIP
            }
            PS C:\> Set-MSGraphConditionalAccessNamedLocation @paramSetMSGraphConditionalAccessNamedLocation

            Modify the conditional access named location via Microsoft Graph, the Token is stored in the $GraphAccessToken,
            the location in $CachedLocationInfoData, and the new ip in $ActIP

            .NOTES
            There is no feedback in any kind.
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      param
      (
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
            HelpMessage = 'The Access Token for the Graph Call')]
         [ValidateNotNullOrEmpty()]
         [Alias('MsGraphAccessToken', 'AccessToken')]
         [psobject]
         $GraphAccessToken,
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
            HelpMessage = 'The Location Obect (Cached or from the API call')]
         [ValidateNotNullOrEmpty()]
         [Alias('SingleLocation')]
         [psobject]
         $Location,
         [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
            HelpMessage = 'The new external UP Address')]
         [ValidateNotNullOrEmpty()]
         [Alias('NewIP', 'ExternalIP')]
         [ipaddress]
         $UpdatedIP
      )

      begin
      {
         if (-not ($GraphAccessToken))
         {
            $paramWriteError = @{
               Message      = 'The Access Token is missing'
               Exception    = 'The Access Token is missing'
               Category     = 'ObjectNotFound'
               TargetObject = $GraphAccessToken
               ErrorAction  = 'Stop'
            }
            Write-Error @paramWriteError
         }

         # Extract the location ID
         $LocationID = (($Location).id)

         # URI to call
         $BaseURI = 'https://graph.microsoft.com/beta/identity/conditionalAccess/namedLocations/' + $LocationID

         # Extract the IP address
         [String]$UpdatedIP = (($UpdatedIP).IPAddressToString).Trim()
      }

      process
      {
         # Modify the location object
         $Location.ipRanges | ForEach-Object {
            if ($_ -match '/32')
            {
               # Change to the new address in Sigle IP CIDR (fixed value only)
               $PSItem.cidrAddress = ($UpdatedIP + '/32')
            }
         }

         $paramConvertToJson = @{
            InputObject = $Location
            Compress    = $true
         }
         $paramInvokeRestMethod = @{
            Headers = @{
               Authorization  = ('Bearer ' + $GraphAccessToken.access_token)
               'Content-type' = 'application/json'
            }
            Uri     = $BaseURI
            Method  = 'Patch'
            Body    = (ConvertTo-Json @paramConvertToJson)
         }

         if ($PsCmdlet.ShouldProcess('Conditional Access Named Locations', 'Update via Microsoft Graph'))
         {
            $null = (Invoke-RestMethod @paramInvokeRestMethod)
         }
      }
   }
   #endregion HelperFunctions
}

process
{
   #region ExecuteLogic
   try
   {
      # Do we need a new access token?
      if (-not ($GraphAccessToken))
      {
         # Splat the parameters
         $paramGetMSGraphAuthenticationToken = @{
            ClientId     = $ClientId
            ClientSecret = $ClientSecret
            TenantName   = $TenantName
         }
         # Get the access token
         $GraphAccessToken = (Get-MSGraphAuthenticationToken @paramGetMSGraphAuthenticationToken)

         if ($CacheToken -eq $true)
         {
            $Global:GraphAccessToken = $GraphAccessToken
         }
      }

      # Cleanup
      $CachedLocationInfoData = $null

      # Are we using caching?
      if (($CacheLocationInfo -eq $true) -and ($CacheLocationInfoFile))
      {
         # Call the Helper function to handle the cache
         $paramStartHandleCacheLocationInfo = @{
            Path = ($ToolPath + $CacheLocationInfoFile)
         }
         $CachedLocationInfoData = (Start-HandleCacheLocationInfo @paramStartHandleCacheLocationInfo)
      }

      # Do we have any cached infos?
      if (-not ($CachedLocationInfoData))
      {
         # Get the Location we want
         $paramGetMSGraphconditionalAccessNamedLocation = @{
            GraphAccessToken = $GraphAccessToken
            Location         = $LocationID
         }
         $CachedLocationInfoData = (Get-MSGraphconditionalAccessNamedLocation @paramGetMSGraphconditionalAccessNamedLocation)


         # Cache the Info ?
         if (($CacheLocationInfo -eq $true) -and ($CacheLocationInfoFile))
         {
            # Covert the object to JSON and store it in a local file
            $paramConvertToJson = @{
               InputObject = $CachedLocationInfoData
               Compress    = $true
            }
            $paramNewItem = @{
               Path  = ($ToolPath + $CacheLocationInfoFile)
               Force = $true
            }
            $null = (ConvertTo-Json @paramConvertToJson | New-Item @paramNewItem)
         }
      }

      # Remove Objects that might cause issues later
      try
      {
         $CachedLocationInfoData.PSObject.Properties.Remove('@odata.context')
         $CachedLocationInfoData.PSObject.Properties.Remove('createdDateTime')
         $CachedLocationInfoData.PSObject.Properties.Remove('modifiedDateTime')
      }
      catch
      {
         Write-Verbose -Message 'Whoopsie'
      }

      # Cleanup
      $ActIP = $null
      $MyTrustedIP = $null

      # Get the external IP address
      $paramGetExternalIpAddress = @{
         Service = 'https://ipinfo.io/ip'
      }
      [ipaddress]$ActIP = (Get-ExternalIpAddress @paramGetExternalIpAddress)

      # Get the conditional access named location IP value
      $paramGetAcctualConditionalAccessNamedLocationIp = @{
         Object = $CachedLocationInfoData
      }
      [IPAddress]$MyTrustedIP = (Get-AcctualConditionalAccessNamedLocationIp @paramGetAcctualConditionalAccessNamedLocationIp)

      # Compare the objects we have
      $paramCompareLocationInformation = @{
         ReferenceObject  = $MyTrustedIP
         DifferenceObject = $ActIP
      }
      if ((Compare-LocationInformation @paramCompareLocationInformation) -eq $false)
      {
         # Update the conditional access named location entry with the latest external IP
         $null = (Set-MSGraphConditionalAccessNamedLocation -GraphAccessToken $GraphAccessToken -Location $CachedLocationInfoData -UpdatedIP $ActIP)

         if (($CacheLocationInfo -eq $true) -and ($CacheLocationInfoFile))
         {
            # Remove the cache file
            $paramRemoveItem = @{
               Path    = ($ToolPath + $CacheLocationInfoFile)
               Force   = $true
               Confirm = $false
            }
            $null = (Remove-Item @paramRemoveItem)

            # Get the location we want
            $paramGetMSGraphconditionalAccessNamedLocation = @{
               GraphAccessToken = $GraphAccessToken
               Location         = $LocationID
            }
            $CachedLocationInfoData = (Get-MSGraphconditionalAccessNamedLocation @paramGetMSGraphconditionalAccessNamedLocation)

            # Remove Objects that might cause issues later
            try
            {
               $CachedLocationInfoData.PSObject.Properties.Remove('@odata.context')
               $CachedLocationInfoData.PSObject.Properties.Remove('createdDateTime')
               $CachedLocationInfoData.PSObject.Properties.Remove('modifiedDateTime')
            }
            catch
            {
               Write-Verbose -Message 'Whoopsie'
            }

            # Save the info
            $paramConvertToJson = @{
               InputObject = $CachedLocationInfoData
               Compress    = $true
            }
            $paramNewItem = @{
               Path  = ($ToolPath + $CacheLocationInfoFile)
               Force = $true
            }
            $null = (ConvertTo-Json @paramConvertToJson | New-Item @paramNewItem)
         }
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

      Write-Error -Message ($info.Exception) -ErrorAction Stop

      # Only here to catch a global ErrorAction overwrite
      break
      #endregion ErrorHandler
   }
   #endregion ExecuteLogic
}
