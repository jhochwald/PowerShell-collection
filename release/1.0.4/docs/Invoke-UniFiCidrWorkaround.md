---
external help file: UniFiTooling-help.xml
Module Name: UniFiTooling
online version:
schema: 2.0.0
---

# Invoke-UniFiCidrWorkaround

## SYNOPSIS
IPv4 CIDR Workaround for UBNT USG Firewall Rules

## SYNTAX

```
Invoke-UniFiCidrWorkaround [-CidrList] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
IPv4 CIDR Workaround for UBNT USG Firewall Rules (Single IPv4 has to be without /32)

## EXAMPLES

### EXAMPLE 1
```
Invoke-UniFiCidrWorkaround -CidrList $value1
```

IPv4 CIDR Workaround for UBNT USG Firewall Rules

### EXAMPLE 2
```
$value1 | Invoke-UniFiCidrWorkaround
```

IPv4 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

## PARAMETERS

### -CidrList
Existing CIDR List Object

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: UniFiCidrList

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
This is an internal helper function only

## RELATED LINKS

[Invoke-UniFiCidrWorkaroundV6]()

