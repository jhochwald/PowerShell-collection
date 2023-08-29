#requires -Version 5.0

# UAC "Notify me only when apps try to make changes to my computer (default)"
# Detection-UACDefault

$RegPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'PromptOnSecureDesktop' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'EnableLUA' -ErrorAction SilentlyContinue) -eq 1))
   {
      exit 1
   }
   
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ConsentPromptBehaviorAdmin' -ErrorAction SilentlyContinue) -eq 5))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0
