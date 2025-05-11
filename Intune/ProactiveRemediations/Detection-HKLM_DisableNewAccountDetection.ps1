# Detection: Hide the messages to sync Consumer OneDrive files
# https://learn.microsoft.com/en-us/sharepoint/use-group-policy?WT.mc_id=M365-MVP-4040055#hide-the-messages-to-sync-consumer-onedrive-files

$RegPath = 'HKLM:\SOFTWARE\Microsoft\OneDrive'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'DisableNewAccountDetection'
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
