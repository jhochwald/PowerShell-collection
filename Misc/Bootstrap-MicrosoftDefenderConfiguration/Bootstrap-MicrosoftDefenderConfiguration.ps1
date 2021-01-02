#requires -Version 3.0 -Modules ConfigDefender, NetSecurity

<#
      .SYNOPSIS
      Bootstrap Microsoft Defender configuration

      .DESCRIPTION
      Bootstrap Microsoft Defender configuration, optimize and tweak Windows 10 protection and security

      .PARAMETER CsvPath
      The CSV with the configuration.
      This is optional. Defaults are in the Script.

      .PARAMETER Force
      Enforce to apply the customize attack surface reduction rules

      .EXAMPLE
      PS C:\> .\Bootstrap-MicrosoftDefenderConfiguration.ps1

      Bootstrap Microsoft Defender configuration, optimize and tweak Windows 10 Protection

      .EXAMPLE
      PS C:\> .\Bootstrap-MicrosoftDefenderConfiguration.ps1 -Verbose -Force

      Bootstrap Microsoft Defender configuration, optimize and tweak Windows 10 Protection

      .EXAMPLE
      PS C:\> .\Bootstrap-MicrosoftDefenderConfiguration.ps1 -Verbose

      Bootstrap Microsoft Defender configuration, optimize and tweak Windows 10 Protection

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/defender/index?view=win10-ps

      .LINK
      https://github.com/jhochwald/PowerShell-collection/blob/master/Misc/Optimize-MicrosoftDefenderExclusions.ps1

      .LINK
      https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/enable-exploit-protection

      .LINK
      https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps

      .LINK
      https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/customize-attack-surface-reduction

      .LINK
      https://support.microsoft.com/en-us/help/822158/virus-scanning-recommendations-for-enterprise-computers-that-are-runni

      .LINK
      https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/enable-cloud-protection-windows-defender-antivirus

      .LINK
      https://demo.wd.microsoft.com/?ocid=cx-wddocs-testground

      .NOTES
      Please review the settings, please tweak the rules file (or modify the default rule set here)

      You need to run this in an elevated PowerShell!

      I use this during the bootstrap process of Windows systems.
      Most of the settings here is also enforced by some of our Group Policies and we also have a lot of it configured via MDM CSPs (InTune).

      This script is only a quick hack to harden (and secure) any new system, even if it is not managed afterwords.
#>
[CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('RulesCsv')]
   [string]
   $CsvPath = '.\Bootstrap-MicrosoftDefenderConfiguration.csv',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [Alias('EnforceRule')]
   [switch]
   $Force = $null
)

begin
{
   # Create a new Mail Object
   $AttackSurfaceReductionRuleList = @()

   #region CsvHandler
   if (Test-Path -Path $CsvPath -ErrorAction SilentlyContinue)
   {
      #region ImportCsv
      Write-Verbose -Message ('Import the attack surface reduction settings from ' + $CsvPath)
      $AttackSurfaceReductionRuleList = (Import-Csv -Path $CsvPath -Delimiter ',' -Encoding UTF8)
      #endregion ImportCsv
   }
   else
   {
      #region DefaultCsv
      Write-Verbose -Message 'Use the attack surface reduction default settings'

      # Create a virtual CSV File (Quick hack: To keep it plain and simple to maintain)
      $RuleDefaults = 'RuleID,RuleDescription,RuleAction
         75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84, Block Office applications from injecting into other processes, Enabled
         3B576869-A4EC-4529-8536-B80A7769E899, Block Office applications from creating executable content, Enabled
         D4F940AB-401B-4EfC-AADC-AD5F3C50688A, Block Office applications from creating child processes, Enabled
         D3E037E1-3EB8-44C8-A917-57927947596D, Impede JavaScript and VBScript to launch executable, Enabled
         5BEB7EFE-FD9A-4556-801D-275E5FFC04CC, Block execution of potentially obfuscated script, Enabled
         BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550, Block executable content from email client and webmail, Enabled
         92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B, Block Win32 imports from Macro code in Office, Enabled
         c1db55ab-c21a-4637-bb3f-a12568109d35, Use advanced protection against ransomware, Enabled
         9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2, Block credential stealing from the Windows local security authority subsystem (lsass.exe), Enabled
         d1e49aac-8f56-4280-b9ba-993a6d77406c, Block process creations originating from PSExec and WMI commands, Enabled
         b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4, Block untrusted and unsigned processes that run from USB, Enabled
         26190899-1602-49e8-8b27-eb1d0a1ce869, Block Office communication applications from creating child processes, AuditMode
         7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c, Block Adobe Reader from creating child processes, Enabled
         e6db77e5-3df2-4cf1-b95a-636979351e5b, Block persistence through WMI event subscription, Enabled
      01443614-cd74-433a-b99e-2ecdc07bfc25, Block executable files from running unless they meet a prevalence age or trusted list criteria, AuditMode'

      # Import the virtual CSV File
      $AttackSurfaceReductionRuleList = (ConvertFrom-Csv -InputObject $RuleDefaults -Delimiter ',')
      #endregion DefaultCsv
   }
   #endregion CsvHandler
}

process
{
   #region SetMpPreference
   #region EnableNetworkProtection
   Write-Verbose -Message 'Network protection helps to prevent employees from using any application to access dangerous domains that may host phishing scams, exploits, and other malicious content on the Internet'
   $null = (Set-MpPreference -EnableNetworkProtection Enabled -Force -ErrorAction Continue)
   #endregion EnableNetworkProtection

   #region EnableControlledFolderAccess
   Write-Verbose -Message 'Controlled folder access helps you protect valuable data from malicious apps and threats, such as ransomware'
   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction Continue)
   #endregion EnableControlledFolderAccess

   #region SignatureScheduleDay
   Write-Verbose -Message 'Specifies the day of the week on which to check for definition updates'
   $null = (Set-MpPreference -SignatureScheduleDay Everyday -Force -ErrorAction Continue)
   #endregion SignatureScheduleDay

   #region SignatureScheduleTime
   Write-Verbose -Message 'Specifies the time of day, as the number of minutes after midnight, to check for definition updates'
   $null = (Set-MpPreference -SignatureScheduleTime 320 -Force -ErrorAction Continue)
   #endregion SignatureScheduleTime

   #region DisableArchiveScanning
   Write-Verbose -Message 'Indicates whether to scan archive files for malicious and unwanted software'
   $null = (Set-MpPreference -DisableArchiveScanning $true -Force -ErrorAction Continue)
   #endregion DisableArchiveScanning

   #region DisableAutoExclusions
   Write-Verbose -Message 'Indicates whether to disable the Automatic Exclusions feature for the server'
   $null = (Set-MpPreference -DisableAutoExclusions $false -Force -ErrorAction Continue)
   #endregion DisableAutoExclusions

   #region DisableBehaviorMonitoring
   Write-Verbose -Message 'Indicates whether to enable behavior monitoring'
   $null = (Set-MpPreference -DisableBehaviorMonitoring $true -Force -ErrorAction Continue)
   #endregion DisableBehaviorMonitoring

   #region DisableBlockAtFirstSeen
   Write-Verbose -Message 'Indicates whether to enable block at first seen'
   $null = (Set-MpPreference -DisableBlockAtFirstSeen $true -Force -ErrorAction Continue)
   #endregion DisableBlockAtFirstSeen

   #region DisableCatchupFullScan
   Write-Verbose -Message 'Indicates whether Windows Defender runs catch-up scans for scheduled full scans'
   $null = (Set-MpPreference -DisableCatchupFullScan $true -Force -ErrorAction Continue)
   #endregion DisableCatchupFullScan

   #region DisableCatchupQuickScan
   Write-Verbose -Message 'Indicates whether Windows Defender runs catch-up scans for scheduled quick scans'
   $null = (Set-MpPreference -DisableCatchupQuickScan $true -Force -ErrorAction Continue)
   #endregion DisableCatchupQuickScan

   #region DisableEmailScanning
   Write-Verbose -Message 'Indicates whether Windows Defender parses the mailbox and mail files, according to their specific format, in order to analyze mail bodies and attachments'
   $null = (Set-MpPreference -DisableEmailScanning $false -Force -ErrorAction Continue)
   #endregion DisableEmailScanning

   #region DisableIOAVProtection
   Write-Verbose -Message 'Indicates whether Windows Defender scans all downloaded files and attachments (e.g. Downloads)'
   $null = (Set-MpPreference -DisableIOAVProtection $true -Force -ErrorAction Continue)
   #endregion DisableIOAVProtection

   #region DisableIntrusionPreventionSystem
   Write-Verbose -Message 'Indicates whether to configure network protection against exploitation of known vulnerabilities'
   $null = (Set-MpPreference -DisableIntrusionPreventionSystem $false -Force -ErrorAction Continue)
   #endregion DisableIntrusionPreventionSystem

   #region DisablePrivacyMode
   Write-Verbose -Message 'Indicates whether to disable privacy mode. Privacy mode prevents users, other than administrators, from displaying threat history'
   $null = (Set-MpPreference -DisablePrivacyMode $false -Force -ErrorAction Continue)
   #endregion DisablePrivacyMode

   #region DisableRealtimeMonitoring
   Write-Verbose -Message 'Indicates whether to use real-time protection'
   $null = (Set-MpPreference -DisableRealtimeMonitoring $false -Force -ErrorAction Continue)
   #endregion DisableRealtimeMonitoring

   #region CheckForSignaturesBeforeRunningScan
   Write-Verbose -Message 'Enable checking signatures before scanning'
   $null = (Set-MpPreference -CheckForSignaturesBeforeRunningScan 1 -Force -ErrorAction Continue)
   #endregion CheckForSignaturesBeforeRunningScan

   #region DisableRemovableDriveScanning
   Write-Verbose -Message 'Indicates whether to scan for malicious and unwanted software in removable drives, such as flash drives, during a full scan'
   $null = (Set-MpPreference -DisableRemovableDriveScanning $true -Force -ErrorAction Continue)
   #endregion DisableRemovableDriveScanning

   #region DisableRestorePoint
   Write-Verbose -Message 'Indicates whether to disable scanning of restore points'
   $null = (Set-MpPreference -DisableRestorePoint $true -Force -ErrorAction Continue)
   #endregion DisableRestorePoint

   #region DisableScanningMappedNetworkDrivesForFullScan
   Write-Verbose -Message 'Indicates whether to scan mapped network drives'
   $null = (Set-MpPreference -DisableScanningMappedNetworkDrivesForFullScan $true -Force -ErrorAction Continue)
   #endregion DisableScanningMappedNetworkDrivesForFullScan

   #region DisableScanningNetworkFiles
   Write-Verbose -Message 'Indicates whether to scan for network files'
   $null = (Set-MpPreference -DisableScanningNetworkFiles $false -Force -ErrorAction Continue)
   #endregion DisableScanningNetworkFiles

   #region DisableScriptScanning
   Write-Verbose -Message 'Specifies whether to disable the scanning of scripts during malware scans'
   $null = (Set-MpPreference -DisableScriptScanning $false -Force -ErrorAction Continue)
   #endregion DisableScriptScanning

   #region HighThreatDefaultAction
   Write-Verbose -Message 'Specifies which automatic remediation action to take for a high level threat'
   $null = (Set-MpPreference -HighThreatDefaultAction Quarantine -Force -ErrorAction Continue)
   #endregion HighThreatDefaultAction

   #region LowThreatDefaultAction
   Write-Verbose -Message 'Specifies which automatic remediation action to take for a low level threat'
   $null = (Set-MpPreference -LowThreatDefaultAction Block -Force -ErrorAction Continue)
   #endregion LowThreatDefaultAction

   #region ModerateThreatDefaultAction
   Write-Verbose -Message 'Specifies which automatic remediation action to take for a moderate level threat'
   $null = (Set-MpPreference -ModerateThreatDefaultAction Quarantine -Force -ErrorAction Continue)
   #endregion ModerateThreatDefaultAction

   #region PUAProtection
   Write-Verbose -Message 'Disable PUA Protection'
   $null = (Set-MpPreference -PUAProtection Enabled -Force -ErrorAction Continue)
   #endregion PUAProtection

   #region QuarantinePurgeItemsAfterDelay
   Write-Verbose -Message 'Specifies the number of days to keep items in the Quarantine folder'
   $null = (Set-MpPreference -QuarantinePurgeItemsAfterDelay 30 -Force -ErrorAction Continue)
   #endregion QuarantinePurgeItemsAfterDelay

   #region RandomizeScheduleTaskTimes
   Write-Verbose -Message 'Indicates whether to select a random time for the scheduled start and scheduled update for definitions'
   $null = (Set-MpPreference -RandomizeScheduleTaskTimes $true -Force -ErrorAction Continue)
   #endregion RandomizeScheduleTaskTimes

   #region RealTimeScanDirection
   Write-Verbose -Message 'Specifies scanning configuration for incoming and outgoing files on NTFS volumes'
   $null = (Set-MpPreference -RealTimeScanDirection 0 -Force -ErrorAction Continue)
   #endregion RealTimeScanDirection

   #region RemediationScheduleDay
   Write-Verbose -Message 'Specifies the day of the week on which to perform a scheduled full scan in order to complete remediation'
   $null = (Set-MpPreference -RemediationScheduleDay Everyday -Force -ErrorAction Continue)
   #endregion

   #region RemediationScheduleTime
   Write-Verbose -Message 'Specifies the time of day, as the number of minutes after midnight, to perform a scheduled scan'
   $null = (Set-MpPreference -RemediationScheduleTime 120 -Force -ErrorAction Continue)
   #endregion RemediationScheduleDay

   #region ReportingAdditionalActionTimeOut
   Write-Verbose -Message 'Specifies the number of minutes before a detection in the additional action state changes to the cleared state'
   $null = (Set-MpPreference -ReportingAdditionalActionTimeOut 10080 -Force -ErrorAction Continue)
   #endregion ReportingAdditionalActionTimeOut

   #region ReportingCriticalFailureTimeOut
   Write-Verbose -Message 'Specifies the number of minutes before a detection in the critically failed state changes to either the additional action state or the cleared state'
   $null = (Set-MpPreference -ReportingCriticalFailureTimeOut 10080 -Force -ErrorAction Continue)
   #endregion ReportingCriticalFailureTimeOut

   #region ReportingNonCriticalTimeOut
   Write-Verbose -Message 'Specifies the number of minutes before a detection in the non-critically failed state changes to the cleared state'
   $null = (Set-MpPreference -ReportingNonCriticalTimeOut 11440 -Force -ErrorAction Continue)
   #endregion ReportingNonCriticalTimeOut

   #region ScanAvgCPULoadFactor
   Write-Verbose -Message 'Specifies the maximum percentage CPU usage for a scan'
   $null = (Set-MpPreference -ScanAvgCPULoadFactor 50 -Force -ErrorAction Continue)
   #endregion ScanAvgCPULoadFactor

   #region ScanOnlyIfIdleEnabled
   Write-Verbose -Message 'Indicates whether to start scheduled scans only when the computer is not in use'
   $null = (Set-MpPreference -ScanOnlyIfIdleEnabled $true -Force -ErrorAction Continue)
   #endregion ScanOnlyIfIdleEnabled

   #region ScanParameters
   Write-Verbose -Message 'Specifies the scan type to use during a scheduled scan'
   $null = (Set-MpPreference -ScanParameters 1 -Force -ErrorAction Continue)
   #endregion ScanParameters

   #region ScanPurgeItemsAfterDelay
   Write-Verbose -Message 'Specifies the number of days to keep items in the scan history folder'
   $null = (Set-MpPreference -ScanPurgeItemsAfterDelay 15 -Force -ErrorAction Continue)
   #endregion ScanPurgeItemsAfterDelay

   #region ScanScheduleDay
   Write-Verbose -Message 'Specifies the day of the week on which to perform a scheduled scan'
   $null = (Set-MpPreference -ScanScheduleDay Everyday -Force -ErrorAction Continue)
   #endregion ScanScheduleDay

   #region ScanScheduleQuickScanTime
   Write-Verbose -Message 'Specifies the time of day, as the number of minutes after midnight, to perform a scheduled quick scan'
   $null = (Set-MpPreference -ScanScheduleQuickScanTime 0 -Force -ErrorAction Continue)
   #endregion ScanScheduleQuickScanTime

   #region ScanScheduleTime
   Write-Verbose -Message 'Specifies the time of day, as the number of minutes after midnight, to perform a scheduled scan'
   $null = (Set-MpPreference -ScanScheduleTime 120 -Force -ErrorAction Continue)
   #endregion ScanScheduleTime

   #region SevereThreatDefaultAction
   Write-Verbose -Message 'Specifies which automatic remediation action to take for a severe level threat'
   $null = (Set-MpPreference -SevereThreatDefaultAction Quarantine -Force -ErrorAction Continue)
   #endregion SevereThreatDefaultAction

   #region SignatureAuGracePeriod
   Write-Verbose -Message 'Specifies a grace period, in minutes, for the definition'
   $null = (Set-MpPreference -SignatureAuGracePeriod 0 -Force -ErrorAction Continue)
   #endregion SignatureAuGracePeriod

   #region SignatureDisableUpdateOnStartupWithoutEngine
   Write-Verbose -Message 'Indicates whether to initiate definition updates even if no antimalware engine is present'
   $null = (Set-MpPreference -SignatureDisableUpdateOnStartupWithoutEngine $false -Force -ErrorAction Continue)
   #endregion SignatureDisableUpdateOnStartupWithoutEngine

   #region SignatureFirstAuGracePeriod
   Write-Verbose -Message 'Specifies a grace period, in minutes, for the definition. If a definition successfully updates within this period, Windows Defender abandons any service initiated updates'
   $null = (Set-MpPreference -SignatureFirstAuGracePeriod 120 -Force -ErrorAction Continue)
   #endregion SignatureFirstAuGracePeriod

   #region SignatureScheduleDay
   Write-Verbose -Message 'Specifies the day of the week on which to check for definition updates'
   $null = (Set-MpPreference -SignatureScheduleDay Everyday -Force -ErrorAction Continue)
   #endregion SignatureScheduleDay

   #region SignatureScheduleTime
   Write-Verbose -Message 'Specifies the time of day, as the number of minutes after midnight, to check for definition updates'
   $null = (Set-MpPreference -SignatureScheduleTime 165 -Force -ErrorAction Continue)
   #endregion SignatureScheduleTime

   #region SignatureUpdateCatchupInterval
   Write-Verbose -Message 'Specifies the number of days after which Windows Defender requires a catch-up definition update'
   $null = (Set-MpPreference -SignatureUpdateCatchupInterval 1 -Force -ErrorAction Continue)
   #endregion SignatureUpdateCatchupInterval

   #region SignatureUpdateInterval
   Write-Verbose -Message 'Specifies the interval, in hours, at which to check for definition updates'
   $null = (Set-MpPreference -SignatureUpdateInterval 12 -Force -ErrorAction Continue)
   #endregion SignatureUpdateInterval

   #region SubmitSamplesConsent
   Write-Verbose -Message 'Specifies how Windows Defender checks for user consent for certain samples'
   $null = (Set-MpPreference -SubmitSamplesConsent AlwaysPrompt -Force -ErrorAction Continue)
   #endregion SubmitSamplesConsent

   #region MAPSReporting MAPSReporting
   Write-Verbose -Message 'Membership in Microsoft Active Protection Service Enable'
   $null = (Set-MpPreference -MAPSReporting Advanced -Force -ErrorAction Continue)
   #endregion MAPSReporting MAPSReporting

   #region ThrottleLimit
   Write-Verbose -Message 'Specifies the maximum number of concurrent operations that can be established to run the cmdlet'
   $null = (Set-MpPreference -ThrottleLimit 0 -Force -ErrorAction Continue)
   #endregion ThrottleLimit

   #region UILockdown
   Write-Verbose -Message 'Indicates whether to disable UI lock down mode'
   $null = (Set-MpPreference -UILockdown $false -Force -ErrorAction Continue)
   #endregion UILockdown

   #region UnknownThreatDefaultAction
   Write-Verbose -Message 'Specifies which automatic remediation action to take for an unknown level threat'
   $null = (Set-MpPreference -UnknownThreatDefaultAction Block -Force -ErrorAction Continue)
   #endregion UnknownThreatDefaultAction

   #region SignatureFallbackOrder
   Write-Verbose -Message 'Specifies the order in which to contact different definition update sources.'
   $null = (Set-MpPreference -SignatureFallbackOrder 'MicrosoftUpdateServer | MMPC' -Force -ErrorAction Continue)
   #endregion SignatureFallbackOrder

   #region ControlledFolderAccessAllowedApplications
   Write-Verbose -Message 'Setup the Controlled Folder Access Allowed Applications'

   # Define a list of Applications to exclude - Fully Qualified
   <#
         I like to keep this list as short as possible
   #>
   $NewControlledFolderAccessAllowedApplications = @(
      "$env:windir\System32\taskhostw.exe"
   )

   # Create a new Object
   $AllControlledFolderAccessAllowedApplications = (New-Object -TypeName System.Collections.Generic.List[System.Object])

   # Get the existing exclusions
   $AllControlledFolderAccessAllowedApplications.Add((Get-MpPreference -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ControlledFolderAccessAllowedApplications))

   #region NewControlledFolderAccessAllowedApplicationsLoop
   foreach ($NewControlledFolderAccessAllowedApplication in $NewControlledFolderAccessAllowedApplications)
   {
      if ($AllControlledFolderAccessAllowedApplications -notcontains $NewControlledFolderAccessAllowedApplication)
      {
         Write-Verbose -Message ('Add ' + $NewControlledFolderAccessAllowedApplication + ' to the Controlled Folder Access Allowed Applications list')

         $AllControlledFolderAccessAllowedApplications.Add($NewControlledFolderAccessAllowedApplication)
      }
   }
   #endregion NewControlledFolderAccessAllowedApplicationsLoop

   # Make sure we have nothing doubled
   $AllControlledFolderAccessAllowedApplications = ($AllControlledFolderAccessAllowedApplications | Sort-Object -Unique)

   # Apply the new exclusion list. This will replace the complete list.
   Write-Verbose -Message 'Apply the new Controlled Folder Access Allowed Applications list'

   $null = (Set-MpPreference -ControlledFolderAccessAllowedApplications $AllControlledFolderAccessAllowedApplications -Force -ErrorAction Continue)
   #endregion ControlledFolderAccessAllowedApplications

   #region ExclusionPath
   # Define a list of Applications to exclude - Fully Qualified
   $NewExclusionPathList = @(
      "$env:windir\SoftwareDistribution\DataStore\Datastore.edb",
      "$env:windir\SoftwareDistribution\DataStore\Logs\Edb*.jrs",
      "$env:windir\SoftwareDistribution\DataStore\Logs\Edb.chk",
      "$env:windir\SoftwareDistribution\DataStore\Logs\Tmp.edb",
      "$env:windir\Security\Database\*.edb",
      "$env:windir\Security\Database\*.sdb",
      "$env:windir\Security\Database\*.log",
      "$env:windir\Security\Database\*.chk",
      "$env:windir\Security\Database\*.jrs",
      "$env:windir\Security\Database\*.xml",
      "$env:windir\Security\Database\*.csv",
      "$env:windir\Security\Database\*.cmtx",
      "$env:ProgramData\ntuser.pol",
      "$env:windir\System32\GroupPolicy\Machine\Registry.pol",
      "$env:windir\System32\GroupPolicy\Machine\Registry.tmp",
      "$env:windir\System32\GroupPolicy\User\Registry.pol",
      "$env:windir\System32\GroupPolicy\User\Registry.tmp"
   )

   # Create a new Object
   $AllExclusionPath = (New-Object -TypeName System.Collections.Generic.List[System.Object])

   # Get the existing exclusions
   $AllExclusionPath.Add((Get-MpPreference -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ExclusionPath))

   #region NewExclusionPathLoop
   foreach ($NewExclusionPath in $NewExclusionPathList)
   {
      if ($AllExclusionPath -notcontains $NewExclusionPath)
      {
         Write-Verbose -Message ('Add ' + $NewExclusionPath + ' as path to exclude')

         $AllExclusionPath.Add($NewExclusionPath)
      }
   }
   #endregion NewExclusionPathLoop

   # Make sure we have nothing doubled
   $AllExclusionPath = ($AllExclusionPath | Sort-Object -Unique)

   # Apply the new exclusion list. This will replace the complete list.
   Write-Verbose -Message 'Apply the new Path to exclude list'

   $null = (Set-MpPreference -ExclusionPath $AllExclusionPath -Force -ErrorAction Continue)
   #endregion ExclusionPath

   #region ExclusionProcess
   # Define a list of Applications to exclude - Fully Qualified
   $NewExclusionProcessList = @(
      "$env:windir\System32\svchost.exe",
      "$env:windir\System32\wuauclt.exe"
   )

   # Create a new Object
   $AllExclusionProcess = (New-Object -TypeName System.Collections.Generic.List[System.Object])

   # Get the existing exclusions
   $AllExclusionProcess.Add((Get-MpPreference -ErrorAction SilentlyContinue | Select-Object -ExpandProperty ExclusionProcess))

   #region NewExclusionProcessLoop
   foreach ($NewExclusionProcess in $NewExclusionProcessList)
   {
      if ($AllExclusionProcess -notcontains $NewExclusionProcess)
      {
         Write-Verbose -Message ('Add ' + $NewExclusionProcess + ' as process to exclude')

         $AllExclusionProcess.Add($NewExclusionProcess)
      }
   }
   #endregion NewExclusionProcessLoop

   # Make sure we have nothing doubled
   $AllExclusionProcess = ($AllExclusionProcess | Sort-Object -Unique)

   # Apply the new exclusion list. This will replace the complete list.
   Write-Verbose -Message 'Apply the new Process to exclude list'

   $null = (Set-MpPreference -ExclusionProcess $AllExclusionProcess -Force -ErrorAction Continue)
   #endregion ExclusionProcess
   #endregion SetMpPreference

   #region ProcessMitigation
   # Local Process Mitigation file
   $ProcessMitigationFile = '.\ProcessMitigation.xml'

   # Check if we have a local Process Mitigation file
   if (-not (Test-Path -Path $ProcessMitigationFile -ErrorAction SilentlyContinue))
   {
      # Where to download the XML File?
      $ProcessMitigationUri = 'https://demo.wd.microsoft.com/Content/ProcessMitigation.xml'

      Write-Verbose -Message ('Downloading Process Mitigation file from ' + $ProcessMitigationUri)

      # Download
      $paramInvokeWebRequest = @{
         Uri         = $ProcessMitigationUri
         OutFile     = $ProcessMitigationFile
         Method      = 'Get'
         ContentType = 'text/xml'
         ErrorAction = 'Continue'
      }
      $null = (Invoke-WebRequest @paramInvokeWebRequest)
   }

   if (Test-Path -Path $ProcessMitigationFile -ErrorAction SilentlyContinue)
   {
      Write-Verbose -Message 'Enabling Exploit Protection'

      # Apply the File
      $null = (Set-ProcessMitigation -PolicyFilePath $ProcessMitigationFile -ErrorAction Continue)

      # Cleanup
      $paramRemoveItem = @{
         Path        = $ProcessMitigationFile
         Force       = $true
         Confirm     = $false
         ErrorAction = 'Continue'
      }
      $null = (Remove-Item @paramRemoveItem)
   }
   else
   {
      Write-Warning -Message ('The local Process Mitigation file (' + $ProcessMitigationFile + ') is missing! Not enabling Exploit Protection.')
   }
   #endregion ProcessMitigation

   #region WindowsDefenderSandbox
   Write-Verbose -Message 'Turn on Windows Defender Sandbox'
   $null = ([Environment]::SetEnvironmentVariable('MP_FORCE_USE_SANDBOX', 1, 'Machine'))
   #endregion WindowsDefenderSandbox

   #region AttackSurfaceReduction
   #region GetAttackSurfaceReductionRulesIds
   $AttackSurfaceReductionRulesIds = (Get-MpPreference -ErrorAction SilentlyContinue | Select-Object -ExpandProperty AttackSurfaceReductionRules_Ids)
   #endregion GetAttackSurfaceReductionRulesIds

   Write-Verbose -Message 'Enabling Attack Surface Reduction rules'

   #region SetMpPreferenceDefaults
   $AddMpPreferenceParameters = @{
      ErrorAction = 'Stop'
      Force       = $true
   }
   #endregion SetMpPreferenceDefaults

   #region RuleLoop
   foreach ($AttackSurfaceReductionRule in $AttackSurfaceReductionRuleList)
   {
      #region SingleLoop
      try
      {
         if (($Force) -or ($AttackSurfaceReductionRulesIds -notcontains $AttackSurfaceReductionRule.RuleID))
         {
            #region AppleTheRuleValue
            Write-Verbose -Message ('Set ' + $AttackSurfaceReductionRule.RuleDescription + ' to ' + $AttackSurfaceReductionRule.RuleAction)

            # Add some values
            $AddMpPreferenceParameters.AttackSurfaceReductionRules_Ids = $AttackSurfaceReductionRule.RuleID
            $AddMpPreferenceParameters.AttackSurfaceReductionRules_Actions = $AttackSurfaceReductionRule.RuleAction

            # Apply the Rule
            $null = (Add-MpPreference @AddMpPreferenceParameters)
            #endregion AppleTheRuleValue
         }
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_

         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }

         $info | Out-String | Write-Verbose

         Write-Warning -Message ('Unable to enable to Rule: ' + $AttackSurfaceReductionRule.RuleID + ' (' + $AttackSurfaceReductionRule.RuleDescription + ')')
         #endregion ErrorHandler
      }
      #endregion SingleLoop
   }
   #endregion RuleLoop
   #endregion AttackSurfaceReduction

   #region ReloadRegistry
   & "$env:windir\system32\rundll32.exe" USER32.DLL, UpdatePerUserSystemParameters , 1 , True
   #endregion ReloadRegistry

   #region EnableFirewall
   Write-Verbose -Message 'Enable the Windows Firewall for all Profiles - Set the default to block everything'
   $null = (Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True -DefaultInboundAction Block -LogBlocked True -Confirm:$false -ErrorAction Continue)
   #endregion EnableFirewall
}

end
{
   #region UpdateSignature
   Write-Verbose -Message 'Update Defender'
   $null = (Update-MpSignature)
   #endregion UpdateSignature
}

#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2021, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
