---
author: Joerg Hochwald
category: UNIFITOOLING
external help file: UniFiTooling-help.xml
layout: post
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/raw/master/docs/Invoke-UniFiCidrWorkaround.md
schema: 2.0.0
tags: OnlineHelp PowerShell
timestamp: 2019-01-13
title: Invoke-UniFiCidrWorkaround
---

# Invoke-UniFiCidrWorkaround

## SYNOPSIS
IPv4 and IPv6 CIDR Workaround for UBNT USG Firewall Rules

## SYNTAX

```
Invoke-UniFiCidrWorkaround [-CidrList] <PSObject> [-6] [<CommonParameters>]
```

## DESCRIPTION
IPv4 and IPv6 CIDR Workaround for UBNT USG Firewall Rules (Single IPv4 has to be without /32 OR single IPv6 has to be without /128)

## EXAMPLES

### EXAMPLE 1
```
Invoke-UniFiCidrWorkaround -CidrList $value1
```

IPv4 CIDR Workaround for UBNT USG Firewall Rules

### EXAMPLE 2
```
Invoke-UniFiCidrWorkaround -6 -CidrList $value1
```

IPv6 CIDR Workaround for UBNT USG Firewall Rules

### EXAMPLE 3
```
$value1 | Invoke-UniFiCidrWorkaround
```

IPv4 or IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

### EXAMPLE 4
```
$value1 | Invoke-UniFiCidrWorkaround -6
```

IPv6 CIDR Workaround for UBNT USG Firewall Rules via Pipeline

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

### -6
Process IPv6 CIDR (Single IPv6 has to be without /128)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: IPv6, V6

Required: False
Position: 3
Default value: False
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
This is an internal helper function only (Will be moved to the private functions soon)

## RELATED LINKS

[https://github.com/jhochwald/UniFiTooling/issues/5](https://github.com/jhochwald/UniFiTooling/issues/5)

