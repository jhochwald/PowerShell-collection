#requires -Version 5.0

# Disable Copilot for All Users
# Detection-DisableCopilotForAllUsers

$RegPath = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsCopilot'

try 
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      Exit 1
   }

	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue) -eq 0))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}


Exit 0