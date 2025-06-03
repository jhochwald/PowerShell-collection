# Detection Auto Time-Zone Update
# Detection-AutoTimeZoneUpdate

try 
{
   #region tzautoupdate
   [string]$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate'

   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'Start' -ErrorAction SilentlyContinue) -eq 3))
   {
      exit 1
   }
   
   $RegPath = $null
   #endregion tzautoupdate

   #region location
   [string]$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'
   
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }

   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'Value' -ErrorAction SilentlyContinue) -eq 'Allow'))
   {
      exit 1
   }
   
   $RegPath = $null
   #endregion location
}
catch
{
   exit 1
}

# Ensure a clean exit!
exit 0
