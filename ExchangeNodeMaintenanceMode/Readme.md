# ExchangeNodeMaintenanceMode

i no longer run Exchange on Premises.

Exchange Cluster Node Maintenance Mode Utilities

## Description

Exchange Cluster Node Maintenance Mode Utilities

## Introduction

Apply an Exchange Cumulative Update, with the optional AD and Schema updates, and additional UM language packs update.

Please read the Release Notes from Microsoft carefully, some updates need an Active Directory schema and/or Active Directory and/or Active Directory domain updates.
If this is the case, please use the "Prepare" Switch on ONE Node!
Nevertheless, please keep in mind, that you do NOT need to run the command with this Switch more than once. However, even if, the Switch will not harm in any kind, it is just a waste of time, and the installation will take longer.

## Requirements

PowerShell 5.0, or later.
Windows (Will not work on MacOS or Linux, at least not yet).
Exchange 2013 SP1, or later, or Exchange 2016 CU5, or later (PowerShell Module must be installed)

## Installation

Powershell Gallery (PS 5.0, Preferred method)
`install-module ExchangeNodeMaintenanceMode`

Manual Installation
`iex (New-Object Net.WebClient).DownloadString("https://github.com/jhochwald/ExchangeNodeMaintenanceMode/raw/master/Install.ps1")`

Or clone this repository to your local machine, extract, go to the .\releases\ExchangeNodeMaintenanceMode directory
and import the module to your session to test, but not install this module.

## Features

- Get-ExchangeAdminExecution
- Get-ExchangeExecutionPolicy
- Invoke-ApplyExchangeCumulativeUpdate
- Invoke-Exchange2016Workaround
- Set-ExchangeNodeMaintenanceModeOff
- Set-ExchangeNodeMaintenanceModeOn
- Test-ExchangeNodeMaintenanceMode
- Restart-ExchangeClusterNode

## Latest Version

### Version 1.0.0.18
- CHANGED: Change Date back to ISO (Internal)
- CHANGED: Framework modules (ModuleBuild, platyPS) to latest stable version
- CHANGED: Implement permanent Workaround from 1.0.0.16 and 1.0.0.17

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual
Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code]
* [PowerShell Extension]

This module is tested with the PowerShell testing framework Pester. To run all
tests, just start the included test script `.\Build.ps1 -test` or invoke Pester
directly with the `Invoke-Pester` cmdlet in the tests directory. The tests will automatically download
the latest meta test from the claudiospizzi/PowerShellModuleBase repository.

## Other Information

**Author:** Joerg Hochwald

**Website:** https://github.com/jhochwald/ExchangeNodeMaintenanceMode
