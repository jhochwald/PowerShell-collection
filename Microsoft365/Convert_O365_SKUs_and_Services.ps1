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
      A hash table of Office 365 Service Plans and there Human understandable description

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
         'AAD_BASIC'                          = 'Azure Active Directory Basic'
         'AAD_PREMIUM'                        = 'Azure Active Directory Premium'
         'MFA_PREMIUM'                        = 'Azure Multi-Factor Authentication'
         'RMS_S_ENTERPRISE'                   = 'Azure Information Protection'
         'RMS_S_ENTERPRISE_GOV'               = 'Azure Information Protection for Government'
         'SHAREPOINT_DUET_EDU'                = 'Duet Online for Academics'
         'SHAREPOINT_DUET_GOV'                = 'Duet Online for Government'
         'EXCHANGE_S_STANDARD'                = 'Exchange Online (Plan 1)'
         'EXCHANGE_S_STANDARD_GOV'            = 'Exchange Online (Plan 1 for Government)'
         'EXCHANGE_S_ENTERPRISE'              = 'Exchange Online (Plan 2)'
         'EXCHANGE_S_ENTERPRISE_GOV'          = 'Exchange Online (Plan 2 for Government)'
         'EXCHANGE_S_ARCHIVE'                 = 'Exchange Online Archiving'
         'EXCHANGE_S_ARCHIVE_GOV'             = 'Exchange Online Archiving for Government'
         'EXCHANGE_S_DESKLESS'                = 'Exchange Online Kiosk'
         'EXCHANGE_S_DESKLESS_GOV'            = 'Exchange Online Kiosk for Government'
         'EOP_ENTERPRISE'                     = 'Exchange Online Protection'
         'EOP_ENTERPRISE_GOV'                 = 'Exchange Online Protection for Government'
         'INTUNE_A'                           = 'Intune'
         'MCOIMP'                             = 'Skype for Business Online (formerly Lync Online (Plan 1)'
         'MCOIMP_GOV'                         = 'Skype for Business Online (Plan 1 for Government)'
         'MCOSTANDARD'                        = 'Skype for Business Online (Plan 2)'
         'MCOSTANDARD_GOV'                    = 'Skype for Business Online (Plan 2 for Government)'
         'MCOVOICECONF'                       = 'Skype for Business Online (Plan 3)'
         'MCOVOICECONF_GOV'                   = 'Skype for Business Online (Plan 3 for Government)'
         'CRMENTERPRISE'                      = 'Microsoft Dynamics CRM Online Enterprise'
         'CRMSTANDARD_GCC'                    = 'Microsoft Dynamics CRM Online Government Professional'
         'CRMSTANDARD'                        = 'Microsoft Dynamics CRM Online Professional'
         'DMENTERPRISE'                       = 'Microsoft Dynamics Marketing Online Enterprise'
         'MDM_SALES_COLLABORATION'            = 'Microsoft Dynamics Marketing Sales Collaboration'
         'SQL_IS_SSIM'                        = 'Microsoft Power BI Information Services Plan 1'
         'BI_AZURE_P1'                        = 'Microsoft Power BI Reporting and Analytics Plan 1'
         'BI_AZURE_P2'                        = 'Microsoft Power BI Reporting and Analytics Plan 2'
         'NBENTERPRISE'                       = 'Microsoft Social Listening Enterprise'
         'NBPROFESSIONALFORCRM'               = 'Microsoft Social Listening Professional'
         'INTUNE_O365'                        = 'Mobile Device Management for Office 365'
         'OFFICE_BUSINESS'                    = 'Office 365 Business'
         'OFFICESUBSCRIPTION'                 = 'Office 365 ProPlus'
         'OFFICESUBSCRIPTION_GOV'             = 'Office 365 ProPlus for Government'
         'OFFICE_PRO_PLUS_SUBSCRIPTION_SMBIZ' = 'Office 365 Small Business Subscription'
         'SHAREPOINTWAC'                      = 'Office Online'
         'SHAREPOINTWAC_DEVELOPER'            = 'Office Online Developer'
         'SHAREPOINTWAC_EDU'                  = 'Office Online EDU'
         'SHAREPOINTWAC_DEVELOPER_GOV'        = 'Office Online for Government Developer'
         'SHAREPOINTWAC_GOV'                  = 'Office Online for Government'
         'ONEDRIVESTANDARD'                   = 'OneDrive for Business (Plan 1)'
         'ONEDRIVESTANDARD_GOV'               = 'OneDrive for Business (Plan 1 for Government)'
         'ONEDRIVELITE'                       = 'OneDrive for Business Lite'
         'PARATURE_ENTERPRISE'                = 'Parature Enterprise'
         'PARATURE_ENTERPRISE_GOV'            = 'Parature Enterprise for Government'
         'BI_AZURE_P0'                        = 'Power BI'
         'PROJECT_ESSENTIALS'                 = 'Project Lite'
         'PROJECT_ESSENTIALS_GOV'             = 'Project Lite for Government'
         'SHAREPOINT_PROJECT'                 = 'Project Online'
         'SHAREPOINT_PROJECT_EDU'             = 'Project Online for Academics'
         'SHAREPOINT_PROJECT_GOV'             = 'Project Online for Government'
         'PROJECT_CLIENT_SUBSCRIPTION'        = 'Project Pro for Office 365'
         'PROJECT_CLIENT_SUBSCRIPTION_GOV'    = 'Project Pro for Office 365 for Government'
         'SHAREPOINTSTANDARD'                 = 'SharePoint Online (Plan 1)'
         'SHAREPOINTSTANDARD_EDU'             = 'SharePoint Online (Plan 1 for Academics)'
         'SHAREPOINTSTANDARD_GOV'             = 'SharePoint Online (Plan 1 for Government)'
         'SHAREPOINTENTERPRISE'               = 'SharePoint Online (Plan 2)'
         'SHAREPOINTENTERPRISE_EDU'           = 'SharePoint Online (Plan 2 for Academics)'
         'SHAREPOINTENTERPRISE_GOV'           = 'SharePoint Online (Plan 2 for Government)'
         'SHAREPOINT_S_DEVELOPER'             = 'SharePoint Online for Developer'
         'SHAREPOINT_S_DEVELOPER_GOV'         = 'SharePoint Online for Government Developer'
         'SHAREPOINTDESKLESS'                 = 'SharePoint Online Kiosk'
         'SHAREPOINTDESKLESS_GOV'             = 'SharePoint Online Kiosk for Government'
         'VISIO_CLIENT_SUBSCRIPTION'          = 'Visio Pro for Office 365'
         'VISIO_CLIENT_SUBSCRIPTION_GOV'      = 'Visio Pro for Office 365 for Government'
         'YAMMER_ENTERPRISE'                  = 'Yammer Enterprise'
         'YAMMER_EDU'                         = 'Yammer for Academic For Academics'
         'FLOW_O365_P2'                       = 'Flow for Office 365 P2'
         'POWERAPPS_O365_P2'                  = 'PowerApps for Office 365 P2'
         'TEAMS1'                             = 'Microsoft Teams'
         'PROJECTWORKMANAGEMENT'              = 'Microsoft Planner'
         'SWAY'                               = 'SWAY'
         'Deskless'                           = 'Microsoft StaffHub'
         'FLOW_O365_P3'                       = 'Flow for Office 365 P3'
         'POWERAPPS_O365_P3'                  = 'PowerApps for Office 365 P3'
         'ADALLOM_S_O365'                     = 'Office 365 Advanced Security Management'
         'EQUIVIO_ANALYTICS'                  = 'Office 365 Advanced eDiscovery'
         'LOCKBOX_ENTERPRISE'                 = 'Customer Lockbox'
         'EXCHANGE_ANALYTICS'                 = 'Microsoft MyAnalytics'
         'ATP_ENTERPRISE'                     = 'Exchange Online Advanced Threat Protection (These licenses do not need to be individually assigned)'
         'MCOEV'                              = 'Teams/Skype for Business Cloud PBX'
         'MCOMEETADV'                         = 'Teams/Skype for Business PSTN Conferencing'
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
         'AAD_BASIC'                          = 'Azure Active Directory Basic'
         'AAD_PREMIUM'                        = 'Azure Active Directory Premium'
         'RIGHTSMANAGEMENT'                   = 'Azure Active Directory Rights'
         'RIGHTSMANAGEMENT_FACULTY'           = 'Azure Active Directory Rights for Faculty'
         'RIGHTSMANAGEMENT_GOV'               = 'Azure Active Directory Rights for Government'
         'RIGHTSMANAGEMENT_STUDENT'           = 'Azure Active Directory Rights for Students'
         'MFA_STANDALONE'                     = 'Azure Multi-Factor Authentication Premium Standalone'
         'EMS'                                = 'Microsoft Enterprise Mobility + Security Suite'
         'EXCHANGESTANDARD_FACULTY'           = 'Exchange (Plan 1 for Faculty)'
         'EXCHANGESTANDARD_STUDENT'           = 'Exchange (Plan 1 for Students)'
         'EXCHANGEENTERPRISE_FACULTY'         = 'Exchange (Plan 2 for Faculty)'
         'EXCHANGEENTERPRISE_STUDENT'         = 'Exchange (Plan 2 for Students)'
         'EXCHANGEARCHIVE'                    = 'Exchange Archiving'
         'EXCHANGEARCHIVE_FACULTY'            = 'Exchange Archiving for Faculty'
         'EXCHANGEARCHIVE_GOV'                = 'Exchange Archiving for Government'
         'EXCHANGEARCHIVE_STUDENT'            = 'Exchange Archiving for Students'
         'EXCHANGESTANDARD_GOV'               = 'Exchange for Government (Plan 1G)'
         'EXCHANGEENTERPRISE_GOV'             = 'Exchange for Government (Plan 2G)'
         'EXCHANGEDESKLESS'                   = 'Exchange Kiosk'
         'EXCHANGEDESKLESS_GOV'               = 'Exchange Kiosk for Government'
         'EXCHANGESTANDARD'                   = 'Exchange Plan 1'
         'EXCHANGEENTERPRISE'                 = 'Exchange Plan 2'
         'EOP_ENTERPRISE_FACULTY'             = 'Exchange Protection for Faculty'
         'EOP_ENTERPRISE_GOV'                 = 'Exchange Protection for Government'
         'EOP_ENTERPRISE_STUDENT'             = 'Exchange Protection for Student'
         'EXCHANGE_ONLINE_WITH_ONEDRIVE_LITE' = 'Exchange with OneDrive for Business'
         'INTUNE_A'                           = 'Intune'
         'MCOIMP_FACULTY'                     = 'Lync (Plan 1 for Faculty)'
         'MCOIMP_STUDENT'                     = 'Lync (Plan 1 for Students)'
         'MCOSTANDARD_FACULTY'                = 'Lync (Plan 2 for Faculty)'
         'MCOSTANDARD_STUDENT'                = 'Lync (Plan 2 for Students)'
         'MCOVOICECONF'                       = 'Lync (Plan 3)'
         'MCOIMP_GOV'                         = 'Lync for Government (Plan 1G)'
         'MCOSTANDARD_GOV'                    = 'Lync for Government (Plan 2G)'
         'MCOVOICECONF_GOV'                   = 'Lync for Government (Plan 3G)'
         'MCOINTERNAL'                        = 'Lync Internal Incubation and Corp to Cloud'
         'MCOIMP'                             = 'Skype Plan 1'
         'MCOSTANDARD'                        = 'Skype Plan 2'
         'MCOVOICECONF_FACULTY'               = 'Lync Plan 3 for Faculty'
         'MCOVOICECONF_STUDENT'               = 'Lync Plan 3 for Students'
         'CRMENTERPRISE'                      = 'Microsoft Dynamics CRM Online Enterprise'
         'CRMSTANDARD_GCC'                    = 'Microsoft Dynamics CRM Online Government Professional'
         'CRMSTANDARD'                        = 'Microsoft Dynamics CRM Online Professional'
         'DMENTERPRISE'                       = 'Microsoft Dynamics Marketing Online Enterprise'
         'INTUNE_O365_STANDALONE'             = 'Mobile Device Management for Office 365'
         'OFFICE_BASIC'                       = 'Office 365 Basic'
         'O365_BUSINESS'                      = 'Office 365 Business'
         'O365_BUSINESS_ESSENTIALS'           = 'Office 365 Business Essentials'
         'O365_BUSINESS_PREMIUM'              = 'Office 365 Business Premium'
         'DEVELOPERPACK'                      = 'Office 365 Developer'
         'DEVELOPERPACK_GOV'                  = 'Office 365 Developer for Government'
         'EDUPACK_FACULTY'                    = 'Office 365 Education for Faculty'
         'EDUPACK_STUDENT'                    = 'Office 365 Education for Students'
         'EOP_ENTERPRISE'                     = 'Office 365 Exchange Protection Enterprise'
         'EOP_ENTERPRISE_PREMIUM'             = 'Office 365 Exchange Protection Premium'
         'STANDARDPACK_GOV'                   = 'Office 365 for Government (Plan G1)'
         'STANDARDWOFFPACK_GOV'               = 'Office 365 for Government (Plan G2)'
         'ENTERPRISEPACK_GOV'                 = 'Office 365 for Government (Plan G3)'
         'ENTERPRISEWITHSCAL_GOV'             = 'Office 365 for Government (Plan G4)'
         'DESKLESSPACK_GOV'                   = 'Office 365 for Government (Plan F1G)'
         'STANDARDPACK_FACULTY'               = 'Office 365 Plan A1 for Faculty'
         'STANDARDPACK_STUDENT'               = 'Office 365 Plan A1 for Students'
         'STANDARDWOFFPACK_FACULTY'           = 'Office 365 Plan A2 for Faculty'
         'STANDARDWOFFPACK_STUDENT'           = 'Office 365 Plan A2 for Students'
         'ENTERPRISEPACK_FACULTY'             = 'Office 365 Plan A3 for Faculty'
         'ENTERPRISEPACK_STUDENT'             = 'Office 365 Plan A3 for Students'
         'ENTERPRISEWITHSCAL_FACULTY'         = 'Office 365 Plan A4 for Faculty'
         'ENTERPRISEWITHSCAL_STUDENT'         = 'Office 365 Plan A4 for Students'
         'STANDARDPACK'                       = 'Office 365 Plan E1'
         'STANDARDWOFFPACK'                   = 'Office 365 Plan E2'
         'ENTERPRISEPACK'                     = 'Office 365 Plan E3'
         'ENTERPRISEWITHSCAL'                 = 'Office 365 Plan E4'
         'DESKLESSPACK'                       = 'Office 365 Plan F1'
         'DESKLESSPACK_YAMMER'                = 'Office 365 Plan F1 with Yammer'
         'OFFICESUBSCRIPTION'                 = 'Office Professional Plus'
         'OFFICESUBSCRIPTION_FACULTY'         = 'Office Professional Plus for Faculty'
         'OFFICESUBSCRIPTION_GOV'             = 'Office Professional Plus for Government'
         'OFFICESUBSCRIPTION_STUDENT'         = 'Office Professional Plus for Students'
         'WACSHAREPOINTSTD_FACULTY'           = 'Office Web Apps (Plan 1 For Faculty)'
         'WACSHAREPOINTSTD_STUDENT'           = 'Office Web Apps (Plan 1 For Students)'
         'WACSHAREPOINTSTD_GOV'               = 'Office Web Apps (Plan 1G for Government)'
         'WACSHAREPOINTENT_FACULTY'           = 'Office Web Apps (Plan 2 For Faculty)'
         'WACSHAREPOINTENT_STUDENT'           = 'Office Web Apps (Plan 2 For Students)'
         'WACSHAREPOINTENT_GOV'               = 'Office Web Apps (Plan 2G for Government)'
         'WACSHAREPOINTSTD'                   = 'Office Web Apps with SharePoint Plan 1'
         'WACSHAREPOINTENT'                   = 'Office Web Apps with SharePoint Plan 2'
         'ONEDRIVESTANDARD'                   = 'OneDrive for Business'
         'ONEDRIVESTANDARD_GOV'               = 'OneDrive for Business for Government (Plan 1G)'
         'WACONEDRIVESTANDARD'                = 'OneDrive for Business with Office Web Apps'
         'WACONEDRIVESTANDARD_GOV'            = 'OneDrive for Business with Office Web Apps for Government'
         'PARATURE_ENTERPRISE'                = 'Parature Enterprise'
         'PARATURE_ENTERPRISE_GOV'            = 'Parature Enterprise for Government'
         'POWER_BI_STANDARD'                  = 'Power BI'
         'POWER_BI_STANDALONE'                = 'Power BI for Office 365'
         'POWER_BI_STANDALONE_FACULTY'        = 'Power BI for Office 365 for Faculty'
         'POWER_BI_STANDALONE_STUDENT'        = 'Power BI for Office 365 for Students'
         'PROJECTESSENTIALS'                  = 'Project Essentials'
         'PROJECTESSENTIALS_GOV'              = 'Project Essentials for Government'
         'PROJECTONLINE_PLAN_1'               = 'Project Plan 1'
         'PROJECTONLINE_PLAN_1_FACULTY'       = 'Project Plan 1 for Faculty'
         'PROJECTONLINE_PLAN_1_GOV'           = 'Project Plan 1for Government'
         'PROJECTONLINE_PLAN_1_STUDENT'       = 'Project Plan 1 for Students'
         'PROJECTONLINE_PLAN_2'               = 'Project Plan 2'
         'PROJECTONLINE_PLAN_2_FACULTY'       = 'Project Plan 2 for Faculty'
         'PROJECTONLINE_PLAN_2_GOV'           = 'Project Plan 2 for Government'
         'PROJECTONLINE_PLAN_2_STUDENT'       = 'Project Plan 2 for Students'
         'PROJECTCLIENT'                      = 'Project Pro for Office 365'
         'PROJECTCLIENT_FACULTY'              = 'Project Pro for Office 365 for Faculty'
         'PROJECTCLIENT_GOV'                  = 'Project Pro for Office 365 for Government'
         'PROJECTCLIENT_STUDENT'              = 'Project Pro for Office 365 for Students'
         'SHAREPOINTSTANDARD_FACULTY'         = 'SharePoint (Plan 1 for Faculty)'
         'SHAREPOINTSTANDARD_STUDENT'         = 'SharePoint (Plan 1 for Students)'
         'SHAREPOINTSTANDARD_YAMMER'          = 'SharePoint (Plan 1 with Yammer)'
         'SHAREPOINTENTERPRISE_FACULTY'       = 'SharePoint (Plan 2 for Faculty)'
         'SHAREPOINTENTERPRISE_STUDENT'       = 'SharePoint (Plan 2 for Students)'
         'SHAREPOINTENTERPRISE_YAMMER'        = 'SharePoint (Plan 2 with Yammer)'
         'SHAREPOINTSTANDARD_GOV'             = 'SharePoint for Government (Plan 1G)'
         'SHAREPOINTENTERPRISE_GOV'           = 'SharePoint for Government (Plan 2G)'
         'SHAREPOINTDESKLESS'                 = 'SharePoint Kiosk'
         'SHAREPOINTSTANDARD'                 = 'SharePoint Plan 1'
         'SHAREPOINTENTERPRISE'               = 'SharePoint Plan 2'
         'SMB_BUSINESS'                       = 'SMB Business'
         'SMB_BUSINESS_ESSENTIALS'            = 'SMB Business Essentials'
         'SMB_BUSINESS_PREMIUM'               = 'SMB Business Premium'
         'VISIOCLIENT'                        = 'Visio Pro for Office 365'
         'VISIOCLIENT_FACULTY'                = 'Visio Pro for Office 365 for Faculty'
         'VISIOCLIENT_GOV'                    = 'Visio Pro for Office 365 for Government'
         'VISIOCLIENT_STUDENT'                = 'Visio Pro for Office 365 for Students'
         'YAMMER_ENTERPRISE_STANDALONE'       = 'Yammer Enterprise Standalone'
         'RIGHTSMANAGEMENT_ADHOC'             = 'Azure Rights Management Service'
         'ENTERPRISEPREMIUM'                  = 'Office 365 Enterprise E5'
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
      $PSItem.ServiceStatus.ServicePlan.ServiceName
      }
      } | ForEach-Object -Process {
      $PSItem.ServicePlanName
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
            $PSItem.Value -eq "$ServicePlanFriendlyName"
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
            $PSItem.Value -eq "$SkuPartNumberFriendlyName"
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
      $PSItem.ServiceStatus.ServicePlan.ServiceName
   }
} | ForEach-Object -Process {
   $PSItem.ServicePlanName
} | Convert-MsolServicePlanName

Write-Output -InputObject ''

Write-Output -InputObject 'MsolAccountSkuName:'
Get-MsolAccountSku | Select-Object -ExpandProperty SkuPartNumber | Convert-MsolAccountSkuName
#endregion Info


#region LICENSE
<#
   BSD 3-Clause License

   Copyright (c) 2022, enabling Technology
   All rights reserved.

   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
