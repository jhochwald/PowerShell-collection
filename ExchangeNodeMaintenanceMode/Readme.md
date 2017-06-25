# ExchangeNodeMaintenanceMode

Exchange Cluster Node Maintenance Mode Utilities

## Description

Exchange Cluster Node Maintenance Mode Utilities

## Introduction

Exchange Cluster Node Maintenance Mode Utilities, mostly used to apply updates and CU installation.
At thhe moment a two (2) node Cluster is supported.

## Requirements

Exchange 2013 SP1, or later. Alternative Exchange 2016 CU5, or later.

## Installation

Powershell Gallery (PS 5.0, Preferred method)
`install-module ExchangeNodeMaintenanceMode`

Manual Installation
`iex (New-Object Net.WebClient).DownloadString("https://raw.githubusercontent.com/jhochwald/PowerShell-collection/master/ExchangeNodeMaintenanceMode/Install.ps1")`

Or clone this repository to your local machine, extract, go to the .\releases\ExchangeNodeMaintenanceMode directory
and import the module to your session to test, but not install this module.

## Features

## Versions

1.0.0.0 - Initial Release
1.0.0.1 - Test Release
1.0.0.2 - Bugfix
1.0.0.3 - Test Release
1.0.0.4 - MD Help files are now deliverey
1.0.0.5 - Try to adopt a new build process
1.0.0.6 - Updateable help is now supported
1.0.0.7 - Fix an Issue with the GUID handling

## Contribute

Please feel free to contribute by opening new issues or providing pull requests.
For the best development experience, open this project as a folder in Visual Studio Code and ensure that the PowerShell extension is installed.

* [Visual Studio Code]
* [PowerShell Extension]

This module is tested with the PowerShell testing framework Pester. To run all tests, just start the included test script `.\Build.ps1 -test` or invoke Pester directly with the `Invoke-Pester` cmdlet in the tests directory.
The tests will automatically download the latest meta test from the claudiospizzi/PowerShellModuleBase repository.

## Other Information

**Author:** Joerg Hochwald

**Website:** https://github.com/jhochwald/PowerShell-collection
