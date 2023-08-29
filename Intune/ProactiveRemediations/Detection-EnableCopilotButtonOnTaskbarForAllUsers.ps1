#requires -Version 5.0

# Enable Copilot Button on Taskbar for All Users
# Detection-EnableCopilotButtonOnTaskbarForAllUsers

try 
{
   if (!(Test-Path -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'))
   {
      Exit 1
   }

   if (!(Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideCopilotButton'))
   {
      Exit 1
   }

	
   if (!((Get-ItemProperty -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer' -Name 'HideCopilotButton' -ErrorAction SilentlyContinue) -eq $null))
   {
      Exit 1
   }
	
   if (!((Get-ItemPropertyValue -LiteralPath 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideCopilotButton' -Name 'value' -ErrorAction SilentlyContinue) -eq 0))
   {
      Exit 1
   }
}
catch
{
   Exit 1
}


Exit 0