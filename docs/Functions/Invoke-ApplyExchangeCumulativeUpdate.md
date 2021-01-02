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
 [[-UMLangSource] <String>] [[-UMLanguages] <String>] [-WhatIf] [-Confirm]
```

## DESCRIPTION
Apply an Exchange Cumulative Update, with the optional AD and Schema updates,
and additional UM language packs update.

Please read the Release Notes from Microsoft carefully, some updates need an Active
Directory schema and/or Active Directory and/or Active Directory domain updates.
If this is the case, please use the "Prepare" Switch on ONE Node!

Nevertheless, please keep in mind, that you do NOT need to run the command with this
Switch more than once.
However, even if, the Switch will not harm in any kind,
it is just a waste of time, and the installation will take longer.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
# Use the defaults to install the CU
```

PS \> Invoke-ApplyExchangeCumulativeUpdate

Microsoft Exchange Server 2016 Cumulative Update 6 Unattended Setup
Copying Files...
File copy complete.
Setup will now collect additional information needed for installation.
Performing Microsoft Exchange Server Prerequisite Check
Prerequisite Analysis                                                                             COMPLETED
Extending Active Directory schema                                                                 COMPLETED
Organization Preparation                                                                          COMPLETED

### -------------------------- EXAMPLE 2 --------------------------
```
# Use the defaults to install the CU, where '\\SERVER\Share\' is the location of the CU (Sources)
```

PS \> Invoke-ApplyExchangeCumulativeUpdate -Source '\\\\SERVER\Share\'

Performing Microsoft Exchange Server Prerequisite Check

Configuring Prerequisites                                                                         COMPLETED
Prerequisite Analysis                                                                             COMPLETED

Configuring Microsoft Exchange Server

Preparing Setup                                                                                   COMPLETED
Stopping Services                                                                                 COMPLETED
Language Files                                                                                    COMPLETED
Removing Exchange Files                                                                           COMPLETED
Preparing Files                                                                                   COMPLETED
Copying Exchange Files                                                                            COMPLETED
Language Files                                                                                    COMPLETED
Restoring Services                                                                                COMPLETED
Language Configuration                                                                            COMPLETED
Exchange Management Tools                                                                         COMPLETED
Mailbox role: Transport service                                                                   COMPLETED
Mailbox role: Client Access service                                                               COMPLETED
Mailbox role: Unified Messaging service                                                           COMPLETED
Mailbox role: Mailbox service                                                                     COMPLETED
Mailbox role: Front End Transport service                                                         COMPLETED
Mailbox role: Client Access Front End service                                                     COMPLETED
Finalizing Setup                                                                                  COMPLETED

### -------------------------- EXAMPLE 3 --------------------------
```
# Install the the and the updates the default UM Languages from a given location
```

PS \> Invoke-ApplyExchangeCumulativeUpdate -Source '\\\\SERVER\Share\' -UMLangHandling -UMLangSource '\\\\SERVER\Share\UM-Updates\'

### -------------------------- EXAMPLE 4 --------------------------
```
# Install the the and the updates the given UM Languages
```

PS \> Invoke-ApplyExchangeCumulativeUpdate -UMLangHandling -UMLanguages 'es-MX,es-ES'

Microsoft Exchange Server 2016 Cumulative Update 6 Unattended Setup

UM Language Pack for es-MX
UM Language Pack for es-ES

Performing Microsoft Exchange Server Prerequisite Check

Prerequisite Analysis                                                                             COMPLETED

Configuring Microsoft Exchange Server

UM language pack for (es-MX)                                                                      COMPLETED
UM language pack for (es-ES)                                                                      COMPLETED

The Exchange Server setup operation completed successfully.

## PARAMETERS

### -Source
Source Directory of the Exchange Cumulative Update.
Must exist.

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
You need to do this one one Node.
the 2nd one could run the installer without it.
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
Handle the UM Language(s).
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
Source Directory of the UM Language Pack(s).
The Directory must exist!

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
Default value: De-DE,en-GB
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

## INPUTS

## OUTPUTS

## NOTES
TODO: Error handling.
At the moment it is just a fire an forget thing!

This function is just a wrapper for the default SETUP.EXE of the Exchange Cumulative 
Update package and the UM Language Pack update(s).

You might tweak the directory variable.
Or just use the parameters to do so.

Someone asked me: "Why not stopping the Windows Defender during the update?
Defender will
consume a lot of CPU." I agree; it will use some CPU during the update, but I'm not a fan
of doing this.
There is a reason for an Anti-Virus tool, by stopping the scan engine the
system would be at risk!
And this is something I don't want a system I'm responsible for!
If you want to do something like this, this is your decision.
However, I "highly" recommend
not doing it.
And this applies to all AV scanners on your servers!

One last thing: Be patient if you install the Exchange Cumulative Update!
The preparation
(e.g.
Schema, Active Directory and Domain) should be quick, even if you environment is
distributed.
The removal of the old installation and especially the update installation
with the restart of all services might take a while to complete (depending on your
hardware, it could be 30 minutes, or more!).
Why this is important: During the installation, the other Node(s) needs to handle the load,
and you might need to communicate, that you have the risk of a single point of failure.

.
LINK
Invoke-Exchange2016Workaround
Set-ExchangeNodeMaintenanceModeOn
Set-ExchangeNodeMaintenanceModeOff
Test-ExchangeNodeMaintenanceMode

## RELATED LINKS

