#requires -Version 1.0

# Enable Cellular Data Roaming
# Detection-EnableCellularDataRoaming

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WcmSvc\GroupPolicy'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemProperty -LiteralPath $RegPath -Name 'fBlockRoaming' -ErrorAction SilentlyContinue) -eq $null))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
