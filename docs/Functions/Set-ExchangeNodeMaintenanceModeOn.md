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
Set-ExchangeNodeMaintenanceModeOn [[-ComputerName] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Enable the Maintenance Mode on a given the Exchange Node.

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

## NOTES
Perfect to apply Updates (or even CU installations).
Check the Update/CU, aou might need a
restart of the Server, so there might be no need to bring the Node back in Service.

.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOff
Test-ExchangeNodeMaintenanceMode
Invoke-ApplyExchangeCumulativeUpdate

## RELATED LINKS

