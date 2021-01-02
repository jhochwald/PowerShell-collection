---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/raw/master/docs/Get-UnifiNetworkDetails.md
schema: 2.0.0
---

# Get-UnifiNetworkDetails

## SYNOPSIS
Get the details about one network via the API of the UniFi Controller

## SYNTAX

### Request by Id
```
Get-UnifiNetworkDetails [-Id] <String[]> [[-UnifiSite] <String>] [<CommonParameters>]
```

### Request by Name
```
Get-UnifiNetworkDetails [-Name] <String[]> [[-UnifiSite] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the details about one network via the API of the UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3'
```

Get the details about the network with ID ba7e58be13574ef4881a79c3 via the API of the UniFi Controller

### EXAMPLE 2
```
Get-UnifiNetworkDetails -UnifiNetwork 'ba7e58be13574ef4881a79c3'
```

Same as above, with the legacy parameter alias used.

### EXAMPLE 3
```
Get-UnifiNetworkDetails -name 'JoshHome'
```

Get the details about the network JoshHome via the API of the UniFi Controller

### EXAMPLE 4
```
Get-UnifiNetworkDetails -name 'JoshHome', 'JohnHome'
```

Get the details about the networks JoshHome and JohnHome via the API of the UniFi Controller

### EXAMPLE 5
```
Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3', '2437bdf7fdf04f1a96c0fd32'
```

Get the details about the networks with IDs ba7e58be13574ef4881a79c3 and 2437bdf7fdf04f1a96c0fd32 via the API of the UniFi Controller

### EXAMPLE 6
```
Get-UnifiNetworkDetails -id 'ba7e58be13574ef4881a79c3' -UnifiSite 'Contoso'
```

Get the details about the network with ID ba7e58be13574ef4881a79c3 on Site 'Contoso' via the API of the UniFi Controller

### EXAMPLE 7
```
Get-UnifiNetworkDetails -name 'JoshHome' -UnifiSite 'Contoso'
```

Get the details about the network JoshHome on Site 'Contoso' via the API of the UniFi Controller

## PARAMETERS

### -Id
The ID (network_id) of the network you would like to get detaild information about.
Multiple values are supported.

```yaml
Type: String[]
Parameter Sets: Request by Id
Aliases: UnifiNetwork, UnifiNetworkId, NetworkId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
The Name (not the ID/network_id) of the network you would like to get detaild information about.
Multiple values are supported.

```yaml
Type: String[]
Parameter Sets: Request by Name
Aliases: UnifiNetworkName, NetworkName

Required: True
Position: 1
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
Position: 2
Default value: Default
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
The parameter UnifiNetwork is now an Alias.
If the UnifiNetwork parameter is used, it must(!) be the ID (network_id).
This was necessary to make it a non breaking change.

## RELATED LINKS

[Get-UnifiNetworkList]()

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

