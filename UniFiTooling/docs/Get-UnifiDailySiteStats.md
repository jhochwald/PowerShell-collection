---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-UnifiDailySiteStats.md
schema: 2.0.0
---

# Get-UnifiDailySiteStats

## SYNOPSIS
Get daily statistics for a complete Site

## SYNTAX

```
Get-UnifiDailySiteStats [[-UnifiSite] <String>] [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get daily statistics for a complete UniFi Site

For convenience, we return the a bit more then the API, e.g.
everything in KB, MB, GB, and TB instead of just bytes

We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

Sample output:
Time         : 1/28/2019 7:00:00 AM
wan-tx_bytes : 5943900.402553191
wan-tx_kb    : 5804.59
wan-tx_mb    : 5.67
wan-tx_gb    : 0.01
wan-rx_bytes : 33117387.3812766
wan-rx_kb    : 32341.2
wan-rx_mb    : 31.58
wan-rx_gb    : 0.03
wan_bytes    : 39061287.783829791
wan_kb       : 38145.79
wan_mb       : 37.25
wan_gb       : 0.04
wlan_bytes   : 7030900.205833333
wlan_kb      : 6866.11
wlan_mb      : 6.71
wlan_gb      : 0.01
Clients      : 33
LAN_Clients  : 29
WLAN_Clients : 4

You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

You can Filter for whatever parameter you like (e.g.
with Select-Object)

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiDailySiteStats
```

Get daily statistics for a complete UniFi for the default site

### EXAMPLE 2
```
(Get-UnifiDailySiteStats -Start '1548971935421' -End '1548975579019')
```

Get daily statistics for a complete UniFi for the default site for a given time period.

### EXAMPLE 3
```
(Get-UnifiDailySiteStats -Start '1548980058135')
```

Get daily statistics for a complete UniFi for the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-UnifiDailySiteStats -UnifiSite 'contoso')[-1]
```

Get daily statistics for a complete UniFi for the site 'contoso'

### EXAMPLE 5
```
Get-UnifiDailySiteStats -Attributes 'bytes','wan-tx_bytes','wan-rx_bytes','wlan_bytes','num_sta','lan-num_sta','wlan-num_sta')
```

Get all Values from the API

## PARAMETERS

### -UnifiSite
ID of the client-device to be modified

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

### -Start
Startpoint in UniFi Unix timestamp in milliseconds

```yaml
Type: String
Parameter Sets: (All)
Aliases: Startpoint, StartTime

Required: False
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -End
Endpoint in UniFi Unix timestamp in milliseconds

```yaml
Type: String
Parameter Sets: (All)
Aliases: EndPoint, EndTime

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Attributes
array containing attributes (strings) to be returned, defaults are all

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: attribs, UniFiAttributes

Required: False
Position: 4
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
Defaults to the past 7 days (52*7*24 hours)

"bytes" are no longer returned with controller version 4.9.1 and later

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

