---
author: Joerg Hochwald
category: UNIFITOOLING
external help file: UniFiTooling-help.xml
layout: post
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/docs/Invoke-UniFiCidrWorkaroundV6.md
schema: 2.0.0
tags: OnlineHelp PowerShell
timestamp: 2019-01-12
title: Invoke-UniFiCidrWorkaroundV6
---

# Invoke-UniFiCidrWorkaroundV6

## SYNOPSIS
IPv6 CIDR Workaround for UBNT USG Firewall Rules

## SYNTAX

```
Invoke-UniFiCidrWorkaroundV6 [-CidrList] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
IPv6 CIDR Workaround for UBNT USG Firewall Rules (Single IPv6 has to be without /128)

## EXAMPLES

### EXAMPLE 1
```
Invoke-UniFiCidrWorkaroundV6 -CidrList $value1
```

IPv6 CIDR Workaround for UBNT USG Firewall Rules

### EXAMPLE 2
```
$value1 | Invoke-UniFiCidrWorkaroundV6
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
This is an internal helper function only

## RELATED LINKS

[Invoke-UniFiCidrWorkaround]()

