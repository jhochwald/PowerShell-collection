# UniFiTooling

This is an early beta version for an PowerShell Module for the Ubiquiti UniFi Controller API.

An sample use case is coming soon. This sample script is doing the following:
Get the latest Office 365 Endpoint Information for Exchange Online via my own `Get-Office365Endpoints` function and modifies 4 existing UniFi Security Gateway Firewall Rules.

I use this script daily to update my own UniFi Security Gateway Firewalls (on two sites) with the latest Office 365 Endpoint Information for Exchange Online. I just have to clean up some of the code and do some more tests before publish it here.

I use this module for many automated updates for my UniFi Security Gateway Firewall Rules.

### Feedback

Any Feedback is appreciated! Please open a [GitHub issue](https://github.com/jhochwald/PowerShell-collection/issues/new/choose) as *Bug report* if you find something not working.

### Contribute

Anything missing? Please open a [GitHub issue](https://github.com/jhochwald/PowerShell-collection/issues/new/choose) as *Feature request*. Suggest an idea for this Module will help to improve this module.

### Description

PowerShell Module for Ubiquiti UniFi Security Gateway automation via the API of the Ubiquiti UniFi Controller

### Note

Early beta version, use at your own risk!

### Config

Keep this file in a secure place, especially in a shared environment. It contains the credentials (Yes, username and password) of your UniFi Admin User in plain text (human readable).

Here is a sample configuration:

```json
{
   "Login": {
      "Username": "adminuser",
      "Password": "AdminPassword"
   },
   "protocol": "https",
   "SelfSignedCert": true,
   "Hostname": "unifi.contoso.com",
   "Port": 443
}
```

#### Username

The login of a UniFi User with admin rights

#### Password

The password for the user given above. It is clear text for now. I know... But the Ubiquiti UniFi Controller seems to understand plain text only.

I plan to use a hashed and/or encryted version for a future version. But during the runtime, it is still as human readable clear text in memory and the `Invoke-UniFiApiLogin` furthermore, sends it as human readable clear text information within a JSON formatted body.

#### protocol

Valid is `http` and `https`. Please note: `http` is untested and it might not even work!

#### SelfSignedCert

If you use a self signed certificate and/or a certificate from an untrusted CA, you might want to use `true` here.
This is a Bool, but only `true` or `false` for now. I use this directly in PowerShell.

Please note: I can be dangerous to trust a certificate without checking it! I think it is OK to do within an Intranet, but I would avoid doing it over the public Internet! Especially with the `Invoke-UniFiApiLogin` command, because this will send the Credentials (Yes, username and password) of your UniFi Admin User in clear text in a JSON based body. If this is intercepted you might be in danger!

#### Hostname

The Ubiquiti UniFi Controller you want to use. You can use a Fully-Qualified Host Name (FQHN) or an IP address. Please note that your certificate must match the name and/or IP address as SAN name. Otherwise you might need to set the `SelfSignedCert` to `true`.

#### Port

The port number that you have configured on your Ubiquiti UniFi Controller.

### Examples

##### IPv4 CIDR Workaround for UBNT USG Firewall Rules

```powershell
# IPv4 CIDR Workaround for UBNT USG Firewall Rules
PS C:\> Invoke-UniFiCidrWorkaround -CidrList $value1
```

##### IPv6 CIDR Workaround for UBNT USG Firewall Rules

```powershell
# IPv6 CIDR Workaround for UBNT USG Firewall Rules
PS C:\> Invoke-UniFiCidrWorkaroundV6 -CidrList $value1
```

##### Build a Body for Set-UnifiFirewallGroup call

```powershell
# Build a Body for Set-UnifiFirewallGroup call
PS C:\> Get-UnifiFirewallGroupBody -UnfiFirewallGroup $value1 -UnifiCidrInput $value2
```

##### Set the default Header for all UniFi Requests

```powershell
# Set the default Header for all UniFi Requests
PS C:\> Set-UniFiDefaultRequestHeader
```

##### Read the UniFi config file

```powershell
# Read the UniFi config file
PS C:\> Get-UniFiConfig
```

##### Read the API Credentials from the UniFi config file

```powershell
# Read the API Credentials from the UniFi config file
PS C:\> Get-UniFiCredentials
```

##### Login to API of the Ubiquiti UniFi Controller

```powershell
# Login to API of the Ubiquiti UniFi Controller
PS C:\> Invoke-UniFiApiLogin
```

##### Logout from the API of the Ubiquiti UniFi Controller

```powershell
# Logout from the API of the Ubiquiti UniFi Controller
PS C:\> Invoke-UniFiApiLogout
```

##### Get a List Firewall Groups on Site 'Contoso' via the API of the Ubiquiti UniFi Controller

```powershell
# Get a List Firewall Groups on Site 'Contoso' via the API of the Ubiquiti UniFi Controller
PS C:\> Get-UnifiFirewallGroups -UnifiSite 'Contoso'
```

##### Get a given Firewall Group via the API of the Ubiquiti UniFi Controller

```powershell
# Get a given Firewall Group via the API of the Ubiquiti UniFi Controller
PS C:\> Set-UnifiFirewallGroup -UnfiFirewallGroup 'Value1' -UnifiCidrInput $value2
```

### Authors

Joerg Hochwald - [http://hochwald.net](http://hochwald.net)

### Contributors

N.N. (could be you)

### Copyright

Copyright (c) 2018, [enabling Technology](http://www.enatec.io)
All rights reserved.

### License

BSD 3-Clause "New" or "Revised" License. - [Online](https://github.com/jhochwald/PowerShell-collection/blob/master/LICENSE)

### Keywords

UniFi, API, Automation, Ubiquiti,USG, RESTful, ubiquiti-unifi-controller, unifi-controller
