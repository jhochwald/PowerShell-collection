---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Set-UnifiFirewallGroup.md
schema: 2.0.0
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
Position: 1
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
Position: 2
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
Position: 3
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

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

