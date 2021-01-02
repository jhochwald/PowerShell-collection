---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-UnifiDailyGatewayStats.md
schema: 2.0.0
---

# Get-UnifiDailyGatewayStats

## SYNOPSIS
Get daily statistics for the USG

## SYNTAX

```
Get-UnifiDailyGatewayStats [[-UnifiSite] <String>] [[-Start] <String>] [[-End] <String>]
 [[-Attributes] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
Get daily statistics for the USG (UniFi Secure Gateway)

For convenience, we return the a bit more then the API, e.g.
everything in KB, MB, GB, and TB instead of just bytes
We also return real timestamps instead of the unix timestaps in miliseconds that the UniFi returns

Sample output:
Time           : 2/1/2019 1:00:00 AM
mem            : 33.23
cpu            : 3.25
lan-rx_errors  : 0
lan-rx_bytes   : 1715484318.69231
lan-rx_kb      : 1675277.65
lan-rx_mb      : 1636.01
lan-rx_gb      : 1.6
lan-rx_packets : 16370719.6153846
lan-rx_dropped : 125
wan-rx_errors  : 0
wan-rx_packets : 20559905.0769231
wan-rx_dropped : 1214
lan-tx_errors  : 0
lan-tx_bytes   : 30648673319.6923
lan-tx_kb      : 29930345.04
lan-tx_mb      : 29228.85
lan-tx_gb      : 28.54
lan-tx_tb      : 0.03
lan-tx_packets : 25358762.6923077
lan-tx_dropped : 0
wan-tx_errors  : 0
wan-tx_bytes   : 1047615654
wan-tx_kb      : 1023062.16
wan-tx_mb      : 999.08
wan-tx_gb      : 0.98
wan-tx_packets : 11374571.2307692
wan-tx_dropped : 0

You might filter out all the 0 values, we keep them to prevent any null pointer expetions!

You can Filter for whatever parameter you like (e.g.
with Select-Object)

BUG: The loadavg_ attributes are not working at the moment.
The UniFi SDN Controller does not return any values for them!

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiDailyGatewayStats
```

Get daily statistics for the USG (UniFi Secure Gateway) in the default site

### EXAMPLE 2
```
(Get-UnifiDailyGatewayStats -Start '1548971935421' -End '1548975579019')
```

Get daily statistics for the USG (UniFi Secure Gateway) in the default site for a given time period.

### EXAMPLE 3
```
(Get-UnifiDailyGatewayStats -Start '1548980058135')
```

Get daily statistics for the USG (UniFi Secure Gateway) in the default site for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 4
```
(Get-UnifiDailyGatewayStats -UnifiSite 'contoso')[-1]
```

Get daily statistics for the USG (UniFi Secure Gateway) in the site 'contoso'

### EXAMPLE 5
```
Get-UnifiDailyGatewayStats -Attributes 'mem','cpu','loadavg_5','lan-rx_errors','wan-rx_errors','lan-tx_errors','wan-tx_errors','lan-rx_bytes','wan-rx_bytes','lan-tx_bytes','wan-tx_bytes','lan-rx_packets','wan-rx_packets','lan-tx_packets','wan-tx_packets','lan-rx_dropped','wan-rx_dropped','lan-tx_dropped','wan-tx_dropped')
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
Defaults to the past year (52*7*24 hours)

A USG (UniFi Secure Gateway) is required on the site you querry!

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

