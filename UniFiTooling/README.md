# UniFiTooling

### SHORT DESCRIPTION	

Ubiquiti UniFi Security Gateway automation via the API of the Ubiquiti UniFi Controller
	
### LONG DESCRIPTION
Ubiquiti UniFi Security Gateway automation via the API of the Ubiquiti UniFi Controller
	
### NOTE
Early beta version

### EXAMPLES

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

### Author

Joerg Hochwald - [http://hochwald.net](http://hochwald.net)

### Copyright

Copyright (c) 2018, [enabling Technology](http://www.enatec.io)
All rights reserved.

### License

BSD 3-Clause "New" or "Revised" License. - [Online](https://github.com/jhochwald/PowerShell-collection/blob/master/LICENSE)

### KEYWORDS

UniFi, API, Automation, Ubiquiti,USG,RESTful
	
### SEE ALSO

* Get-UniFiConfig
* Get-UniFiCredentials
* Invoke-UniFiApiLogin
* Set-IgnoreSelfSignedCerts
* Set-UniFiDefaultRequestHeader
