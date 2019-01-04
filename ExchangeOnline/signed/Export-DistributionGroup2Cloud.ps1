function Export-DistributionGroup2Cloud
{
  <#
      .SYNOPSIS
      Function to convert/migrate on-premises Exchange distribution group to a Cloud (Exchange Online) distribution group

      .DESCRIPTION
      Copies attributes of a synchronized group to a placeholder group and CSV file.
      After initial export of group attributes, the on-premises group can have the attribute "AdminDescription" set to "Group_NoSync" which will stop it from be synchronized.
      The "-Finalize" switch can then be used to write the addresses to the new group and convert the name.  The final group will be a cloud group with the same attributes as the previous but with the additional ability of being able to be "self-managed".
      Once the contents of the new group are validated, the on-premises group can be deleted.

      .PARAMETER Group
      Name of group to recreate.

      .PARAMETER CreatePlaceHolder
      Create placeholder DistributionGroup wit ha given name.

      .PARAMETER Finalize
      Convert a given placeholder group to final DistributionGroup.

      .PARAMETER ExportDirectory
      Export Directory for internal CSV handling.

      .EXAMPLE
      PS> Export-DistributionGroup2Cloud -Group "DL-Marketing" -CreatePlaceHolder

      Create the Placeholder for the distribution group "DL-Marketing"

      .EXAMPLE
      PS> Export-DistributionGroup2Cloud -Group "DL-Marketing" -Finalize

      Transform the Placeholder for the distribution group "DL-Marketing" to the real distribution group in the cloud

      .NOTES
      This function is based on the Recreate-DistributionGroup.ps1 script of Joe Palarchio

      License: BSD 3-Clause

      .LINK
      https://gallery.technet.microsoft.com/PowerShell-Script-to-Move-5c3cd668

      .LINK
      http://blogs.perficient.com/microsoft/?p=32092
  #>
  [CmdletBinding(ConfirmImpact = 'Low')]
  param
  (
    [Parameter(Mandatory,
    HelpMessage = 'Name of group to recreate.')]
    [string]
    $Group,
    [switch]
    $CreatePlaceHolder,
    [switch]
    $Finalize,
    [ValidateNotNullOrEmpty()]
    [string]
    $ExportDirectory = 'C:\scripts\PowerShell\exports\ExportedAddresses\'
  )

  begin
  {
    # Defaults
    $SCN = 'SilentlyContinue'
    $CNT = 'Continue'
    $STP = 'Stop'
  }

  process
  {
    If ($CreatePlaceHolder.IsPresent)
    {
      # Create the Placeholder
      If (((Get-DistributionGroup -Identity $Group -ErrorAction $SCN).IsValid) -eq $True)
      {
        # Splat to make it more human readable
        $paramGetDistributionGroup = @{
          Identity      = $Group
          ErrorAction   = $STP
          WarningAction = $CNT
        }
        try
        {
          $OldDG = (Get-DistributionGroup @paramGetDistributionGroup)
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)

          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }

        try
        {
          [IO.Path]::GetInvalidFileNameChars() | ForEach-Object -Process {
            $Group = $Group.Replace($_,'_')
          }
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)

          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }

        $OldName = [string]$OldDG.Name
        $OldDisplayName = [string]$OldDG.DisplayName
        $OldPrimarySmtpAddress = [string]$OldDG.PrimarySmtpAddress
        $OldAlias = [string]$OldDG.Alias

        # Splat to make it more human readable
        $paramGetDistributionGroupMember = @{
          Identity      = $OldDG.Name
          ErrorAction   = $STP
          WarningAction = $CNT
        }
        try
        {
          $OldMembers = ((Get-DistributionGroupMember @paramGetDistributionGroupMember).Name)
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)

          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }

        If(!(Test-Path -Path $ExportDirectory -ErrorAction $SCN -WarningAction $CNT))
        {
          Write-Verbose -Message ('  Creating Directory: {0}' -f $ExportDirectory)

          # Splat to make it more human readable
          $paramNewItem = @{
            ItemType      = 'directory'
            Path          = $ExportDirectory
            Force         = $True
            Confirm       = $False
            ErrorAction   = $STP
            WarningAction = $CNT
          }
          try
          {
            $null = (New-Item @paramNewItem)
          }
          catch
          {
            $line = ($_.InvocationInfo.ScriptLineNumber)

            # Dump the Info
            Write-Warning -Message ('Error was in Line {0}' -f $line)

            # Dump the Error catched
            Write-Error -Message $_ -ErrorAction $STP

            # Something that should never be reached
            break
          }
        }

        # Define variables - mostly for future use
        $ExportDirectoryGroupCsv = $ExportDirectory + '\' + $Group + '.csv'

        try
        {
          # TODO: Refactor in future version
          'EmailAddress' > $ExportDirectoryGroupCsv
          $OldDG.EmailAddresses >> $ExportDirectoryGroupCsv
          'x500:'+$OldDG.LegacyExchangeDN >> $ExportDirectoryGroupCsv
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)

          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }

        # Define variables - mostly for future use
        $NewDistributionGroupName = 'Cloud- ' + $OldName
        $NewDistributionGroupAlias = 'Cloud-' + $OldAlias
        $NewDistributionGroupDisplayName = 'Cloud-' + $OldDisplayName
        $NewDistributionGroupPrimarySmtpAddress = 'Cloud-' + $OldPrimarySmtpAddress

        # TODO: Replace with Write-Verbose in future version of the function
        Write-Output -InputObject ('  Creating Group: {0}' -f $NewDistributionGroupDisplayName)

        # Splat to make it more human readable
        $paramNewDistributionGroup = @{
          Name               = $NewDistributionGroupName
          Alias              = $NewDistributionGroupAlias
          DisplayName        = $NewDistributionGroupDisplayName
          ManagedBy          = $OldDG.ManagedBy
          Members            = $OldMembers
          PrimarySmtpAddress = $NewDistributionGroupPrimarySmtpAddress
          ErrorAction        = $STP
          WarningAction      = $CNT
        }
        try
        {
          $null = (New-DistributionGroup @paramNewDistributionGroup)
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)
          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }

        # Wait for 3 seconds
        $null = (Start-Sleep -Seconds 3)

        # Define variables - mostly for future use
        $SetDistributionGroupIdentity = 'Cloud-' + $OldName
        $SetDistributionGroupDisplayName = 'Cloud-' + $OldDisplayName

        # TODO: Replace with Write-Verbose in future version of the function
        Write-Output -InputObject ('  Setting Values For: {0}' -f $SetDistributionGroupDisplayName)

        # Splat to make it more human readable
        $paramSetDistributionGroup = @{
          Identity                               = $SetDistributionGroupIdentity
          AcceptMessagesOnlyFromSendersOrMembers = $OldDG.AcceptMessagesOnlyFromSendersOrMembers
          RejectMessagesFromSendersOrMembers     = $OldDG.RejectMessagesFromSendersOrMembers
          ErrorAction                            = $STP
          WarningAction                          = $CNT
        }
        try
        {
          $null = (Set-DistributionGroup @paramSetDistributionGroup)
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)

          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }

        # Define variables - mostly for future use
        $SetDistributionGroupIdentity = 'Cloud-' + $OldName

        # Splat to make it more human readable
        $paramSetDistributionGroup = @{
          Identity                             = $SetDistributionGroupIdentity
          AcceptMessagesOnlyFrom               = $OldDG.AcceptMessagesOnlyFrom
          AcceptMessagesOnlyFromDLMembers      = $OldDG.AcceptMessagesOnlyFromDLMembers
          BypassModerationFromSendersOrMembers = $OldDG.BypassModerationFromSendersOrMembers
          BypassNestedModerationEnabled        = $OldDG.BypassNestedModerationEnabled
          CustomAttribute1                     = $OldDG.CustomAttribute1
          CustomAttribute2                     = $OldDG.CustomAttribute2
          CustomAttribute3                     = $OldDG.CustomAttribute3
          CustomAttribute4                     = $OldDG.CustomAttribute4
          CustomAttribute5                     = $OldDG.CustomAttribute5
          CustomAttribute6                     = $OldDG.CustomAttribute6
          CustomAttribute7                     = $OldDG.CustomAttribute7
          CustomAttribute8                     = $OldDG.CustomAttribute8
          CustomAttribute9                     = $OldDG.CustomAttribute9
          CustomAttribute10                    = $OldDG.CustomAttribute10
          CustomAttribute11                    = $OldDG.CustomAttribute11
          CustomAttribute12                    = $OldDG.CustomAttribute12
          CustomAttribute13                    = $OldDG.CustomAttribute13
          CustomAttribute14                    = $OldDG.CustomAttribute14
          CustomAttribute15                    = $OldDG.CustomAttribute15
          ExtensionCustomAttribute1            = $OldDG.ExtensionCustomAttribute1
          ExtensionCustomAttribute2            = $OldDG.ExtensionCustomAttribute2
          ExtensionCustomAttribute3            = $OldDG.ExtensionCustomAttribute3
          ExtensionCustomAttribute4            = $OldDG.ExtensionCustomAttribute4
          ExtensionCustomAttribute5            = $OldDG.ExtensionCustomAttribute5
          GrantSendOnBehalfTo                  = $OldDG.GrantSendOnBehalfTo
          HiddenFromAddressListsEnabled        = $True
          MailTip                              = $OldDG.MailTip
          MailTipTranslations                  = $OldDG.MailTipTranslations
          MemberDepartRestriction              = $OldDG.MemberDepartRestriction
          MemberJoinRestriction                = $OldDG.MemberJoinRestriction
          ModeratedBy                          = $OldDG.ModeratedBy
          ModerationEnabled                    = $OldDG.ModerationEnabled
          RejectMessagesFrom                   = $OldDG.RejectMessagesFrom
          RejectMessagesFromDLMembers          = $OldDG.RejectMessagesFromDLMembers
          ReportToManagerEnabled               = $OldDG.ReportToManagerEnabled
          ReportToOriginatorEnabled            = $OldDG.ReportToOriginatorEnabled
          RequireSenderAuthenticationEnabled   = $OldDG.RequireSenderAuthenticationEnabled
          SendModerationNotifications          = $OldDG.SendModerationNotifications
          SendOofMessageToOriginatorEnabled    = $OldDG.SendOofMessageToOriginatorEnabled
          BypassSecurityGroupManagerCheck      = $True
          ErrorAction                          = $STP
          WarningAction                        = $CNT
        }
        try
        {
          $null = (Set-DistributionGroup @paramSetDistributionGroup)
        }
        catch
        {
          $line = ($_.InvocationInfo.ScriptLineNumber)
          # Dump the Info
          Write-Warning -Message ('Error was in Line {0}' -f $line)

          # Dump the Error catched
          Write-Error -Message $_ -ErrorAction $STP

          # Something that should never be reached
          break
        }
      }
      Else
      {
        Write-Error -Message ('The distribution group {0} was not found' -f $Group) -ErrorAction $CNT
      }
    }
    ElseIf ($Finalize.IsPresent)
    {
      # Do the final steps

      # Define variables - mostly for future use
      $GetDistributionGroupIdentity = 'Cloud-' + $Group

      # Splat to make it more human readable
      $paramGetDistributionGroup = @{
        Identity      = $GetDistributionGroupIdentity
        ErrorAction   = $STP
        WarningAction = $CNT
      }
      try
      {
        $TempDG = (Get-DistributionGroup @paramGetDistributionGroup)
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)

        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      $TempPrimarySmtpAddress = $TempDG.PrimarySmtpAddress

      try
      {
        [IO.Path]::GetInvalidFileNameChars() | ForEach-Object -Process {
          $Group = $Group.Replace($_,'_')
        }
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)

        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      $OldAddressesPatch = $ExportDirectory + '\' + $Group + '.csv'

      # Splat to make it more human readable
      $paramImportCsv = @{
        Path          = $OldAddressesPatch
        ErrorAction   = $STP
        WarningAction = $CNT
      }
      try
      {
        $OldAddresses = @(Import-Csv @paramImportCsv)
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)

        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      try
      {
        $NewAddresses = $OldAddresses | ForEach-Object -Process {
          $_.EmailAddress.Replace('X500','x500')
        }
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)

        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      $NewDGName = $TempDG.Name.Replace('Cloud-','')
      $NewDGDisplayName = $TempDG.DisplayName.Replace('Cloud-','')
      $NewDGAlias = $TempDG.Alias.Replace('Cloud-','')

      try
      {
        $NewPrimarySmtpAddress = ($NewAddresses | Where-Object -FilterScript {
            $_ -clike 'SMTP:*'
        }).Replace('SMTP:','')
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)
        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      # Splat to make it more human readable
      $paramSetDistributionGroup = @{
        Identity                        = $TempDG.Name
        Name                            = $NewDGName
        Alias                           = $NewDGAlias
        DisplayName                     = $NewDGDisplayName
        PrimarySmtpAddress              = $NewPrimarySmtpAddress
        HiddenFromAddressListsEnabled   = $False
        BypassSecurityGroupManagerCheck = $True
        ErrorAction                     = $STP
        WarningAction                   = $CNT
      }
      try
      {
        $null = (Set-DistributionGroup @paramSetDistributionGroup)
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)
        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      $paramSetDistributionGroup = @{
        Identity                        = $NewDGName
        EmailAddresses                  = @{
          Add = $NewAddresses
        }
        BypassSecurityGroupManagerCheck = $True
        ErrorAction                     = $STP
        WarningAction                   = $CNT
      }
      try
      {
        $null = (Set-DistributionGroup @paramSetDistributionGroup)
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)
        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }

      # Splat to make it more human readable
      $paramSetDistributionGroup = @{
        Identity                        = $NewDGName
        EmailAddresses                  = @{
          Remove = $TempPrimarySmtpAddress
        }
        BypassSecurityGroupManagerCheck = $True
        ErrorAction                     = $STP
        WarningAction                   = $CNT
      }
      try
      {
        $null = (Set-DistributionGroup @paramSetDistributionGroup)
      }
      catch
      {
        $line = ($_.InvocationInfo.ScriptLineNumber)

        # Dump the Info
        Write-Warning -Message ('Error was in Line {0}' -f $line)

        # Dump the Error catched
        Write-Error -Message $_ -ErrorAction $STP

        # Something that should never be reached
        break
      }
    }
    Else
    {
      Write-Error -Message "  ERROR: No options selected, please use '-CreatePlaceHolder' or '-Finalize'" -ErrorAction $STP

      # Something that should never be reached
      break
    }
  }

  end
  {
    <#
        From the original Script Author

        Name:        Recreate-DistributionGroup.ps1

        Version:     1.0

        Description: Copies attributes of a synchronized group to a placeholder group and CSV file.
        After initial export of group attributes, the on-premises group can have the attribute "AdminDescription" set to "Group_NoSync" which will stop it from be synchronized.
        The "-Finalize" switch can then be used to write the addresses to the new group and convert the name.  The final group will be a cloud group with the same attributes as the previous but with the additional ability of being able to be "self-managed".
        Once the contents of the new group are validated, the on-premises group can be deleted.

        Requires:    Remote PowerShell Connection to Exchange Online

        Author:      Joe Palarchio

        Usage:       Additional information on the usage of this script can found at the following blog post: http://blogs.perficient.com/microsoft/?p=32092

        Disclaimer:  This script is provided AS IS without any support. Please test in a lab environment prior to production use.
    #>
  }
}

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
# MIIO6AYJKoZIhvcNAQcCoIIO2TCCDtUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVMjKQYQhd2zafWLpqw6HAw96
# p82gggxZMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
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
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggciMIIG
# CqADAgECAgIA5jANBgkqhkiG9w0BAQUFADA9MQswCQYDVQQGEwJHQjERMA8GA1UE
# ChMIQXNjZXJ0aWExGzAZBgNVBAMTEkFzY2VydGlhIFJvb3QgQ0EgMjAeFw0wOTA0
# MjExMjE1MTdaFw0yODA0MTQyMzU5NTlaMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQK
# EwhBc2NlcnRpYTEdMBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDEwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDPWPIzxLPZHflPEdu447bWvKchN1cu
# e6kMlLPLEvBHWs4hcF4Tg5w+zKP+nr1T1tgwZD+Kbl3EG1KwEfXZCNBO9gRP/v8k
# cl8NrLSqfDT42wpYJms0u6xpNCjM8YVrkheQld6fi/Hfo4rVEEhWeHE5XjSdaLua
# swnz/WQOJ12InjrOxOdu8fvyHVHt64fW07nBMI+Np8nNXQ/rfn8Em19GxgezP826
# lbFX9Jtv5rSKGGUq4A9AAA5EcMB++AZ6tWozF/SbMRk1RL0bBjn6lmnnolWUad8h
# jcHRCfae65imcyCh1Zl3CCK5/Okds+hZ8NIQcJopDi3O7EQ4cxdyQTdlAgMBAAGj
# ggQoMIIEJDAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIBAjCB8AYD
# VR0gBIHoMIHlMIHiBgorBgEEAfxJAQEBMIHTMIHQBggrBgEFBQcCAjCBwxqBwFdh
# cm5pbmc6IENlcnRpZmljYXRlcyBhcmUgaXNzdWVkIHVuZGVyIHRoaXMgcG9saWN5
# IHRvIGluZGl2aWR1YWxzIHRoYXQgaGF2ZSBub3QgaGFkIHRoZWlyIGlkZW50aXR5
# IGNvbmZpcm1lZC4gRG8gbm90IHVzZSB0aGVzZSBjZXJ0aWZpY2F0ZXMgZm9yIHZh
# bHVhYmxlIHRyYW5zYWN0aW9ucy4gTk8gTElBQklMSVRZIElTIEFDQ0VQVEVELjCC
# ATMGA1UdDgSCASoEggEmMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
# z1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLwR1rOIXBeE4OcPsyj/p69U9bY
# MGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0+NsKWCZrNLusaTQozPGFa5IX
# kJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDiddiJ46zsTnbvH78h1R7euH1tO5
# wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0ihhlKuAPQAAORHDAfvgGerVq
# Mxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuYpnMgodWZdwgiufzpHbPoWfDS
# EHCaKQ4tzuxEOHMXckE3ZQIDAQABMFoGA1UdHwRTMFEwT6BNoEuGSWh0dHA6Ly93
# d3cuYXNjZXJ0aWEuY29tL09ubGluZUNBL2NybHMvQXNjZXJ0aWFSb290Q0EyL0Fz
# Y2VydGlhUm9vdENBMi5jcmwwPQYIKwYBBQUHAQEEMTAvMC0GCCsGAQUFBzABhiFo
# dHRwOi8vb2NzcC5nbG9iYWx0cnVzdGZpbmRlci5jb20wggE3BgNVHSMEggEuMIIB
# KoCCASYwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCWN76e4Nk+poYT
# F/ZK86kH8xZo1X9EFkfzIZ99/OT/pPQLvs30wgYD4uyhRBTFkKGf0dH3HjKz1N9S
# FJud0eqbxtH3YPr8rUjHkxjrX34LxCFWBNoj4T3Fw3LGnTpGeO6xEaEDAdvdInm3
# BJvpG4VWES3Z7SJteaIbkNmqDn0DhRpMFXiNKgZKNWIcJM1ZGW9+OZO7vxUZrOPB
# fceplWg70Torc8TBYL7Pv1/g6kuZCO7Dx1nF6agi9GCIHRkMrcjguIqkg8qSL+KW
# xwWuKi8YHBG4i7vIgvHOKL2lnmdoe63WRAG9wUHb68duwBc1tIAPqam90MQrMyhT
# GzhwI7aDAgMBAAEwDQYJKoZIhvcNAQEFBQADggEBAJSUl6GjE5m6hkpci2WLPoJM
# rG90TALbigGZS1zTYLsIwUxfx0VndhR/YU7dUQf5vFPhzQf9mwm9vidT9Wwd6Wg0
# hmDiT8Lh5y7T4XyqjuMKN3cp7eDFkrSCUhvT8Lg2n/qxeeJMD3ghtFhoyXtI5A/6
# CmPHBkcNMtQZAhORKjpJ41wSa+vH6v1TzC8otw+xuxgyAkO/hRmmmBIgGDuwxKfL
# rdBQRZWeBRmWqH7grQlE0gYYpBFS4FlorwBqjiIDp6FH52OrLS9gLV2f1emxMQAl
# wh3LMBmwvUtTQs++8M8oX2EpXZCIHeoOEFEMbzmEv4I88yooHJxcTL026vcl/1Ix
# ggH5MIIB9QIBATBYMD8xCzAJBgNVBAYTAkdCMREwDwYDVQQKEwhBc2NlcnRpYTEd
# MBsGA1UEAxMUQXNjZXJ0aWEgUHVibGljIENBIDECFQCdDgExwhEGCyl5TLUkaz5m
# Lyd2ojAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUyuxiV4d4YrpwAWZVRF5QnheOzecwDQYJKoZI
# hvcNAQEBBQAEggEAuX3ER+Y/xVxMWxOXa0/C2r/3RwLEjpTdSnqlO6xVPIYbHqVg
# Ijv7/rV+f9LGMc1PDaPhpYMLV/oM8OpEyX0z7OvhL2bqSF6qKcqjwDq7oa0F4i+V
# 6j2tyzxZlMVhr6RbQSCeFEpwUhlzHMT1K6yjfx4KR0u9qTuJH5KBhK7fQlcjPd2I
# mVRrVqepAhTWH/GL342NhAU9rGjL0bXzDLVZ2rCOCPsNc38cvJnHC7nDHF7bia0D
# j6S19kjUw1/ufn6Q5FdeDynmorNemBsjjz+DsvYc+QZGKCXSDtH7drJoFxPGekb6
# /PWnu9ComWrmAGbQsWWu/yKn9MvE/FOTYNF4YA==
# SIG # End signature block
