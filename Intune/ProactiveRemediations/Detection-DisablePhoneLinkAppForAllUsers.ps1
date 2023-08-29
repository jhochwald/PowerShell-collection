#requires -Version 5.0

# Disable Phone Link app for All Users
# Detection-DisablePhoneLinkAppForAllUsers

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'EnableMmx' -ErrorAction SilentlyContinue) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
