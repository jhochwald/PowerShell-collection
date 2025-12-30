# Check: Enabling NVME native drivers in Win 11
# Check-EnablingNvmeNativeDrivers.ps1

$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Policies\Microsoft\FeatureManagement\Overrides'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      $RegPath = $null
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '735209102' -ErrorAction SilentlyContinue) -eq 1))
   {
      $RegPath = $null
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '1853569164' -ErrorAction SilentlyContinue) -eq 1))
   {
      $RegPath = $null
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name '156965516' -ErrorAction SilentlyContinue) -eq 1))
   {
      $RegPath = $null
      exit 1
   }
}
catch
{
   $RegPath = $null
   exit 1
}

$RegPath = $null
exit 0
