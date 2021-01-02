#region CHANGELOG
<#
      Version: 1.0.11 - 2019-02-01

      Added
      - Get-UnifiHourlySiteStats - Get horly statistics for a complete UniFi Site
      - Get-UnifiDailySiteStats - Get daily statistics for a complete UniFi Site
      - Get-Unifi5minutesSiteStats - Get statistics in 5 minute segments for a complete UniFi Site
      - Get-Unifi5minutesGatewayStats - Get statistics in 5 minute segments for the USG (UniFi Secure Gateway)
      - Get-UnifiHourlyGatewayStats - Get hourly statistics for the USG (UniFi Secure Gateway)
      - Get-UnifiDailyGatewayStats - Get daily statistics for the USG (UniFi Secure Gateway)
      - Get-UnifiDailyClientStats - Get daily user/client statistics for a given user/client
      - Get-UnifiHourlyClientStats - Get hourly user/client statistics for a given user/client
      - Get-Unifi5minutesClientStats - Get user/client statistics in 5 minute segments for a given client
      - Get-UnifiDailyApStats - Get daily stats for all or just one access points in a given UniFi site
      - Get-UnifiHourlyApStats - Get hourly stats for all or just one access points in a given UniFi site
      - Get-Unifi5minutesApStats - Get the stats in 5 minute segments for all or just one access points in a given UniFi site
      - ConvertTo-UniFiValidMacAddress - Helper to check and make sure we have the right format (private function)
      - Get-CallerPreference - Add private meta function
      - CODEOWNERS - Add GitHub code owners feature file
      - Set-UnifiClientDeviceNote - Add/modify/remove a client-device note
      - Set-UnifiClientDeviceName - Add/modify/remove a client device name
      - New-UnifiClientDevice - Create a new user/client-device (unfinished beta)

      Changed
      - New-UnifiClientDevice now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Invoke-UnifiUnblockClient now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Invoke-UnifiUnauthorizeGuest now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Invoke-UnifiReconnectClient now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Invoke-UnifiForgetClient now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Invoke-UnifiBlockClient now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Invoke-UnifiAuthorizeGuest now use ConvertTo-UniFiValidMacAddress to check and make sure we have the right format
      - Get-CallerPreference - Implemented private meta function usage to all (public/private) functions

      Removed
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.
      - Add-HostsEntry should never be a part of this module. I just use them for some internal tests.
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.

      Fixed
      - Fixed the Get-CallerPreference usage


      Version: 1.0.10 - 2019-01-23

      Deprecated
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.
      - Get-HostsFile should never be a part of this module. I just use them for some internal tests.


      Version: 1.0.9 - 2019-01-20

      Added
      - Invoke-UnifiForgetClient - Forget one or more client devices via the API of the UniFi Controller
      - Invoke-UnifiUnblockClient - Unblock a client device via the API of the UniFi Controller
      - Invoke-UnifiBlockClient - Block a client device via the API of the UniFi Controller
      - Invoke-UnifiReconnectClient - Reconnect a client device via the API of the UniFi Controller
      - Invoke-UnifiUnauthorizeGuest - Unauthorize a client device via the API of the UniFi Controller
      - Invoke-UnifiAuthorizeGuest - Authorize a client device via the API of the UniFi Controller
      - Get-UnifiSpeedTestResult has now a -last parameter to get only the latest result

      Changed
      - Change some links to the GitHub Wiki
      - Change the Verbose output (Detailed connection details)
      - Refactored a lot of code.


      Version: 1.0.8 - 2019-01-19

      Added
      - Get-UnifiSpeedTestResult - Get the UniFi Security Gateway (USG) Speed Test results
      - Add-HostsEntry - Add a single Hosts Entry to the HOSTS File (Helper)
      - Remove-HostsEntry - Removes a single Hosts Entry from the HOSTS File (Helper)
      - Get-HostsFile - Print the HOSTS File in a more clean format (Helper)
      - ConvertFrom-UnixTimeStamp - Converts a Timestamp (Epochdate) into Datetime (Helper)
      - ConvertTo-UnixTimeStamp - ConvertTo-UnixTimeStamp (Helper)
      - Get-UniFiIsAlive - Use a simple API call to see if the session is alive (internal not exported function)

      Changed
      - Refactored some of the code that handles all errors.
      - All commands now use Get-UniFiIsAlive internally. That should make it easier for new users.
      - Get-UnifiSpeedTestResult has now filtering and returns values human readable


      Version: 1.0.7 - 2019-01-14

      Added
      - Add License.md, a Markdown version of LICENSE
      - Editor Config
      - Git Attributes File
      - Get-UnifiFirewallGroupDetails - Related to #10

      Changed
      - Moved Get-UnifiFirewallGroupBody from Public to Private (No longer exported as command)
      - Add -name parameter to Get-UnifiNetworkDetails - Related to #9
      - Get-UnifiNetworkDetails: For the parameter -UnifiNetworkName an ID (Network_id) must be used, necessary to make it a non breaking change
      - Get-UnifiNetworkDetails: -UnifiNetworkName is now a legacy alias, necessary to make it a non breaking change
      - Add -Id parameter to Get-UnifiNetworkDetails. This replaced the -UnifiNetworkName parameter - Related to #9
      - Add Multi valued inputs to Get-UnifiNetworkDetails
      - Git Ignore extended
      - Markdown Documents tweaked (Header)

      Fixed
      - Found the following issue: Even if an obejct is not found (e.g. network) the UniFi API returns OK (200) with null bytes in Data. That is OK, but we need a workaround. Added the Workaround to Get-UnifiFirewallGroupDetails and Get-UnifiNetworkDetails for testing.
      - Position numbers corrected (Now starts with 0 instead off 1)


      Version: 1.0.6 - 2019-01-13

      Added
      - New function New-UniFiConfig - #1
      - CHANGELOG.md (this file) is back
      - Set $ProgressPreference to 'SilentlyContinue' - #7


      Version: 1.0.5 - 2019-01-12

      Changed
      - Invoke-UniFiCidrWorkaround now has the parameter -6 to handle IPv6 CIDR data - #5
      - Describe the config.json handling #2
      - Changed the Build System - #3
      - Samples optimized
      - Tweak the build system

      Removed
      - Invoke-UniFiCidrWorkaroundV6 is now part of Invoke-UniFiCidrWorkaround - #5


      Version: 1.0.4 - 2019-01-08

      Changed
      - Samples optimized
      - Tweak the build system


      Version: 1.0.3 - 2019-01-07

      Added
      - Sample: UpdateUniFiVpnPeerIP - Update a VPN PeerIp for a given UniFi Network (IPSec VPN with dynamic IP)
      - Sample: UpdateUniFiWithLatestExchangeOnlineEndpoints - Update existing UniFi Firewall Groups with the latest Exchange Online Endpoints.

      Fixed
      - Debug output removed


      Version: 1.0.2 - 2019-01-07

      Changed
      - Internal Build Process: Initial internal release


      Version: 1.0.1 - 2019-01-07

      Added
      - Invoke-UniFiCidrWorkaround for CIDR handling
      - Invoke-UniFiCidrWorkaroundV6 for CIDR handling


      Version: 1.0.0 - 2019-01-01

      Added
      - config.json instead of hardcoded configuration
      - SYNOPSIS for all functions
      - XML/MAML Documentation
      - Samples

      Changed
      - Removed all internal systems (hardcoded for internal use)


      Version: 0.9.1 - 2019-01-01

      Deprecated
      - Invoke-UBNT* is now Invoke-UniFi*


      Version: 0.9.0 - 2019-01-01

      Added
      - Controller Parameter (URI) in the Header of the PS1 File

      Changed
      - Migrated Invoke-UBNTApiLogin and Invoke-UBNTApiLogout from Invoke-WebRequest to Invoke-RestMethod
      - Better Session handling for Invoke-UBNTApiRequest


      Version: 0.8.0 - 2019-01-01

      Security
      - Removed Hard coded credentials from the code


      Version: 0.7.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release


      Version: 0.6.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release


      Version: 0.5.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release


      Version: 0.4.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release


      Version: 0.3.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release


      Version: 0.2.0 - 2019-01-01

      Changed
      - Internal Build Process: Initial internal release


      Version: 0.1.0 - 2019-01-01

      Added
      - Invoke-UBNTApiLogout - With harcoded Controller info
      - Invoke-UBNTApiRequest - Universal Invoke-RestMethod wrapper, tweaked for UBNT Equipment
      - Invoke-UBNTApiLogin - With harcoded credentials and Controller info
#>
#endregion CHANGELOG

#region LICENSE
<#
      Copyright (c) 2019, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

      By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The developer of this Software is NOT sponsored by or affiliated with Ubiquiti Networks, Inc (UBNT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - The Software is not supported by Ubiquiti Networks, Inc (UBNT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER

$ThisModuleLoaded = $true
