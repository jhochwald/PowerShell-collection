function Invoke-UniFiCidrWorkaround
{
   <#
         .SYNOPSIS
         IPv4 CIDR Workaround for UBNT USG Firewall Rules
	
         .DESCRIPTION
         IPv4 CIDR Workaround for UBNT USG Firewall Rules (Single IPv4 has to be without /32)
	
         .PARAMETER CidrList
         Existing CIDR List Object
	
         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaround -CidrList $value1

         IPv4 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaround

         IPv4 CIDR Workaround for UBNT USG Firewall Rules via Pipeline
	
         .NOTES
         This is an internal helper function only

         .LINK
         Invoke-UniFiCidrWorkaroundV6
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Existing CIDR List Object')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiCidrList')]
      [psobject]
      $CidrList
   )
	
   begin
   {
      # Cleanup
      $AddItem = @()
   }
	
   process
   {
      # Loop over the new list
      foreach ($NewInputItem in $CidrList)
      {
         # CIDR Workaround for UBNT USG Firewall Rules (Single IP has to be without /32)
         if ($NewInputItem -match '/32')
         {
            $NewInputItem = $NewInputItem.Replace('/32', '')
         }
         # Add to the List
         $AddItem = $AddItem + $NewInputItem
      }
   }
	
   end
   {
      # Dump
      $AddItem

      # Cleanup
      $AddItem = $null
   }
}

function Invoke-UniFiCidrWorkaroundV6
{
   <#
         .SYNOPSIS
         IPv6 CIDR Workaround for UBNT USG Firewall Rules
	
         .DESCRIPTION
         IPv6 CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)
	
         .PARAMETER CidrList
         Existing CIDR List Object
	
         .EXAMPLE
         PS C:\> Invoke-UniFiCidrWorkaroundV6 -CidrList $value1

         IPv6 CIDR Workaround for UBNT USG Firewall Rules

         .EXAMPLE
         PS C:\> $value1 | Invoke-UniFiCidrWorkaroundV6

         IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline
	
         .NOTES
         This is an internal helper function only

         .LINK
         Invoke-UniFiCidrWorkaround
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Existing CIDR List Object')]
      [ValidateNotNullOrEmpty()]
      [Alias('UniFiCidrList')]
      [psobject]
      $CidrList
   )
	
   begin
   {
      # Cleanup
      $AddItem = @()
   }
	
   process
   {
      # Loop over the new list
      foreach ($NewInputItem in $CidrList)
      {
         # CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)
         if ($NewInputItem -match '/128')
         {
            $NewInputItem = $NewInputItem.Replace('/128', '')
         }
         # Add to the List
         $AddItem = $AddItem + $NewInputItem
      }
   }
	
   end
   {
      # Dump
      $AddItem

      # Cleanup
      $AddItem = $null
   }
}

function Get-UnifiFirewallGroupBody
{
   <#
         .SYNOPSIS
         Build a Body for Set-UnifiFirewallGroup call
	
         .DESCRIPTION
         Build a JSON based Body for Set-UnifiFirewallGroup call
	
         .PARAMETER UnfiFirewallGroup
         Existing Unfi Firewall Group
	
         .PARAMETER UnifiCidrInput
         IPv4 or IPv6 input List
	
         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupBody -UnfiFirewallGroup $value1 -UnifiCidrInput $value2
	
         Build a Body for Set-UnifiFirewallGroup call

         .NOTES
         This is an internal helper function only

         . LINK
         Set-UnifiFirewallGroup
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Existing Unfi Firewall Group')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroup')]
      [psobject]
      $UnfiFirewallGroup,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'IPv4 or IPv6 input List')]
      [ValidateNotNullOrEmpty()]
      [Alias('CidrInput')]
      [psobject]
      $UnifiCidrInput
   )
	
   begin
   {
      Write-Verbose -Message 'Cleanup exitsing Group'
      Write-Verbose -Message "Old Values: $UnfiFirewallGroup.group_members"
      $UnfiFirewallGroup.group_members = $null
   }
	
   process
   {
      Write-Verbose -Message 'Create a new Object'
      $NewUnifiCidrItem = @()
		
      foreach ($UnifiCidrItem in $UnifiCidrInput)
      {
         $NewUnifiCidrItem = $NewUnifiCidrItem + $UnifiCidrItem
      }
		
      # Add the new values
      $paramAddMember = @{
         MemberType = 'NoteProperty'
         Name       = 'group_members'
         Value      = $NewUnifiCidrItem
         Force      = $true
      }
      $UnfiFirewallGroup | Add-Member @paramAddMember
		
      # Cleanup
      $NewUnifiCidrItem = $null
		
      try
      {
         # Create a new Request Body
         $paramConvertToJson = @{
            InputObject   = $UnfiFirewallGroup
            Depth         = 5
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $UnfiFirewallGroupJson = (ConvertTo-Json @paramConvertToJson)
      }
      catch
      {
         $null = (Invoke-InternalScriptVariables)
			
         Write-Error -Message 'Unable to convert new List to JSON' -ErrorAction Stop
			
         break
      }
   }
	
   end
   {
      # Dump
      $UnfiFirewallGroupJson
   }
}

function Set-UniFiDefaultRequestHeader
{
   <#
         .SYNOPSIS
         Set the default Header for all UniFi Requests
	
         .DESCRIPTION
         Set the default Header for all UniFi Requests
	
         .EXAMPLE
         PS C:\> Set-UniFiDefaultRequestHeader

         Set the default Header for all UniFi Requests
	
         .NOTES
         This is an internal helper function only
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()
	
   begin
   {
      # Cleanup
      $RestHeader = $null
   }

   process
   {
      Write-Verbose -Message 'Create the Default Request Header'
      $Global:RestHeader = @{
         'charset'    = 'utf-8'
         'Content-Type' = 'application/json'
      }
      Write-Verbose -Message ('Default Request Header is {0}' -f $RestHeader)
   }
}

function Get-UniFiConfig
{
   <#
         .SYNOPSIS
         Read the UniFi config file
	
         .DESCRIPTION
         Get the default values from the  UniFi config file
	
         .PARAMETER Path
         Path to the config file
	
         .EXAMPLE
         PS C:\> Get-UniFiConfig

         Read the UniFi config file
	
         .NOTES
         We do not import/read the username and password

         .LINK
         Get-UniFiCredentials
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiConfig')]
      [string]
      $Path = '.\UniFiConfig.json'
   )
	
   begin
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config File'
         $RawJson = (Get-Content -Path $Path -Force -ErrorAction Stop -WarningAction SilentlyContinue)

         Write-Verbose -Message 'Convert the JSON config File to a PSObject'
         $UnifiConfig = ($RawJson | ConvertFrom-Json -ErrorAction Stop -WarningAction SilentlyContinue)
      }
      catch
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Default error handling: Re-Throw the error
         Write-Error -Message ('Error was {0}' -f $_) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      # Cleanup
      $RawJson = $null
		
      # Set the config for later use
      $Global:ApiProto = $UnifiConfig.protocol
      Write-Verbose -Message ('ApiProto is {0}' -f $ApiProto)

      $Global:ApiHost = $UnifiConfig.Hostname
      Write-Verbose -Message ('ApiHost is {0}' -f $ApiHost)

      $Global:ApiPort = $UnifiConfig.Port
      Write-Verbose -Message ('ApiPort is {0}' -f $ApiPort)

      $Global:ApiSelfSignedCert = $UnifiConfig.SelfSignedCert
      Write-Verbose -Message ('ApiSelfSignedCert is {0}' -f $ApiSelfSignedCert)

      # Build the Base URI String
      $Global:ApiUri = $ApiProto + '://' + $ApiHost + ':' + $ApiPort + '/api/'
      Write-Verbose -Message ('ApiUri is {0}' -f $ApiUri)
   }
	
   end
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
   }
}

function Get-UniFiCredentials
{
   <#
         .SYNOPSIS
         Read the API Credentials from the UniFi config file
	
         .DESCRIPTION
         Read the API Credentials from the UniFi config file
	
         .EXAMPLE
         PS C:\> Get-UniFiCredentials

         Read the API Credentials from the UniFi config file
	
         .NOTES
         Only import/read the username and password

         .LINK
         Get-UniFiConfig
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiConfig')]
      [string]
      $Path = '.\UniFiConfig.json'
   )
	
   begin
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config File'
         $RawJson = (Get-Content -Path $Path -Force -ErrorAction Stop -WarningAction SilentlyContinue)

         Write-Verbose -Message 'Convert the JSON config File to a PSObject'
         $UnifiConfig = ($RawJson | ConvertFrom-Json -ErrorAction Stop -WarningAction SilentlyContinue)
      }
      catch
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Default error handling: Re-Throw the error
         Write-Error -Message ('Error was {0}' -f $_) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      # Cleanup
      $RawJson = $null
		
      Write-Verbose -Message 'Try to setup the API Credentials'

      if ((-not $UnifiConfig.Login.Username) -or (-not $UnifiConfig.Login.Password)) 
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)

         # Bad news!
         Write-Error -Message 'Unable to setup the API Credentials, please check your config file!' -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      $ApiUsername = $null
      $ApiPassword = $null
      $Global:ApiUsername = $UnifiConfig.Login.Username
      $Global:ApiPassword = $UnifiConfig.Login.Password

      Write-Verbose -Message 'API Credentials set'
   }
	
   end
   {
      # Cleanup
      $RawJson = $null
      $UnifiConfig = $null
		
   }
}

function Invoke-UniFiApiLogin
{
   <#
         .SYNOPSIS
         Login to API of the UniFi Controller
	
         .DESCRIPTION
         Login to API of the Ubiquiti UniFi Controller
	
         .EXAMPLE
         PS C:\> Invoke-UniFiApiLogin

         Login to API of the Ubiquiti UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Get-UniFiCredentials

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogout
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()
	
   begin
   {
      # Cleanup
      $RestSession = $null
      $Session = $null
		
      function Set-UniFiApiLoginBody
      {
         <#
               .SYNOPSIS
               Create the request body for the UniFi Login
	
               .DESCRIPTION
               Creates the JSON based request body for the UniFi Login
	
               .EXAMPLE
               Set-UniFiApiLoginBody
	
               Creates the JSON based request body for the UniFi Login
	
               .NOTES
               This is an internal helper function only
         #>
         [CmdletBinding(ConfirmImpact = 'None')]
         param ()
			
         begin
         {
            # Cleanup
            $RestBody = $null
            $JsonBody = $null

            Write-Verbose -Message 'Check for API Credentials'
            if ((-not $ApiUsername) -or (-not $ApiPassword))
            {
               Write-Error -Message 'Please set the UniFi API Credentials'
					
               # Only here to catch a global ErrorAction overwrite
               break
            }
         }
			
         process
         {
            Write-Verbose -Message 'Create the Body Object'
            $RestBody = [PSCustomObject][ordered]@{
               username = $ApiUsername
               password = $ApiPassword
            }

            # Convert the Body Object to JSON
            try
            {
               $paramConvertToJson = @{
                  InputObject   = $RestBody
                  Depth         = 5
                  ErrorAction   = 'Stop'
                  WarningAction = 'SilentlyContinue'
               }
               $Script:JsonBody = (ConvertTo-Json @paramConvertToJson)
            }
            catch
            {
               # Verbose stuff
               $Script:line = $_.InvocationInfo.ScriptLineNumber
               Write-Verbose -Message ('Error was in Line {0}' -f $line)
					
               # Default error handling: Re-Throw the error
               Write-Error -Message ('Error was {0}' -f $_) -ErrorAction Stop
					
               # Only here to catch a global ErrorAction overwrite
               break
            }
         }
			
         end
         {
            Write-Verbose -Message 'Created the Body Object'

            # Cleanup
            $RestBody = $null
         }
      }
   }
	
   process
   {
      # Login
      try
      {
         # 
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)

         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)

         Write-Verbose -Message 'Read the Credentials'
         $null = (Get-UniFiCredentials)
			
         Write-Verbose -Message 'Create the Body'
         $null = (Set-UniFiApiLoginBody)

         Write-Verbose -Message 'Cleanup the credentials variables'
         $ApiUsername = $null
         $ApiPassword = $null
			
         # Cleanup
         $Session = $null
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 'login'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

         Write-Verbose -Message 'Send the Request to Login'
         $paramInvokeRestMethod = @{
            Method          = 'Post'
            Uri             = $ApiRequestUri
            Headers         = $RestHeader
            Body            = $JsonBody
            ErrorAction     = 'SilentlyContinue'
            WarningAction   = 'SilentlyContinue'
            SessionVariable = 'RestSession'
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)

         $Global:RestSession = $RestSession

         # Remove the Body variable
         $JsonBody = $null
      }
      catch
      {
         # Remove the Body variable
         $JsonBody = $null
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Cleanup
      $Session = $null
   }
}

function Invoke-UniFiApiLogout
{
   <#
         .SYNOPSIS
         Logout from the API of the UniFi Controller
	
         .DESCRIPTION
         Logout from the API of the Ubiquiti UniFi Controller
	
         .EXAMPLE
         
         PS C:\> Invoke-UniFiApiLogout

         Logout from the API of the Ubiquiti UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Invoke-UniFiApiLogin
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param ()
	
   begin
   {
      # Cleanup
      $Session = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)

         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }

         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)

         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 'logout'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)

         Write-Verbose -Message 'Send the Request to Login'
         $paramInvokeRestMethod = @{
            Method        = 'Post'
            Uri           = $ApiRequestUri
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Remove the Body variable
         $JsonBody = $null
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)

         # Error Message
         Write-Error -Message 'Unable to Logout' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }

      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Cleanup
      $Session = $null
      $RestSession = $null
   }
}

function Get-UnifiNetworkList
{
   <#
         .SYNOPSIS
         Get a List Networks via the API of the UniFi Controller
	
         .DESCRIPTION
         Get a List Networks via the API of the Ubiquiti UniFi Controller
	
         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default
	
         .EXAMPLE
         PS C:\> Get-UnifiNetworkList

         Get a List Networks via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkList -UnifiSite 'Contoso'

         Get a List Networks on Site 'Contoso' via the API of the UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Set-UniFiDefaultRequestHeader
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )
	
   begin
   {
      # Cleanup
      $Session = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)
			
         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
			
         Write-Verbose -Message 'Send the Request'
         $paramInvokeRestMethod = @{
            Method        = 'Get'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)

         # Remove the Body variable
         $JsonBody = $null

         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to get Firewall Groups' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to get the network list' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Dump the Result
      $Session.data
		
      # Cleanup
      $Session = $null
   }
}

function Get-UnifiNetworkDetails
{
   <#
         .SYNOPSIS
         Get the details about one network via the API of the UniFi Controller
	
         .DESCRIPTION
         Get the details about one network via the API of the UniFi Controller
	
         .PARAMETER UnifiNetwork
         The ID (network_id) of the network you would like to get detaild information about.
	
         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default
	
         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -UnifiNetwork $value1

         Get the details about one network via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiNetworkDetails -UnifiNetwork $value1 -UnifiSite 'Contoso'

         Get the details about one network on Site 'Contoso' via the API of the UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Set-UniFiDefaultRequestHeader
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'The ID (network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetworkId', 'NetworkId')]
      [string]
      $UnifiNetwork,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )
	
   begin
   {
      # Cleanup
      $Session = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)
			
         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/' + $UnifiNetwork
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
			
         Write-Verbose -Message 'Send the Request'
         $paramInvokeRestMethod = @{
            Method        = 'Get'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)
			
         # Remove the Body variable
         $JsonBody = $null
			
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to get the network details' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Dump the Result
      $Session.data
		
      # Cleanup
      $Session = $null
   }
}

function Set-UnifiNetworkDetails
{
   <#
         .SYNOPSIS
         Modifies one network via the API of the UniFi Controller
	
         .DESCRIPTION
         Modifies one network via the API of the UniFi Controller
	
         .PARAMETER UnifiNetwork
         The ID (network_id) of the network you would like to get detaild information about.

         .PARAMETER UniFiBody
         JSON formed Body for the Request
	
         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default
	
         .EXAMPLE
         PS C:\> Set-UnifiNetworkDetails -UnifiNetwork $value1

         Get the details about one network via the API of the UniFi Controller

         .EXAMPLE
         PS C:\> Set-UnifiNetworkDetails -UnifiNetwork $value1 -UnifiSite 'Contoso'

         Get the details about one network on Site 'Contoso' via the API of the UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Set-UniFiDefaultRequestHeader
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'The ID (network_id) of the network you would like to get detaild information about.')]
      [ValidateNotNullOrEmpty()]
      [Alias('UnifiNetworkId', 'NetworkId')]
      [string]
      $UnifiNetwork,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'JSON formed Body for the Request')]
      [ValidateNotNullOrEmpty()]
      [Alias('Body')]
      [string]
      $UniFiBody,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )
	
   begin
   {
      # Cleanup
      $Session = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)
			
         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/networkconf/' + $UnifiNetwork
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
			
         Write-Verbose -Message 'Send the Request'
         $paramInvokeRestMethod = @{
            Method        = 'Put'
            Uri           = $ApiRequestUri
            Body          = $UniFiBody
            Headers       = $RestHeader
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)
			
         # Remove the Body variable
         $JsonBody = $null
			
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to modify given network' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Dump the Result
      $Session.data
		
      # Cleanup
      $Session = $null
   }
}

function Get-UnifiFirewallGroups
{
   <#
         .SYNOPSIS
         Get a List Firewall Groups via the API of the UniFi Controller
	
         .DESCRIPTION
         Get a List Firewall Groups via the API of the Ubiquiti UniFi Controller
	
         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default
	
         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroups

         Get a List Firewall Groups via the API of the Ubiquiti UniFi Controller

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroups -UnifiSite 'Contoso'

         Get a List Firewall Groups on Site 'Contoso' via the API of the Ubiquiti UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function

         .LINK
         Get-UniFiConfig

         .LINK
         Set-UniFiDefaultRequestHeader

         .LINK
         Set-UniFiDefaultRequestHeader
   #>
	
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )
	
   begin
   {
      # Cleanup
      $Session = $null
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)
			
         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/list/firewallgroup'
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
			
         Write-Verbose -Message 'Send the Request'
         $paramInvokeRestMethod = @{
            Method        = 'Get'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)

         # Remove the Body variable
         $JsonBody = $null

         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to get Firewall Groups' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Dump the Result
      $Session.data
		
      # Cleanup
      $Session = $null
   }
}

function Set-UnifiFirewallGroup
{
   <#
         .SYNOPSIS
         Get a given Firewall Group via the API of the UniFi Controller
	
         .DESCRIPTION
         Get a given Firewall Group via the API of the Ubiquiti UniFi Controller
	
         .PARAMETER UnfiFirewallGroup
         Unfi Firewall Group
	
         .PARAMETER UnifiCidrInput
         IPv4 or IPv6 input List (PSObject)
	
         .PARAMETER UnifiSite
         UniFi Site as configured. The default is: default
	
         .EXAMPLE
         PS C:\> Set-UnifiFirewallGroup -UnfiFirewallGroup 'Value1' -UnifiCidrInput $value2
		
         Get a given Firewall Group via the API of the Ubiquiti UniFi Controller
	
         .NOTES
         Initial version of the Ubiquiti UniFi Controller automation function
	
         .LINK
         Get-UnifiFirewallGroups
	
         .LINK
         Get-UnifiFirewallGroupBody
	
         .LINK
         Get-UniFiConfig
	
         .LINK
         Set-UniFiDefaultRequestHeader
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'Unfi Firewall Group')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroup')]
      [string]
      $UnfiFirewallGroup,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 2,
      HelpMessage = 'IPv4 or IPv6 input List')]
      [ValidateNotNullOrEmpty()]
      [Alias('CidrInput')]
      [psobject]
      $UnifiCidrInput,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [ValidateNotNullOrEmpty()]
      [Alias('Site')]
      [string]
      $UnifiSite = 'default'
   )
	
   begin
   {
      # Cleanup
      $TargetFirewallGroup = $null
      $Session = $null
		
      Write-Verbose -Message ('Check if {0} exists' -f $UnfiFirewallGroup)
      $TargetFirewallGroup = (Get-UnifiFirewallGroups | Where-Object -FilterScript {
            ($_.Name -eq $UnfiFirewallGroup)
      })
		
      if (-not $TargetFirewallGroup)
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
			
         Write-Error -Message ('Unable to find the Firewall Group {0}' -f $UnfiFirewallGroup) -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      Write-Verbose -Message ('{0} exists' -f $UnfiFirewallGroup)
		
      $UnfiFirewallGroupBody = (Get-UnifiFirewallGroupBody -UnfiFirewallGroup $TargetFirewallGroup -UnifiCidrInput $UnifiCidrInput)
   }
	
   process
   {
      try
      {
         Write-Verbose -Message 'Read the Config'
         $null = (Get-UniFiConfig)
			
         Write-Verbose -Message ('Certificate check - Should be {0}' -f $ApiSelfSignedCert)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = {
            $ApiSelfSignedCert
         }
			
         Write-Verbose -Message 'Set the API Call default Header'
         $null = (Set-UniFiDefaultRequestHeader)
			
         Write-Verbose -Message 'Create the Request URI'
         $ApiRequestUri = $ApiUri + 's/' + $UnifiSite + '/rest/firewallgroup/' + $TargetFirewallGroup._id
         Write-Verbose -Message ('URI: {0}' -f $ApiRequestUri)
			
         Write-Verbose -Message 'Send the Request'
         $paramInvokeRestMethod = @{
            Method        = 'Put'
            Uri           = $ApiRequestUri
            Headers       = $RestHeader
            Body          = $UnfiFirewallGroupBody
            ErrorAction   = 'SilentlyContinue'
            WarningAction = 'SilentlyContinue'
            WebSession    = $RestSession
         }
         $Session = (Invoke-RestMethod @paramInvokeRestMethod)
         Write-Verbose -Message ('Session Info: {0}' -f $Session)
      }
      catch
      {
         # Try to Logout
         $null = (Invoke-UniFiApiLogout)
			
         # Remove the Body variable
         $JsonBody = $null
			
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $_)
			
         # Error Message
         Write-Error -Message 'Unable to get Firewall Groups' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
      finally
      {
         # Reset the SSL Trust (make sure everything is back to default)
         [Net.ServicePointManager]::ServerCertificateValidationCallback = $null
      }
		
      # check result
      if ($Session.meta.rc -ne 'ok')
      {
         # Verbose stuff
         $Script:line = $_.InvocationInfo.ScriptLineNumber
         Write-Verbose -Message ('Error was in Line {0}' -f $line)
         Write-Verbose -Message ('Error was {0}' -f $Session.meta.rc)
			
         # Error Message
         Write-Error -Message 'Unable to Login' -ErrorAction Stop
			
         # Only here to catch a global ErrorAction overwrite
         break
      }
   }
	
   end
   {
      # Cleanup
      $Session = $null
   }
}
