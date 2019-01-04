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
# MIIjzQYJKoZIhvcNAQcCoIIjvjCCI7oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCmr1sxTKSfdYKZMRk4CGhKqQ
# IP+ggh8rMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
# SIb3DQEBCwUAMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsG
# A1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwHhcNMTkwMTA0MTUzMjA3WhcNMTkw
# MjA0MTUzMjA3WjCBpzELMAkGA1UEBhMCREUxITAfBgkqhkiG9w0BCQEWEmpvZXJn
# QGhvY2h3YWxkLm5ldDEPMA0GA1UECBMGSGVzc2VuMRAwDgYDVQQHEwdNYWludGFs
# MRcwFQYDVQQKEw5Kb2VyZyBIb2Nod2FsZDEgMB4GA1UECxMXT3BlbiBTb3VyY2Ug
# RGV2ZWxvcG1lbnQxFzAVBgNVBAMTDkpvZXJnIEhvY2h3YWxkMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy+erEpBAhw0epCs5yobwm9/nDvCufmCXVxu5
# Gc5CnJ7DoqPNN/mtz5Dv8xTR/QrqvjnP9cEZHqHj2mi75PVa10ODQY8cevWTv0WP
# hB0jmes93ghW/JoMyzX9WeKsIFlfdRhdSD2uFZ4pQ0sLFvfGsUPpZDl6i7tfKoU9
# Ujz/MWaf+ZhtnLQ9xwO6eposgl5BQQSJYOh3Zz5/wHMavU+7/RqWFePo857dgK3v
# mCVfSekpd6inIY5TSHpLRDTiVep5JnmSfTyY+rDowBbQD5RSYKBtRcNfvhqKDcgt
# +57qljipQir6fG69BdosVo7NktTrp/8PtOiZ1+P9GWYU3e3UnwIDAQABo4IBtzCC
# AbMwDgYDVR0PAQH/BAQDAgbAMAwGA1UdEwEB/wQCMAAwPQYIKwYBBQUHAQEEMTAv
# MC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20w
# gfAGA1UdIASB6DCB5TCB4gYKKwYBBAH8SQEBATCB0zCB0AYIKwYBBQUHAgIwgcMM
# gcBXYXJuaW5nOiBDZXJ0aWZpY2F0ZXMgYXJlIGlzc3VlZCB1bmRlciB0aGlzIHBv
# bGljeSB0byBpbmRpdmlkdWFscyB0aGF0IGhhdmUgbm90IGhhZCB0aGVpciBpZGVu
# dGl0eSBjb25maXJtZWQuIERvIG5vdCB1c2UgdGhlc2UgY2VydGlmaWNhdGVzIGZv
# ciB2YWx1YWJsZSB0cmFuc2FjdGlvbnMuIE5PIExJQUJJTElUWSBJUyBBQ0NFUFRF
# RC4wTAYDVR0fBEUwQzBBoD+gPYY7aHR0cDovL3d3dy5nbG9iYWx0cnVzdGZpbmRl
# ci5jb20vY3Jscy9Bc2NlcnRpYVB1YmxpY0NBMS5jcmwwEwYDVR0lBAwwCgYIKwYB
# BQUHAwMwDQYJKoZIhvcNAQELBQADggEBAIxGRztqVffdY91xmUr4P41HdSRX9lAJ
# wnlu7MSLyJOwFT7OspypFCHSecguJKoDV5LN6vOKcGgpo8T1W5oOsGVfxLVSG21+
# M6DVu1FQVJdyMngqisWj05wk6FZ2W6HdEvfasFeTmCjxRpj7rp6kkOhuLpUxbx6G
# Oax3eYyO+VZnpjdZVuhZYnSY6IR+m4jPjjN6dS8HGLb4rT1kj+HL7Bb7RSoad67y
# lIojwchPqpsfbTbktcqYMUX7Z3QsJmqp14823mUaDaQ9Ru0a3IeFnqVehYSte96g
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggWPMIIE
# d6ADAgECAgIA5TANBgkqhkiG9w0BAQUFADA9MQswCQYDVQQGEwJHQjERMA8GA1UE
# ChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlhIFJvb3QgQ0EgMjAeFw0wOTA0
# MTcxMzIyMzVaFw0yOTAzMTUxMjU5NTlaMD0xCzAJBgNVBAYTAkdCMREwDwYDVQQK
# EwhBc2NlcnRpYTEbMBkGA1UEAxMSQXNjZXJ0aWEgUm9vdCBDQSAyMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlje+nuDZPqaGExf2SvOpB/MWaNV/RBZH
# 8yGfffzk/6T0C77N9MIGA+LsoUQUxZChn9HR9x4ys9TfUhSbndHqm8bR92D6/K1I
# x5MY619+C8QhVgTaI+E9xcNyxp06RnjusRGhAwHb3SJ5twSb6RuFVhEt2e0ibXmi
# G5DZqg59A4UaTBV4jSoGSjViHCTNWRlvfjmTu78VGazjwX3HqZVoO9E6K3PEwWC+
# z79f4OpLmQjuw8dZxemoIvRgiB0ZDK3I4LiKpIPKki/ilscFriovGBwRuIu7yILx
# zii9pZ5naHut1kQBvcFB2+vHbsAXNbSAD6mpvdDEKzMoUxs4cCO2gwIDAQABo4IC
# lzCCApMwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wggEzBgNVHQ4E
# ggEqBIIBJjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6m
# hhMX9krzqQfzFmjVf0QWR/Mhn3385P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU
# 31IUm53R6pvG0fdg+vytSMeTGOtffgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290i
# ebcEm+kbhVYRLdntIm15ohuQ2aoOfQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms
# 48F9x6mVaDvROitzxMFgvs+/X+DqS5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv
# 4pbHBa4qLxgcEbiLu8iC8c4ovaWeZ2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCsz
# KFMbOHAjtoMCAwEAATCCATcGA1UdIwSCAS4wggEqgIIBJjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBAJY3vp7g2T6mhhMX9krzqQfzFmjVf0QWR/Mhn338
# 5P+k9Au+zfTCBgPi7KFEFMWQoZ/R0fceMrPU31IUm53R6pvG0fdg+vytSMeTGOtf
# fgvEIVYE2iPhPcXDcsadOkZ47rERoQMB290iebcEm+kbhVYRLdntIm15ohuQ2aoO
# fQOFGkwVeI0qBko1YhwkzVkZb345k7u/FRms48F9x6mVaDvROitzxMFgvs+/X+Dq
# S5kI7sPHWcXpqCL0YIgdGQytyOC4iqSDypIv4pbHBa4qLxgcEbiLu8iC8c4ovaWe
# Z2h7rdZEAb3BQdvrx27AFzW0gA+pqb3QxCszKFMbOHAjtoMCAwEAATANBgkqhkiG
# 9w0BAQUFAAOCAQEAAVsprh7rRtV3De9pJytO4jlHvWlPXEtAtOsUZf60zEPPn2xx
# PkCn5bv/M+nM/I5lNl54gOT0FNbZK7dowkEvy83zn2fo1N5IK/OkNmmuDFITQMls
# 7Pt0ODRcLDlb/u0YTPRMhOG1bnisazG7oDMTZOEtUfFaCRCN4ZvjrqmWOJrESoWu
# xALt41CLGLIq1q8m4lKrcKo1mNq10gjVnNlpzzLNYDm6WtJUoTNU1wAOBCxqBd5l
# S6qyf56d6cqZD/S9rWTtiXXza+F+F+Ukbq+dvbiaspHXOauRw0oizYmHC68rDtEv
# x99cm/EGUkjgWLBZVUo/f0ilKq4bFAuaBHP4KzCCBmowggVSoAMCAQICEAMBmgI6
# /1ixa9bV6uYX8GYwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCVVMxFTATBgNV
# BAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEhMB8G
# A1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMB4XDTE0MTAyMjAwMDAwMFoX
# DTI0MTAyMjAwMDAwMFowRzELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lDZXJ0
# MSUwIwYDVQQDExxEaWdpQ2VydCBUaW1lc3RhbXAgUmVzcG9uZGVyMIIBIjANBgkq
# hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo2Rd/Hyz4II14OD2xirmSXU7zG7gU6mf
# H2RZ5nxrf2uMnVX4kuOe1VpjWwJJUNmDzm9m7t3LhelfpfnUh3SIRDsZyeX1kZ/G
# FDmsJOqoSyyRicxeKPRktlC39RKzc5YKZ6O+YZ+u8/0SeHUOplsU/UUjjoZEVX0Y
# hgWMVYd5SEb3yg6Np95OX+Koti1ZAmGIYXIYaLm4fO7m5zQvMXeBMB+7NgGN7yfj
# 95rwTDFkjePr+hmHqH7P7IwMNlt6wXq4eMfJBi5GEMiN6ARg27xzdPpO2P6qQPGy
# znBGg+naQKFZOtkVCVeZVjCT88lhzNAIzGvsYkKRrALA76TwiRGPdwIDAQABo4ID
# NTCCAzEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAww
# CgYIKwYBBQUHAwgwggG/BgNVHSAEggG2MIIBsjCCAaEGCWCGSAGG/WwHATCCAZIw
# KAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwggFkBggr
# BgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBzACAA
# QwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBzACAA
# YQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAARABpAGcAaQBDAGUA
# cgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAAUgBlAGwAeQBpAG4A
# ZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBoACAA
# bABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4AZAAgAGEAcgBlACAA
# aQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkAbgAgAGIAeQAgAHIA
# ZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMVMB8GA1UdIwQYMBaAFBUAEisT
# mLKZB+0e36K+Vw0rZwLNMB0GA1UdDgQWBBRhWk0ktkkynUoqeRqDS/QeicHKfTB9
# BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYyaHR0cDovL2NybDQuZGlnaWNlcnQu
# Y29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwdwYIKwYBBQUHAQEEazBpMCQG
# CCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUHMAKG
# NWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENB
# LTEuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCdJX4bM02yJoFcm4bOIyAPgIfliP//
# sdRqLDHtOhcZcRfNqRu8WhY5AJ3jbITkWkD73gYBjDf6m7GdJH7+IKRXrVu3mrBg
# JuppVyFdNC8fcbCDlBkFazWQEKB7l8f2P+fiEUGmvWLZ8Cc9OB0obzpSCfDscGLT
# Ykuw4HOmksDTjjHYL+NtFxMG7uQDthSr849Dp3GdId0UyhVdkkHa+Q+B0Zl0DSbE
# Dn8btfWg8cZ3BigV6diT5VUW8LsKqxzbXEgnZsijiwoc5ZXarsQuWaBh3drzbaJh
# 6YoLbewSGL33VVRAA5Ira8JRwgpIr7DUbuD0FAo6G+OPPcqvao173NhEMIIGzTCC
# BbWgAwIBAgIQBv35A5YDreoACus/J7u6GzANBgkqhkiG9w0BAQUFADBlMQswCQYD
# VQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGln
# aWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3QgQ0Ew
# HhcNMDYxMTEwMDAwMDAwWhcNMjExMTEwMDAwMDAwWjBiMQswCQYDVQQGEwJVUzEV
# MBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29t
# MSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEwggEiMA0GCSqGSIb3
# DQEBAQUAA4IBDwAwggEKAoIBAQDogi2Z+crCQpWlgHNAcNKeVlRcqcTSQQaPyTP8
# TUWRXIGf7Syc+BZZ3561JBXCmLm0d0ncicQK2q/LXmvtrbBxMevPOkAMRk2T7It6
# NggDqww0/hhJgv7HxzFIgHweog+SDlDJxofrNj/YMMP/pvf7os1vcyP+rFYFkPAy
# IRaJxnCI+QWXfaPHQ90C6Ds97bFBo+0/vtuVSMTuHrPyvAwrmdDGXRJCgeGDboJz
# PyZLFJCuWWYKxI2+0s4Grq2Eb0iEm09AufFM8q+Y+/bOQF1c9qjxL6/siSLyaxhl
# scFzrdfx2M8eCnRcQrhofrfVdwonVnwPYqQ/MhRglf0HBKIJAgMBAAGjggN6MIID
# djAOBgNVHQ8BAf8EBAMCAYYwOwYDVR0lBDQwMgYIKwYBBQUHAwEGCCsGAQUFBwMC
# BggrBgEFBQcDAwYIKwYBBQUHAwQGCCsGAQUFBwMIMIIB0gYDVR0gBIIByTCCAcUw
# ggG0BgpghkgBhv1sAAEEMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5kaWdp
# Y2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwICMIIB
# Vh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0AGkA
# ZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBlAHAA
# dABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABDAFAA
# LwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABhAHIA
# dAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBpAHQA
# IABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBvAHIA
# cABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQByAGUA
# bgBjAGUALjALBglghkgBhv1sAxUwEgYDVR0TAQH/BAgwBgEB/wIBADB5BggrBgEF
# BQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBD
# BggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0
# QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2Ny
# bDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDig
# NoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9v
# dENBLmNybDAdBgNVHQ4EFgQUFQASKxOYspkH7R7for5XDStnAs0wHwYDVR0jBBgw
# FoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQEFBQADggEBAEZQPsm3
# KCSnOB22WymvUs9S6TFHq1Zce9UNC0Gz7+x1H3Q48rJcYaKclcNQ5IK5I9G6OoZy
# rTh4rHVdFxc0ckeFlFbR67s2hHfMJKXzBBlVqefj56tizfuLLZDCwNK1lL1eT7EF
# 0g49GqkUW6aGMWKoqDPkmzmnxPXOHXh2lCVz5Cqrz5x2S+1fwksW5EtwTACJHvzF
# ebxMElf+X+EevAJdqP77BzhPDcZdkbkPZ0XN1oPt55INjbFpjE/7WeAjD9KqrgB8
# 7pxCDs+R1ye3Fu4Pw718CqDuLAhVhSK46xgaTfwqIa1JMYNHlXdx3LEbS0scEJx3
# FMGdTy9alQgpECYwggciMIIGCqADAgECAgIA5jANBgkqhkiG9w0BAQUFADA9MQsw
# CQYDVQQGEwJHQjERMA8GA1UEChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlh
# IFJvb3QgQ0EgMjAeFw0wOTA0MjExMjE1MTdaFw0yODA0MTQyMzU5NTlaMD8xCzAJ
# BgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEg
# UHVibGljIENBIDEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIz
# xLPZHflPEdu447bWvKchN1cue6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+K
# bl3EG1KwEfXZCNBO9gRP/v8kcl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6f
# i/Hfo4rVEEhWeHE5XjSdaLuaswnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+N
# p8nNXQ/rfn8Em19GxgezP826lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/Sb
# MRk1RL0bBjn6lmnnolWUad8hjcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJop
# Di3O7EQ4cxdyQTdlAgMBAAGjggQoMIIEJDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0T
# AQH/BAgwBgEB/wIBAjCB8AYDVR0gBIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQ
# BggrBgEFBQcCAjCBwxqBwFdhcm5pbmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVk
# IHVuZGVyIHRoaXMgcG9saWN5IHRvIGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3Qg
# aGFkIHRoZWlyIGlkZW50aXR5IGNvbmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBj
# ZXJ0aWZpY2F0ZXMgZm9yIHZhbHVhYmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklM
# SVRZIElTIEFDQ0VQVEVELjCCATMGA1UdDgSCASoEggEmMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAz1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLw
# R1rOIXBeE4OcPsyj/p69U9bYMGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0
# +NsKWCZrNLusaTQozPGFa5IXkJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDidd
# iJ46zsTnbvH78h1R7euH1tO5wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0
# ihhlKuAPQAAORHDAfvgGerVqMxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuY
# pnMgodWZdwgiufzpHbPoWfDSEHCaKQ4tzuxEOHMXckE3ZQIDAQABMFoGA1UdHwRT
# MFEwT6BNoEuGSWh0dHA6Ly93d3cuYXNjZXJ0aWEuY29tL09ubGluZUNBL2NybHMv
# QXNjZXJ0aWFSb290Q0EyL0FzY2VydGlhUm9vdENBMi5jcmwwPQYIKwYBBQUHAQEE
# MTAvMC0GCCsGAQUFBzABhiFodHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5j
# b20wggE3BgNVHSMEggEuMIIBKoCCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCWN76e4Nk+poYTF/ZK86kH8xZo1X9EFkfzIZ99/OT/pPQLvs30wgYD
# 4uyhRBTFkKGf0dH3HjKz1N9SFJud0eqbxtH3YPr8rUjHkxjrX34LxCFWBNoj4T3F
# w3LGnTpGeO6xEaEDAdvdInm3BJvpG4VWES3Z7SJteaIbkNmqDn0DhRpMFXiNKgZK
# NWIcJM1ZGW9+OZO7vxUZrOPBfceplWg70Torc8TBYL7Pv1/g6kuZCO7Dx1nF6agi
# 9GCIHRkMrcjguIqkg8qSL+KWxwWuKi8YHBG4i7vIgvHOKL2lnmdoe63WRAG9wUHb
# 68duwBc1tIAPqam90MQrMyhTGzhwI7aDAgMBAAEwDQYJKoZIhvcNAQEFBQADggEB
# AJSUl6GjE5m6hkpci2WLPoJMrG90TALbigGZS1zTYLsIwUxfx0VndhR/YU7dUQf5
# vFPhzQf9mwm9vidT9Wwd6Wg0hmDiT8Lh5y7T4XyqjuMKN3cp7eDFkrSCUhvT8Lg2
# n/qxeeJMD3ghtFhoyXtI5A/6CmPHBkcNMtQZAhORKjpJ41wSa+vH6v1TzC8otw+x
# uxgyAkO/hRmmmBIgGDuwxKfLrdBQRZWeBRmWqH7grQlE0gYYpBFS4FlorwBqjiID
# p6FH52OrLS9gLV2f1emxMQAlwh3LMBmwvUtTQs++8M8oX2EpXZCIHeoOEFEMbzmE
# v4I88yooHJxcTL026vcl/1IxggQMMIIECAIBATBYMD8xCzAJBgNVBAYTAkdCMREw
# DwYDVQQKEwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEC
# FQCdDgExwhEGCyl5TLUkaz5mLyd2ojAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIB
# DDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE
# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUSmF/py/h4ygY
# cWZ4/J8oiCLHyjIwDQYJKoZIhvcNAQEBBQAEggEAxKGLAtAicbF8IIVKHt4PEyAj
# JtY9JxL7l2XibnPAFTZaE2qnelBBBvnTn6upJayYlhtJzzLMNKe96n82mpr7iZud
# QZcytAPJjleKtMjQHW0U6DQ7kSR64UWAtqMos8pH3y+yHV7QaYAYIIAzar9CZZMz
# jtWdhybXEejx3gnRCrfpSYoHTBr3yjq0/9H2N04OL1EKPLBr8Xa8F3P0LmLSpRso
# s3TTXLm6d24JlQnVGHszYU2yWsY3t6Kevep5K3w7nCgjR7ykE6BCXoqHZ4CRpJET
# +yP05OY4tUSTTJsPtL66dwuU1pdQA1bQXbG2d5aqNGuH1vsXoQEt6FsJoPMcnKGC
# Ag8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# ITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq
# 5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkq
# hkiG9w0BCQUxDxcNMTkwMTA0MjA1MDE4WjAjBgkqhkiG9w0BCQQxFgQUm2qCUtYX
# Pxpcab8rLgNysvq+WLcwDQYJKoZIhvcNAQEBBQAEggEAmj9FYSH7/5os1WZcqdl5
# CVQ8Zsr50kO/05U3/TJltavzU6bt6aH+55TCorkOtI96arMzBAx/dJKuz/pLZqev
# MeCv8XlzUgchYJSNkyEzF7sHn+A8T+QZeM9zWa1CdafIRSGCRb9bAA4NpR0L7P5L
# qt/ZLcHz4BjGZhfS74v1w+9m53Q1fWpqM7VLAWa2Z8Xkx02vDJf/S5iRqTwnvtAZ
# RFKGyGIXvGMbeO73ES9gIToOkzmagmhJctwN+/olCfPXodkPYE1+476GA2q+DUYU
# 4nJK9r2qDYBhiwyqDBf6nefVXDLF4y7aJbMPJdCovB4tHocKA584fUuEomw5tiy3
# hg==
# SIG # End signature block
