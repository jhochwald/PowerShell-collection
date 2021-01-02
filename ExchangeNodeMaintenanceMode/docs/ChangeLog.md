# Change Log

Project Site: [https://github.com/jhochwald/ExchangeNodeMaintenanceMode](https://github.com/jhochwald/ExchangeNodeMaintenanceMode)

## Version 1.0.0.1
- Initial release

## Version 1.0.0.2
- Internal Build

## Version 1.0.0.3
- Internal Build
- 
## Version 1.0.0.4
- Internal Build

## Version 1.0.0.5
- Internal Build

## Version 1.0.0.6
- Internal Build

## Version 1.0.0.7
- Internal Build

## Version 1.0.0.8
- Internal Build

## Version 1.0.0.9
- Internal Build

## Version 1.0.0.10
- Internal Build

## Version 1.0.0.11
- Internal Build

## Version 1.0.0.12
- Internal Build

## Version 1.0.0.13
- Internal Build

## Version 1.0.0.14
- Internal Build

## Version 1.0.0.15
- Update the Help of the Invoke-ApplyExchangeCumulativeUpdate command
- Extented: Invoke-ApplyExchangeCumulativeUpdate - SupportsShouldProcess and ConfirmImpact added
- Update the Docs (MD)
- Update (tweak) the build process.
- UMLangHandling execution is removed, mostly a reboot is needed.
- ADD: Get-ExchangeExecutionPolicy - Just a neat wrapper for Get-ExecutionPolicy
- ADD: Get-ExchangeAdminExecution - Just a neat function to check if we are elevated

## Version 1.0.0.16
- NEW: Restart-ExchangeClusterNode - Wrapper to initiate a clean reboot
- CHANGE: Invoke-ApplyExchangeCumulativeUpdate - Optimize
- CHANGE: Set-ExchangeNodeMaintenanceModeOn - Add SupportsShouldProcess
- CHANGE: Set-ExchangeNodeMaintenanceModeOff - Add SupportsShouldProcess

## Version 1.0.0.17
- CHANGE: PowerShell Gallery Icon
- WORKAROUND: GUID Handler (To mitigate an ModuleBuild issue)

## Version 1.0.0.18
- CHANGED: Change Date back to ISO (Internal)
- CHANGED: Framework modules (ModuleBuild, platyPS) to latest stable version
- CHANGED: Implement permanent Workaround from 1.0.0.16 and 1.0.0.17
