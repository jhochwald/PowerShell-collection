# Detection: Opting in to preview Visual Studio updates via Microsoft Update
# https://developercommunity.visualstudio.com/t/automatic-updates/599126

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\VisualStudio\Setup'

$paramDefaults = @{
   LiteralPath = $RegPath
   ErrorAction = 'SilentlyContinue'
}

try
{
   if (!(Test-Path @paramDefaults))
   {
      exit 1
   }

   # Join Preview = 1 / Leave Preview = 0
   if (!((Get-ItemPropertyValue -Name 'PreviewAutomaticUpdates' @paramDefaults) -eq 1))
   {
      exit 1
   }

   # Opt-in = 0 / Opt-out = 1
   if (!((Get-ItemPropertyValue -Name 'VSthroughMUUpdatesOptOut' @paramDefaults) -eq 0))
   {
      exit 1
   }
}
catch
{
   exit 1
}

exit 0
