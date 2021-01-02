---
author: Joerg Hochwald
category: UNIFITOOLING
external help file: UniFiTooling-help.xml
layout: post
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/docs/Set-UnifiFirewallGroup.md
schema: 2.0.0
tags: OnlineHelp PowerShell
timestamp: 2019-01-12
title: Set-UnifiFirewallGroup
---

# Set-UnifiFirewallGroup

## SYNOPSIS
Get a given Firewall Group via the API of the UniFi Controller

## SYNTAX

```
Set-UnifiFirewallGroup [-UnfiFirewallGroup] <String> [-UnifiCidrInput] <PSObject> [[-UnifiSite] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get a given Firewall Group via the API of the Ubiquiti UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Set-UnifiFirewallGroup -UnfiFirewallGroup 'Value1' -UnifiCidrInput $value2
```

Get a given Firewall Group via the API of the Ubiquiti UniFi Controller

## PARAMETERS

### -UnfiFirewallGroup
Unfi Firewall Group

```yaml
Type: String
Parameter Sets: (All)
Aliases: FirewallGroup

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UnifiCidrInput
IPv4 or IPv6 input List (PSObject)

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

### -UnifiSite
UniFi Site as configured.
The default is: default

```yaml
Type: String
Parameter Sets: (All)
Aliases: Site

Required: False
Position: 4
Default value: Default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Initial version of the Ubiquiti UniFi Controller automation function

## RELATED LINKS

[Get-UnifiFirewallGroups]()

[Get-UnifiFirewallGroupBody]()

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

