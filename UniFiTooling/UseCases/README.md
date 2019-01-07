# UniFiTooling Sample Use Cases

This folder contains a few sample use cases for the UniFiTooling tooling.

## UpdateUniFiVpnPeerIP.ps1

Update the Peer address info on a given Network Object in the Controller.
This can be handy when the external IP adresses change (e.g. with DSK in Germany and others).

### Usage

```powershell
.\UpdateUniFiVpnPeerIP.ps1 -VPN2Update 'JoshAtHomeVpn' -NewPeerIp 10.10.10.10
```

Update the Peer IP of the Network 'JoshAtHomeVpn' to 10.10.10.10

#### Note

Only IPv4 is supported as far as I know.

