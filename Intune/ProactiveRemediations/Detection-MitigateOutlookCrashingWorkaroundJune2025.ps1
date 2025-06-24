# Classic Outlook crashes opening or starting a new email
# Detection-MitigateOutlookCrashingWorkaroundJune2025.ps1

<#
      How to use it in Intune:
      - Run this script using the logged-on credentials (This is crucial)
      - Run script in 64-bit PowerShell
#>

# https://support.microsoft.com/en-us/office/classic-outlook-crashes-opening-or-starting-a-new-email-1b413573-7dfc-4147-9c53-c2f1183b89b8

$Forms2Path = ('{0}\Microsoft\FORMS2' -f $env:LOCALAPPDATA)

try
{
   if (!(Test-Path -Path $Forms2Path -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   else
   {
      exit 0
   }
}
catch
{
   exit 1
}

# Make a clean exit
exit 0
