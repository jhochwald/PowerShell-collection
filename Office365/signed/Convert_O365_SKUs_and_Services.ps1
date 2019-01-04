#requires -Version 2.0 -Modules MSOnline

<#
    PowerShell Core (PWSH) is not supported, at least not yet

    # Easy way to install the MSOL Module, requires PowerShell 5 or PSGet
    Install-Module -Name MSOnline

    I still use the old (MSOL) module, cause it works best at the moment.
    I might convert more and more to the newer modules
#>

#region HelperFunctions
function Get-ServicePlanFriendlyList
{
  <#
      .SYNOPSIS
      A Hashtable of Office 365 Service Plans and there Human understandable description

      .DESCRIPTION
      Helper function to make the Office 365 Service Plans as returned from scripts understandable for humans

      .EXAMPLE
      PS C:\> Get-ServicePlanFriendlyList

      .NOTES
      Internal Helper

      Version: 2.1 - Latest List
      Author: Joerg Hochwald <http://jhochwald.com>
      License: The 3-Clause BSD License <https://opensource.org/licenses/BSD-3-Clause>
  #>
	
  [CmdletBinding()]
  [OutputType([hashtable])]
  param ()
	
  begin
  {
    # Cleanup
    $ServicePlanFriendlyList = $null
  }
	
  process
  {
    # Build the HashTable
    $ServicePlanFriendlyList = @{
      'AAD_BASIC'                        = 'Azure Active Directory Basic'
      'AAD_PREMIUM'                      = 'Azure Active Directory Premium'
      'MFA_PREMIUM'                      = 'Azure Multi-Factor Authentication'
      'RMS_S_ENTERPRISE'                 = 'Azure Information Protection'
      'RMS_S_ENTERPRISE_GOV'             = 'Azure Information Protection for Government'
      'SHAREPOINT_DUET_EDU'              = 'Duet Online for Academics'
      'SHAREPOINT_DUET_GOV'              = 'Duet Online for Government'
      'EXCHANGE_S_STANDARD'              = 'Exchange Online (Plan 1)'
      'EXCHANGE_S_STANDARD_GOV'          = 'Exchange Online (Plan 1 for Government)'
      'EXCHANGE_S_ENTERPRISE'            = 'Exchange Online (Plan 2)'
      'EXCHANGE_S_ENTERPRISE_GOV'        = 'Exchange Online (Plan 2 for Government)'
      'EXCHANGE_S_ARCHIVE'               = 'Exchange Online Archiving'
      'EXCHANGE_S_ARCHIVE_GOV'           = 'Exchange Online Archiving for Government'
      'EXCHANGE_S_DESKLESS'              = 'Exchange Online Kiosk'
      'EXCHANGE_S_DESKLESS_GOV'          = 'Exchange Online Kiosk for Government'
      'EOP_ENTERPRISE'                   = 'Exchange Online Protection'
      'EOP_ENTERPRISE_GOV'               = 'Exchange Online Protection for Government'
      'INTUNE_A'                         = 'Intune'
      'MCOIMP'                           = 'Skype for Business Online (formerly Lync Online (Plan 1)'
      'MCOIMP_GOV'                       = 'Skype for Business Online (Plan 1 for Government)'
      'MCOSTANDARD'                      = 'Skype for Business Online (Plan 2)'
      'MCOSTANDARD_GOV'                  = 'Skype for Business Online (Plan 2 for Government)'
      'MCOVOICECONF'                     = 'Skype for Business Online (Plan 3)'
      'MCOVOICECONF_GOV'                 = 'Skype for Business Online (Plan 3 for Government)'
      'CRMENTERPRISE'                    = 'Microsoft Dynamics CRM Online Enterprise'
      'CRMSTANDARD_GCC'                  = 'Microsoft Dynamics CRM Online Government Professional'
      'CRMSTANDARD'                      = 'Microsoft Dynamics CRM Online Professional'
      'DMENTERPRISE'                     = 'Microsoft Dynamics Marketing Online Enterprise'
      'MDM_SALES_COLLABORATION'          = 'Microsoft Dynamics Marketing Sales Collaboration'
      'SQL_IS_SSIM'                      = 'Microsoft Power BI Information Services Plan 1'
      'BI_AZURE_P1'                      = 'Microsoft Power BI Reporting and Analytics Plan 1'
      'BI_AZURE_P2'                      = 'Microsoft Power BI Reporting and Analytics Plan 2'
      'NBENTERPRISE'                     = 'Microsoft Social Listening Enterprise'
      'NBPROFESSIONALFORCRM'             = 'Microsoft Social Listening Professional'
      'INTUNE_O365'                      = 'Mobile Device Management for Office 365'
      'OFFICE_BUSINESS'                  = 'Office 365 Business'
      'OFFICESUBSCRIPTION'               = 'Office 365 ProPlus'
      'OFFICESUBSCRIPTION_GOV'           = 'Office 365 ProPlus for Government'
      'OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ' = 'Office 365 Small Business Subscription'
      'SHAREPOINTWAC'                    = 'Office Online'
      'SHAREPOINTWAC_DEVELOPER'          = 'Office Online Developer'
      'SHAREPOINTWAC_EDU'                = 'Office Online EDU'
      'SHAREPOINTWAC_DEVELOPER_GOV'      = 'Office Online for Government Developer'
      'SHAREPOINTWAC_GOV'                = 'Office Online for Government'
      'ONEDRIVESTANDARD'                 = 'OneDrive for Business (Plan 1)'
      'ONEDRIVESTANDARD_GOV'             = 'OneDrive for Business (Plan 1 for Government)'
      'ONEDRIVELITE'                     = 'OneDrive for Business Lite'
      'PARATURE_ENTERPRISE'              = 'Parature Enterprise'
      'PARATURE_ENTERPRISE_GOV'          = 'Parature Enterprise for Government'
      'BI_AZURE_P0'                      = 'Power BI'
      'PROJECT_ESSENTIALS'               = 'Project Lite'
      'PROJECT_ESSENTIALS_GOV'           = 'Project Lite for Government'
      'SHAREPOINT_PROJECT'               = 'Project Online'
      'SHAREPOINT_PROJECT_EDU'           = 'Project Online for Academics'
      'SHAREPOINT_PROJECT_GOV'           = 'Project Online for Government'
      'PROJECT_CLIENT_SUBSCRIPTION'      = 'Project Pro for Office 365'
      'PROJECT_CLIENT_SUBSCRIPTION_GOV'  = 'Project Pro for Office 365 for Government'
      'SHAREPOINTSTANDARD'               = 'SharePoint Online (Plan 1)'
      'SHAREPOINTSTANDARD_EDU'           = 'SharePoint Online (Plan 1 for Academics)'
      'SHAREPOINTSTANDARD_GOV'           = 'SharePoint Online (Plan 1 for Government)'
      'SHAREPOINTENTERPRISE'             = 'SharePoint Online (Plan 2)'
      'SHAREPOINTENTERPRISE_EDU'         = 'SharePoint Online (Plan 2 for Academics)'
      'SHAREPOINTENTERPRISE_GOV'         = 'SharePoint Online (Plan 2 for Government)'
      'SHAREPOINT_S_DEVELOPER'           = 'SharePoint Online for Developer'
      'SHAREPOINT_S_DEVELOPER_GOV'       = 'SharePoint Online for Government Developer'
      'SHAREPOINTDESKLESS'               = 'SharePoint Online Kiosk'
      'SHAREPOINTDESKLESS_GOV'           = 'SharePoint Online Kiosk for Government'
      'VISIO_CLIENT_SUBSCRIPTION'        = 'Visio Pro for Office 365'
      'VISIO_CLIENT_SUBSCRIPTION_GOV'    = 'Visio Pro for Office 365 for Government'
      'YAMMER_ENTERPRISE'                = 'Yammer Enterprise'
      'YAMMER_EDU'                       = 'Yammer for Academic For Academics'
      'FLOW_O365_P2'                     = 'Flow for Office 365 P2'
      'POWERAPPS_O365_P2'                = 'PowerApps for Office 365 P2'
      'TEAMS1'                           = 'Microsoft Teams'
      'PROJECTWORKMANAGEMENT'            = 'Microsoft Planner'
      'SWAY'                             = 'SWAY'
      'Deskless'                         = 'Microsoft StaffHub'
      'FLOW_O365_P3'                     = 'Flow for Office 365 P3'
      'POWERAPPS_O365_P3'                = 'PowerApps for Office 365 P3'
      'ADALLOM_S_O365'                   = 'Office 365 Advanced Security Management'
      'EQUIVIO_ANALYTICS'                = 'Office 365 Advanced eDiscovery'
      'LOCKBOX_ENTERPRISE'               = 'Customer Lockbox'
      'EXCHANGE_ANALYTICS'               = 'Microsoft MyAnalytics'
      'ATP_ENTERPRISE'                   = 'Exchange Online Advanced Threat Protection (These licenses do not need to be individually assigned)'
      'MCOEV'                            = 'Teams/Skype for Business Cloud PBX'
      'MCOMEETADV'                       = 'Teams/Skype for Business PSTN Conferencing'
    }
  }
	
  end
  {
    # Dump
    $ServicePlanFriendlyList
  }
}

function Get-SkuPartNumberFriendlyNameList
{
  <#
      .SYNOPSIS
      A Hashtable of Office 365 SKUs and there Human understandable description

      .DESCRIPTION
      Helper function to make the Office 365 SKUs as returned from scripts understandable for humans

      .EXAMPLE
      PS C:\> Get-SkuPartNumberFriendlyNameList

      .NOTES
      Internal Helper

      Version: 2.1 - Latest List
      Author: Joerg Hochwald <http://jhochwald.com>
      License: The 3-Clause BSD License <https://opensource.org/licenses/BSD-3-Clause>
  #>
	
  [CmdletBinding()]
  [OutputType([hashtable])]
  param ()
	
  begin
  {
    # Cleanup
    $SkuPartNumberFriendlyNameList = $null
  }
	
  process
  {
    # Build the HashTable
    $SkuPartNumberFriendlyNameList = @{
      'AAD_BASIC'                        = 'Azure Active Directory Basic'
      'AAD_PREMIUM'                      = 'Azure Active Directory Premium'
      'RIGHTSMANAGEMENT'                 = 'Azure Active Directory Rights'
      'RIGHTSMANAGEMENT_FACULTY'         = 'Azure Active Directory Rights for Faculty'
      'RIGHTSMANAGEMENT_GOV'             = 'Azure Active Directory Rights for Government'
      'RIGHTSMANAGEMENT_STUDENT'         = 'Azure Active Directory Rights for Students'
      'MFA_STANDALONE'                   = 'Azure Multi-Factor Authentication Premium Standalone'
      'EMS'                              = 'Microsoft Enterprise Mobility + Security Suite'
      'EXCHANGESTANDARD_FACULTY'         = 'Exchange (Plan 1 for Faculty)'
      'EXCHANGESTANDARD_STUDENT'         = 'Exchange (Plan 1 for Students)'
      'EXCHANGEENTERPRISE_FACULTY'       = 'Exchange (Plan 2 for Faculty)'
      'EXCHANGEENTERPRISE_STUDENT'       = 'Exchange (Plan 2 for Students)'
      'EXCHANGEARCHIVE'                  = 'Exchange Archiving'
      'EXCHANGEARCHIVE_FACULTY'          = 'Exchange Archiving for Faculty'
      'EXCHANGEARCHIVE_GOV'              = 'Exchange Archiving for Government'
      'EXCHANGEARCHIVE_STUDENT'          = 'Exchange Archiving for Students'
      'EXCHANGESTANDARD_GOV'             = 'Exchange for Government (Plan 1G)'
      'EXCHANGEENTERPRISE_GOV'           = 'Exchange for Government (Plan 2G)'
      'EXCHANGEDESKLESS'                 = 'Exchange Kiosk'
      'EXCHANGEDESKLESS_GOV'             = 'Exchange Kiosk for Government'
      'EXCHANGESTANDARD'                 = 'Exchange Plan 1'
      'EXCHANGEENTERPRISE'               = 'Exchange Plan 2'
      'EOP_ENTERPRISE_FACULTY'           = 'Exchange Protection for Faculty'
      'EOP_ENTERPRISE_GOV'               = 'Exchange Protection for Government'
      'EOP_ENTERPRISE_STUDENT'           = 'Exchange Protection for Student'
      'EXCHANGE_ONLINE_WITH_ONEDRIVE_LITE' = 'Exchange with OneDrive for Business'
      'INTUNE_A'                         = 'Intune'
      'MCOIMP_FACULTY'                   = 'Lync (Plan 1 for Faculty)'
      'MCOIMP_STUDENT'                   = 'Lync (Plan 1 for Students)'
      'MCOSTANDARD_FACULTY'              = 'Lync (Plan 2 for Faculty)'
      'MCOSTANDARD_STUDENT'              = 'Lync (Plan 2 for Students)'
      'MCOVOICECONF'                     = 'Lync (Plan 3)'
      'MCOIMP_GOV'                       = 'Lync for Government (Plan 1G)'
      'MCOSTANDARD_GOV'                  = 'Lync for Government (Plan 2G)'
      'MCOVOICECONF_GOV'                 = 'Lync for Government (Plan 3G)'
      'MCOINTERNAL'                      = 'Lync Internal Incubation and Corp to Cloud'
      'MCOIMP'                           = 'Skype Plan 1'
      'MCOSTANDARD'                      = 'Skype Plan 2'
      'MCOVOICECONF_FACULTY'             = 'Lync Plan 3 for Faculty'
      'MCOVOICECONF_STUDENT'             = 'Lync Plan 3 for Students'
      'CRMENTERPRISE'                    = 'Microsoft Dynamics CRM Online Enterprise'
      'CRMSTANDARD_GCC'                  = 'Microsoft Dynamics CRM Online Government Professional'
      'CRMSTANDARD'                      = 'Microsoft Dynamics CRM Online Professional'
      'DMENTERPRISE'                     = 'Microsoft Dynamics Marketing Online Enterprise'
      'INTUNE_O365_STANDALONE'           = 'Mobile Device Management for Office 365'
      'OFFICE_BASIC'                     = 'Office 365 Basic'
      'O365_BUSINESS'                    = 'Office 365 Business'
      'O365_BUSINESS_ESSENTIALS'         = 'Office 365 Business Essentials'
      'O365_BUSINESS_PREMIUM'            = 'Office 365 Business Premium'
      'DEVELOPERPACK'                    = 'Office 365 Developer'
      'DEVELOPERPACK_GOV'                = 'Office 365 Developer for Government'
      'EDUPACK_FACULTY'                  = 'Office 365 Education for Faculty'
      'EDUPACK_STUDENT'                  = 'Office 365 Education for Students'
      'EOP_ENTERPRISE'                   = 'Office 365 Exchange Protection Enterprise'
      'EOP_ENTERPRISE_PREMIUM'           = 'Office 365 Exchange Protection Premium'
      'STANDARDPACK_GOV'                 = 'Office 365 for Government (Plan G1)'
      'STANDARDWOFFPACK_GOV'             = 'Office 365 for Government (Plan G2)'
      'ENTERPRISEPACK_GOV'               = 'Office 365 for Government (Plan G3)'
      'ENTERPRISEWITHSCAL_GOV'           = 'Office 365 for Government (Plan G4)'
      'DESKLESSPACK_GOV'                 = 'Office 365 for Government (Plan F1G)'
      'STANDARDPACK_FACULTY'             = 'Office 365 Plan A1 for Faculty'
      'STANDARDPACK_STUDENT'             = 'Office 365 Plan A1 for Students'
      'STANDARDWOFFPACK_FACULTY'         = 'Office 365 Plan A2 for Faculty'
      'STANDARDWOFFPACK_STUDENT'         = 'Office 365 Plan A2 for Students'
      'ENTERPRISEPACK_FACULTY'           = 'Office 365 Plan A3 for Faculty'
      'ENTERPRISEPACK_STUDENT'           = 'Office 365 Plan A3 for Students'
      'ENTERPRISEWITHSCAL_FACULTY'       = 'Office 365 Plan A4 for Faculty'
      'ENTERPRISEWITHSCAL_STUDENT'       = 'Office 365 Plan A4 for Students'
      'STANDARDPACK'                     = 'Office 365 Plan E1'
      'STANDARDWOFFPACK'                 = 'Office 365 Plan E2'
      'ENTERPRISEPACK'                   = 'Office 365 Plan E3'
      'ENTERPRISEWITHSCAL'               = 'Office 365 Plan E4'
      'DESKLESSPACK'                     = 'Office 365 Plan F1'
      'DESKLESSPACK_YAMMER'              = 'Office 365 Plan F1 with Yammer'
      'OFFICESUBSCRIPTION'               = 'Office Professional Plus'
      'OFFICESUBSCRIPTION_FACULTY'       = 'Office Professional Plus for Faculty'
      'OFFICESUBSCRIPTION_GOV'           = 'Office Professional Plus for Government'
      'OFFICESUBSCRIPTION_STUDENT'       = 'Office Professional Plus for Students'
      'WACSHAREPOINTSTD_FACULTY'         = 'Office Web Apps (Plan 1 For Faculty)'
      'WACSHAREPOINTSTD_STUDENT'         = 'Office Web Apps (Plan 1 For Students)'
      'WACSHAREPOINTSTD_GOV'             = 'Office Web Apps (Plan 1G for Government)'
      'WACSHAREPOINTENT_FACULTY'         = 'Office Web Apps (Plan 2 For Faculty)'
      'WACSHAREPOINTENT_STUDENT'         = 'Office Web Apps (Plan 2 For Students)'
      'WACSHAREPOINTENT_GOV'             = 'Office Web Apps (Plan 2G for Government)'
      'WACSHAREPOINTSTD'                 = 'Office Web Apps with SharePoint Plan 1'
      'WACSHAREPOINTENT'                 = 'Office Web Apps with SharePoint Plan 2'
      'ONEDRIVESTANDARD'                 = 'OneDrive for Business'
      'ONEDRIVESTANDARD_GOV'             = 'OneDrive for Business for Government (Plan 1G)'
      'WACONEDRIVESTANDARD'              = 'OneDrive for Business with Office Web Apps'
      'WACONEDRIVESTANDARD_GOV'          = 'OneDrive for Business with Office Web Apps for Government'
      'PARATURE_ENTERPRISE'              = 'Parature Enterprise'
      'PARATURE_ENTERPRISE_GOV'          = 'Parature Enterprise for Government'
      'POWER_BI_STANDARD'                = 'Power BI'
      'POWER_BI_STANDALONE'              = 'Power BI for Office 365'
      'POWER_BI_STANDALONE_FACULTY'      = 'Power BI for Office 365 for Faculty'
      'POWER_BI_STANDALONE_STUDENT'      = 'Power BI for Office 365 for Students'
      'PROJECTESSENTIALS'                = 'Project Essentials'
      'PROJECTESSENTIALS_GOV'            = 'Project Essentials for Government'
      'PROJECTONLINE_PLAN_1'             = 'Project Plan 1'
      'PROJECTONLINE_PLAN_1_FACULTY'     = 'Project Plan 1 for Faculty'
      'PROJECTONLINE_PLAN_1_GOV'         = 'Project Plan 1for Government'
      'PROJECTONLINE_PLAN_1_STUDENT'     = 'Project Plan 1 for Students'
      'PROJECTONLINE_PLAN_2'             = 'Project Plan 2'
      'PROJECTONLINE_PLAN_2_FACULTY'     = 'Project Plan 2 for Faculty'
      'PROJECTONLINE_PLAN_2_GOV'         = 'Project Plan 2 for Government'
      'PROJECTONLINE_PLAN_2_STUDENT'     = 'Project Plan 2 for Students'
      'PROJECTCLIENT'                    = 'Project Pro for Office 365'
      'PROJECTCLIENT_FACULTY'            = 'Project Pro for Office 365 for Faculty'
      'PROJECTCLIENT_GOV'                = 'Project Pro for Office 365 for Government'
      'PROJECTCLIENT_STUDENT'            = 'Project Pro for Office 365 for Students'
      'SHAREPOINTSTANDARD_FACULTY'       = 'SharePoint (Plan 1 for Faculty)'
      'SHAREPOINTSTANDARD_STUDENT'       = 'SharePoint (Plan 1 for Students)'
      'SHAREPOINTSTANDARD_YAMMER'        = 'SharePoint (Plan 1 with Yammer)'
      'SHAREPOINTENTERPRISE_FACULTY'     = 'SharePoint (Plan 2 for Faculty)'
      'SHAREPOINTENTERPRISE_STUDENT'     = 'SharePoint (Plan 2 for Students)'
      'SHAREPOINTENTERPRISE_YAMMER'      = 'SharePoint (Plan 2 with Yammer)'
      'SHAREPOINTSTANDARD_GOV'           = 'SharePoint for Government (Plan 1G)'
      'SHAREPOINTENTERPRISE_GOV'         = 'SharePoint for Government (Plan 2G)'
      'SHAREPOINTDESKLESS'               = 'SharePoint Kiosk'
      'SHAREPOINTSTANDARD'               = 'SharePoint Plan 1'
      'SHAREPOINTENTERPRISE'             = 'SharePoint Plan 2'
      'SMB_BUSINESS'                     = 'SMB Business'
      'SMB_BUSINESS_ESSENTIALS'          = 'SMB Business Essentials'
      'SMB_BUSINESS_PREMIUM'             = 'SMB Business Premium'
      'VISIOCLIENT'                      = 'Visio Pro for Office 365'
      'VISIOCLIENT_FACULTY'              = 'Visio Pro for Office 365 for Faculty'
      'VISIOCLIENT_GOV'                  = 'Visio Pro for Office 365 for Government'
      'VISIOCLIENT_STUDENT'              = 'Visio Pro for Office 365 for Students'
      'YAMMER_ENTERPRISE_STANDALONE'     = 'Yammer Enterprise Standalone'
      'RIGHTSMANAGEMENT_ADHOC'           = 'Azure Rights Management Service'
      'ENTERPRISEPREMIUM'                = 'Office 365 Enterprise E5'
    }
  }
	
  end
  {
    # Dump
    $SkuPartNumberFriendlyNameList
  }
}
#endregion HelperFunctions

# region MainFunctions
function Convert-MsolServicePlanName
{
  <#
      .SYNOPSIS
      Convert between the Office 365 ServicePlanName from Get-MsolAccountSku to a human understandable format. It works in both directions

      .DESCRIPTION
      Coverts the Office 365 ServicePlanName from Get-MsolAccountSku to a human understandable format (as viewed in the Office 365 Admin Portal).
      I use this for reporting and other licence related scripts to make the output understandable for the user.

      .PARAMETER ServicePlanName
      ServicePlanName from PowerShell query, e.g. Intune

      .PARAMETER ServicePlanFriendlyName
      Human underandable description of a plan, e.g. Azure Multi-Factor Authentication

      .EXAMPLE
      # Get all availible Services in a Human understanable Format
      PS> Get-MsolAccountSku | Select-Object -Property @{
      Name       = 'ServicePlanName'
      Expression = {
      $_.ServiceStatus.ServicePlan.ServiceName
      }
      } | ForEach-Object -Process {
      $_.ServicePlanName
      } | Convert-MsolServicePlanName

      Teams/Skype for Business Cloud PBX
      Power BI
      Teams/Skype for Business PSTN Conferencing
      Microsoft StaffHub
      Microsoft Teams
      Office Online
      Microsoft Planner
      SWAY
      Mobile Device Management for Office 365
      Yammer Enterprise
      Skype for Business Online (Plan 2)
      SharePoint Online (Plan 1)
      Exchange Online (Plan 1)

      .EXAMPLE
      # Convert a SKU Service Name to a human understandable format
      PS> Convert-MsolServicePlanName -ServicePlanName "AAD_BASIC"

      Azure Active Directory Basic

      .EXAMPLE
      # Convert a human understandable format to SKU Service Name, to use in scripts
      PS> Convert-MsolServicePlanName -ServicePlanFriendlyName "Azure Multi-Factor Authentication"

      MFA_PREMIUM

      .NOTES
      Version: 2.1 - Latest List
      Author: Joerg Hochwald <http://jhochwald.com>
      License: The 3-Clause BSD License <https://opensource.org/licenses/BSD-3-Clause>
  #>
  [CmdletBinding(DefaultParameterSetName = 'ByFriendlyName')]
  param
  (
    [Parameter(ParameterSetName = 'ByServicePlanName',
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0,
    HelpMessage = 'ServicePlanName from PowerShell query, e.g. AAD_BASIC')]
    [Alias('Name')]
    [string]
    $ServicePlanName,
    [Parameter(ParameterSetName = 'ByFriendlyName',
        Mandatory = $true,
        Position = 0,
    HelpMessage = 'Friendly name of a plan, e.g. Exchange Online (Plan 1)')]
    [Alias('FriendlyName')]
    [string]
    $ServicePlanFriendlyName
  )
	
  process
  {
    # Moved to a dedicated function
    $ServicePlanFriendlyList = (Get-ServicePlanFriendlyList)
		
    if ($ServicePlanName)
    {
      $ServicePlanFriendlyList["$ServicePlanName"]
    }
		
    if ($ServicePlanFriendlyName)
    {
      ($ServicePlanFriendlyList.GetEnumerator() | Where-Object -FilterScript {
          $_.Value -eq "$ServicePlanFriendlyName"
      }).Name
    }
  }
}

function Convert-MsolAccountSkuName
{
  <#
      .SYNOPSIS
      Convert between the Office 365 SKU Name from Get-MsolAccountSku to a human understandable format. It works in both directions

      .DESCRIPTION
      Coverts the Office 365 SKU Name from Get-MsolAccountSku to a human understandable format (as viewed in the Office 365 Admin Portal).
      I use this for reporting and other licence related scripts to make the output understandable for the user.

      .PARAMETER SkuPartNumber
      ServicePlanName from scripted query, e.g. EXCHANGEENTERPRISE

      .PARAMETER SkuPartNumberFriendlyName
      human understandable format of a plan, e.g. Exchange Plan 1

      .EXAMPLE
      # Get a human understandable output for all existing SKUs
      Get-MsolAccountSku | Select-Object -ExpandProperty SkuPartNumber | Convert-MsolAccountSkuName

      Power BI
      Office 365 Plan E1

      .EXAMPLE
      # Get the human understandable description from a SKU Number/Name
      Convert-MsolAccountSkuName -SkuPartNumber 'EXCHANGEENTERPRISE'

      Exchange Plan 2

      .EXAMPLE
      # Get the script compatible description from an human understandable format
      Convert-MsolAccountSkuName  -SkuPartNumberFriendlyName 'Exchange Plan 1'

      EXCHANGESTANDARD

      .NOTES
      Version: 2.1 - Latest List
      Author: Joerg Hochwald <http://jhochwald.com>
      License: The 3-Clause BSD License <https://opensource.org/licenses/BSD-3-Clause>
  #>
  [CmdletBinding(DefaultParameterSetName = 'BySkuFriendlyName')]
  param
  (
    [Parameter(ParameterSetName = 'BySkuPartNumber',
        Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0,
    HelpMessage = 'ServicePlanName from PowerShell query, e.g. "EXCHANGEENTERPRISE"')]
    [Alias('PartNumber')]
    [string]
    $SkuPartNumber,
    [Parameter(ParameterSetName = 'BySkuFriendlyName',
        Mandatory = $true,
        Position = 0,
    HelpMessage = 'Friendly name of a plan, e.g. "Exchange Plan 1"')]
    [Alias('FriendlyName')]
    [string]
    $SkuPartNumberFriendlyName
  )
	
  process
  {
    # Moved to a dedicated function
    $SkuPartNumberFriendlyNameList = (Get-SkuPartNumberFriendlyNameList)
		
    if ($SkuPartNumber)
    {
      $SkuPartNumberFriendlyNameList["$SkuPartNumber"]
    }
		
    if ($SkuPartNumberFriendlyName)
    {
      ($SkuPartNumberFriendlyNameList.GetEnumerator() | Where-Object -FilterScript {
          $_.Value -eq "$SkuPartNumberFriendlyName"
      }).Name
    }
  }
}
#endregion MainFunctions

#region Info
Write-Output -InputObject 'MsolServicePlanName:'
Get-MsolAccountSku | Select-Object -Property @{
  Name       = 'ServicePlanName'
  Expression = {
    $_.ServiceStatus.ServicePlan.ServiceName
  }
} | ForEach-Object -Process {
  $_.ServicePlanName
} | Convert-MsolServicePlanName

Write-Output -InputObject ''

Write-Output -InputObject 'MsolAccountSkuName:'
Get-MsolAccountSku | Select-Object -ExpandProperty SkuPartNumber | Convert-MsolAccountSkuName
#endregion Info

#region CHANGELOG
<#
  Soon
#>
#endregion CHANGELOG

#region LICENSE
<#
  LICENSE:

  Copyright 2018 by enabling Technology - http://enatec.io

  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
  1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
  3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  By using the Software, you agree to the License, Terms and Conditions above!
#>
#endregion LICENSE

#region DISCLAIMER
<#
  DISCLAIMER:

  - Use at your own risk, etc.
  - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
  - This is a third-party Software
  - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
  - The Software is not supported by Microsoft Corp (MSFT)
  - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
  - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER

# SIG # Begin signature block
# MIIZkAYJKoZIhvcNAQcCoIIZgTCCGX0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCmr1sxTKSfdYKZMRk4CGhKqQ
# IP+gghTyMIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggUvMIIEF6ADAgECAhUAnQ4BMcIRBgspeUy1JGs+Zi8ndqIwDQYJKoZIhvcNAQEL
# BQAwPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMR0wGwYDVQQDExRB
# c2NlcnRpYSBQdWJsaWMgQ0EgMTAeFw0xOTAxMDQxNTMyMDdaFw0xOTAyMDQxNTMy
# MDdaMIGnMQswCQYDVQQGEwJERTEhMB8GCSqGSIb3DQEJARYSam9lcmdAaG9jaHdh
# bGQubmV0MQ8wDQYDVQQIEwZIZXNzZW4xEDAOBgNVBAcTB01haW50YWwxFzAVBgNV
# BAoTDkpvZXJnIEhvY2h3YWxkMSAwHgYDVQQLExdPcGVuIFNvdXJjZSBEZXZlbG9w
# bWVudDEXMBUGA1UEAxMOSm9lcmcgSG9jaHdhbGQwggEiMA0GCSqGSIb3DQEBAQUA
# A4IBDwAwggEKAoIBAQDL56sSkECHDR6kKznKhvCb3+cO8K5+YJdXG7kZzkKcnsOi
# o803+a3PkO/zFNH9Cuq+Oc/1wRkeoePaaLvk9VrXQ4NBjxx69ZO/RY+EHSOZ6z3e
# CFb8mgzLNf1Z4qwgWV91GF1IPa4VnilDSwsW98axQ+lkOXqLu18qhT1SPP8xZp/5
# mG2ctD3HA7p6miyCXkFBBIlg6HdnPn/Acxq9T7v9GpYV4+jznt2Are+YJV9J6Sl3
# qKchjlNIektENOJV6nkmeZJ9PJj6sOjAFtAPlFJgoG1Fw1++GooNyC37nuqWOKlC
# Kvp8br0F2ixWjs2S1Oun/w+06JnX4/0ZZhTd7dSfAgMBAAGjggG3MIIBszAOBgNV
# HQ8BAf8EBAMCBsAwDAYDVR0TAQH/BAIwADA9BggrBgEFBQcBAQQxMC8wLQYIKwYB
# BQUHMAGGIWh0dHA6Ly9vY3NwLmdsb2JhbHRydXN0ZmluZGVyLmNvbTCB8AYDVR0g
# BIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQBggrBgEFBQcCAjCBwwyBwFdhcm5p
# bmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVkIHVuZGVyIHRoaXMgcG9saWN5IHRv
# IGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3QgaGFkIHRoZWlyIGlkZW50aXR5IGNv
# bmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBjZXJ0aWZpY2F0ZXMgZm9yIHZhbHVh
# YmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklMSVRZIElTIEFDQ0VQVEVELjBMBgNV
# HR8ERTBDMEGgP6A9hjtodHRwOi8vd3d3Lmdsb2JhbHRydXN0ZmluZGVyLmNvbS9j
# cmxzL0FzY2VydGlhUHVibGljQ0ExLmNybDATBgNVHSUEDDAKBggrBgEFBQcDAzAN
# BgkqhkiG9w0BAQsFAAOCAQEAjEZHO2pV991j3XGZSvg/jUd1JFf2UAnCeW7sxIvI
# k7AVPs6ynKkUIdJ5yC4kqgNXks3q84pwaCmjxPVbmg6wZV/EtVIbbX4zoNW7UVBU
# l3IyeCqKxaPTnCToVnZbod0S99qwV5OYKPFGmPuunqSQ6G4ulTFvHoY5rHd5jI75
# VmemN1lW6FlidJjohH6biM+OM3p1LwcYtvitPWSP4cvsFvtFKhp3rvKUiiPByE+q
# mx9tNuS1ypgxRftndCwmaqnXjzbeZRoNpD1G7Rrch4WepV6FhK173qBfwA+8t8Kr
# B0W4h716Ejk7RkyQk7hawO2GBLDqa2qbXLkiHPsa7W7x1DCCByIwggYKoAMCAQIC
# AgDmMA0GCSqGSIb3DQEBBQUAMD0xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2Nl
# cnRpYTEbMBkGA1UEAxMSQXNjZXJ0aWEgUm9vdCBDQSAyMB4XDTA5MDQyMTEyMTUx
# N1oXDTI4MDQxNDIzNTk1OVowPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2Vy
# dGlhMR0wGwYDVQQDExRBc2NlcnRpYSBQdWJsaWMgQ0EgMTCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAM9Y8jPEs9kd+U8R27jjtta8pyE3Vy57qQyUs8sS
# 8EdaziFwXhODnD7Mo/6evVPW2DBkP4puXcQbUrAR9dkI0E72BE/+/yRyXw2stKp8
# NPjbClgmazS7rGk0KMzxhWuSF5CV3p+L8d+jitUQSFZ4cTleNJ1ou5qzCfP9ZA4n
# XYieOs7E527x+/IdUe3rh9bTucEwj42nyc1dD+t+fwSbX0bGB7M/zbqVsVf0m2/m
# tIoYZSrgD0AADkRwwH74Bnq1ajMX9JsxGTVEvRsGOfqWaeeiVZRp3yGNwdEJ9p7r
# mKZzIKHVmXcIIrn86R2z6Fnw0hBwmikOLc7sRDhzF3JBN2UCAwEAAaOCBCgwggQk
# MA4GA1UdDwEB/wQEAwIBBjASBgNVHRMBAf8ECDAGAQH/AgECMIHwBgNVHSAEgegw
# geUwgeIGCisGAQQB/EkBAQEwgdMwgdAGCCsGAQUFBwICMIHDGoHAV2FybmluZzog
# Q2VydGlmaWNhdGVzIGFyZSBpc3N1ZWQgdW5kZXIgdGhpcyBwb2xpY3kgdG8gaW5k
# aXZpZHVhbHMgdGhhdCBoYXZlIG5vdCBoYWQgdGhlaXIgaWRlbnRpdHkgY29uZmly
# bWVkLiBEbyBub3QgdXNlIHRoZXNlIGNlcnRpZmljYXRlcyBmb3IgdmFsdWFibGUg
# dHJhbnNhY3Rpb25zLiBOTyBMSUFCSUxJVFkgSVMgQUNDRVBURUQuMIIBMwYDVR0O
# BIIBKgSCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIzxLPZ
# HflPEdu447bWvKchN1cue6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+Kbl3E
# G1KwEfXZCNBO9gRP/v8kcl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6fi/Hf
# o4rVEEhWeHE5XjSdaLuaswnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+Np8nN
# XQ/rfn8Em19GxgezP826lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/SbMRk1
# RL0bBjn6lmnnolWUad8hjcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJopDi3O
# 7EQ4cxdyQTdlAgMBAAEwWgYDVR0fBFMwUTBPoE2gS4ZJaHR0cDovL3d3dy5hc2Nl
# cnRpYS5jb20vT25saW5lQ0EvY3Jscy9Bc2NlcnRpYVJvb3RDQTIvQXNjZXJ0aWFS
# b290Q0EyLmNybDA9BggrBgEFBQcBAQQxMC8wLQYIKwYBBQUHMAGGIWh0dHA6Ly9v
# Y3NwLmdsb2JhbHRydXN0ZmluZGVyLmNvbTCCATcGA1UdIwSCAS4wggEqgIIBJjCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6mhhMX9krzqQfz
# FmjVf0QWR/Mhn3385P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU31IUm53R6pvG
# 0fdg+vytSMeTGOtffgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290iebcEm+kbhVYR
# LdntIm15ohuQ2aoOfQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms48F9x6mVaDvR
# OitzxMFgvs+/X+DqS5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv4pbHBa4qLxgc
# EbiLu8iC8c4ovaWeZ2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCszKFMbOHAjtoMC
# AwEAATANBgkqhkiG9w0BAQUFAAOCAQEAlJSXoaMTmbqGSlyLZYs+gkysb3RMAtuK
# AZlLXNNguwjBTF/HRWd2FH9hTt1RB/m8U+HNB/2bCb2+J1P1bB3paDSGYOJPwuHn
# LtPhfKqO4wo3dynt4MWStIJSG9PwuDaf+rF54kwPeCG0WGjJe0jkD/oKY8cGRw0y
# 1BkCE5EqOknjXBJr68fq/VPMLyi3D7G7GDICQ7+FGaaYEiAYO7DEp8ut0FBFlZ4F
# GZaofuCtCUTSBhikEVLgWWivAGqOIgOnoUfnY6stL2AtXZ/V6bExACXCHcswGbC9
# S1NCz77wzyhfYSldkIgd6g4QUQxvOYS/gjzzKigcnFxMvTbq9yX/UjGCBAgwggQE
# AgEBMFgwPzELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMR0wGwYDVQQD
# ExRBc2NlcnRpYSBQdWJsaWMgQ0EgMQIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMAkG
# BSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJ
# AzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMG
# CSqGSIb3DQEJBDEWBBRKYX+nL+HjKBhxZnj8nyiIIsfKMjANBgkqhkiG9w0BAQEF
# AASCAQDEoYsC0CJxsXwghUoe3g8TICMm1j0nEvuXZeJuc8AVNloTaqd6UEEG+dOf
# q6klrJiWG0nPMsw0p73qfzaamvuJm51BlzK0A8mOV4q0yNAdbRToNDuRJHrhRYC2
# oyizykffL7IdXtBpgBgggDNqv0JlkzOO1Z2HJtcR6PHeCdEKt+lJigdMGvfKOrT/
# 0fY3Tg4vUQo8sGvxdrwXc/QuYtKlGyizdNNcubp3bgmVCdUYezNhTbJaxje3op69
# 6nkrfDucKCNHvKQToEJeiodngJGkkRP7I/Tk5ji1RJNMmw+0vrp3C5TWl1ADVtBd
# sbZ3lqo0a4fW+xehAS3oWwmg8xycoYICCzCCAgcGCSqGSIb3DQEJBjGCAfgwggH0
# AgEBMHIwXjELMAkGA1UEBhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0
# aW9uMTAwLgYDVQQDEydTeW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIENB
# IC0gRzICEA7P9DjI/r81bgTYapgbGlAwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJ
# AzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE5MDEwNDE2MDExMVowIwYJ
# KoZIhvcNAQkEMRYEFJtqglLWFz8aXGm/Ky4DcrL6vli3MA0GCSqGSIb3DQEBAQUA
# BIIBADsE4yX+R4Vt1g5e+HJPPr5V4YtJJo/3ZEJloWpxCl4xeYDSRt4L0xjVWzSl
# X8HqWKi5damD+w1OMJsgCU2I0HBU/Qa/sztb00wpd380kApEPsv3K6e9l+hMelFk
# Z1d6SnJoUawxiF8KJdQs9HmztGK6iafXnZhUYDyCq8X1PKceWayWrnOZetaP2EH8
# dDSVRVaDHfQq27dEdDlxjtMGjkOT9aXMXySqFaScIpk8CSzGNcz5/II6Uck0y9De
# WfuqXI+5sBecR+PO54k2G/9dMsNtdUdTAO7WeWzByZO/4++2BW4VrdB3q4rUv8O8
# YZecyaYac4/WDMm5BjTQglsMscs=
# SIG # End signature block
