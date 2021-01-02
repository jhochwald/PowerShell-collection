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
Set-ExchangeNodeMaintenanceModeOff [[-ComputerName] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Disable the Maintenance Mode on a given the Exchange Node.

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### System.Boolean

## NOTES
If you installed an update (or CU), you might need a reboot anyway.

.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOn
Test-ExchangeNodeMaintenanceMode
Invoke-ApplyExchangeCumulativeUpdate

## RELATED LINKS

