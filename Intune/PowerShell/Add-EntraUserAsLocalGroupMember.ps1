#requires -Version 3.0 -Modules Microsoft.PowerShell.LocalAccounts -RunAsAdministrator

<#
      .SYNOPSIS
      Add a given EntraID User to given local group

      .DESCRIPTION
      Add a given EntraID User to given local group

      .PARAMETER MemberUPN
      UPN of the Entra ID User

      .PARAMETER GroupSID
      SID of the local group

      .EXAMPLE
      PS C:\> .\Add-EntraUserAsLocalGroupMember.ps1 -MemberUPN 'john.doe@contoso.com' -GroupSID 'S-1-5-32-544'
      Adds the user 'john.doe@contoso.com' to the local Administrator group ('S-1-5-32-544')

      .LINK
      https://learn.microsoft.com/en-us/entra/identity/devices/assign-local-admin

      .NOTES
      Quick and dirty Intune helper to add a given Entra ID User to a local Windows group.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipelineByPropertyName,
   ValueFromRemainingArguments = $true)]
   [ValidateNotNullOrEmpty()]
   [string]
   $MemberUPN = 'dummy',
   [Parameter(ValueFromPipeline,
   ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [string]
   $GroupSID = 'S-1-5-32-544'
)

begin
{
   function Get-LocalGroupBySid
   {
      <#
            .SYNOPSIS
            Get the Local Group Name based on SID

            .DESCRIPTION
            Get the Local Group Name based on SID

            .PARAMETER Group
            The SID of the group
            Default: Administrators (S-1-5-32-544)

            .EXAMPLE
            PS C:\> Get-LocalGroupBySid

            .EXAMPLE
            PS C:\> Get-LocalGroupBySid -Group 'S-1-5-32-544'
            The the name of the "Administrators" Group

            .EXAMPLE
            PS C:\> Get-LocalGroupBySid -Group 'S-1-5-32-545'
            The the name of the "Users" Group

            .EXAMPLE
            PS C:\> Get-LocalGroupBySid -Group 'S-1-5-32-546'
            The the name of the "Guests" Group

            .EXAMPLE
            PS C:\> Get-LocalGroupBySid -Group 'S-1-5-32-547'
            The the name of the "Power Users" Group

            .LINK
            https://learn.microsoft.com/en-us/windows/win32/secauthz/well-known-sids

            .NOTES
            Internal function to get the name of a group by WELL-KNOWN SIDS (a small multi lingual problem solver)
      #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([string])]
      param
      (
         [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
         [ValidateNotNullOrEmpty()]
         [Alias('GroupName')]
         [string]
         $Group = 'S-1-5-32-544'
      )

      process
      {
         $paramNewObject = @{
            TypeName     = 'System.Security.Principal.SecurityIdentifier'
            ArgumentList = ($Group)
            ErrorAction  = 'Stop'
         }
         $objSID = (New-Object @paramNewObject)
         $objgroup = $objSID.Translate([Security.Principal.NTAccount])
         $objgroupname = ($objgroup.Value).Split('\')[1]
      }

      end
      {
         $objgroupname
      }
   }
}

process
{
   $adminGroup = $null
   $paramGetLocalGroupBySid = @{
      Group       = $GroupSID
      ErrorAction = 'SilentlyContinue'
   }
   $adminGroup = (Get-LocalGroupBySid @paramGetLocalGroupBySid)

   if ($adminGroup)
   {
      try
      {
         $paramAddLocalGroupMember = @{
            Group       = $adminGroup
            Member      = ('AzureAD\{0}' -f $MemberUPN)
            Confirm     = $false
            ErrorAction = 'Stop'
         }
         $null = (Add-LocalGroupMember @paramAddLocalGroupMember)
      }
      catch
      {
         Write-Verbose -Message 'Sorry captain, something went wrong!'
      }
   }
   else
   {
      Write-Verbose -Message 'Sorry captain, something was wrong with the given SID!'
   }
}
