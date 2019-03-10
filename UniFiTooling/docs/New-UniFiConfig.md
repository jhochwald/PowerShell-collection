---
external help file: UniFiTooling-help.xml
HelpVersion: 1.0.8
Locale: en-US
Module Guid: 7fff91a0-02eb-4df2-84d5-c7d3cd7f7a5d
Module Name: UniFiTooling
online version: https://github.com/Enatec/UniFiTooling/raw/master/docs/New-UniFiConfig.md
schema: 2.0.0
---

# New-UniFiConfig

## SYNOPSIS
Creates the UniFi config JSON file

## SYNTAX

```
New-UniFiConfig [[-UniFiUsername] <String>] [[-UniFiPassword] <String>] [[-UniFiProtocol] <String>]
 [[-UniFiSelfSignedCert] <Boolean>] [[-UniFiHostname] <String>] [[-UniFiPort] <Int32>] [[-Path] <String>]
 [-force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates the UniFi config JSON file.
If no input is given it creates one with all the defaults.

## EXAMPLES

### EXAMPLE 1
```
New-UniFiConfig
```

### EXAMPLE 2
```
New-UniFiConfig -UniFiUsername 'unfi.admin.user' -UniFiPassword 'mySuperSecretPassworHere' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json'
```

### EXAMPLE 3
```
New-UniFiConfig -UniFiUsername 'unfi.admin.user' -UniFiPassword 'mySuperSecretPassworHere' -UniFiProtocol 'https' -UniFiSelfSignedCert $true -UniFiHostname 'unifi.contoso.com' -UniFiPort '8443' -Path '.\UniFiConfig.json' -force
```

## PARAMETERS

### -UniFiUsername
The login of a UniFi User with admin rights

```yaml
Type: String
Parameter Sets: (All)
Aliases: enUniFiUsername

Required: False
Position: 1
Default value: Unfi.admin.user
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiPassword
The password for the user given above.
It is clear text for now.
I know...
But the Ubiquiti UniFi Controller seems to understand plain text only.

```yaml
Type: String
Parameter Sets: (All)
Aliases: enUniFiPassword

Required: False
Position: 2
Default value: MySuperSecretPassworHere
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiProtocol
Valid is http and https.
default is https
Please note: http is untested and it might not even work!

```yaml
Type: String
Parameter Sets: (All)
Aliases: enUniFiProtocol

Required: False
Position: 3
Default value: Https
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiSelfSignedCert
If you use a self signed certificate and/or a certificate from an untrusted CA, you might want to use true here.
Default is FALSE

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: enUniFiSelfSignedCert

Required: False
Position: 4
Default value: False
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiHostname
The Ubiquiti UniFi Controller you want to use.
You can use a Fully-Qualified Host Name (FQHN) or an IP address.

```yaml
Type: String
Parameter Sets: (All)
Aliases: enUniFiHostname

Required: False
Position: 5
Default value: Unifi.contoso.com
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -UniFiPort
The port number that you have configured on your Ubiquiti UniFi Controller.
The default is 8443

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: enUniFiPort

Required: False
Position: 6
Default value: 8443
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Path
Where to safe the JSON config.
Default is the directory where you call the function.
e.g.
.\UniFiConfig.json

```yaml
Type: String
Parameter Sets: (All)
Aliases: enConfigPath, ConfigPath

Required: False
Position: 7
Default value: .\UniFiConfig.json
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -force
Replaces the contents of a file, even if the file is read-only.
Without this parameter, read-only files are not changed.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: False
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Just an helper function to create a JSON config

## RELATED LINKS

[Get-UniFiConfig]()

[Get-UniFiCredentials]()

