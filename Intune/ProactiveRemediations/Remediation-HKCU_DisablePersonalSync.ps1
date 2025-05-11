# Remediation: Prevent users from syncing personal OneDrive accounts
# https://learn.microsoft.com/en-us/sharepoint/use-group-policy?WT.mc_id=M365-MVP-4040055#prevent-users-from-syncing-personal-onedrive-accounts

$RegPath = 'HKCU:\Software\Microsoft\OneDrive'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'DisablePersonalSync'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null
