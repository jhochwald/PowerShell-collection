#requires -Version 5.0

# Enable "Interactive logon: Don't display last signed-in"
# Detection-EnableDontDisplayLastSignedinUser

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'dontdisplaylastusername' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
