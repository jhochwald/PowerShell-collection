function Get-enADObject
{
   <#
         .SYNOPSIS
         Export Active Directory Objects

         .DESCRIPTION
         Export Active Directory Objects

         .PARAMETER ADObjectFilter
         Provide specific AD Objects to report on.  Otherwise, all AD Objects will be reported.  Please review the examples provided.

         .PARAMETER DetailedReport
         Provides a full report of all attributes.  Otherwise, only a refined report will be given.

         .EXAMPLE
         PS ~> Get-enADObject | Export-Csv C:\scripts\PowerShell\Reports\ADObjects.csv -notypeinformation -encoding UTF8

         Export Active Directory Objects

         .EXAMPLE
         PS ~> {objectclass -eq "publicFolder"} | Get-enADObject -DetailedReport | Export-Csv C:\scripts\PowerShell\Reports\PFs.csv -NoTypeInformation -Encoding UTF8

         Export Active Directory Objects

         .EXAMPLE
         PS ~> '{proxyaddresses -like "*contoso.com"}' | Get-enADObject | Export-Csv C:\scripts\PowerShell\Reports\ADObjects.csv -notypeinformation -encoding UTF8

         Export Active Directory Objects

         .EXAMPLE
         PS ~> '{proxyaddresses -like "*contoso.com"}' | Get-enADObject -DetailedReport | Export-Csv C:\scripts\PowerShell\Reports\ADObjects_Detailed.csv -notypeinformation -encoding UTF8

         Export Active Directory Objects

         .OUTPUTS
         PSObject
	
         .NOTES
         Version: 1.0.1
		
         GUID: ae1cde05-b498-46dc-832c-41a5f642dd8a
		
         Author: Joerg Hochwald
		
         Companyname: enabling Technology
		
         Copyright: Copyright (c) 2ß18-2019, enabling Technology - All rights reserved.
		
         License: https://opensource.org/licenses/BSD-3-Clause
		
         Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version
		
         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
		
         Dependencies:
         Active Directory PowerShell Module
	
         .LINK
         https://www.enatec.io

         .LINK
         Get-ADObject
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param (
      [switch]
      $DetailedReport,
      [Parameter(ValueFromPipeline)]
      [string[]]
      $ADObjectFilter
   )
	
   begin
   {
      if ($DetailedReport)
      {
         $Selectproperties = @(
            'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress'
            'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
            'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
            'whenChanged', 'whenCreated', 'adminCount', 'AccountNotDelegated', 'AllowReversiblePasswordEncryption'
            'CannotChangePassword', 'Deleted', 'DoesNotRequirePreAuth', 'HomedirRequired', 'isDeleted', 'LockedOut'
            'mAPIRecipient', 'mDBUseDefaults', 'MNSLogonAccount', 'msExchHideFromAddressLists'
            'msNPAllowDialin', 'PasswordExpired', 'PasswordNeverExpires', 'PasswordNotRequired', 'ProtectedFromAccidentalDeletion'
            'SmartcardLogonRequired', 'TrustedForDelegation', 'TrustedToAuthForDelegation', 'UseDESKeyOnly', 'logonHours'
            'msExchMailboxGuid', 'replicationSignature', 'AccountExpirationDate', 'AccountLockoutTime', 'Created', 'createTimeStamp'
            'LastBadPasswordAttempt', 'LastLogonDate', 'Modified', 'modifyTimeStamp', 'msTSExpireDate', 'PasswordLastSet'
            'msExchMailboxSecurityDescriptor', 'nTSecurityDescriptor', 'BadLogonCount', 'codePage', 'countryCode'
            'deletedItemFlags', 'dLMemDefault', 'garbageCollPeriod', 'instanceType', 'msDS-SupportedEncryptionTypes'
            'msDS-User-Account-Control-Computed', 'msExchALObjectVersion', 'msExchMobileMailboxFlags', 'msExchRecipientDisplayType'
            'msExchUserAccountControl', 'primaryGroupID', 'replicatedObjectVersion', 'sAMAccountType', 'sDRightsEffective'
            'userAccountControl', 'accountExpires', 'lastLogonTimestamp', 'lockoutTime', 'msExchRecipientTypeDetails', 'msExchVersion'
            'pwdLastSet', 'uSNChanged', 'uSNCreated', 'ObjectGUID', 'objectSid', 'SID', 'autoReplyMessage', 'CanonicalName'
            'displayNamePrintable', 'Division', 'EmployeeID', 'EmployeeNumber', 'HomeDirectory', 'HomeDrive', 'homeMDB', 'homeMTA'
            'HomePage', 'Initials', 'LastKnownParent', 'legacyExchangeDN', 'LogonWorkstations'
            'Manager', 'msExchHomeServerName', 'msExchUserCulture', 'msTSLicenseVersion', 'msTSManagingLS'
            'ObjectCategory', 'ObjectClass', 'Organization', 'OtherName', 'POBox', 'PrimaryGroup'
            'ProfilePath', 'ScriptPath', 'sn', 'textEncodedORAddress', 'userParameters'
         )
			
         $CalculatedProps = @(
            @{
               n = 'OU'
               e = {
                  $_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
               }
            }, 
            @{
               n = 'proxyAddresses'
               e = {
                  ($_.proxyAddresses | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join '|'
               }
            }, 
            @{
               n = 'altRecipientBL'
               e = {
                  ($_.altRecipientBL | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'AuthenticationPolicy'
               e = {
                  ($_.AuthenticationPolicy | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'AuthenticationPolicySilo'
               e = {
                  ($_.AuthenticationPolicySilo | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'Certificates'
               e = {
                  ($_.Certificates | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'CompoundIdentitySupported'
               e = {
                  ($_.CompoundIdentitySupported | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'dSCorePropagationData'
               e = {
                  ($_.dSCorePropagationData | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'KerberosEncryptionType'
               e = {
                  ($_.KerberosEncryptionType | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'managedObjects'
               e = {
                  ($_.managedObjects | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'MemberOf'
               e = {
                  ($_.MemberOf | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'msExchADCGlobalNames'
               e = {
                  ($_.msExchADCGlobalNames | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'msExchPoliciesExcluded'
               e = {
                  ($_.msExchPoliciesExcluded | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'PrincipalsAllowedToDelegateToAccount'
               e = {
                  ($_.PrincipalsAllowedToDelegateToAccount | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'protocolSettings'
               e = {
                  ($_.protocolSettings | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'publicDelegatesBL'
               e = {
                  ($_.publicDelegatesBL | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'securityProtocol'
               e = {
                  ($_.securityProtocol | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'ServicePrincipalNames'
               e = {
                  ($_.ServicePrincipalNames | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'showInAddressBook'
               e = {
                  ($_.showInAddressBook | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'SIDHistory'
               e = {
                  ($_.SIDHistory | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'userCertificate'
               e = {
                  ($_.userCertificate | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }
         )
			
         $ExtensionAttribute = @(
            'extensionAttribute1', 'extensionAttribute2', 'extensionAttribute3', 'extensionAttribute4', 'extensionAttribute5'
            'extensionAttribute6', 'extensionAttribute7', 'extensionAttribute8', 'extensionAttribute9', 'extensionAttribute10'
            'extensionAttribute11', 'extensionAttribute12', 'extensionAttribute13', 'extensionAttribute14', 'extensionAttribute15'
         )
      }
      else
      {
         $Props = @(
            'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress', 
            'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
            'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
            'whenChanged', 'whenCreated', 'adminCount', 'Memberof', 'msExchPoliciesExcluded', 'proxyAddresses'
         )
			
         $Selectproperties = @(
            'DisplayName', 'UserPrincipalName', 'mail', 'CN', 'mailNickname', 'Name', 'GivenName', 'Surname', 'StreetAddress', 
            'City', 'State', 'Country', 'PostalCode', 'Company', 'Title', 'Department', 'Description', 'OfficePhone'
            'MobilePhone', 'HomePhone', 'Fax', 'SamAccountName', 'DistinguishedName', 'Office', 'Enabled'
            'whenChanged', 'whenCreated', 'adminCount'
         )
			
			
         $CalculatedProps = @(
            @{
               n = 'proxyAddresses'
               e = {
                  ($_.proxyAddresses | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join '|'
               }
            }, 
            @{
               n = 'OU'
               e = {
                  $_.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
               }
            }, 
            @{
               n = 'MemberOf'
               e = {
                  ($_.MemberOf | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }, 
            @{
               n = 'msExchPoliciesExcluded'
               e = {
                  ($_.msExchPoliciesExcluded | Where-Object -FilterScript {
                        $_ -ne $null
                  }) -join ';'
               }
            }
         )
      }
   }
	
   process
   {
      if ($ADObjectFilter)
      {
         foreach ($CurADObjectFilter in $ADObjectFilter)
         {
            if (! $DetailedReport)
            {
               Get-ADObject -Filter $CurADObjectFilter -Properties $Props -ResultSetSize $null | Select-Object -Property ($Selectproperties + $CalculatedProps)
            }
            else
            {
               Get-ADObject -Filter $CurADObjectFilter -Properties * -ResultSetSize $null | Select-Object -Property ($Selectproperties + $CalculatedProps + $ExtensionAttribute)
            }
         }
      }
      else
      {
         if (! $DetailedReport)
         {
            Get-ADObject -Filter * -Properties $Props -ResultSetSize $null | Select-Object -Property ($Selectproperties + $CalculatedProps)
         }
         else
         {
            Get-ADObject -Filter * -Properties * -ResultSetSize $null | Select-Object -Property ($Selectproperties + $CalculatedProps + $ExtensionAttribute)
         }
      }
   }
}
