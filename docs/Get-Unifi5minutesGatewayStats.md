---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-Unifi5minutesGatewayStats.md
schema: 2.0.0
---

# Get-Unifi5minutesGatewayStats

## SYNOPSIS
Get statistics in 5 minute segments for the USG

## SYNTAX

```
Get-Unifi5minutesGatewayStats [[-UnifiSite] <String>] [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get statistics in 5 minute segments for the USG (UniFi Secure Gateway)

For convenience, we return the a bit more then the API, e.g.
everything in KB, MB, GB, and TB instead of just bytes
We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

Sample output:
Time           : 2/1/2019 6:20:00 PM
gateway        : 78:8a:20:59:e6:88
mem            : 33.00
cpu            : 0.13
lan-rx_errors  : 0
lan-rx_bytes   : 1373037.08
lan-rx_kb      : 1340.86
lan-rx_mb      : 1.31
lan-rx_packets : 8410.58
lan-rx_dropped : 0
wan-rx_errors  : 0
wan-rx_packets : 1413.88
wan-rx_dropped : 0
lan-tx_errors  : 0
lan-tx_bytes   : 1908328.2
lan-tx_kb      : 1863.60
lan-tx_mb      : 1.82
lan-tx_packets : 8597.439999999999
lan-tx_dropped : 0
wan-tx_errors  : 0
wan-tx_bytes   : 391328.44
wan-tx_kb      : 382.16
wan-tx_mb      : 0.37
wan-tx_packets : 979.14
wan-tx_dropped : 0

You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

You can Filter for whatever parameter you like (e.g.
with Select-Object)

BUG: The loadavg_ attributes are not working at the moment.
The UniFi SDN Controller does not return any values for them!

## EXAMPLES

### EXAMPLE 1
```
Get-Unifi5minutesGatewayStats
```

Get statistics in 5 minute segments for the USG (UniFi Secure Gateway) in the default site

### EXAMPLE 2
```
(Get-Unifi5minutesGatewayStats -Start '1548971935421' -End '1548975579019')
```

Get statistics in 5 minute segments for the USG (UniFi Secure Gateway) in the default site for a given time period.

### EXAMPLE 3
```
(Get-Unifi5minutesGatewayStats -Start '1548980058135')
```

Get statistics in 5 minute segments for the USG (UniFi Secure Gateway) in the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-Unifi5minutesGatewayStats -UnifiSite 'contoso')[-1]
```

Get statistics in 5 minute segments for the USG (UniFi Secure Gateway) in the site 'contoso'

### EXAMPLE 5
```
Get-Unifi5minutesGatewayStats -Attributes 'mem','cpu','loadavg_5','lan-rx_errors','wan-rx_errors','lan-tx_errors','wan-tx_errors','lan-rx_bytes','wan-rx_bytes','lan-tx_bytes','wan-tx_bytes','lan-rx_packets','wan-rx_packets','lan-tx_packets','wan-tx_packets','lan-rx_dropped','wan-rx_dropped','lan-tx_dropped','wan-tx_dropped')
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
Defaults to the past 12 hours.
Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
Ubiquiti announced this with the Controller version 5.8 - It will not work on older versions!

A USG (UniFi Secure Gateway) is required on the site you querry!

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

