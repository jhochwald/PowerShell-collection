#requires -Version 3.0

<#
      .SYNOPSIS
      Get FritzBox Smart Home information

      .DESCRIPTION
      Get FritzBox Smart Home information
      Only thermostats are supported as of now

      .PARAMETER FritzBoxHost
      The name or IP of the FritzBox

      .PARAMETER FritzBoxUser
      The FritzBox User account

      .PARAMETER FritzBoxPassword
      The plain text password for the given user
      Please note: This is not secure!!!

      .EXAMPLE
      PS C:\> .\Invoke-FritzBoxSmartHomePrototype.ps1

      Get FritzBox Smart Home Information's

      .NOTES
      Internal prototype, more a proof of concept and not a complete solution or application.
      You can adopt the idea behind this prototype and use it with other functions in the
      "AVM Home Automation HTTP Interface":
      https://avm.de/fileadmin/user_upload/Global/Service/Schnittstellen/AHA-HTTP-Interface.pdf

      As soon as the authentication (via SID) was done, you can execute any valid command via encoded URL requests.
      There is no real body, like you might know it from a JSON based API, just a long encoded string.

      Your FritzBox should run Version 6.69, or newer. Better 7.x, or newer.

      And I repeat myself: This it a very simple prototype (proof of concept)!
      I created this as a template to check the functions described in the "AVM Home Automation HTTP Interface" document.
      Not more, but not also less. But the functionality is very simple and also very limited.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('FritzBox')]
   [string]
   $FritzBoxHost = '<YourFritzBoxHost>',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('User')]
   [string]
   $FritzBoxUser = '<YourFritzBoxUsername>',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [string]
   $FritzBoxPassword = '<YourFritzBoxPassword>'
)

begin
{
   # Check if the defaults are used, or if anything seems to be crappy in any way
   if ((($null -eq $FritzBoxHost) -or ($FritzBoxHost -eq '') -or ($FritzBoxHost -eq '<YourFritzBoxHost>')) -or (($null -eq $FritzBoxUser) -or ($FritzBoxUser -eq '') -or ($FritzBoxUser -eq '<YourFritzBoxUsername>')) -or (($null -eq $FritzBoxPassword) -or ($FritzBoxPassword -eq '') -or ($FritzBoxPassword -eq '<YourFritzBoxPassword>')))
   {
      # Bro, what did you do? How hard can it be?
      $paramWriteError = @{
         Exception         = 'Script not configured, or parameter wrong'
         Message           = 'Please ensure you pass the correct values to the script or edit the defaults'
         Category          = 'InvalidData'
         TargetObject      = $FritzBoxHost
         RecommendedAction = 'Ensure that you overwrite the defaults or pass the correct values'
         ErrorAction       = 'Stop'
      }
      Write-Error @paramWriteError

      # Ensure we go away!
      Exit 1
   }

   #region ARM64
   # If we are running as a 32-bit process on an x64 system, re-launch as a 64-bit process
   if ("$env:PROCESSOR_ARCHITEW6432" -ne 'ARM64')
   {
      $paramTestPath = @{
         Path          = ('{0}\SysNative\WindowsPowerShell\v1.0\powershell.exe' -f $env:WINDIR)
         ErrorAction   = 'SilentlyContinue'
         WarningAction = 'SilentlyContinue'
      }
      if (Test-Path @paramTestPath)
      {
         & "$($env:WINDIR)\SysNative\WindowsPowerShell\v1.0\powershell.exe" -ExecutionPolicy bypass -NoProfile -File $PSCommandPath
         exit $lastexitcode
      }
   }
   #endregion ARM64

   #region EnsureTLS
   if ([Net.ServicePointManager]::SecurityProtocol -notcontains 'Tls12')
   {
      # This should work with all .NET frameworks / And do NOT violate CA5386
      $SecurityProtocolType = ([Enum]::ToObject([Net.SecurityProtocolType], 3072))
      $null = ([Net.ServicePointManager]::SecurityProtocol = $SecurityProtocolType)
   }
   #endregion EnsureTLS

   # Workaround for ARM64 (Access Denied / Win32 internal Server error)
   $script:ProgressPreference = 'SilentlyContinue'

   #region IgnoreCertTrust
   if (! ($IsCoreCLR))
   {
      <#
            This will not throw an error for the untrusted certificate on Windows PowerShell
            Please note: This will not work on PowerShell 6.x, or newer!
      #>

      # Ignore Certificate Errors
      [Net.ServicePointManager]::ServerCertificateValidationCallback = {
         $true
      }

      try
      {
         if (-not ('dummy' -as [type]))
         {
            $null = (Add-Type -TypeDefinition @'
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;

public static class Dummy
{
    private static bool ReturnTrue(
        object sender,
        X509Certificate certificate,
        X509Chain chain,
        SslPolicyErrors sslPolicyErrors
    )
    {
        return true;
    }

    public static RemoteCertificateValidationCallback GetDelegate()
    {
        return ReturnTrue;
    }
}
'@ -ErrorAction SilentlyContinue)
         }
         $null = [Net.ServicePointManager]::ServerCertificateValidationCallback = [dummy]::GetDelegate()
      }
      catch
      {
         Write-Verbose -Message 'Shit happens!'
      }

      try
      {
         if (-not ('TrustAllCertsPolicy' -as [type]))
         {
            $null = (Add-Type -TypeDefinition @'
using System.Net;
using System.Security.Cryptography.X509Certificates;

namespace Dummy;

public class TrustAllCertsPolicy : ICertificatePolicy
{
    public bool CheckValidationResult(
        ServicePoint srvPoint,
        X509Certificate certificate,
        WebRequest request,
        int certificateProblem
    )
    {
        return true;
    }
}
'@ -ErrorAction SilentlyContinue)
         }
         $null = [Net.ServicePointManager]::CertificatePolicy = (New-Object -TypeName TrustAllCertsPolicy)
      }
      catch
      {
         Write-Verbose -Message 'Shit happens!'
      }
   }
   #endregion IgnoreCertTrust

   #region Helper
   function Get-MD5sum
   {
      <#
            .SYNOPSIS
            Get a MD5 sum of a given string

            .DESCRIPTION
            Get a MD5 sum of a given string

            .PARAMETER text
            The string you want the MD5 sum for

            .EXAMPLE
            PS C:\> Get-MD5sum -text 'Value1'

            .NOTES
            Make it compatible to the md5sum on Linux
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([object])]
      param
      (
         [Parameter(Mandatory, HelpMessage = 'The string you want the MD5 sum for',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [string]
         $text
      )

      begin
      {
         # Clean up
         $HC = $null
         # Create a new object
         $md5 = (New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider)
      }

      process
      {
         try
         {
            # Generate the MD5 sum
            $md5.ComputeHash([Text.Encoding]::utf8.getbytes($text)) | ForEach-Object -Process {
               $HC = ''
            } {
               $HC += $_.tostring('x2')
            } {
               $HC
            }
         }
         catch
         {
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

            Write-Error -Exception $info.Exception -Message $info.Exception -TargetObject $info.Target -ErrorAction Stop
         }
      }
   }
   #endregion Helper

   #region Cleanup
   $hostfb = $null
   $page_login = $null
   $Challenge = $null
   $Code1 = $null
   $Code2 = $null
   $Response = $null
   $SID = $null
   $ainlist = $null
   $item = $null
   #endregion Cleanup

   # Constants - Should be a switch in the future
   #$hostfb = ('https://{0}:46065' -f $FritzBoxHost) # See your FritzBox for the external port, if you want to use it from outside of your network (Might not be smart, but you decide)
   $hostfb = ('https://{0}:443' -f $FritzBoxHost)
   $page_login = '/login_sid.lua'
}

process
{
   #region SidAuth
   # Get the challenge code
   $paramInvokeRestMethod = @{
      Method      = 'Get'
      Uri         = ($hostfb + $page_login)
      ErrorAction = 'Stop'
   }
   if ($IsCoreCLR)
   {
      <#
            This will not throw an error for the untrusted certificate on PowerShell 6.x, or newer!
            Please note: Windows PowerShell does NOT understand this parameters, therefore we can NOT use there.
      #>
      $paramInvokeRestMethod.SkipCertificateCheck = $true
      $paramInvokeRestMethod.SkipHttpErrorCheck = $true
   }
   $Challenge = (Invoke-RestMethod @paramInvokeRestMethod).SessionInfo.challenge
   # Merge the challange code with the given password (plain text, therefore insecure)
   $Code1 = $Challenge + '-' + $FritzBoxPassword
   # Mangle the string
   $Code2 = [char[]]$Code1 | ForEach-Object -Process {
      $Code2 = ''
   } {
      $Code2 += $_ + [Char]0
   } {
      $Code2
   }
   # Get the MD5sum for the string from above
   $Response = 'response=' + $Challenge + '-' + $(Get-MD5sum -text ($Code2) -ErrorAction Stop)
   # Append the user for the login
   $Response += '&username=' + $FritzBoxUser
   # Do the login
   $paramInvokeRestMethod = @{
      Method      = 'Post'
      Uri         = ($hostfb + $page_login)
      Body        = $Response
      ErrorAction = 'Stop'
   }
   if ($IsCoreCLR)
   {
      $paramInvokeRestMethod.SkipCertificateCheck = $true
      $paramInvokeRestMethod.SkipHttpErrorCheck = $true
   }
   $SID = ((Invoke-RestMethod @paramInvokeRestMethod).SessionInfo.SID)
   #endregion SidAuth

   #region DeviceList
   # Get the list of smart home devices
   $paramInvokeRestMethod = @{
      Method      = 'Get'
      Uri         = ($hostfb + '/webservices/homeautoswitch.lua?switchcmd=getdevicelistinfos&sid=' + $SID)
      ErrorAction = 'Stop'
   }
   if ($IsCoreCLR)
   {
      $paramInvokeRestMethod.SkipCertificateCheck = $true
      $paramInvokeRestMethod.SkipHttpErrorCheck = $true
   }
   $ainlist = (Invoke-RestMethod @paramInvokeRestMethod)

   <#
         All Devices are now stored in the $ainlist variable!
         You might want to check it for other device types, not all are supported within this prototype.
   #>
   #endregion DeviceList

   # Loop over the list
   foreach ($item in ($ainlist.devicelist.device))
   {
      # Thermostats - Because I only have "Comet DECT" devices to test
      if ($item.productname -eq 'Comet DECT')
      {
         $DeviceName = $item.name
         # Remove the blanks in the string
         $DeviceAin = ($item.identifier -replace ' ', '')
         # the next few variables are not used, so I collect them just for fun
         $DeviceManufacturer = $item.manufacturer
         $DeviceProductname = $item.productname
         $DevicePresent = $item.present
         $DeviceFirmware = $item.fwversion
         # That will make it human readable and append a decimal delimiter to it
         $hkrTist = '{0:N1}' -f $([Math]::Floor($item.hkr.tist) / 2)
         $hkrTsoll = '{0:N1}' -f $([Math]::Floor($item.hkr.tsoll) / 2)
         $hkrAbsenk = '{0:N1}' -f $([Math]::Floor($item.hkr.absenk) / 2)
         $hkrKomfort = '{0:N1}' -f $([Math]::Floor($item.hkr.komfort) / 2)
         $DeviceBatteryLevel = $item.battery
         # Make the battery warning a bool
         [bool]$DeviceBatteryWarnung = $(if ($item.batterylow -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceBatteryWarnung = $(if ($item.batterylow -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         # the next few variables are not used, so I collect them just for fun
         [bool]$DeviceLock = $(if ($item.hkr.lock -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceDeviceLock = $(if ($item.hkr.devicelock -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceErrorCode = $(if ($item.hkr.errorcode -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         # Make the window open warning a bool
         [bool]$DeviceWindowOpenActiv = $(if ($item.hkr.windowopenactiv -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         # the next few variables are not used, so I collect them just for fun
         [bool]$DeviceWindowOpenActiveEndTime = $(if ($item.hkr.windowopenactiveendtime -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceBoostActive = $(if ($item.hkr.boostactive -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceBoostActiveEndTime = $(if ($item.hkr.boostactiveendtime -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceSummerActive = $(if ($item.hkr.summeractive -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceHolidayActive = $(if ($item.hkr.holidayactive -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceAdaptiveHeatingActive = $(if ($item.hkr.adaptiveHeatingActive -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         [bool]$DeviceAdaptiveHeatingRunning = $(if ($item.hkr.adaptiveHeatingRunning -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )
         $DeviceNextChange = $item.hkr.nextchange

         <#
               Now we just dump the info to the console!
               I recommend to use a psoject! But for this prototype we just dump some strings!!!
               As a very simple showcase this is enough, right?
         #>

         # Device Name
         ('{0}' -f $DeviceName)
         # Window open warning
         if ($DeviceWindowOpenActiv)
         {
            Write-Warning -Message 'The window is open!!!'
         }
         # Just for the fun of it
         Write-Verbose -Message ('AIN: {0}' -f $DeviceAin)
         # Actual Temperature
         ('Actual-Temperature: {0} °C' -f $hkrTist)
         ('Should-emperature: {0} °C' -f $hkrTsoll)
         ('Lowering-emperature: {0} °C' -f $hkrAbsenk)
         ('Comfort-emperature: {0} °C' -f $hkrKomfort)
         ('Battery-Level: {0}%' -f $DeviceBatteryLevel)
         ('Battery-Warning: {0}' -f $DeviceBatteryWarnung)
         ''
      }

      # Button and sensing device - I only have one "FRITZ!DECT 440" to do tests.
      if ($item.productname -eq 'FRITZ!DECT 440')
      {
         $DeviceName = $item.name
         $DeviceAin = $item.identifier -replace ' ', ''
         # the next few variables are not used, so I collect them just for fun
         $DeviceManufacturer = $item.manufacturer
         $DeviceProductname = $item.productname
         $DevicePresent = $item.present
         $DeviceFirmware = $item.fwversion
         # That will make it human readable and append a decimal delimiter to it
         $TemperatureCelsius = '{0:N1}' -f $([Math]::Floor($item.temperature.celsius) / 10)
         $humidityPercentage = $item.humidity.rel_humidity
         $DeviceBatteryLevel = $item.battery
         # Make it a bool
         [bool]$DeviceBatteryWarnung = $(if ($item.batterylow -eq 0)
            {
               $false
            }
            else
            {
               $true
            }
         )

         <#
               Now we just dump the info to the console!
               I recommend to use a psoject! But for this prototype we just dump some strings!!!
               As a very simple showcase this is enough, right?
         #>

         ('{0}' -f $DeviceName)
         Write-Verbose -Message ('AIN: {0}' -f $DeviceAin)
         ('Actual-Temperature: {0} °C' -f $TemperatureCelsius)
         ('Humidity: {0}%' -f $humidityPercentage)
         ('Battery-Level: {0}%' -f $DeviceBatteryLevel)
         ('Battery-Warning: {0}' -f $DeviceBatteryWarnung)
         ''
      }
   }
}

end
{
   # Logoff because we do NOT need the session any longer!
   $paramInvokeRestMethod = @{
      Method      = 'Get'
      Uri         = ($hostfb + $page_login + '?logout=1&sid=' + $SID)
      ErrorAction = 'SilentlyContinue'
   }
   if ($IsCoreCLR)
   {
      $paramInvokeRestMethod.SkipCertificateCheck = $true
      $paramInvokeRestMethod.SkipHttpErrorCheck = $true
   }
   $null = (Invoke-RestMethod @paramInvokeRestMethod)

   # Ensure the certificate trust is restored
   [Net.ServicePointManager]::ServerCertificateValidationCallback = $null

   #region Cleanup
   $hostfb = $null
   $page_login = $null
   $Challenge = $null
   $Code1 = $null
   $Code2 = $null
   $Response = $null
   $SID = $null
   $ainlist = $null
   $item = $null
   #endregion Cleanup
}