---
author: Joerg Hochwald
category: UNIFITOOLING
external help file: UniFiTooling-help.xml
layout: post
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/tree/master/docs/Get-UnifiFirewallGroupBody.md
schema: 2.0.0
tags: OnlineHelp PowerShell
timestamp: 2019-01-12
title: Get-UnifiFirewallGroupBody
---

# Get-UnifiFirewallGroupBody

## SYNOPSIS
Build a Body for Set-UnifiFirewallGroup call

## SYNTAX

```
Get-UnifiFirewallGroupBody [-UnfiFirewallGroup] <PSObject> [-UnifiCidrInput] <PSObject> [<CommonParameters>]
```

## DESCRIPTION
Build a JSON based Body for Set-UnifiFirewallGroup call

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiFirewallGroupBody -UnfiFirewallGroup $value1 -UnifiCidrInput $value2
```

Build a Body for Set-UnifiFirewallGroup call

## PARAMETERS

### -UnfiFirewallGroup
Existing Unfi Firewall Group

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: FirewallGroup

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UnifiCidrInput
IPv4 or IPv6 input List

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases: CidrInput

Required: True
Position: 3
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

.
LINK
Set-UnifiFirewallGroup

## RELATED LINKS
