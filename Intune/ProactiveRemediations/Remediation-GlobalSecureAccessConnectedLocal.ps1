#requires -Version 5.0 -Modules DnsClient, NetTCPIP

<#
      .SYNOPSIS
      Remediation for Entra Global Secure Access (GSA) - Private Access automatic network detection
   
      .DESCRIPTION
      Remediation for Entra Global Secure Access (GSA) - Private Access automatic network detection
   
      .EXAMPLE
      PS C:\> .\Remediation-GlobalSecureAccessConnectedLocal.ps1

      .LINK
      https://github.com/KnudsenMorten/EntraGSA_InternalNetworkDetection_Performance/blob/main/EntraGSA_internal_network_intune_remediationscript.ps1

      .LINK
      https://mortenknudsen.net/?p=3090#EntraGSAv2

      .NOTES
      User must be allowed to set this!
      Please see: https://microsoft.github.io/GlobalSecureAccess/How-To/HardenWinGSA/#hiding-gsa-client-context-menu-options

      This is based on the idea of Morten Knudsen
      It is tested with the Global Secure Access client for Windows version 2.18.62
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param ()

begin
{
   <#
         # All the supported modes

         # Method #1 - DNSName-to-IP - Local DNS Name lookup - result should respond to IP addr
         # NOTE: Requires local DNS solution like Windows AD DNS, InfoBlox, Router DNS, etc.
         $Mode = "Resolve_DNSName-Validate_Against_IP"
         $Target  = "DC1.2linkit.local"
         $ExpectedResult   = "10.1.0.5"
         $FailoverTargetIP = "172.22.0.11"

         # Method #2A - IP-to-DNSName - IP address reverse lookup - result should respond to DNS hostname address - use specific DNS server
         # NOTE: This DNS domain cannot be inside Private Access tunnel. Must be an external zone used locally
         #       Reason: Entra Private Access treats any hosts names part of Private DNS-functionality as wildcards, so it will respond with an internal tunnel IP when client is running
         $Mode = "Ping_IP-Resolve-to-DNSName"
         $Target = "10.1.0.5"
         $ExpectedResult = "DC1.2linkit.local"
         $DNSServerIP   = "10.1.0.5"

         # Method #2B - IP-to-DNSName - IP address reverse lookup - result should respond to DNS hostname address - use DNS from IP/DHCP settings on client
         # NOTE: This DNS domain cannot be inside Private Access tunnel. Must be an external zone used locally
         #       Reason: Entra Private Access treats any hosts names part of Private DNS-functionality as wildcards, so it will respond with an internal tunnel IP when client is running
         $Mode = "Ping_IP-Resolve-to-DNSName"
         $Target = "10.1.0.5"
         $ExpectedResult = "DC1.2linkit.local"
         $DNSServerIP = $null

         # Method #3 - IP-to-MACAddr - Ping IP addr and validate MAC address matches the expected result
         # NOTE: Method can typically only be used when device is on same subnet as target IP device fx. router (switched network)
         #       This method can easily be extended into an array covering all local sites, but it must be manually maintained
         $Mode = "Ping_IP-Validate_MACAddr_Against_ARP_Cache"
         $Target  = "192.168.1.1"
         $ExpectedResult = "d2-21-f9-7e-82-86"
   #>
   
   # Put you chosen method here below
   [string]$Mode = 'Ping_IP-Validate_MACAddr_Against_ARP_Cache'
   [string]$Target  = '10.16.1.90'
   [string]$ExpectedResult = '24-5E-BE-6A-56-47'
   
   <#
         Minutes to pause between each run, 1 is a good value here.

         If $RerunTesting is set to $true, this will be ignored anyway!

         But this must be set anyway, to prevent any issues.
   #>
   [int]$RerunEveryMin = 1
   <#
         When it hits the number, it forces script to Exit 1.
         It must be less than 1 hr, as remediation job kicks off hourly
         Because each test will take a few seconds, I think 58 or 59 is fine
   #>
   [int]$RerunNumberBeforeExiting = 58
   <#
         If $true it wil force script to run every few seconds
         If $false it uses the minutes to pause value in $RerunEveyMin

         This is perfect for testing and if you want fast checks to be done.
         The pause (in seconds) can be changed within the script,
         the defaut is 10 seconds between each check.
         Please see the comment in the script!
   #>
   [bool]$RerunTesting = $false

   #############################################################################
   # Do not change anything below this line, until you know what you are doing
   #############################################################################
   
   # Registry Path
   [string]$RegPath = 'HKCU:\SOFTWARE\EntraGSA_NetworkDetection'
   # Registry values
   [string]$RegKey_LastRemediation = 'EntraGSA_RemediationScript_Last_Run'
   [string]$RegKey_SuspendRemediation = 'EntraGSA_SuspendNetworkDetectionRemediation'
   # Registry Path
   [string]$RegPathSuspendPrivateAccess = 'HKCU:\Software\Microsoft\Global Secure Access Client'
   <#
         This value (DWORD) can be:
         0 = Private Access is Active
         1 = Private Access is Suspended

         Source: https://microsoft.github.io/GlobalSecureAccess/How-To/HardenWinGSA/#disable-the-gsa-client-via-the-registry-key
   #>
   [string]$RegKeySuspendPrivateAccess = 'IsPrivateAccessDisabledByUser'
   [int]$RunFrequency = 1

   Write-Verbose -Message '--------------------------------------------------'
}

process
{
   # Now we start a loop
   while ($RunFrequency -le $RerunNumberBeforeExiting)
   {
      # Set the default, we asume we are not connected
      $LocalNetworkDetected = $false

      <#
            Here we check if the script should be suspended
            Typically caused by a rougue detection or user wants to manually override
      #>
      $paramGetItemProperty = @{
         Path        = $RegPath
         Name        = $RegKey_SuspendRemediation
         ErrorAction = 'SilentlyContinue'
      }
      $SuspendStatusKey = (Get-ItemProperty @paramGetItemProperty)
      $paramGetItemProperty = $null
      
      # Key found - checking value of it
      if ($SuspendStatusKey)
      {
         $paramGetItemPropertyValue = @{
            Path        = $RegPath
            Name        = $RegKey_SuspendRemediation
            ErrorAction = 'SilentlyContinue'
         }
         $SuspendStatusValue = (Get-ItemPropertyValue @paramGetItemPropertyValue)
         $paramGetItemPropertyValue = $null
      }
      
      if (($null -eq $SuspendStatusKey) -or ($SuspendStatusKey -eq '') -or ($SuspendStatusValue -eq 0))
      {
         # Initial check
         Write-Verbose -Message ('Script run frequency (loop): {0} / {1}' -f ($RunFrequency), ($RerunNumberBeforeExiting))
         Write-Verbose -Message ('Mode: {0}' -f ($Mode))
         Write-Verbose -Message ('Target: {0}' -f ($Target))

         # Checking DNS record
         $paramClearDnsClientCache = @{
            Confirm     = $false
            ErrorAction = 'SilentlyContinue'
         }
         $null = (Clear-DnsClientCache @paramClearDnsClientCache)
         $paramClearDnsClientCache = $null
         
         # Let us think about a switch here for future version
         if ($Mode -eq 'Resolve_DNSName-Validate_Against_IP')
         {
            # Set some defaults
            $LocalNetworkDetected = $false
            $DNSCheck = $null
            # Set some defaults
            $LocalNetworkDetected = $false
            $DNSCheck = $null
            
            # (1) Resolve_DNSName-Validate_Against_IP
            $FailoverActive = $false
            $paramResolveDnsName = @{
               Name        = $Target
               Type        = 'A'
               ErrorAction = 'SilentlyContinue'
            }
            $DNSCheck = $null
            $DNSCheck = (Resolve-DnsName @paramResolveDnsName)
            $paramResolveDnsName = $null
            
            if (($null -eq $DNSCheck) -or ($DNSCheck -eq ''))
            {
               $DNSCheck = [PSCustomObject]@{
                  IPAddress = 'NOT Found'
               }
               
               Write-Verbose -Message 'Failover-mode .... Doing a secondary ping test'
            }
            elseif ($DNSCheck.IPAddress -eq $ExpectedResult)
            {
               # Real IP try to test using ping
               $paramTestConnection = @{
                  ComputerName = $ExpectedResult
                  Count        = 3
                  Quiet        = $true
                  ErrorAction  = 'SilentlyContinue'
               }
               $PingCheck = $null
               $PingCheck = (Test-Connection @paramTestConnection)
               $paramTestConnection = $null
               $FailoverActive = $true
               
               if ($PingCheck)
               {
                  $LocalNetworkDetected = $true
               }
               else
               {
                  $LocalNetworkDetected = $false
               }
            }
            else
            {
               # Failover to try to test using ping
               $paramTestConnection = @{
                  ComputerName = $FailoverTargetIP
                  Count        = 3
                  Quiet        = $false
                  ErrorAction  = 'SilentlyContinue'
               }
               $PingCheck = $null
               $PingCheck = (Test-Connection @paramTestConnection)
               $paramTestConnection = $null
               
               if ($PingCheck.IPV4Address.IPAddressToString[1] -eq $FailoverTargetIP)
               {
                  $LocalNetworkDetected = $true
               }
               else
               {
                  $LocalNetworkDetected = $false
               }
            }
         }
         elseif ($Mode -eq 'Ping_IP-Resolve-to-DNSName')
         {
            # Set some defaults
            $LocalNetworkDetected = $false
            $DNSCheck = $null
            
            # (2) Ping_IP-Resolve-to-DNSName
            $paramTestConnection = @{
               ComputerName = $Target
               Count        = 3
               Quiet        = $true
               ErrorAction  = 'SilentlyContinue'
            }
            $PingCheck = $null
            $PingCheck = (Test-Connection @paramTestConnection)
            $paramTestConnection = $null
            
            if ($PingCheck) # True
            {
               $paramResolveDnsName = @{
                  Name        = $Target
                  Type        = 'PTR'
                  ErrorAction = 'SilentlyContinue'
               }
               
               if ($DNSServerIP)
               {
                  $paramResolveDnsName.Add('Server', $DNSServerIP)
               }
               
               $DNSCheck = (Resolve-DnsName @paramResolveDnsName)
               $paramResolveDnsName = $null
            }
            
            if (($null -eq $DNSCheck) -or ($DNSCheck -eq ''))
            {
               $DNSCheck = [PSCustomObject]@{
                  IPAddress = 'NOT Found'
               }
            }

            if ($DNSCheck.NameHost -eq $ExpectedResult)
            {
               $LocalNetworkDetected = $true
            }
            else
            {
               $LocalNetworkDetected = $false
            }
         }
         elseif ($Mode -eq 'Ping_IP-Validate_MACAddr_Against_ARP_Cache')
         {
            # (3) Ping_IP-Validate_MACAddr_Against_ARP_Cache

            # Set some defaults
            $MACAddr = 'NOT_FOUND'
            $LocalNetworkDetected = $false
            
            # Do some checks
            $paramTestConnection = @{
               ComputerName = $Target
               Count        = 3
               Quiet        = $true
               ErrorAction  = 'SilentlyContinue'
            }
            $DNSCheck = $null
            $DNSCheck = (Test-Connection @paramTestConnection)
            $paramTestConnection = $null
            
            if ($DNSCheck)
            {
               # Calm down and be patient, the ARP state will change from 'Probe' to something usefull
               Start-Sleep -Seconds 3

               $paramGetNetNeighbor = @{
                  IncludeAllCompartments = $true
                  AddressFamily          = 'IPv4'
                  ErrorAction            = 'SilentlyContinue'
               }
               $ARPCache = (Get-NetNeighbor @paramGetNetNeighbor)
               $paramGetNetNeighbor = $null
               
               if ($ARPCache)
               {
                  $ValidateARPCache = $ARPCache | Where-Object {
                     ($_.IPAddress -eq $Target)
                  }
                  
                  foreach ($Entry in $ValidateARPCache)
                  {
                     if ($Entry.IPAddress -eq $Target)
                     {
                        # Check the state, to prevent stale ARP entries
                        if ($Entry.State -eq 'Reachable')
                        {
                           $MACAddr = $Entry.LinkLayerAddress
                        }
                        else
                        {
                           $MACAddr = 'NOT_FOUND'
                        }
                     }
                  }
               }

               # Do the compare               
               if ($MACAddr -eq $ExpectedResult)
               {
                  $LocalNetworkDetected = $true
               }
               else
               {
                  $LocalNetworkDetected = $false
               }
            }
         }
         
         # Get the Status of the GSA Private access setting
         $SuspendPrivateAccessStatus = $null
         $SuspendPrivateAccessStatus = ((Get-ItemProperty -Path $RegPathSuspendPrivateAccess -Name $RegKeySuspendPrivateAccess -ErrorAction SilentlyContinue).$RegKeySuspendPrivateAccess)
         
         # Default is false, but we check the result above
         if (!(Test-Path -Path $RegPathSuspendPrivateAccess -ErrorAction SilentlyContinue))
         {
            $paramNewItem = @{
               Path          = $RegPathSuspendPrivateAccess
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'SilentlyContinue'
               WarningAction = 'SilentlyContinue'
            }
            $null = (New-Item @paramNewItem)
            $paramNewItem = $null
         }
         
         if ($LocalNetworkDetected)
         {
            # Internal network was detected
            Write-Verbose -Message 'Status: Computer ''is'' connected to internal network'

            if ($SuspendPrivateAccessStatus -ne 1)
            {
               Write-Verbose -Message 'Remediation: Entra Global Secure Access Private Access is ''not'' suspend'
               
               $paramNewItemProperty = @{
                  Path         = $RegPathSuspendPrivateAccess
                  Name         = $RegKeySuspendPrivateAccess
                  Value        = 1
                  PropertyType = 'DWord'
                  Force        = $true
                  Confirm      = $false
                  ErrorAction  = 'SilentlyContinue'
               }
               $null = (New-ItemProperty @paramNewItemProperty)
               $paramNewItemProperty = $null
               $paramClearDnsClientCache = @{
                  Confirm       = $false
                  ErrorAction   = 'SilentlyContinue'
                  WarningAction = 'SilentlyContinue'
               }
               $null = (Clear-DnsClientCache @paramClearDnsClientCache)
               $paramClearDnsClientCache = $null
            }
            else
            {
               Write-Verbose -Message 'Success: Entra Global Secure Access - Private Access ''is'' suspend'
            }
            
            Write-Verbose -Message 'Check: Internal network ''is'' detected and Entra Global Secure Access - Private Access ''is'' suspend'
         }
         elseif (!($LocalNetworkDetected))
         {
            # Internal network was NOT detected
            Write-Verbose -Message 'Status: Computer is ''not'' connected to internal network'

            if (!($SuspendPrivateAccessStatus -ne 1))
            {
               Write-Verbose -Message 'Remediation: Entra Global Secure Access - Private Access ''is'' suspend'

               $paramNewItemProperty = @{
                  Path         = $RegPathSuspendPrivateAccess
                  Name         = $RegKeySuspendPrivateAccess
                  Value        = 0
                  PropertyType = 'DWord'
                  Force        = $true
                  Confirm      = $false
                  ErrorAction  = 'SilentlyContinue'
               }
               $null = (New-ItemProperty @paramNewItemProperty)
               $paramNewItemProperty = $null

               $paramClearDnsClientCache = @{
                  Confirm       = $false
                  ErrorAction   = 'SilentlyContinue'
                  WarningAction = 'SilentlyContinue'
               }
               $null = (Clear-DnsClientCache @paramClearDnsClientCache)
               $paramClearDnsClientCache = $null
            }
            else
            {
               Write-Verbose -Message 'Success: Entra Global Secure Access - Private Access is ''not'' suspend'
            }

            Write-Verbose -Message 'Check: Internal network is ''not'' detected and Entra Global Secure Access - Private Access is ''not'' suspend'
         }
         
         $SuspendPrivateAccessStatus = $null
 
         # Create initial reg-path stucture in registry
         if (!(Test-Path -Path $RegPath))
         {
            $paramNewItem = @{
               Path          = $RegPath
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'SilentlyContinue'
               WarningAction = 'SilentlyContinue'
            }
            $null = (New-Item @paramNewItem)
            $paramNewItem = $null
         }
         
         # Set last run value in registry
         $paramNewItemProperty = @{
            Path         = $RegPath
            Name         = $RegKey_LastRemediation
            Value        = (Get-Date)
            PropertyType = 'STRING'
            Force        = $true
            Confirm      = $false
            ErrorAction  = 'SilentlyContinue'
         }
         $null = (New-ItemProperty @paramNewItemProperty)
         $paramNewItemProperty = $null
         
         # Loop & Wait: increase the $RunFrequency by +1
         [int]$RunFrequency = (1 + $RunFrequency)

         if ($RerunTesting -eq $true)
         {
            <#
                  You can set whatever you want here!
                  If you do the checks to fast, it might cause issues!
                  I had many issues ehen I use ARP checks, 10 seconds seems to be OK here!
            #>
            [int]$ReunTestingPause = 10
            Write-Verbose -Message ('Sleeping for {0} seconds' -f $ReunTestingPause)
            Write-Verbose -Message '--------------------------------------------------'
            
            Start-Sleep -Seconds $ReunTestingPause
         }
         else
         {
            # Transform minutes into seconds (for 'Start-Sleep')
            [int]$SleepSeconds = ($RerunEveryMin * 60)
            Write-Verbose -Message ('Sleeping for {0} minute(s)' -f ($RerunEveryMin))
            Write-Verbose -Message '--------------------------------------------------'
            
            Start-Sleep -Seconds $SleepSeconds
         }
      }
      else
      {
         Write-Verbose -Message 'Suspending script as suspend-key was detected .... exiting script!'
         exit 0
      }
   }
}

end
{
   # Tell Intune script has terminated succesfully, when it has reached the rerun-number
   exit 0
}
