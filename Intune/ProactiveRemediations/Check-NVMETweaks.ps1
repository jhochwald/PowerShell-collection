# Check: Some relatively aggressive NVME tweaks for Windows 11
# Check-NVMETweaks.ps1

try
{
   #region ServicesstornvmeParameters
   # Source: https://github.com/AlchemyTweaks/Verified-Tweaks/tree/main/NVME
   $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\stornvme\Parameters'
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   $expectedValues = @{
      'QueueDepth'              = 64
      'NvmeMaxReadSplit'        = 4
      'NvmeMaxWriteSplit'       = 4
      'ForceFlush'              = 1
      'ImmediateData'           = 1
      'MaxSegmentsPerCommand'   = 256
      'MaxOutstandingCmds'      = 256
      'ForceEagerWrites'        = 1
      'MaxQueuedCommands'       = 256
      'MaxOutstandingIORequests'= 256
      'NumberOfRequests'        = 1500
      'IoSubmissionQueueCount'  = 3
      'IoQueueDepth'            = 64
      'HostMemoryBufferBytes'   = 1500
      'ArbitrationBurst'        = 256
   }

   foreach ($name in $expectedValues.Keys)
   {
      $value = Get-ItemPropertyValue -LiteralPath $RegPath -Name $name -ErrorAction SilentlyContinue
      if ($value -ne $expectedValues[$name])
      {
         exit 1
      }
   }
   #endregion ServicesstornvmeParameters

   #region ControlStorNVMeParametersDevice
   # Source: https://github.com/AlchemyTweaks/Verified-Tweaks/tree/main/NVME
   $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\StorNVMe\Parameters\Device'
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'QueueDepth' -ErrorAction SilentlyContinue) -eq 64))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'NvmeMaxReadSplit' -ErrorAction SilentlyContinue) -eq 4))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'NvmeMaxWriteSplit' -ErrorAction SilentlyContinue) -eq 4))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ForceFlush' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ImmediateData' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'MaxSegmentsPerCommand' -ErrorAction SilentlyContinue) -eq 256))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'MaxOutstandingCmds' -ErrorAction SilentlyContinue) -eq 256))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ForceEagerWrites' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'MaxQueuedCommands' -ErrorAction SilentlyContinue) -eq 256))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'MaxOutstandingIORequests' -ErrorAction SilentlyContinue) -eq 256))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'NumberOfRequests' -ErrorAction SilentlyContinue) -eq 1500))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'IoSubmissionQueueCount' -ErrorAction SilentlyContinue) -eq 3))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'IoQueueDepth' -ErrorAction SilentlyContinue) -eq 64))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'HostMemoryBufferBytes' -ErrorAction SilentlyContinue) -eq 1500))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ArbitrationBurst' -ErrorAction SilentlyContinue) -eq 256))
   {
      exit 1
   }
   #endregion ControlStorNVMeParametersDevice

   #region MicrosoftFeatureManagementOverrides
   <#
         Enable NVME native drivers in Windows 11
         Source: https://x.com/pureplayerpc/status/2002980378013786329
         Can significantly increase Read/Write/Seq/Rnd and can only be used with Windows 11 25H2, or later
         Experimental - Can brick Windows or third-party storage software
   #>
   $RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides'
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '735209102' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '1853569164' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '156965516' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
   #endregion MicrosoftFeatureManagementOverrides
}
catch
{
   exit 1
}

exit 0
