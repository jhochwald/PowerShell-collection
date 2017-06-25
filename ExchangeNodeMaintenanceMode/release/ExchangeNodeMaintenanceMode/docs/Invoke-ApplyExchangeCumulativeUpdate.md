---
external help file: ExchangeNodeMaintenanceMode-help.xml
online version: 
schema: 2.0.0
---

# Invoke-ApplyExchangeCumulativeUpdate

## SYNOPSIS
Apply an Exchange Cumulative Update

## SYNTAX

```
Invoke-ApplyExchangeCumulativeUpdate [[-Source] <String>] [-Prepare] [-UMLangHandling]
 [[-UMLangSource] <String>] [[-UMLanguages] <String>]
```

## DESCRIPTION
Apply an Exchange Cumulative Update, with the optional AD and Schema
update, and an optional UM language Update.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
# Use the defaults to install the CU
```

PS \> Invoke-ApplyExchangeCumulativeUpdate

### -------------------------- EXAMPLE 2 --------------------------
```
# Use the defaults to install the CU, where '\\SERVER\Share\' is the location of the CU (Sources)
```

PS \> Invoke-ApplyExchangeCumulativeUpdate -Source '\\\\SERVER\Share\'

### -------------------------- EXAMPLE 3 --------------------------
```
# Install the the and the updates the default UM Languages from a given location
```

PS \> Invoke-ApplyExchangeCumulativeUpdate -Source '\\\\SERVER\Share\' -UMLangHandling -UMLangSource '\\\\SERVER\Share\UM-Updates\'

### -------------------------- EXAMPLE 4 --------------------------
```
# Install the the and the updates the given UM Languages
```

PS \> Invoke-ApplyExchangeCumulativeUpdate -UMLangHandling -UMLanguages = 'es-MX,es-ES'

## PARAMETERS

### -Source
Source Directory of the Exchange Cumulative Update, must exist.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 2
Default value: E:\
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Prepare
Run prepare of Schema, Active Directory and AD Domain.
Enabled by default

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 3
Default value: True
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UMLangHandling
Handle the UMLangHandling.
Disabled by default

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 

Required: False
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UMLangSource
Source Directory of the UM Lang Packs, must exist

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 5
Default value: F:\
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UMLanguages
UM Languages to handle.
This is one string that should contain all languages.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: 6
Default value: De-DE,en-GB,en-US
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
TODO: Error handling.
At the moment it is just a fire an forget thing!

This function is just a wrapper for the default SETUP.EXE of the
Exchange Cumulative Update package.
You might tweak the directory variable.
Or just use the parameter.

.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOn
Set-ExchangeNodeMaintenanceModeOff
Test-ExchangeNodeMaintenanceMode

## RELATED LINKS

