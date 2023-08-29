#requires -Version 5.0

# Turn on Phone Link for current user
# Detection-TurnOnPhoneLinkForCurrentUser

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Mobility'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'PhoneLinkEnabled' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
