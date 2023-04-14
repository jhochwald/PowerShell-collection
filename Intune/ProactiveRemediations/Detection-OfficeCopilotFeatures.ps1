<#
   Detection: Enable or disable Copilot Preview Feature in Office
#>

# Enable or disable Copilot Preview with this bool
$EnableCopilot = 'true'

try
{
   #region ExternalFeatureOverrides
   if (-not (Test-Path -LiteralPath 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides' -ErrorAction Stop))
   {
      exit 1
   }
   #endregion ExternalFeatureOverrides

   #region ExternalFeatureOverridesExcel
   $RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\excel'

   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction Stop))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'Microsoft.Office.Excel.CopilotExperiment' -ErrorAction Stop) -eq $EnableCopilot))
   {
      exit 1
   }
   #endregion ExternalFeatureOverridesExcel

   #region ExternalFeatureOverridesOneNote
   $RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\onenote'

   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction Stop))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'Microsoft.Office.OneNote.Copilot' -ErrorAction Stop) -eq $EnableCopilot))
   {
      exit 1
   }
   #endregion ExternalFeatureOverridesOneNote

   #region ExternalFeatureOverridesPowerPoint
   $RegistryPath = 'HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentConfigs\ExternalFeatureOverrides\powerpoint'

   if (-not (Test-Path -LiteralPath $RegistryPath -ErrorAction Stop))
   {
      exit 1
   }

   if (-not ((Get-ItemPropertyValue -LiteralPath $RegistryPath -Name 'Microsoft.Office.PowerPoint.CopilotExperiment' -ErrorAction Stop) -eq $EnableCopilot))
   {
      exit 1
   }
   #endregion ExternalFeatureOverridesPowerPoint
}
catch
{
   exit 1
}

exit 0