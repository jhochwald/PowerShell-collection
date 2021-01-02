---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-UnifiDailyClientStats.md
schema: 2.0.0
---

# Get-UnifiDailyClientStats

## SYNOPSIS
Get daily user/client statistics for a given user/client

## SYNTAX

```
Get-UnifiDailyClientStats [[-UnifiSite] <String>] [-Mac] <String> [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get daily user/client statistics for a given user/client

For convenience, we return the a bit more then the API, e.g.
everything in KB, MB, GB, and TB instead of just bytes
We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

Sample output:
Time          : 2/1/2019 1:00:00 AM
rx_bytes      : 105.0
rx_kb         : 0.10
rx_mb         : 0.00
rx_gb         : 0.00
rx_tb         : 0.00
rx_rate       : 650000.0
rx_rate_mbps  : 634.77
rx_retries    : 0
rx_packets    : 2.5
tx_bytes      : 213.0
tx_kb         : 0.21
tx_mb         : 0.00
tx_gb         : 0.00
tx_tb         : 0.00
tx_rate       : 650000.0
tx_rate_mbps  : 634.77
tx_retries    : 1
tx_packets    : 4.5
Traffic_bytes : 318
Traffic_kb    : 0.31
Traffic_mb    : 0.00
Traffic_gb    : 0.00
Traffic_tb    : 0.00
Signal        : -65
Signal_plain  : -65.0

In reality, we filter out all 0.00 values (e.g.
tx_mb above)
You can Filter for whatever parameter you like (e.g.
with Select-Object)

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiDailyClientStats -Mac '78:8a:20:59:e6:88'
```

Get daily user/client statistics for given (78:8a:20:59:e6:88) user/client in the default site

### EXAMPLE 2
```
(Get-UnifiDailyClientStats -Mac '78:8a:20:59:e6:88' -Start '1548971935421' -End '1548975579019')
```

Get daily user/client statistics for a given (78:8a:20:59:e6:88) user/client in the default site for a given time period.

### EXAMPLE 3
```
(Get-UnifiDailyClientStats -Mac '78:8a:20:59:e6:88' -Start '1548980058135')
```

Get daily user/client statistics for a given (78:8a:20:59:e6:88) user/client in the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-UnifiDailyClientStats -Mac '78:8a:20:59:e6:88' -UnifiSite 'contoso')[-1]
```

Get daily user/client statistics for a given (78:8a:20:59:e6:88) user/client in the site 'contoso'

### EXAMPLE 5
```
Get-UnifiDailyClientStats -Mac '78:8a:20:59:e6:88' -Attributes 'rx_bytes', 'tx_bytes', 'signal', 'rx_rate', 'tx_rate', 'rx_retries', 'tx_retries', 'rx_packets', 'tx_packets')
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

### -Mac
Client MAC address (required)

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

### -Start
Startpoint in UniFi Unix timestamp in milliseconds

```yaml
Type: String
Parameter Sets: (All)
Aliases: Startpoint, StartTime

Required: False
Position: 3
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
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Attributes
array containing attributes (strings) to be returned, defaults to rx_bytes and tx_bytes

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: attribs, UniFiAttributes

Required: False
Position: 5
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
defaults to the past week (7*24 hours)
Ubiquiti announced this with the Controller version 5.8 - It will not work on older versions!
Make sure that "Clients Historical Data" (Collect clients' historical data) has been enabled in the UniFi controller in "Settings/Maintenance"

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

