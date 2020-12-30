---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Invoke-UnifiAuthorizeGuest.md
schema: 2.0.0
---

# Invoke-UnifiAuthorizeGuest

## SYNOPSIS
Authorize a client device via the API of the UniFi Controller

## SYNTAX

```
Invoke-UnifiAuthorizeGuest [[-UnifiSite] <String>] [-Mac] <String> [[-Minutes] <Int32>] [[-Up] <Int32>]
 [[-Down] <Int32>] [[-Limit] <Int32>] [[-AccessPoint] <String>] [<CommonParameters>]
```

## DESCRIPTION
Authorize a client device via the API of the Ubiquiti UniFi Controller

## EXAMPLES

### EXAMPLE 1
```
Invoke-UnifiAuthorizeGuest -Mac '84:3a:4b:cd:88:2D'
```

Authorize a client device via the API of the UniFi Controller

### EXAMPLE 2
```
Invoke-UnifiAuthorizeGuest -Mac '84:3a:4b:cd:88:2D' -AccessPoint '788a2059c699'
```

Authorize a client device via the API of the UniFi Controller, it used the AccessPoint with the Mac address 78:8a:20:59:c6:99 directly for a faster authorization

### EXAMPLE 3
```
Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Minutes 180
```

Authorize a client device for 180 minutes via the API of the UniFi Controller

### EXAMPLE 4
```
Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Up 1024 -Down 2048
```

Authorize a client device with a restriction of 1024 kbit/s upload rate and 2048 kbit/s download rate via the API of the UniFi Controller

### EXAMPLE 5
```
Invoke-UnifiAuthorizeGuest -Mac '843a4bcd882D' -Limit 102400
```

Authorize a client device with a limitation of  via 102400 megabytes of traffic (combined) the API of the UniFi Controller

### EXAMPLE 6
```
Invoke-UnifiAuthorizeGuest '84-3a-4b-cd-88-2D' -UnifiSite 'Contoso'
```

Authorize a client device on site 'Contoso' via the API of the UniFi Controller (The function will normalize the MAC Address for us)

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

### -Minutes
Minutes (from now) until authorization expires, the default is 60 (1 hour)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: UniFiMinutes

Required: False
Position: 3
Default value: 60
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Up
Upload speed limit in Kilobit per second (kbit/s)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: UniFiUp

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Down
Download speed limit in Kilobit per second (kbit/s)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Limit
Data transfer limit in megabytes (MB), upload and download will be combined.
The default is unlimited

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: MBytes, UniFiLimit, UniFiMBytes

Required: False
Position: 6
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -AccessPoint
MAC address of the Access Point to which client is connected, should result in a much faster authorization

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiAccessPoint, ApMac, UniFiApMac, ap_mac

Required: False
Position: 7
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

