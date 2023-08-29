#requires -Version 5.0

# Enable or Disable Windows Copilot in Windows 11
# Detection-EnableOrDisableWindowsCopilotForCurrentUser

$RegPath = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'

try 
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      Exit 1
   }

	
   if ((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'TurnOffWindowsCopilot' -ErrorAction SilentlyContinue) -eq 0)
   {

   }
   else
   {
      Exit 1
   }
}
catch
{
   Exit 1
}


Exit 0