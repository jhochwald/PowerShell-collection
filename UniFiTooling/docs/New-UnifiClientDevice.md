---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/New-UnifiClientDevice.md
schema: 2.0.0
---

# New-UnifiClientDevice

## SYNOPSIS
Create a new user/client-device via the API of the UniFi Controller

## SYNTAX

```
New-UnifiClientDevice [[-UnifiSite] <String>] [-Mac] <String> [-Group] <String> [[-Name] <String>]
 [[-Note] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create a new user/client-device via the API of the Ubiquiti UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
New-UnifiClientDevice -Mac '84:3a:4b:cd:88:2D' -Group 'Value2'
```

Create a new user/client-device

### EXAMPLE 2
```
New-UnifiClientDevice -Mac '84:3a:4b:cd:88:2D' -Group 'Value2' -UnifiSite 'Contoso'
```

Create a new user/client-device on Site 'Contoso'

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
Type: String
Parameter Sets: (All)
Aliases: UniFiMac, MacAddress

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Group
Value for the user group the new user/client-device should belong to which can be obtained from the output of XXX

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiGroup, ClientGroup, UserGroup

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
Name to be given to the new user/client-device (optional)

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiName, ClientName, UserName

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Note
Note to be applied to the new user/client-device (optional)

```yaml
Type: String
Parameter Sets: (All)
Aliases: UnifiNote, UserNote, ClientNote

Required: False
Position: 5
Default value: None
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Initial version of the Ubiquiti UniFi Controller automation function

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

