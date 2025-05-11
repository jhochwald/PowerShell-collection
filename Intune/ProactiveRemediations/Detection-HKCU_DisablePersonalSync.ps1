# Detection: Prevent users from syncing personal OneDrive accounts
#https://learn.microsoft.com/en-us/sharepoint/use-group-policy?WT.mc_id=M365-MVP-4040055#prevent-users-from-syncing-personal-onedrive-accounts

$RegPath = 'HKCU:\Software\Microsoft\OneDrive'

try
{
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'DisablePersonalSync'
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
