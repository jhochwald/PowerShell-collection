---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/raw/master/docs/Get-UnifiFirewallGroupDetails.md
schema: 2.0.0
---

# Get-UnifiFirewallGroupDetails

## SYNOPSIS
Get the details about one Firewall Group via the API of the UniFi Controller

## SYNTAX

### Request by Id
```
Get-UnifiFirewallGroupDetails [-Id] <String[]> [[-UnifiSite] <String>] [<CommonParameters>]
```

### Request by Name
```
Get-UnifiFirewallGroupDetails [-Name] <String[]> [[-UnifiSite] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get the details about one Firewall Group via the API of the UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiFirewallGroupDetails -id 'ba7e58be13574ef4881a79c3'
```

Get the details about the Firewall Group with ID ba7e58be13574ef4881a79c3 via the API of the UniFi Controller

### EXAMPLE 2
```
Get-UnifiFirewallGroupDetails -name 'MyExtDNS'
```

Get the details about the Firewall Group MyExtDNS via the API of the UniFi Controller

### EXAMPLE 3
```
Get-UnifiFirewallGroupDetails -name 'MyExtDNS', 'MailHost'
```

Get the details about the Firewall Groups MyExtDNS and MailHost via the API of the UniFi Controller

### EXAMPLE 4
```
Get-UnifiFirewallGroupDetails -id 'ba7e58be13574ef4881a79c3', '2437bdf7fdf04f1a96c0fd32'
```

Get the details about the Firewall Groups with IDs ba7e58be13574ef4881a79c3 and 2437bdf7fdf04f1a96c0fd32 via the API of the UniFi Controller

### EXAMPLE 5
```
Get-UnifiFirewallGroupDetails -id 'ba7e58be13574ef4881a79c3' -UnifiSite 'Contoso'
```

Get the details about the Firewall Groups with ID ba7e58be13574ef4881a79c3 on Site 'Contoso' via the API of the UniFi Controller

### EXAMPLE 6
```
Get-UnifiFirewallGroupDetails -name 'MailHost' -UnifiSite 'Contoso'
```

Get the details about the Firewall Groups MailHost on Site 'Contoso' via the API of the UniFi Controller

## PARAMETERS

### -Id
The ID (_id) of the Firewall Group you would like to get detaild information about.
Multiple values are supported.

```yaml
Type: String[]
Parameter Sets: Request by Id
Aliases: FirewallGroupId

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Name
The Name (not the _id) of the Firewall Group you would like to get detaild information about.
Multiple values are supported.

```yaml
Type: String[]
Parameter Sets: Request by Name
Aliases: FirewallGroupName

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
Initial Release with 1.0.7

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[https://github.com/jhochwald/UniFiTooling/issues/10](https://github.com/jhochwald/UniFiTooling/issues/10)

