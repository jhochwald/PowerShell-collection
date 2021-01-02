#requires -Version 3.0 -Modules UniFiTooling

<#
      .SYNOPSIS
      Update a VPN PeerIp for a given UniFi Network
	
      .DESCRIPTION
      Update a VPN PeerIp for a given UniFi Network via the API of the UniFi Controller
	
      .PARAMETER VPN2Update
      Name of the UniFi VPN Network
	
      .PARAMETER NewPeerIp
      New IP address of the VPN peer (Remote)
      IPv4 address onyl, the Controller rejects any other format.
	
      .EXAMPLE
      PS C:\> .\UpdateUniFiVpnPeerIP.ps1 -VPN2Update 'JoshAtHomeVpn' -NewPeerIp 10.10.10.10

      Update the Peer IP of the Network 'JoshAtHomeVpn' to 10.10.10.10
	
      .NOTES
      Just a use case demo
      
      Requires the UniFiTooling module version 1.0.3, or later
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([bool])]
param
(
   [Parameter(Mandatory,
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1,
   HelpMessage = 'Name of the UniFi VPN Network')]
   [ValidateNotNullOrEmpty()]
   [string]
   $VPN2Update,
   [Parameter(Mandatory,
         HelpMessage = 'New IP address of the VPN peer (Remote)',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName,
   Position = 2)]
   [ValidateNotNullOrEmpty()]
   [ipaddress]
   $NewPeerIp
)

begin
{
   # Login
   $null = (Invoke-UniFiApiLogin)
   
   # Put the input to a new variable
   # I use [ipaddress] above and let PowerShell do the input checks, because the Controlelr is a bit picky with the format
   $NewPeerIp2 = $NewPeerIp.IPAddressToString
}

process
{
   # Get all UniFi Networks and filter based on the input above
   $UnifiNetwork = (((Get-UnifiNetworkList) | Where-Object -FilterScript {
            ($_.Name -eq $VPN2Update)
   })._id)
	
   # Get the details of the network we found
   $UnifiNetworkDetails = (Get-UnifiNetworkDetails -UnifiNetwork $UnifiNetwork)

   # Replace the Peer IP in the object
   $UnifiNetworkDetails.ipsec_peer_ip = $NewPeerIp2

   # Create a new Request Body
   $paramConvertToJson = @{
      InputObject   = $UnifiNetworkDetails
      Depth         = 5
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   $UnifiNetworkDetailsJson = (ConvertTo-Json @paramConvertToJson)

   # Update the VPN network
   $null = (Set-UnifiNetworkDetails -UnifiNetwork $UnifiNetwork -UniFiBody $UnifiNetworkDetailsJson)
	
   # Get the details of the network again
   $NewPeerIpUniFi = ((Get-UnifiNetworkDetails -UnifiNetwork $UnifiNetwork).ipsec_peer_ip)
	
   # Compare the input with the latest info on the UniFi Controller
   if ($NewPeerIpUniFi -ne $NewPeerIp2)
   {
      Write-Warning -Message ('Peer address is {0} but it should be {1}' -f $NewPeerIpUniFi, $NewPeerIp2)

      $false
   }
   else
   {
      $true
   }
}

end
{
   # Logoff
   $null = (Invoke-UniFiApiLogout)
}


