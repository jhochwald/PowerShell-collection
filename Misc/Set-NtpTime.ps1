function Set-NtpTime
{
   <#
         .SYNOPSIS
         Sets up NTP time sync properly
   
         .DESCRIPTION
         Sets the NTP time settings used by the Windows Time service to sync time
         based on Microsoft Best practices for domain joined computers according to their role.
   
         .PARAMETER NTPServer
         manualpeerlist for the w32tm command
         Defaults is 'time.nist.gov'
   
         .PARAMETER SetClockToUTC
         Sets clock to UTC, prevents time issues when dual booting Linux/OSX systems.
   
         .EXAMPLE
         PS C:\> Set-NtpTime
      
         Sets up NTP time sync properly, using the defaults
   
         .EXAMPLE
         PS C:\> Set-NtpTime -NTPServer 'de.pool.ntp.org'
      
         Sets up NTP time sync properly, using 'de.pool.ntp.org' as source
   
         .EXAMPLE
         PS C:\> Set-NtpTime -NTPServer '0.de.pool.ntp.org 1.de.pool.ntp.org 2.de.pool.ntp.org 3.de.pool.ntp.org'
      
         Sets up NTP time sync properly, using the 'de.pool.ntp.org' pool as source
   
         .EXAMPLE
         PS C:\> Set-NtpTime -NTPServer 'de.pool.ntp.org'
      
         Sets up NTP time sync properly, using 'de.pool.ntp.org' as source and sets clock to UTC,
         prevents time issues when dual booting Linux/OSX systems.
   
         .NOTES
         Original is created by: Vern Anderson (@VernAnderson)
         Original source file: https://github.com/VernAnderson/PowerShell/blob/master/Set-NTPTime.ps1
      
         From the original author:
         This command should be used with caution on Windows Clusters as the cluster service depends on the time service.
         Time is also extremely important for proper logon and kerberos tickets from Active Directory.
         One should never turn their backs on time -Castaway
      
         This also replaces the procedure is described in my Blog, many moons ago!
   
         .LINK
         https://learn.microsoft.com/en-us/archive/technet-wiki/50924.active-directory-time-synchronization
   
         .LINK
         https://hochwald.net/synchronize-time-with-external-ntp-server/
   #>
   
   [CmdletBinding(ConfirmImpact = 'Low',
   SupportsShouldProcess)]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('manualpeerlist', 'peerlist', 'NtpServerList')]
      [string]
      $NTPServer = 'time.nist.gov',
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('UTCClock')]
      [switch]
      $SetClockToUTC
   )
   
   begin
   {
      #region PrivilegeElevation
      <#
            It is required to run this as admin!
            But for a function "#Requires -RunAsAdministrator" can not be used
            This workaround should do the trick for us!
      #>
      if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
      {
         # Simply retry as admin, as a workaround
         $GetMyProcess = ((Get-Process -Id $PID).Path)

         if (($GetMyProcess -like '*pwsh.exe') -and ($GetMyProcess -like '*powershell.exe'))
         {
            Write-Error -Exception 'Unsupported Shell' -Message ('Sorry, but ''{0}'' is not a supported shell! Elevation workaround does not work.' -f $GetMyProcess) -Category PermissionDenied -TargetObject $GetMyProcess -RecommendedAction ('Please start ''{0}'' in an elevated shell!' -f $PSCommandPath) -ErrorAction Stop
         }
         else
         {
            Start-Process -FilePath $GetMyProcess -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -Command `"cd '{0}'; & '{1}';`"" -f $pwd, $PSCommandPath) -Verb RunAs
         }

         $GetMyProcess = $null

         exit
      }
      #endregion PrivilegeElevation

      #region SetupDefaults
      # Set some defaults
      [bool]$IsDcServer = $false
      [bool]$w32timeWasRunning = $false
      #endregion SetupDefaults
      
      #region GetDomainRole
      # Get the systems role
      $DomainRole = ((Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop).DomainRole)
      
      # Identify the role
      switch ($DomainRole)
      {
         0
         {
            'Stand Alone Workstation'
            $SYNCType = 'MANUAL'
         }
         1
         {
            'Member Workstation'
            $SYNCType = 'DOMHIER'
         }
         2
         {
            'Standalone Server'
            $SYNCType = 'MANUAL'
         }
         3
         {
            'Member Server'
            $SYNCType = 'DOMHIER'
         }
         4
         {
            'Backup Domain Controller'
            $SYNCType = 'DOMHIER'
            [bool]$IsDcServer = $false
         }
         5
         {
            'Primary Domain Controller'
            $SYNCType = 'MANUAL'
            [bool]$IsDcServer = $false
         }
         default
         {
            # This should never happen, right?
            Write-Warning -Message ('Returned value ''{0}'' is unknown, we try a manual sync...' -f $DomainRole)
            $SYNCType = 'MANUAL'
         }
      }
      
      # Clean-Up early
      $DomainRole = $null
      #endregion GetDomainRole
   }
   
   process
   {
      #region SetClockToUTC
      # Is the switch used?
      if ($SetClockToUTC.IsPresent)
      {
         # ShouldProcessSupport
         if ($pscmdlet.ShouldProcess('System clock', 'Set to UTC'))
         {
            # Let us set the value, by force - So, we don't check anything
            $paramNewItemProperty = @{
               Path          = 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation'
               Name          = 'RealTimeIsUniversal'
               Value         = 1
               PropertyType  = 'DWord'
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'Continue'
               WarningAction = 'SilentlyContinue'
            }
            $null = (New-ItemProperty @paramNewItemProperty)
            $paramNewItemProperty = $null
         }
      }
      #endregion SetClockToUTC
      
      # ShouldProcessSupport
      if ($pscmdlet.ShouldProcess('Local time', ('Sync with flag {0} and server {1}' -f $SYNCType, $NTPServer)))
      {
         #region CheckIfW32timeIsRunning
         # Is the w32time running?
         if ((Get-Service -Name w32time).Status -eq 'Running')
         {
            [bool]$w32timeWasRunning = $true
            
            # It must be stopped!!!
            $paramStopService = @{
               Name          = 'w32time'
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'SilentlyContinue'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Stop-Service @paramStopService)
            # Let us ensure that, just in case!!!
            $null = (Stop-Service @paramStopService)
            $paramStopService = $null
         }
         #endregion CheckIfW32timeIsRunning
         
         #region SetupNtpServerUsage
         if ($null -ne $SYNCType)
         {
            $W32tmBin = ((Get-Command -Name 'w32tm.exe' -ErrorAction Stop).Source)
            
            if ($W32tmBin)
            {
               $paramStartProcess = @{
                  FilePath     = $W32tmBin
                  ArgumentList = ('/config /update /manualpeerlist:{0} /syncfromflags:{1}' -f $NTPServer, $SYNCType)
                  NoNewWindow  = $true
                  Wait         = $true
               }
               (Start-Process @paramStartProcess)
               $paramStartProcess = $null
            }
         }
         #endregion SetupNtpServerUsage
         
         #region MakeDomainControllerReliable
         # Is this a Domain Controller?
         if ($IsDcServer -eq $true)
         {
            # Make your PDC a reliable time source for others, because we have the accurate time now...
            $paramStartProcess = @{
               FilePath     = $W32tmBin
               ArgumentList = '/config /reliable:yes'
               NoNewWindow  = $true
               Wait         = $true
            }
            Start-Process @paramStartProcess
            $paramStartProcess = $null
         }
         #endregion MakeDomainControllerReliable
         
         #region RestartW32timeIfRequired
         if ($w32timeWasRunning -eq $true)
         {
            $paramStartService = @{
               Name          = 'w32time'
               Confirm       = $false
               ErrorAction   = 'SilentlyContinue'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Start-Service @paramStartService)
            $paramStartService = $null
         }
         #endregion RestartW32timeIfRequired
         
         #region ShowInfo
         # Show what we have now
         $paramStartProcess = @{
            FilePath     = $W32tmBin
            ArgumentList = '/dumpreg /subkey:Parameters'
            NoNewWindow  = $true
            Wait         = $true
         }
         Start-Process @paramStartProcess
         $paramStartProcess = $null
         #endregion ShowInfo
      }
   }
   
   end
   {
      #region FinalCleanup
      $IsDcServer = $null
      $w32timeWasRunning = $null
      #endregion FinalCleanup
      
      #region GarbageCollection
      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      #endregion GarbageCollection
   }
}
