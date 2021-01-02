---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-UnifiHourlyGatewayStats.md
schema: 2.0.0
---

# Get-UnifiHourlyGatewayStats

## SYNOPSIS
Get hourly statistics for the USG

## SYNTAX

```
Get-UnifiHourlyGatewayStats [[-UnifiSite] <String>] [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get hourly statistics for the USG (UniFi Secure Gateway)

For convenience, we return the a bit more then the API, e.g.
everything in KB, MB, GB, and TB instead of just bytes
We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

Sample output:
Time           : 2/1/2019 6:00:00 PM
mem            : 33.29
cpu            : 3.07
lan-rx_errors  : 0
lan-rx_bytes   : 50242070.25
lan-rx_kb      : 49064.52
lan-rx_mb      : 47.91
lan-rx_gb      : 0.05
lan-rx_packets : 298575.0
lan-rx_dropped : 0
wan-rx_errors  : 0
wan-rx_packets : 64705.74999999999
wan-rx_dropped : 0
lan-tx_errors  : 0
lan-tx_bytes   : 82506381.25
lan-tx_kb      : 80572.64
lan-tx_mb      : 78.68
lan-tx_gb      : 0.08
lan-tx_packets : 310632.50000000006
lan-tx_dropped : 0
wan-tx_errors  : 0
wan-tx_bytes   : 16211129
wan-tx_kb      : 15831.18
wan-tx_mb      : 15.46
wan-tx_gb      : 0.02
wan-tx_packets : 42872.99999999999
wan-tx_dropped : 0

You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

You can Filter for whatever parameter you like (e.g.
with Select-Object)

BUG: The loadavg_ attributes are not working at the moment.
The UniFi SDN Controller does not return any values for them!

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiHourlyGatewayStats
```

Get hourly statistics for the USG (UniFi Secure Gateway) in the default site

### EXAMPLE 2
```
(Get-UnifiHourlyGatewayStats -Start '1548971935421' -End '1548975579019')
```

Get hourly statistics for the USG (UniFi Secure Gateway) in the default site for a given time period.

### EXAMPLE 3
```
(Get-UnifiHourlyGatewayStats -Start '1548980058135')
```

Get hourly statistics for the USG (UniFi Secure Gateway) in the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-UnifiHourlyGatewayStats -UnifiSite 'contoso')[-1]
```

Get hourly statistics for the USG (UniFi Secure Gateway) in the site 'contoso'

### EXAMPLE 5
```
Get-UnifiHourlyGatewayStats -Attributes 'mem','cpu','loadavg_5','lan-rx_errors','wan-rx_errors','lan-tx_errors','wan-tx_errors','lan-rx_bytes','wan-rx_bytes','lan-tx_bytes','wan-tx_bytes','lan-rx_packets','wan-rx_packets','lan-tx_packets','wan-tx_packets','lan-rx_dropped','wan-rx_dropped','lan-tx_dropped','wan-tx_dropped')
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
array containing attributes (strings) to be returned, defaults to mem, cpu, and zime (Time is mandatory)

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
Defaults to the past week (7*24 hours)

A USG (UniFi Secure Gateway) is required on the site you querry!

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

