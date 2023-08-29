#requires -Version 1.0

# Enable Phone Link app for All Users
# Detection-EnablePhoneLinkAppForAllUsers

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemProperty -LiteralPath $RegPath -Name 'EnableMmx' -ErrorAction SilentlyContinue) -eq $null))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
