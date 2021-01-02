# ExchangeNodeMaintenanceMode
Exchange Cluster Node Maintenance Mode Utilities

Project Site: [https://github.com/jhochwald/ExchangeNodeMaintenanceMode](https://github.com/jhochwald/ExchangeNodeMaintenanceMode)

## What is ExchangeNodeMaintenanceMode?

Apply an Exchange Cumulative Update, with the optional AD and Schema updates, and additional UM language packs update.Please read the Release Notes from Microsoft carefully, some updates need an Active Directory schema and/or Active Directory and/or Active Directory domain updates.If this is the case, please use the "Prepare" Switch on ONE Node!
Nevertheless, please keep in mind, that you do NOT need to run the command with this Switch more than once. However, even if, the Switch will not harm in any kind, it is just a waste of time, and the installation will take longer.

## Why use the ExchangeNodeMaintenanceMode Module?

Makes the life of an exchange Admin a bit easier by automate some of the processes that needs to be done during the installation of updates!

### Features

Put the node in MaintenanceMode, restore the rgular mode, Wrapper to install a CU for Exchange.

## Installation

ExchangeNodeMaintenanceMode is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/ExchangeNodeMaintenanceMode/).

To Inspect:
```powershell
Save-Module -Name ExchangeNodeMaintenanceMode -Path <path>
```

To install:
```powershell
Install-Module -Name ExchangeNodeMaintenanceMode -Scope CurrentUser
```

## Contributing
[https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/Contributing.md](https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/Contributing.md)

## Release Notes
[https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/ReleaseNotes.md](https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/ReleaseNotes.md)

## Change Log
[https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/ChangeLog.md](https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/ChangeLog.md)

## Acknowledgements
[https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/Acknowledgements.md](https://github.com/jhochwald/ExchangeNodeMaintenanceMode/docs/Acknowledgements.md)

