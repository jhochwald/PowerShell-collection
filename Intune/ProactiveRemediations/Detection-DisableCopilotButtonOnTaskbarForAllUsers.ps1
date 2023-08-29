#requires -Version 5.0

# Disable Copilot Button on Taskbar for All Users
# Detection-DisableCopilotButtonOnTaskbarForAllUsers

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'

try 
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      Exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'HideCopilotButton' -ErrorAction SilentlyContinue) -eq 1))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}


Exit 0