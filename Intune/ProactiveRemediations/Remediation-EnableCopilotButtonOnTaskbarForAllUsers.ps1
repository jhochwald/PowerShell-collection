#requires -Version 1.0

# Enable Copilot Button on Taskbar for All Users
# Remediation-EnableCopilotButtonOnTaskbarForAllUsers

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer') -ne $true)
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

if ((Test-Path -LiteralPath 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideCopilotButton') -ne $true)
{
   $paramNewItem = @{
      Path        = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideCopilotButton'
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramRemoveItemProperty = @{
   LiteralPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer'
   Name        = 'HideCopilotButton'
   Force       = $true
   Confirm     = $false
   ErrorAction = 'SilentlyContinue'
}
$null = (Remove-ItemProperty @paramRemoveItemProperty)

$paramNewItemProperty = @{
   LiteralPath  = 'HKLM:\SOFTWARE\Microsoft\PolicyManager\default\Start\HideCopilotButton'
   Name         = 'value'
   Value        = 0
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
