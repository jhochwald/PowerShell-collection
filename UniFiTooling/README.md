# UniFiTooling

This is an beta version for an PowerShell Module for the Ubiquiti [UBNT SDN Controller API](https://unifi-sdn.ui.com/).



I started this module as an internal helper for many automated updates for my UniFi Security Gateway Firewall Rules and do a few other things (automated). I migrated everything into a regular module and published it as open source after using it for a while.



I plan to release versions that cover more and more functions. However, I need to refactor and document the code before doing so.

### Use Cases

You will find some demo use cases within the [UseCases](https://github.com/jhochwald/UniFiTooling/tree/master/release/UniFiTooling/UseCases) directory.

### Version

This document is based on UniFiTooling version 1.0.9

### Status

Beta version - Work still in progress.

*Please remember this before using it in production. You have been warned :)*

### Requirements

- PowerShell 5.1, or later. Desktop or Core.

  - *Tested on Windows with PowerShell Desktop Version 5.1*

  - *Tested on Windows with PowerShell Core Version 6.1.1*

  - *Tested on macOS with PowerShell Core Version 6.1.2*

  - *Tested on CentOS Linux release 7.6 with PowerShell Core Version 6.1.2*

- Ubiquiti [UBNT SDN Controller](https://unifi-sdn.ui.com/), Version 5.9.32

  - *This is the only tested version*

  - *Olders Ubiquiti [UBNT SDN Controller](https://unifi-sdn.ui.com/) Versions might work*

### Installation

There are several ways to get, install, and use this module.

#### With PowerShellGet

Install the module with PowerShellGet directly from the Powershell Gallery, this is the recommended method!

[![Powershell Gallery](https://img.shields.io/powershellgallery/vpre/UniFiTooling.svg)](https://www.powershellgallery.com/packages/UniFiTooling/) [![Powershell Gallery](https://img.shields.io/powershellgallery/dt/UniFiTooling.svg)](https://www.powershellgallery.com/packages/UniFiTooling/)

##### Just for you

```powershell
# Install the module for the Current User
# with PowerShellGet directly from the Powershell Gallery, Preferred method
# Run in a regular or administrative PowerShell prompt (Elevated).
PS C:\> Install-Module -Name 'UniFiTooling' -Scope CurrentUser
```

##### Systemwide

```powershell
# Install the module for the All Users
# with PowerShellGet directly from the Powershell Gallery, Preferred method.
# Run this in an administrative PowerShell prompt (Elevated).
PS C:\> Install-Module -Name 'UniFiTooling' -Scope AllUsers
```

#### Manual Installation (unsupported)

```powershell
PS C:\> iex (New-Object Net.WebClient).DownloadString("https://github.com/jhochwald/UniFiTooling/raw/master/Install.ps1")
```

#### Download from GitHub

You will find tha latest version in the [release page](https://github.com/jhochwald/UniFiTooling/releases) of the [GitHub repository](https://github.com/jhochwald/UniFiTooling/)

[![GitHub release](https://img.shields.io/github/release/jhochwald/UniFiTooling.svg)](https://github.com/jhochwald/UniFiTooling/releases/) [![GitHub release](https://img.shields.io/github/downloads/jhochwald/UniFiTooling/total.svg)](https://github.com/jhochwald/UniFiTooling/releases/) [![Download Size](https://badge-size.herokuapp.com/jhochwald/UniFiTooling/master/release/UniFiTooling-current.zip)](https://github.com/jhochwald/UniFiTooling/blob/master/release/UniFiTooling-current.zip)

#### Clone the repository

Or clone this [GitHub repository](https://github.com/jhochwald/UniFiTooling/) to your local machine, extract, go to the `.\releases\UniFiTooling` directory and import the module to your session to test, but not install this module.

### Get started

After installation of the Module, open a PowerShell Session (regular or elevated).

#### Config

```powershell
PS C:\> New-UniFiConfig -UniFiUsername 'user' -UniFiPassword 'password' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json'
```

Replace the values with your needs. Please also see the detailed description below.

#### Connect

Before using any command, you need to login to the controller.

```powershell
PS C:\> Invoke-UniFiApiLogin
```

In version 1.0.8, this will change: You no longer need to login/authenticate. All commands will do a check and login/authenticate when needed.

##### Troubleshooting

This will show you the real error-message:

```powershell
PS C:\> Invoke-UniFiApiLogin -verbose
```

#### Execute any command

Execute any command now...

```powershell
PS C:\> Get-UnifiNetworkList
```

#### Logoff

You should logoff after you are done! The session will timeout, but this will clean up everything for you.

```powershell
PS C:\> Invoke-UniFiApiLogout
```

### Feedback

Any Feedback is appreciated! Please open a [GitHub issue](https://github.com/jhochwald/UniFiTooling/issues/new/choose) as *Bug report* if you find something not working.

[![GitHub issues](https://img.shields.io/github/issues/jhochwald/UniFiTooling.svg)](https://GitHub.com/jhochwald/UniFiTooling/issues/) [![GitHub issues-closed](https://img.shields.io/github/issues-closed/jhochwald/UniFiTooling.svg)](https://GitHub.com/jhochwald/UniFiTooling/issues?q=is%3Aissue+is%3Aclosed)

### Contribute

Anything missing? Please open a [GitHub issue](https://github.com/jhochwald/UniFiTooling/issues/new/choose) as *Feature request*.
Suggest an idea for this Module will help to improve this module.

[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com) [![GitHub pull-requests](https://img.shields.io/github/issues-pr/jhochwald/UniFiTooling.svg)](https://GitHub.com/jhochwald/UniFiTooling/pull/) [![GitHub pull-requests closed](https://img.shields.io/github/issues-pr-closed/jhochwald/UniFiTooling.svg)](https://github.com/jhochwald/UniFiTooling/pulls?q=is%3Apr+is%3Aclosed)

Please read our [Contribution Guide](https://github.com/jhochwald/UniFiTooling/blob/master/CONTRIBUTING.md) and [Code of Conduct](https://github.com/jhochwald/UniFiTooling/blob/master/CODE_OF_CONDUCT.md).

### Note

Early beta version, use at your own risk! Not ready for showtime (production) yet...

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

### Authors

Joerg Hochwald - [http://hochwald.net](http://hochwald.net)

### Contributors

N.N. (could be you)

### Copyright

Copyright (c) 2019, [enabling Technology](http://www.enatec.io)
All rights reserved.

### License

BSD 3-Clause "New" or "Revised" License.
Here is the the [online](https://github.com/jhochwald/UniFiTooling/wiki/License) version of the License.

---

[![GitHub license](https://img.shields.io/github/license/jhochwald/UniFiTooling.svg)](https://github.com/jhochwald/UniFiTooling/blob/master/LICENSE) [![made-with-Markdown](https://img.shields.io/badge/Made%20with-Markdown-1f425f.svg)](http://commonmark.org) [![Open Source Love png1](https://badges.frapsoft.com/os/v1/open-source.png?v=103)](https://github.com/ellerbrock/open-source-badges/)
