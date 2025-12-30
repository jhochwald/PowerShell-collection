# Remediate: Some relatively aggresiv NVME tweaks for Windows 11
# Remediate-NVMETweaks.ps1

#region ServicesstornvmeParameters
# Source: https://github.com/AlchemyTweaks/Verified-Tweaks/tree/main/NVME
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\stornvme\Parameters'
if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path          = $RegPath
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

$paramNewItemProperty = @{
   LiteralPath   = $RegPath
   PropertyType  = 'DWord'
   Force         = $true
   Confirm       = $false
   ErrorAction   = 'SilentlyContinue'
   WarningAction = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty -Name 'QueueDepth' -Value 64)
$null = (New-ItemProperty @paramNewItemProperty -Name 'NvmeMaxReadSplit' -Value 4)
$null = (New-ItemProperty @paramNewItemProperty -Name 'NvmeMaxWriteSplit' -Value 4)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ForceFlush' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ImmediateData' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxSegmentsPerCommand' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxOutstandingCmds' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ForceEagerWrites' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxQueuedCommands' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxOutstandingIORequests' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'NumberOfRequests' -Value 1500)
$null = (New-ItemProperty @paramNewItemProperty -Name 'IoSubmissionQueueCount' -Value 3)
$null = (New-ItemProperty @paramNewItemProperty -Name 'IoQueueDepth' -Value 64)
$null = (New-ItemProperty @paramNewItemProperty -Name 'HostMemoryBufferBytes' -Value 1500)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ArbitrationBurst' -Value 256)
$paramNewItemProperty = $null
#endregion ServicesstornvmeParameters

#region ControlStorNVMeParametersDevice
# Source: https://github.com/AlchemyTweaks/Verified-Tweaks/tree/main/NVME
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\StorNVMe\Parameters\Device'
if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path          = $RegPath
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

$paramNewItemProperty = @{
   LiteralPath   = $RegPath
   PropertyType  = 'DWord'
   Force         = $true
   Confirm       = $false
   ErrorAction   = 'SilentlyContinue'
   WarningAction = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty -Name 'QueueDepth' -Value 64)
$null = (New-ItemProperty @paramNewItemProperty -Name 'NvmeMaxReadSplit' -Value 4)
$null = (New-ItemProperty @paramNewItemProperty -Name 'NvmeMaxWriteSplit' -Value 4)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ForceFlush' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ImmediateData' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxSegmentsPerCommand' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxOutstandingCmds' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ForceEagerWrites' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxQueuedCommands' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'MaxOutstandingIORequests' -Value 256)
$null = (New-ItemProperty @paramNewItemProperty -Name 'NumberOfRequests' -Value 1500)
$null = (New-ItemProperty @paramNewItemProperty -Name 'IoSubmissionQueueCount' -Value 3)
$null = (New-ItemProperty @paramNewItemProperty -Name 'IoQueueDepth' -Value 64)
$null = (New-ItemProperty @paramNewItemProperty -Name 'HostMemoryBufferBytes' -Value 1500)
$null = (New-ItemProperty @paramNewItemProperty -Name 'ArbitrationBurst' -Value 256)
$paramNewItemProperty = $null
#endregion ControlStorNVMeParametersDevice

#region MicrosoftFeatureManagementOverrides
<#
      Enable NVME native drivers in Windows 11
      Source: https://x.com/pureplayerpc/status/2002980378013786329
      Can significantly increase Read/Write/Seq/Rnd and can only be used with Windows 11 25H2, or later
      Experimental - Can brick Windows or third-party storage software
#>
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides'
if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path          = $RegPath
      Force         = $true
      Confirm       = $false
      ErrorAction   = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

$paramNewItemProperty = @{
   LiteralPath   = $RegPath
   PropertyType  = 'DWord'
   Force         = $true
   Confirm       = $false
   ErrorAction   = 'SilentlyContinue'
   WarningAction = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty -Name '735209102' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name '1853569164' -Value 1)
$null = (New-ItemProperty @paramNewItemProperty -Name '156965516' -Value 1)
$paramNewItemProperty = $null
#endregion MicrosoftFeatureManagementOverrides
