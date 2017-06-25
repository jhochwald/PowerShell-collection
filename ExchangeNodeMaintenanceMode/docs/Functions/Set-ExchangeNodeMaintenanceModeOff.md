---
external help file: ExchangeNodeMaintenanceMode-help.xml
online version: 
schema: 2.0.0
---

# Set-ExchangeNodeMaintenanceModeOff

## SYNOPSIS
Return Exchange Node to normal operation

## SYNTAX

```
Set-ExchangeNodeMaintenanceModeOff [[-ComputerName] <String>]
```

## DESCRIPTION
Return Exchange Node to normal operation

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
# Enable normal operations
```

PS \> Set-ExchangeNodeMaintenanceModeOff
$true

### -------------------------- EXAMPLE 2 --------------------------
```
# Fails to enable noprmal operations
```

PS \> Set-ExchangeNodeMaintenanceModeOff
$false

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
.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOn
Test-ExchangeNodeMaintenanceMode
Invoke-ApplyExchangeCumulativeUpdate

## RELATED LINKS

