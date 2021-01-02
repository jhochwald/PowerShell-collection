---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-Unifi5minutesSiteStats.md
schema: 2.0.0
---

# Get-Unifi5minutesSiteStats

## SYNOPSIS
Get statistics in 5 minute segments for a complete Site

## SYNTAX

```
Get-Unifi5minutesSiteStats [[-UnifiSite] <String>] [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get statistics in 5 minute segments for a complete UniFi Site

For convenience, we return the a bit more then the API, e.g.
everything in KB, MB, GB, and TB instead of just bytes

We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

Sample output:
Time         : 1/28/2019 8:00:00 AM
wan-tx_bytes : 15674710.4243137
wan-tx_kb    : 15307.33
wan-tx_mb    : 14.95
wan-tx_gb    : 0.01
wan-rx_bytes : 74608528.2870588
wan-rx_kb    : 72859.89
wan-rx_mb    : 71.15
wan-rx_gb    : 0.07
wan_bytes    : 90283238.7113726
wan_kb       : 88167.23
wan_mb       : 86.1
wan_gb       : 0.08
wlan_bytes   : 73033651.4499586
wlan_kb      : 71321.93
wlan_mb      : 69.65
wlan_gb      : 0.07
Clients      : 35
LAN_Clients  : 30
WLAN_Clients : 5

You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

You can Filter for whatever parameter you like (e.g.
with Select-Object)

## EXAMPLES

### EXAMPLE 1
```
Get-Unifi5minutesSiteStats
```

Get statistics in 5 minute segments for a complete UniFi in the default site

### EXAMPLE 2
```
(Get-Unifi5minutesSiteStats -Start '1548971935421' -End '1548975579019')
```

Get statistics in 5 minute segments for a complete UniFi in the default site for a given time period.

### EXAMPLE 3
```
(Get-Unifi5minutesSiteStats -Start '1548980058135')
```

Get statistics in 5 minute segments for a complete UniFi in the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-Unifi5minutesSiteStats -UnifiSite 'contoso')[-1]
```

Get statistics in 5 minute segments for a complete UniFi in the site 'contoso'

### EXAMPLE 5
```
Get-Unifi5minutesSiteStats -Attributes 'bytes','wan-tx_bytes','wan-rx_bytes','wlan_bytes','num_sta','lan-num_sta','wlan-num_sta')
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
Defaults to the past 12 hours

"bytes" are no longer returned with controller version 4.9.1 and later

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

