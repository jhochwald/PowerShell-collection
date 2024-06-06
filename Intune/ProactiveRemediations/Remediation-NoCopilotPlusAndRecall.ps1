# Remediation: Prevent Windows Copilot/Copilot+ and Windows Recall from being installed from updates

#region Copilot
$CopilotRegPath = 'HKLM:\Software\Policies\Microsoft\Windows\WindowsCopilot'

if ((Test-Path -LiteralPath $CopilotRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $CopilotRegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'Stop'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $CopilotRegPath
   Name         = 'TurnOffWindowsCopilot'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'Stop'
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion Copilot

#region Recall
$RecallRegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI'

if ((Test-Path -LiteralPath $RecallRegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $RecallRegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'Stop'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $RecallRegPath
   Name         = 'DisableAIDataAnalysis'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'Stop'
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion Recall