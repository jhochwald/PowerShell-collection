---
external help file: ExchangeNodeMaintenanceMode-help.xml
online version: 
schema: 2.0.0
---

# Set-ExchangeNodeMaintenanceModeOn

## SYNOPSIS
Set the Exchange Node to Service

## SYNTAX

```
Set-ExchangeNodeMaintenanceModeOn [[-ComputerName] <String>]
```

## DESCRIPTION
Set the Exchange Node to Service

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
# Node is in Maintenance Mode
```

PS \> Set-ExchangeNodeMaintenanceModeOn
$false

### -------------------------- EXAMPLE 2 --------------------------
```
# Node is not in Maintenance Mode
```

PS \> Set-ExchangeNodeMaintenanceModeOn
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

## NOTES
TODO: Find a detection for the Workaround
TODO: Find a better solution for the certificate check issue

.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOff
Test-ExchangeNodeMaintenanceMode
Invoke-ApplyExchangeCumulativeUpdate

## RELATED LINKS

