#requires -Version 3.0

<#
      .SYNOPSIS
      Return a list of well known AAGUIDs for Passkey Providers

      .DESCRIPTION
      Return a list of well known AAGUIDs for Passkey Providers

      .EXAMPLE
      PS C:\> .\Get-WellKnownAAGUIDs.ps1
      Return a list of well known AAGUIDs for Passkey Providers, with description

      .EXAMPLE
      PS C:\> (.\Get-WellKnownAAGUIDs.ps1).AAGUID
      Return a list of well known AAGUIDs for Passkey Providers,
      This just return a list of AAGUIDs and is perfect to feed you Graph requests
      as described here:
      https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2

      .LINK
      https://github.com/passkeydeveloper/passkey-authenticator-aaguids

      .LINK
      https://aka.ms/fido2docs

      .LINK
      https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-enable-passkey-fido2

      .LINK
      https://learn.microsoft.com/en-us/entra/identity/authentication/concept-fido2-hardware-vendor

      .LINK
      https://webauthn.passwordless.id/demos/authenticators

      .NOTES
      Basic idea is stolen here: https://github.com/darrenjrobinson/PasskeyProviderAAGUIDs
      I came up with this to create my own Graph (PATCH) request to update the the list of known AAGUIDs

      A PATCH request request should have a JSON body this:
      {
      "@odata.type": "#microsoft.graph.fido2AuthenticationMethodConfiguration",
      "isAttestationEnforced": false,
      "keyRestrictions": {
      "isEnforced": true,
      "enforcementType": "allow",
      "aaGuids": [
      "<LIST OF AAGUIDs>"
      ]
      }
      }

      And send it as a PATCH to https://graph.microsoft.com/v1.0/authenticationMethodsPolicy/authenticationMethodConfigurations/FIDO2
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([pscustomobject])]
param ()

process
{
   # Get the list from GitHub (https://github.com/passkeydeveloper/passkey-authenticator-aaguids)
   $Data = (Invoke-RestMethod -Method Get -Uri 'https://github.com/passkeydeveloper/passkey-authenticator-aaguids/raw/refs/heads/main/combined_aaguid.json' -DisableKeepAlive -ContentType 'application/json' -ErrorAction Stop)
   
   # Create a new object
   $AAGuids = @()
   
   # Add the data we downloaded
   $GuidsList = ($Data | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name)
   
   foreach ($AAGuid in $GuidsList)
   {
      $AAGuidObject = [PSCustomObject][ordered]@{
         AAGUID = ($AAGuid).trim()
         Name   = ($Data.$AAGuid.name).trim()
      }
      $AAGuids += $AAGuidObject
   }
   
   # Remove the objects
   $GuidsList = $null
   $Data = $null
   
   #region AddMicrosoftAuthenticator
   $AAGuidObject = [PSCustomObject][ordered]@{
      AAGUID = ('de1e552d-db1d-4423-a619-566b625cdc84').trim()
      Name   = ('Microsoft Authenticator for Android (Preview)').trim()
   }
   $AAGuids += $AAGuidObject
   
   $AAGuidObject = [PSCustomObject][ordered]@{
      AAGUID = ('90a3ccdf-635c-4729-a248-9b709135078f').trim()
      Name   = ('Microsoft Authenticator for iOS (Preview)').trim()
   }
   $AAGuids += $AAGuidObject
   #endregion AddMicrosoftAuthenticator
   
   #region MyOwnAAGuidList
   # A list of AAGUID's I know or found somewhere
   $MyOwnAAGuidList = '
      "9c835346-796b-4c27-8898-d6032f515cc5";"Cryptnox FIDO2"
      "fbfc3007-154e-4ecc-8c0b-6e020557d7bd";"iCloud Keychain"
      "dd4ec289-e01d-41c9-bb89-70fa845d4bf2";"iCloud Keychain (Managed)"
      "07a9f89c-6407-4594-9d56-621d5f1e358b";"NXP Semiconductros FIDO2 Conformance Testing CTAP2 Authenticator"
      "f8a011f3-8c0a-4d15-8006-17111f9edc7d";"Security Key by Yubico"
      "a4e9fc6d-4cbe-4758-b8ba-37598bb5bbaa";"Security Key NFC by Yubico"
      "47ab2fb4-66ac-4184-9ae1-86be814012d5";"Security Key NFC by Yubico - Enterprise Edition"
      "ed042a3a-4b22-4455-bb69-a267b652ae7e";"Security Key NFC by Yubico - Enterprise Edition"
      "72c6b72d-8512-4c66-8359-9d3d10d9222f";"Security Key NFC by Yubico - Enterprise Edition (Enterprise Profile)"
      "d94a29d9-52dd-4247-9c2d-8b818b610389";"VeriMark Guard Fingerprint Key"
      "08987058-cadc-4b81-b6e1-30de50dcbe96";"Windows Hello Hardware Authenticator"
      "57f7de54-c807-4eab-b1c6-1c9be7984e92";"YubiKey 5 FIPS Series"
      "7b96457d-e3cd-432b-9ceb-c9fdd7ef7432";"YubiKey 5 FIPS Series with Lightning"
      "85203421-48f9-4355-9bc8-8a53846e5083";"YubiKey 5 FIPS Series with Lightning"
      "fcc0118f-cd45-435b-8da1-9782b2da0715";"YubiKey 5 FIPS Series with NFC"
      "c1f9a0bc-1dd2-404a-b27f-8e29047a43fd";"YubiKey 5 FIPS Series with NFC"
      "79f3c8ba-9e35-484b-8f47-53a5a0f5c630";"YubiKey 5 FIPS Series with NFC (Enterprise Profile)"
      "ee882879-721c-4913-9775-3dfcce97072a";"YubiKey 5 Series"
      "cb69481e-8ff7-4039-93ec-0a2729a154a8";"YubiKey 5 Series"
      "20ac7a17-c814-4833-93fe-539f0d5e3389";"YubiKey 5 Series (Enterprise Profile)"
      "a02167b9-ae71-4ac7-9a07-06432ebb6f1c";"YubiKey 5 Series with Lightning"
      "24673149-6c86-42e7-98d9-433fb5b73296";"YubiKey 5 Series with Lightning"
      "d7781e5d-e353-46aa-afe2-3ca49f13332a";"YubiKey 5 Series with NFC"
      "a25342c0-3cdc-4414-8e46-f4807fca511c";"YubiKey 5 Series with NFC"
      "2fc0579f-8113-47ea-b116-bb5a8db9202a";"YubiKey 5 Series with NFC"
      "662ef48a-95e2-4aaa-a6c1-5b9c40375824";"YubiKey 5 Series with NFC - Enhanced PIN"
      "b2c1a50b-dad8-4dc7-ba4d-0ce9597904bc";"YubiKey 5 Series with NFC - Enhanced PIN (Enterprise Profile)"
      "6ab56fad-881f-4a43-acb2-0be065924522";"YubiKey 5 Series with NFC (Enterprise Profile)"
      "9eb7eabc-9db5-49a1-b6c3-555a802093f4";"YubiKey 5 Series with NFC KVZR57"
      "d8522d9f-575b-4866-88a9-ba99fa02f35b";"YubiKey Bio Series - FIDO Edition"
      "7409272d-1ff9-4e10-9fc9-ac0019c124fd";"YubiKey Bio Series - FIDO Edition"
      "dd86a2da-86a0-4cbe-b462-4bd31f57bc6f";"YubiKey Bio Series - FIDO Edition"
      "ad08c78a-4e41-49b9-86a2-ac15b06899e2";"YubiKey Bio Series - FIDO Edition (Enterprise Profile)"
      "8c39ee86-7f9a-4a95-9ba3-f6b097e5c2ee";"YubiKey Bio Series - FIDO Edition (Enterprise Profile)"
      "34744913-4f57-4e6e-a527-e9ec3c4b94e6";"YubiKey Bio Series - Multi-protocol Edition"
      "58276709-bb4b-4bb3-baf1-60eea99282a7";"YubiKey Bio Series - Multi-protocol Edition 1VDJSN"
   '
   
   # Loop over my list
   foreach ($MyOwnAAGuidEntry in ($MyOwnAAGuidList | ConvertFrom-Csv -Delimiter ';' -Header 'AAGUID', 'Name'))
   {
      # Add the items to the existing list (merge)
      $AAGuidObject = [PSCustomObject][ordered]@{
         AAGUID = ($MyOwnAAGuidEntry.AAGUID).trim()
         Name   = ($MyOwnAAGuidEntry.Name).trim()
      }
      $AAGuids += $AAGuidObject
   }
   
   # Remove the object
   $MyOwnAAGuidList = $null
   #endregion MyOwnAAGuidList
   
   # Sort the list
   $AAGuids = ($AAGuids | Sort-Object -Property AAGUID -Unique | Sort-Object -Property Name)
   
   # Dump
   $AAGuids
}

end
{
   # Remove the object
   $AAGuids = $null
}