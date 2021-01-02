---
external help file: ExchangeNodeMaintenanceMode-help.xml
online version: 
schema: 2.0.0
---

# Restart-ExchangeClusterNode

## SYNOPSIS
Wrapper to initiate a clean reboot

## SYNTAX

```
Restart-ExchangeClusterNode [[-ComputerName] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
This function is a neat wrapper to initiate a clean reboot of a given Exchange Cluster Node.
Brings the Exchange Cluster Node in Maintenance Mode and reboots it.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Restart-ExchangeClusterNode
```

## PARAMETERS

### -ComputerName
Name of the Exchange Node.
Default is the local system.

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
Wrapper to initiate a clean reboot

## RELATED LINKS

