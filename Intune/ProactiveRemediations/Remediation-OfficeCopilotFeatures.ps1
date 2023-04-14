<#
   Remediation: Enable or disable Copilot Preview Feature in Office
#>

# Enable or disable Copilot Preview with this bool
$EnableCopilot = 'true'

#region ExternalFeatureOverrides
$RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides'

if ((Test-Path -LiteralPath $RegistryPath) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegistryPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}
#endregion ExternalFeatureOverrides

#region ExternalFeatureOverridesExcel
$RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\excel'

if ((Test-Path -LiteralPath $RegistryPath) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegistryPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $RegistryPath
   Name         = 'Microsoft.Office.Excel.CopilotExperiment'
   Value        = $EnableCopilot
   PropertyType = 'String'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ExternalFeatureOverridesExcel

#region ExternalFeatureOverridesOneNote
$RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\onenote'

if ((Test-Path -LiteralPath $RegistryPath) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegistryPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $RegistryPath
   Name         = 'Microsoft.Office.OneNote.Copilot'
   Value        = $EnableCopilot
   PropertyType = 'String'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ExternalFeatureOverridesOneNote

#region ExternalFeatureOverridesPowerPoint
$RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\powerpoint'

if ((Test-Path -LiteralPath $RegistryPath) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegistryPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
}

$paramNewItemProperty = @{
   LiteralPath  = $RegistryPath
   Name         = 'Microsoft.Office.PowerPoint.CopilotExperiment'
   Value        = $EnableCopilot
   PropertyType = 'String'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
#endregion ExternalFeatureOverridesPowerPoint