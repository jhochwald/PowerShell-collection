---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Invoke-UnifiForgetClient.md
schema: 2.0.0
---

# Invoke-UnifiForgetClient

## SYNOPSIS
Forget one or more client devices via the API of the UniFi Controller

## SYNTAX

```
Invoke-UnifiForgetClient [[-UnifiSite] <String>] [-Mac] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Forget one or more client devices via the API of the Ubiquiti UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Invoke-UnifiForgetClient -Mac '84:3a:4b:cd:88:2D'
```

Forget one or more client devices via the API of the UniFi Controller

### EXAMPLE 2
```
Invoke-UnifiForgetClient -Mac '84:3a:4b:cd:88:2D' -UnifiSite 'Contoso'
```

Forget one or more client devices on Site 'Contoso' via the API of the UniFi Controller

## PARAMETERS

### -UnifiSite
UniFi Site as configured.
The default is: default

```yaml
Type: String
Parameter Sets: (All)
Aliases: Site

Required: False
Position: 1
Default value: Default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Mac
Client MAC address

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: UniFiMac, MacAddress

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

### System.Boolean
## NOTES
Initial version of the Ubiquiti UniFi Controller automation function

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

