#requires -Version 5.0

# Remove Copilot Button from Taskbar for current user
# Detection-RemoveCopilotButtonFromTaskbarForCurrentUser

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

try 
{
   if (!(Test-Path -LiteralPath $RegPath))
   {
      Exit 1
   }

	
   if (!((Get-ItemPropertyValue -LiteralPath $RegPath -Name 'ShowCopilotButton' -ErrorAction SilentlyContinue) -eq 0))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}


Exit 0