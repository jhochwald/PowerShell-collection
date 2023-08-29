#requires -Version 1.0

# Remove Copilot Button from Taskbar for current user
# Remediation-RemoveCopilotButtonFromTaskbarForCurrentUser

$RegPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

if ((Test-Path -LiteralPath $RegPath) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'ShowCopilotButton'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
