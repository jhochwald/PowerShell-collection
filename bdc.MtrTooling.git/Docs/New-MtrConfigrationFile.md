# New-MtrConfigrationFile

## SYNOPSIS
Generate a  Microsoft Teams Room (MTR) System configuration file

## SYNTAX

### Devices (Default)
```
New-MtrConfigrationFile [-AutoScreenShare <String>] [-HideMeetingName <String>] [-IsTeamsDefaultClient <String>] [-BluetoothAdvertisementEnabled <String>] [-SkypeMeetingsEnabled <String>] [-TeamsMeetingsEnabled <String>] [-DualScreenMode <String>] [-Devices] [-Path <String>] [-WhatIf] [-Confirm] [-MicrophoneForCommunication <String>] [-SpeakerForCommunication <String>] [-DefaultSpeaker <String>] [-ContentCameraId <String>] [-ContentCameraInverted <String>] [-ContentCameraEnhancement <String>] [<CommonParameters>]
```

### UserAccount
```
New-MtrConfigrationFile [-AutoScreenShare <String>] [-HideMeetingName <String>] [-UserAccount] [-IsTeamsDefaultClient <String>] [-BluetoothAdvertisementEnabled <String>] [-SkypeMeetingsEnabled <String>] [-TeamsMeetingsEnabled <String>] [-DualScreenMode <String>] [-Path <String>] [-WhatIf] [-Confirm] [-SpeakerForCommunication <String>] [-DefaultSpeaker <String>] [-ContentCameraId <String>] [-ContentCameraInverted <String>] [-ContentCameraEnhancement <String>] [<CommonParameters>]
```

### SendLogs
```
New-MtrConfigrationFile [-AutoScreenShare <String>] [-HideMeetingName <String>] [-IsTeamsDefaultClient <String>] [-BluetoothAdvertisementEnabled <String>] [-SkypeMeetingsEnabled <String>] [-TeamsMeetingsEnabled <String>] [-DualScreenMode <String>] [-SendLogs] [-Path <String>] [-WhatIf] [-Confirm] [-SpeakerForCommunication <String>] [-DefaultSpeaker <String>] [-ContentCameraId <String>] [-ContentCameraInverted <String>] [-ContentCameraEnhancement <String>] [<CommonParameters>]
```

### ThemeName
```
New-MtrConfigrationFile [-AutoScreenShare <String>] [-HideMeetingName <String>] [-IsTeamsDefaultClient <String>] [-BluetoothAdvertisementEnabled <String>] [-SkypeMeetingsEnabled <String>] [-TeamsMeetingsEnabled <String>] [-DualScreenMode <String>] [-ThemeName <String>] [-Path <String>] [-WhatIf] [-Confirm] [-SpeakerForCommunication <String>] [-DefaultSpeaker <String>] [-ContentCameraId <String>] [-ContentCameraInverted <String>] [-ContentCameraEnhancement <String>] [<CommonParameters>]
```

## DESCRIPTION
Generate a  Microsoft Teams Room (MTR) System configuration file

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
PS C:\\\>
```powershell
New-MtrConfigrationFile -ThemeName Custom -CustomThemeImageUrl 'wallpaper.jpg' -RedComponent 100 -BlueComponent 100 -GreenComponent 100
```

Generate a  Microsoft Teams Room (MTR) System configuration file with a custom wallpaper and color settings

### -------------------------- EXAMPLE 2 --------------------------
PS C:\\\>
```powershell
New-MtrConfigrationFile -Devices -MicrophoneForCommunication 'Microsoft LifeChat LX-6000' -SpeakerForCommunication 'Realtek High Definition Audio' -DefaultSpeaker 'Polycom CX5100' -ContentCameraId 'USB\VID_046D&PID_0843&amp;MI_00\7&17446CF2&0&0000' -ContentCameraInverted $false -ContentCameraEnhancement $true
```

Generate a  Microsoft Teams Room (MTR) System configuration file with custom devices

### -------------------------- EXAMPLE 3 --------------------------
PS C:\\\>
```powershell
New-MtrConfigrationFile -UserAccount -SkypeSignInAddress 'RanierConf@contoso.com' -ExchangeAddress 'RanierConf@contoso.com' -DomainUsername 'Seattle\RanierConf' -Password 'password' -ConfigureDomain 'domain1, domain2'
```

Generate a  Microsoft Teams Room (MTR) System configuration file with configured user information (Accounts)

## PARAMETERS

### AutoScreenShare
If true, auto screen share is enabled.

```yaml
Type: String
Parameter Sets: (All)
Aliases: MTRAutoScreenShare

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### HideMeetingName
If true, meeting names are hidden.

```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrHideMeetingName

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### IsTeamsDefaultClient
Is Microsoft Teams the Default for new Meetings

```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrIsTeamsDefaultClient

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### BluetoothAdvertisementEnabled
Support local Bluetooth beakoning

```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrBluetoothAdvertisementEnabled

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### SkypeMeetingsEnabled
Support Skype for Business Meetings

```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrSkypeMeetingsEnabled

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### TeamsMeetingsEnabled
Support Microsoft Terams Meetings

```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrTeamsMeetingsEnabled

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### DualScreenMode
If true, dual screen mode is enabled. Otherwise the device uses single screen mode.

```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrDualScreenMode

Required: false
Position: named
Default Value: 
Pipeline Input: True (ByPropertyName, ByValue)
```

### Devices
The connected audio device names in the child elements are the same values listed in the Device Manager app.
The configuration can contain a device that does not presently exist on the system, such as an A/V device not currently connected to the console.
The configuration would be retained for the respective device.

```yaml
Type: SwitchParameter
Parameter Sets: Devices
Aliases: MtrDevices

Required: false
Position: named
Default Value: False
Pipeline Input: True (ByPropertyName, ByValue)
```

### Path


```yaml
Type: String
Parameter Sets: (All)
Aliases: MtrPath

Required: false
Position: named
Default Value: .
Pipeline Input: True (ByPropertyName, ByValue)
```

### WhatIf


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: false
Position: named
Default Value: 
Pipeline Input: false
```

### Confirm


```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: false
Position: named
Default Value: 
Pipeline Input: false
```

### MicrophoneForCommunication


```yaml
Type: String
Parameter Sets: Devices
Aliases: 

Required: false
Position: named
Default Value: 
Pipeline Input: false
Dynamic: true
```

### SpeakerForCommunication


```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: false
Position: named
Default Value: 
Pipeline Input: false
Dynamic: true
```

### DefaultSpeaker


```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: false
Position: named
Default Value: 
Pipeline Input: false
Dynamic: true
```

### ContentCameraId


```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: false
Position: named
Default Value: 
Pipeline Input: false
Dynamic: true
```

### ContentCameraInverted


```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: false
Position: named
Default Value: 
Pipeline Input: false
Dynamic: true
```

### ContentCameraEnhancement


```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: false
Position: named
Default Value: 
Pipeline Input: false
Dynamic: true
```

### UserAccount
Container for credentials parameters. The sign in address, Exchange address, or email address are usually the same, such as RanierConf@contoso.com.

```yaml
Type: SwitchParameter
Parameter Sets: UserAccount
Aliases: 

Required: false
Position: named
Default Value: False
Pipeline Input: True (ByPropertyName, ByValue)
```

### SendLogs
Configure the "Give Feedback" and "Report Issue"

```yaml
Type: SwitchParameter
Parameter Sets: SendLogs
Aliases: MtrSendLogs

Required: false
Position: named
Default Value: False
Pipeline Input: True (ByPropertyName, ByValue)
```

### ThemeName
Used to identify the theme on the client. The Theme Name options are Default, one of the provided preset themes, or Custom.
Custom theme names always use the name Custom.
The client UI can be set at the console to the Default or one of the presets, but use of a custom theme must be set remotely by an Administrator.

Preset themes include:
Default
Blue Wave
Digital Forest
Dreamcatcher
Limeade
Pixel Perfect
Roadmap
Sunset

To disable the current theme, use "No Theme" for the ThemeName.

```yaml
Type: String
Parameter Sets: ThemeName
Aliases: MtrThemeName

Required: false
Position: named
Default Value: 
Accepted Values: Default 
                 Blue Wave 
                 Digital Forest 
                 Dreamcatcher 
                 Limeade 
                 Pixel Perfect 
                 Roadmap 
                 Sunset
                 No Theme
                 Custom
Pipeline Input: True (ByPropertyName, ByValue)
```

### \<CommonParameters\>
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String


### System.Management.Automation.SwitchParameter


## OUTPUTS

## NOTES

Initial MTR function
The dynmic parameters still need some tweaks!

## RELATED LINKS

[Online version:](http://hochwald.net)


*Generated by: PowerShell HelpWriter 2020 v2.3.46*
