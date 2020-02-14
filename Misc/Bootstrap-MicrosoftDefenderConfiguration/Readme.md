# Bootstrap Microsoft Defender configuration

Bootstrap Microsoft Defender configuration, optimize and tweak Windows 10 protection and security

## What it does

Several Microsoft Defender settings are configured.

### EnableNetworkProtection

Network protection helps to prevent employees from using any application to access dangerous domains that may host phishing scams, exploits, and other malicious content on the Internet

Set to: `Enabled`

### EnableControlledFolderAccess

Controlled folder access helps you protect valuable data from malicious apps and threats, such as ransomware

Set to: `Enabled`

### SignatureScheduleDay

Specifies the day of the week on which to check for definition updates.

Set to: `Everyday`

### SignatureScheduleTime

Specifies the time of day, as the number of minutes after midnight, to check for definition updates

Set to: `320`

### DisableArchiveScanning

Indicates whether to scan archive files for malicious and unwanted software

Set to: `true`

### DisableAutoExclusions

Indicates whether to disable the Automatic Exclusions feature for the server

Set to: `false`

### DisableBehaviorMonitoring

Indicates whether to enable behavior monitoring

Set to: `true`

Something I enable on a few systems only.

### DisableBlockAtFirstSeen

Indicates whether to enable block at first seen

Set to: `true`

### DisableCatchupFullScan

Indicates whether Windows Defender runs catch-up scans for scheduled full scans

Set to: `true`

### DisableCatchupQuickScan

Indicates whether Windows Defender runs catch-up scans for scheduled quick scans

Set to: `true`

### DisableEmailScanning

Indicates whether Windows Defender parses the mailbox and mail files, according to their specific format, in order to analyze mail bodies and attachments

Set to: `false`

### DisableIOAVProtection

Indicates whether Windows Defender scans all downloaded files and attachments (e.g. Downloads)

Set to: `true`

### DisableIntrusionPreventionSystem

Indicates whether to configure network protection against exploitation of known vulnerabilities

Set to: `false`

### DisablePrivacyMode

Indicates whether to disable privacy mode. Privacy mode prevents users, other than administrators, from displaying threat history

Set to: `false`

### DisableRealtimeMonitoring

Indicates whether to use real-time protection

Set to: `false`

### CheckForSignaturesBeforeRunningScan

Set to: `1`

### DisableRemovableDriveScanning

Indicates whether to scan for malicious and unwanted software in removable drives, such as flash drives, during a full scan

Set to: `true`

### DisableRestorePoint

Indicates whether to disable scanning of restore points

Set to: `true`

### DisableScanningMappedNetworkDrivesForFullScan

Indicates whether to scan mapped network drives

Set to: `true`

### DisableScanningNetworkFiles

Indicates whether to scan for network files

Set to: `false`

### DisableScriptScanning

Specifies whether to disable the scanning of scripts during malware scans

Set to: `false`

### HighThreatDefaultAction

Specifies which automatic remediation action to take for a high level threat

Set to: `Quarantine`

### LowThreatDefaultAction

Specifies which automatic remediation action to take for a low level threat

Set to: `Block`

### ModerateThreatDefaultAction

Specifies which automatic remediation action to take for a moderate level threat

Set to: `Quarantine`

### PUAProtection

Disable PUA Protection

Set to: `Enabled`

### QuarantinePurgeItemsAfterDelay

Specifies the number of days to keep items in the Quarantine folder

Set to: `30`

### RandomizeScheduleTaskTimes

Indicates whether to select a random time for the scheduled start and scheduled update for definitions

Set to: `true`

### RealTimeScanDirection

Specifies scanning configuration for incoming and outgoing files on NTFS volumes

Set to: `0`

### RemediationScheduleDay

Specifies the day of the week on which to perform a scheduled full scan in order to complete remediation

Set to: `Everyday`

### RemediationScheduleTime

Specifies the time of day, as the number of minutes after midnight, to perform a scheduled scan

Set to: `120`

### ReportingAdditionalActionTimeOut

Specifies the number of minutes before a detection in the additional action state changes to the cleared state

Set to: `10080`

### ReportingCriticalFailureTimeOut

Specifies the number of minutes before a detection in the critically failed state changes to either the additional action state or the cleared state

Set to: `10080`

### ReportingNonCriticalTimeOut

Specifies the number of minutes before a detection in the non-critically failed state changes to the cleared state

Set to: `11440`

### ScanAvgCPULoadFactor

Specifies the maximum percentage CPU usage for a scan

Set to: `50`

### ScanOnlyIfIdleEnabled

Indicates whether to start scheduled scans only when the computer is not in use

Set to: `true`

### ScanParameters

Specifies the scan type to use during a scheduled scan

Set to: `1`

### ScanPurgeItemsAfterDelay

Specifies the number of days to keep items in the scan history folder

Set to: `15`

### ScanScheduleDay

Specifies the day of the week on which to perform a scheduled scan

Set to: `Everyday`

### ScanScheduleQuickScanTime

Specifies the time of day, as the number of minutes after midnight, to perform a scheduled quick scan

Set to: `0`

### ScanScheduleTime

Specifies the time of day, as the number of minutes after midnight, to perform a scheduled scan

Set to: `120`

### SevereThreatDefaultAction

Specifies which automatic remediation action to take for a severe level threat

Set to: `Quarantine`

### SignatureAuGracePeriod

Specifies a grace period, in minutes, for the definition

Set to: `0`

### SignatureDisableUpdateOnStartupWithoutEngine

Indicates whether to initiate definition updates even if no antimalware engine is present

Set to: `false`

### SignatureFirstAuGracePeriod

Specifies a grace period, in minutes, for the definition. If a definition successfully updates within this period, Windows Defender abandons any service initiated updates

Set to: `120`

### SignatureScheduleDay

Specifies the day of the week on which to check for definition updates

Set to: `Everyday`

### SignatureScheduleTime

Specifies the time of day, as the number of minutes after midnight, to check for definition updates

Set to: `165`

### SignatureUpdateCatchupInterval

Specifies the number of days after which Windows Defender requires a catch-up definition update

Set to: `1`

### SignatureUpdateInterval

Specifies the interval, in hours, at which to check for definition updates

Set to: `12`

### SubmitSamplesConsent

Specifies how Windows Defender checks for user consent for certain samples

Set to: `AlwaysPrompt`

### MAPSReporting

Membership in Microsoft Active Protection Service Enable

Set to: `Advanced`

### ThrottleLimit

Specifies the maximum number of concurrent operations that can be established to run the cmdlet

Set to: `0`

### UILockdown

Indicates whether to disable UI lock down mode

Set to: `false`

### UnknownThreatDefaultAction

Specifies which automatic remediation action to take for an unknown level threat

Set to: `Block`

### SignatureFallbackOrder

Specifies the order in which to contact different definition update sources. Specify the types of update sources in the order in which you want Windows Defender to contact them, enclosed in braces and separated by the pipeline symbol

Set to: `MicrosoftUpdateServer | MMPC`

### ControlledFolderAccessAllowedApplications

We exclude the following Files by default: `$env:windir\System32\taskhostw.exe`

Any exclusions previously configured stay intact!

### ExclusionPath

The following Files/Folders are excluded from the scan:

`windir\SoftwareDistribution\DataStore\Datastore.edb`
`windir\SoftwareDistribution\DataStore\Logs\Edb*.jrs`
`windir\SoftwareDistribution\DataStore\Logs\Edb.chk`
`windir\SoftwareDistribution\DataStore\Logs\Tmp.edb`
`windir\Security\Database\*.edb`
`windir\Security\Database\*.sdb`
`windir\Security\Database\*.log`
`windir\Security\Database\*.chk`
`windir\Security\Database\*.jrs`
`windir\Security\Database\*.xml`
`windir\Security\Database\*.csv`
`windir\Security\Database\*.cmtx`
`ProgramData\ntuser.pol`
`windir\System32\GroupPolicy\Machine\Registry.pol`
`windir\System32\GroupPolicy\Machine\Registry.tmp`
`windir\System32\GroupPolicy\User\Registry.pol`
`windir\System32\GroupPolicy\User\Registry.tmp`

Any exclusions previously configured stay intact!

More Info: [https://support.microsoft.com/en-us/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni](https://support.microsoft.com/en-us/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni)

### ExclusionProcess

The following processes are excluded from the scan:

`$env:windir\System32\svchost.exe`
`$env:windir\System32\wuauclt.exe`

Any exclusions previously configured stay intact!

More Info: [https://support.microsoft.com/en-us/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni](https://support.microsoft.com/en-us/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni)

### Process Mitigation and Exploit Protection

Microsoft provides a XML file (`ProcessMitigation.xml`) that provides a configuration best practice to mitigate the attack surface and provide Exploit Protection.

You can provide your own File, otherwise (if missing) we will download the latest version from Microsoft.

More Info: [https://demo.wd.microsoft.com/Page/EP](https://demo.wd.microsoft.com/Page/EP)

### WindowsDefenderSandbox

We tuen on Windows Defender Sandbox

### AttackSurfaceReduction

Attack Surface Reduction (ASR) is comprised of a number of rules, each of which target specific behaviors that are typically used by malware and malicious apps to infect machines, such as:

- Executable files and scripts used in Office apps or web mail that attempt to download or run files
- Scripts that are obfuscated or otherwise suspicious
- Behaviors that apps undertake that are not usually initiated during normal day-to-day work

More Info: [https://demo.wd.microsoft.com/Page/ASR](https://demo.wd.microsoft.com/Page/ASR)

### ReloadRegistry

We then reload the registry to ensure that the new configuration is activated

### EnableFirewall

Enable the Windows Firewall for all Profiles - Set the default to block everything

We enable the Windows Firewall for the following Network-Profiles:

- Domain
- Public
- Private

We block all inbound connections by default and we log all block-events!

### UpdateSignature

As a final touch: We update the Windows Defender signatures.

## Why this?

I use this during the bootstrap process of Windows systems.
Most of the settings here is also enforced by some of our Group Policies and we also have a lot of it configured via MDM CSPs (InTune).

This script is only a quick hack to harden (and secure) any new system, even if it is not managed afterwords.

## Content

There are two files:

### Bootstrap-MicrosoftDefenderConfiguration.ps1

The PowerShell Script itself

### Bootstrap-MicrosoftDefenderConfiguration.csv

A CSV File that contains the configuration of the attack surface reduction rules.

## Configuration

Please review the `Bootstrap-MicrosoftDefenderConfiguration.csv` where you configure the attack surface reduction rules. Please also review the `Bootstrap-MicrosoftDefenderConfiguration.ps1` file. There is no configuration file, at least not yet!

## Further Information

[https://docs.microsoft.com/en-us/powershell/module/defender/index?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/defender/index?view=win10-ps)

[https://github.com/jhochwald/PowerShell-collection/blob/master/Misc/Optimize-MicrosoftDefenderExclusions.ps1](https://github.com/jhochwald/PowerShell-collection/blob/master/Misc/Optimize-MicrosoftDefenderExclusions.ps1)

[https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/enable-exploit-protection](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/enable-exploit-protection
)

[https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps](https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps)

[https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/customize-attack-surface-reduction](https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps)

[https://support.microsoft.com/en-us/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni](https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps)

[https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/enable-cloud-protection-windows-defender-antivirus](https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps)

[https://demo.wd.microsoft.com/?ocid=cx-wddocs-testground](https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps)

## License

BSD 3-Clause License

Copyright (c) 2020, Joerg Hochwald
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
