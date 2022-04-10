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
                  $PSItem.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
               }
            },
            @{
               n = 'proxyAddresses'
               e = {
                  ($PSItem.proxyAddresses | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join '|'
               }
            },
            @{
               n = 'altRecipientBL'
               e = {
                  ($PSItem.altRecipientBL | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'AuthenticationPolicy'
               e = {
                  ($PSItem.AuthenticationPolicy | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'AuthenticationPolicySilo'
               e = {
                  ($PSItem.AuthenticationPolicySilo | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'Certificates'
               e = {
                  ($PSItem.Certificates | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'CompoundIdentitySupported'
               e = {
                  ($PSItem.CompoundIdentitySupported | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'dSCorePropagationData'
               e = {
                  ($PSItem.dSCorePropagationData | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'KerberosEncryptionType'
               e = {
                  ($PSItem.KerberosEncryptionType | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'managedObjects'
               e = {
                  ($PSItem.managedObjects | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'MemberOf'
               e = {
                  ($PSItem.MemberOf | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'msExchADCGlobalNames'
               e = {
                  ($PSItem.msExchADCGlobalNames | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'msExchPoliciesExcluded'
               e = {
                  ($PSItem.msExchPoliciesExcluded | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'PrincipalsAllowedToDelegateToAccount'
               e = {
                  ($PSItem.PrincipalsAllowedToDelegateToAccount | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'protocolSettings'
               e = {
                  ($PSItem.protocolSettings | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'publicDelegatesBL'
               e = {
                  ($PSItem.publicDelegatesBL | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'securityProtocol'
               e = {
                  ($PSItem.securityProtocol | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'ServicePrincipalNames'
               e = {
                  ($PSItem.ServicePrincipalNames | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'showInAddressBook'
               e = {
                  ($PSItem.showInAddressBook | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'SIDHistory'
               e = {
                  ($PSItem.SIDHistory | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'userCertificate'
               e = {
                  ($PSItem.userCertificate | Where-Object -FilterScript {
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
                  ($PSItem.proxyAddresses | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join '|'
               }
            },
            @{
               n = 'OU'
               e = {
                  $PSItem.DistinguishedName -replace '^.+?,(?=(OU|CN)=)'
               }
            },
            @{
               n = 'MemberOf'
               e = {
                  ($PSItem.MemberOf | Where-Object -FilterScript {
                     $_ -ne $null
                  }) -join ';'
               }
            },
            @{
               n = 'msExchPoliciesExcluded'
               e = {
                  ($PSItem.msExchPoliciesExcluded | Where-Object -FilterScript {
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
