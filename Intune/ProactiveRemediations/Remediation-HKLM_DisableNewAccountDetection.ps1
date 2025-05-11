# Remediation: Hide the messages to sync Consumer OneDrive files
# https://learn.microsoft.com/en-us/sharepoint/use-group-policy?WT.mc_id=M365-MVP-4040055#hide-the-messages-to-sync-consumer-onedrive-files

$RegPath = 'HKLM:\SOFTWARE\Microsoft\OneDrive'

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
   Name         = 'DisableNewAccountDetection'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null
