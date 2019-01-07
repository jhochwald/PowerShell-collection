# UniFiTooling Sample Use Cases

This folder contains a few sample use cases for the UniFiTooling tooling.

## UpdateUniFiVpnPeerIP.ps1

Update the Peer address info on a given Network Object in the Controller.
This can be handy when the external IP adresses change (e.g. with DSK in Germany and others).

### Usage

```powershell
.\UpdateUniFiVpnPeerIP.ps1 -VPN2Update 'JoshAtHomeVpn' -NewPeerIp 10.10.10.10
```

*Update the Peer IP of the Network 'JoshAtHomeVpn' to 10.10.10.10*

#### Note

Only IPv4 is supported as far as I know.

## UpdateUniFiWithLatestExchangeOnlineEndpoints.ps1

Update existing UniFi Firewall Groups with the latest Exchange Online Endpoints.
This script supports IPv4 and IPv6.

### Usage

```powershell
.\UpdateUniFiWithLatestExchangeOnlineEndpoints.ps1
```

*Update the UniFi with the latest Exchange Online Endpoints*

### Note

This script updates the following USG Firewall Groups:

- ExchangeOnline-Sumission-IPv6
- ExchangeOnline-Sumission-IPv4
- ExchangeOnline-SMTP-IPv6
- ExchangeOnline-SMTP-IPv4
    
The Groups are hardcoded in this sample script!
    
The script use my [Get-Office365Endpoints](https://hochwald.net/powershell-get-the-office-365-endpoint-information-from-microsoft/) to get the latest Exchange Online Endpoints from Microsoft.
