#requires -Version 1.0

# Enable or Disable Windows Copilot in Windows 11
# Remediation-EnableOrDisableWindowsCopilotForCurrentUser

$RegPath = 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
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
   Name         = 'TurnOffWindowsCopilot'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
