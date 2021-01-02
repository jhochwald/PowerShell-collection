---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/jhochwald/UniFiTooling/raw/master/docs/Get-UnifiSpeedTestResult.md
schema: 2.0.0
---

# Get-UnifiSpeedTestResult

## SYNOPSIS
Get the UniFi Security Gateway (USG) Speed Test results

## SYNTAX

### DateSet (Default)
```
Get-UnifiSpeedTestResult [[-StartDate] <DateTime>] [[-EndDate] <DateTime>] [[-UnifiSite] <String>] [-all]
 [-UniFiValues] [<CommonParameters>]
```

### TimeFrameSet
```
Get-UnifiSpeedTestResult [[-StartDate] <DateTime>] [[-Timeframe] <Int32>] [[-UnifiSite] <String>] [-all]
 [-UniFiValues] [<CommonParameters>]
```

## DESCRIPTION
Get the UniFi Security Gateway (USG) Speed Test results

## EXAMPLES

### EXAMPLE 1
```
Get-UnifiSpeedTestResult -all
```

Get all the UniFi Security Gateway (USG) Speed Test results

### EXAMPLE 2
```
Get-UnifiSpeedTestResult | Select-Object -Property *
```

Get the UniFi Security Gateway (USG) Speed Test results from the last 24 hours (default), returns all values

### EXAMPLE 3
```
Get-UnifiSpeedTestResult -UnifiSite 'Contoso'
```

Get the UniFi Security Gateway (USG) Speed Test results from the last 24 hours (default)

### EXAMPLE 4
```
Get-UnifiSpeedTestResult -Timeframe 48
```

Get the UniFi Security Gateway (USG) Speed Test results of the last 48 hours

### EXAMPLE 5
```
Get-UnifiSpeedTestResult -StartDate '1/16/2019 12:00 AM' -EndDate '1/16/2019 11:59:59 PM'
```

Get the UniFi Security Gateway (USG) Speed Test results for a given time/date
In the example, all results from 1/16/2019 (all day) will be returned

## PARAMETERS

### -StartDate
Start date (valid Date String)
Default is now

```yaml
Type: DateTime
Parameter Sets: (All)
Aliases: Start

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Timeframe
Timeframe in hours, default is 24

```yaml
Type: Int32
Parameter Sets: TimeFrameSet
Aliases: hours

Required: False
Position: 2
Default value: 0
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -EndDate
End date (valid Date String), default is now minus 24 hours

```yaml
Type: DateTime
Parameter Sets: DateSet
Aliases:

Required: False
Position: 2
Default value: (Get-Date)
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
Position: 3
Default value: Default
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -all
Get all existing Speed Test Results

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: False
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiValues
Show results without modifications, like the UniFi Controller creates them

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: False
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
Initial version that makes it more human readable.
The filetring needs a few more tests

## RELATED LINKS

[Get-UniFiConfig]()

[Set-UniFiDefaultRequestHeader]()

[Invoke-UniFiApiLogin]()

[Invoke-RestMethod]()

[ConvertFrom-UnixTimeStamp]()

[ConvertTo-UnixTimeStamp]()

