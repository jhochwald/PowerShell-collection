#requires -Version 3.0 -Modules AzureAD, Microsoft.Online.SharePoint.PowerShell
<#
      .SYNOPSIS
      Provision new Users personal SharePoint site

      .DESCRIPTION
      Provision new Users personal SharePoint site, Will also trigger the OneDrive provisioning.

      .PARAMETER TenantName
      Microsoft 365 Tenant name (e.g. contoso for contoso.onmicrosoft.com)
      Do not use any of the vanity domains of your tenant here!

      .EXAMPLE
      PS C:\> .\FixPersonalSPOSite.ps1
      Provision new Users personal SharePoint site

      .EXAMPLE
      PS C:\> .\FixPersonalSPOSite.ps1 -TenantName 'contoso'
      Provision new Users personal SharePoint site for the Microsoft 365 tenant with the name 'contoso' (for contoso.onmicrosoft.com)

      .NOTES
      I had issues where newly created users where unable to access there personal site/OneDrive via portal.office.com
      We found this issue in at least two different tenants, therefore we decided to figure out a workaround.

      Want to know how the magic workaround works?
      See the last command of this script, Get-SPOSite does all the magic. Don't ask!

      Author: Joerg Hochwald - https://hochwald.net
      Contributor: Cristopher Pope - https://hope-this-helps.de
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param
(
	[Parameter(ValueFromPipeline,
		ValueFromPipelineByPropertyName,
		Position = 0)]
	[ValidateNotNullOrEmpty()]
	[Alias('Tenant')]
	[string]
	$TenantName = ' contoso'
)

begin
{
	# Set the URL main part
	$AdminUrl = ('https://' + $TenantName + '-admin.sharepoint.com')

	# Connect to AzureAD
	Connect-AzureAD -ErrorAction Stop

	# Connect to SharePoint Online
	Connect-SPOService -Url $AdminUrl -ErrorAction Stop
}

process
{
	# Get all User from the AzureAD
	# Mind the Gap: -All is not a switch, it IS a Boolean <- WTF?
	$paramGetAzureADUser = @{
		All         = $true
		ErrorAction = 'SilentlyContinue'
	}
	$NewODFBUsers = (Get-AzureADUser @paramGetAzureADUser | Select-Object)

	# Filter licensed users
	$NewODFBUsers = ($NewODFBUsers | Where-Object -FilterScript {
			<#
               You can Filter much more, if you like
               We Filter:
               1. User with an assigned License
               2. All external users (based on the '#EXT#' in the UserPrincipalName)
               3. All users without a vanity domain (e.g. everyone within @NAME.onmicrosoft.com) <- Review this before using it!!!
         #>
			(($_.AssignedLicenses -ne $null) -and ($_.UserPrincipalName -notlike ('*#EXT#@*')) -and ($_.UserPrincipalName -notlike ('*@' + $TenantName + '.onmicrosoft.com')))
		} | Select-Object -ExpandProperty UserPrincipalName -ErrorAction SilentlyContinue)

	# The Limit of Request-SPOPersonalSite is 200
	$SliceSize = 150

	# Create a new Index
	$SliceIndex = 0

	# Slice the big array into smaller chunks
	while ($($SliceSize * $SliceIndex) -lt $NewODFBUsers.Length)
 {
		# Cleanup
		$NewODFBUsersSlice = $null

		# Put the number of peaces into the new chunk (e.g. the new object)
		$NewODFBUsersSlice = ($NewODFBUsers | Select-Object -First $SliceSize -Skip ($SliceSize * $SliceIndex) -ErrorAction SilentlyContinue)

		# Just fire the Request, the hard limit is 200 per call
		$paramRequestSPOPersonalSite = @{
			UserEmails    = $NewODFBUsersSlice
			NoWait        = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
		}
		$null = (Request-SPOPersonalSite @paramRequestSPOPersonalSite)

		# Count the slice
		$SliceIndex++
	}

	# Cool down and let Azure (SPO in this case) do the provisioning job in the background
	Start-Sleep -Seconds 60

	<#
         Reference is Case #:23027858 (One Drive is not accessible via portal.office.com)
         Solution: This get will do the magic! You have to do a Select on the "Owner" object to make the magic work.
         Looks like the get will trigger something in the background!
   #>
	$paramGetSPOSite = @{
		IncludePersonalSite = $true
		Limit               = 'all'
		Filter              = "Url -like '-my.sharepoint.com/personal/'"
		ErrorAction         = 'SilentlyContinue'
		WarningAction       = 'SilentlyContinue'
	}
	$null = (Get-SPOSite @paramGetSPOSite | Select-Object -Property Url, Owner)
}
