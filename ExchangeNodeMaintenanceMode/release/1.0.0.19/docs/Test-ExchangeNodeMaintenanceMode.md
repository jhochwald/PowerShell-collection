---
external help file: ExchangeNodeMaintenanceMode-help.xml
online version: 
schema: 2.0.0
---

# Test-ExchangeNodeMaintenanceMode

## SYNOPSIS
Check if the exchange node is in maintenance mode

## SYNTAX

```
Test-ExchangeNodeMaintenanceMode [[-ComputerName] <String>]
```

## DESCRIPTION
Check if the exchange node is in maintenance mode

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
# Given node is in normal operation mode
```

PS \> Test-ExchangeNodeMaintenanceMode
$false

### -------------------------- EXAMPLE 2 --------------------------
```
# Given node is in maintenance mode
```

PS \> Test-ExchangeNodeMaintenanceMode
$true

## PARAMETERS

### -ComputerName
Name of the Exchange Node, default is local system

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: $env:COMPUTERNAME
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES
TODO: The certificate handler is not perfect.
Find a betetr solution!
TODO: Need a few more checks.

.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOn
Set-ExchangeNodeMaintenanceModeOff
Invoke-ApplyExchangeCumulativeUpdate

## RELATED LINKS

