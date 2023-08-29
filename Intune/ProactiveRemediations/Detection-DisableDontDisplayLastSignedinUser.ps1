#requires -Version 1.0

# Disable "Interactive logon: Don't display last signed-in"
# Detection-DisableDontDisplayLastSignedinUser

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemProperty -LiteralPath $RegPath -Name 'dontdisplaylastusername' -ErrorAction SilentlyContinue) -eq $null))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
