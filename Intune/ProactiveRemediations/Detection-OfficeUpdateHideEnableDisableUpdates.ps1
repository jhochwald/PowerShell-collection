# Detection-OfficeUpdateHideEnableDisableUpdates

$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate'

try
{
   $paramTestPath = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }
   if (!(Test-Path @paramTestPath))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'hideenabledisableupdates'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
}
catch
{
   exit 1
}


exit 0