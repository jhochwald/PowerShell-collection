#requires -Version 3.0

<#
      .SYNOPSIS
      Use the Speedtest CLI to gather connection speed

      .DESCRIPTION
      Use the Speedtest CLI to gather connection speed

      .EXAMPLE
      PS C:\> .\Invoke-SpeedtestCLI.ps1

      .NOTES
      Very simple wrapper to create a custom object for long term tracking
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([pscustomobject])]
param ()

begin
{
   #region Cleanup
   $defaultDisplaySet = $null
   $defaultDisplayPropertySet = $null
   $PSStandardMembers = $null
   $SpeedObject = $null
   $SpeedtestBinary = $null
   $SpeedtestData = $null
   #endregion Cleanup
   
   $PSDefaultParameterValues['Get-Date:Format'] = $null
   
   #region
   # Configure a default display set
   $defaultDisplaySet = 'DownloadBandwidth', 'UploadBandwidth', 'Ping', 'ServerName', 'ServerLocation'
      
   # Create the default property display set
   $defaultDisplayPropertySet = (New-Object -TypeName System.Management.Automation.PSPropertySet -ArgumentList ('DefaultDisplayPropertySet', [string[]]$defaultDisplaySet))
   $PSStandardMembers = [Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
   #endregion
}

process
{
   #region GetCLI
   $SpeedtestBinary = (Get-Command -Name speedtest.exe -ErrorAction SilentlyContinue)
   
   if (!($SpeedtestBinary.Source))
   {
      $paramWriteError = @{
         Exception         = 'speedtest.exe not found'
         Message           = 'Speedtest CLI is missing, please install it!'
         Category          = 'ObjectNotFound'
         TargetObject      = 'speedtest.exe'
         RecommendedAction = 'Goto https://www.speedtest.net/apps/cli download and install the Speedtest CLI'
         ErrorAction       = 'Stop'
      }
      Write-Error @paramWriteError
      exit 1
   }
   #endregion GetCLI
   
   #region GetSpeedtestData
   $SpeedtestData = (& $SpeedtestBinary.Source --progress=no --format=json --accept-license --accept-gdpr | ConvertFrom-Json)
   #endregion GetSpeedtestData
   
   #region ModifySpeedtestData
   [pscustomobject]$SpeedObject = [pscustomobject][ordered]@{
      DownloadBandwidth = ('{0:N2}' -f [math]::Round($SpeedtestData.download.bandwidth / 125000, 2))
      DownloadMegabytes = ('{0:N2}' -f [math]::Round($SpeedtestData.download.bytes / 1MB, 2))
      DownloadElapsed   = ('{0:hh\:mm\:ss\.ff}' -f [timespan]::FromMilliseconds($SpeedtestData.download.elapsed))
      DownloadLatency   = ('{0}' -f [math]::Round($SpeedtestData.download.latency.iqm))
      UploadBandwidth   = ('{0:N2}' -f [math]::Round($SpeedtestData.upload.bandwidth / 125000, 2))
      UploadMegabytes   = ('{0:N2}' -f [math]::Round($SpeedtestData.upload.bytes / 1MB, 2))
      UploadElapsed     = ('{0:hh\:mm\:ss\.ff}' -f [timespan]::FromMilliseconds($SpeedtestData.upload.elapsed))
      UploadLatency     = ('{0}' -f [math]::Round($SpeedtestData.upload.latency.iqm))
      IspName           = ('{0}' -f $SpeedtestData.isp)
      ServerName        = ('{0}' -f $SpeedtestData.server.name)
      ServerLocation    = ('{0}' -f $SpeedtestData.server.location)
      ServerCountry     = ('{0}' -f $SpeedtestData.server.country)
      ExternalIP        = ('{0}' -f $SpeedtestData.interface.externalip)
      InternalIP        = ('{0}' -f $SpeedtestData.interface.internalIp)
      isVPN             = ('{0}' -f [bool]$SpeedtestData.interface.isVpn)
      Ping              = ('{0}' -f [math]::Round($SpeedtestData.ping.latency))
      Jitter            = ('{0}' -f [math]::Round($SpeedtestData.ping.jitter))
   }
   
   # Give this object a unique typename
   $null = ($SpeedObject.PSObject.TypeNames.Insert(0, 'Speedtest.Information'))
   $null = ($SpeedObject | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers)
   #endregion ModifySpeedtestData
}

end
{
   #region DumpData
   $SpeedObject
   #endregion DumpData
   
   #region Cleanup
   $defaultDisplaySet = $null
   $defaultDisplayPropertySet = $null
   $PSStandardMembers = $null
   $SpeedObject = $null
   $SpeedtestBinary = $null
   $SpeedtestData = $null
   #endregion Cleanup
}
