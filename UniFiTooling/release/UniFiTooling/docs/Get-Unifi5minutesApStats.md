---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/Get-Unifi5minutesApStats.md
schema: 2.0.0
---

# Get-Unifi5minutesApStats

## SYNOPSIS
Get Access Point stats in 5 minute segments

## SYNTAX

```
Get-Unifi5minutesApStats [[-UnifiSite] <String>] [[-Mac] <String>] [[-Start] <String>] [[-End] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Get the stats in 5 minute segments for all or just one access points in a given UniFi site
For convenience, we return the traffic Megabytes and not in bytes (as the UniFi does it).
We also return real timestamps instead of the unix timestaps that the UniFi returns

## EXAMPLES

### EXAMPLE 1
```
Get-Unifi5minutesApStats
```

Get the stats in 5 minute segments for all access points in the default site

### EXAMPLE 2
```
Get-Unifi5minutesApStats -Mac '78:8a:20:59:e6:88'
```

Get the stats in 5 minute segments for a given (78:8a:20:59:e6:88) access point in the default site

### EXAMPLE 3
```
(Get-Unifi5minutesApStats -Start '1548971935421' -End '1548975579019')
```

Get the statistics for a given time period.

### EXAMPLE 4
```
(Get-Unifi5minutesApStats -Start '1548971935421')
```

Get the statistics for the last 60 minutes (was the timestamp while the sample was created)

### EXAMPLE 5
```
Get-Unifi5minutesApStats -UnifiSite 'contoso' | Where-Object { $_.Traffic -ne '0.00' }
```

Get the stats in 5 minute segments for all access points in the site 'contoso', if traffic is generated.

### EXAMPLE 6
```
(Get-Unifi5minutesApStats -UnifiSite 'contoso')[-1]
```

Get the last stats in 5 minute segments for all access points in the site 'contoso'

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
Client MAC address

```yaml
Type: String
Parameter Sets: (All)
Aliases: UniFiMac, MacAddress

Required: False
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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
Defaults to the past 12 hours.
Make sure that the retention policy for 5 minutes stats is set to the correct value in the controller settings
Ubiquiti announced this with the Controller version 5.5 - It will not work on older versions!

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

