#requires -Version 3.0 -Modules ActiveDirectory

<#
    .SYNOPSIS
    Tool that bulk imports or removes User pictures, based on AD Group Membership
	
    .DESCRIPTION
    Tool that bulk imports or removes User pictures, based on AD Group Membership
    If a user is in both groups, the picture will be removed!
    Idea based on my old tool to import Active Directory pictures.
    They are a bit to tiny, so I use Exchange now to make them look better in Exchange and Skype.
	
    .PARAMETER AddGroup
    Active Directory Group with users that would like to have a picture.
    For all Members of this group, the Tool will try to set an image.
	
    .PARAMETER RemGroup
    Active Directory Group with users that would like have have the picture removed.
    For all Members of this group, the Tool will try to remove the existing image (If set).
	
    .PARAMETER PictureDir
    Directory that contains the picures
	
    .PARAMETER Extension
    Extension of the pictures
	
    .PARAMETER workaround
    Workaround for Exchange 2016 on Windows Server 2016
	
    .PARAMETER UPNDomain
    The default Domain, to add to the UPN
	
    .EXAMPLE
    # Use the Groups 'ADDPIXX' and 'NOPIXX' to Set/Remove the User Pictures
    # There was an Issue with the User joerg.hochwald (Possible Picture Problem!
    PS C:\> .\Set-AllUserPictures.ps1 -AddGroup 'ADDPIXX' -RemGroup 'NOPIXX' -PictureDir 'c:\upixx\' -workaround -UPNDomain 'jhochwald.com'

    WARNING: Unable to set Image c:\upixx\joerg.hochwald.jpg for User joerg.hochwald

    .EXAMPLE
    # Use the Groups 'ADDPIXX' and 'NOPIXX' to Set/Remove the User Pictures
    # There was an Issue with the User jane.doe - Check that this user has a provissioned Mailbox (on Prem or Cloud)
    PS C:\> .\Set-AllUserPictures.ps1 -AddGroup 'ADDPIXX' -RemGroup 'NOPIXX' -PictureDir 'c:\upixx\' -workaround -UPNDomain 'jhochwald.com'

    WARNING: Unable to handle jane.doe - Check that this user has a valid Mailbox!

    .EXAMPLE
    # Use the Groups 'ADDPIXX' and 'NOPIXX' to Set/Remove the User Pictures - Everything went well
    PS C:\> .\Set-AllUserPictures.ps1 -AddGroup 'ADDPIXX' -RemGroup 'NOPIXX' -PictureDir 'c:\upixx\' -workaround -UPNDomain 'jhochwald.com'

    WARNING: Unable to handle jane.doe - Check that this user has a valid Mailbox!

    .NOTES
    TODO: There is no logging! Only the Exchange RBAC logging is in use
    TODO: A few error handlers are still missing

    If a user is in both groups, the picture will be removed!
    Verbose could be very verbose. This is due to the fact, that the complete Exchange logging will be shown!

    There are a few possibilities for Warnings and Errors. (Mostly for missing things)

    Disclaimer: The code is provided 'as is,' with all possible faults, defects or errors, and without warranty of any kind.
#>
param
(
  [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
  HelpMessage = 'Active Directory Group with users that would like to have a picture')]
  [ValidateNotNullOrEmpty()]
  [Alias('positive')]
  [string]
  $AddGroup,
  [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 2,
  HelpMessage = 'Active Directory Group with users that would like have have the picture removed.')]
  [ValidateNotNullOrEmpty()]
  [string]
  $RemGroup,
  [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 3,
  HelpMessage = 'Directory that contains the picures')]
  [ValidateNotNullOrEmpty()]
  [Alias('PixxDir')]
  [string]
  $PictureDir,
  [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
  Position = 5)]
  [Alias('defaultDomain')]
  [string]
  $UPNDomain,
  [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName,
  Position = 4)]
  [ValidateSet('png', 'jpg', 'gif', 'bmp')]
  [ValidateNotNullOrEmpty()]
  [string]
  $Extension = 'jpg',
  [switch]
  $workaround = $false
)

begin
{
  if ($workaround)
  {
    # Unsupported Workaround accoring to https://hochwald.net/workaround-for-get-help-issue-with-exchange-2016-on-windows-server-2016/
    $null = (Add-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.SnapIn)
  }
	
  # Cleanup
  $AddUserPixx = $null
  $NoUserPixx = $null
	
  # Check the source directory string and fix it if needed
  if (-not ($PictureDir).EndsWith('\'))
  {
    # Fix it
    $PictureDir = $PictureDir + '\'
		
    $paramWriteVerbose = @{
      Message = 'Fixed the Source Directory String!'
    }
    Write-Verbose @paramWriteVerbose
  }
	
  try
  {
    $paramGetADGroupMember = @{
      Identity      = $AddGroup
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
    }
    $AddUserPixx = (Get-ADGroupMember @paramGetADGroupMember | Select-Object -ExpandProperty samaccountname)
  }
  catch
  {
    $paramWriteError = @{
      Message     = ('Unable to find {0}' -f $AddGroup)
      ErrorAction = 'Stop'
    }
    Write-Error @paramWriteError
		
    return
  }
	
  try
  {
    $paramGetADGroupMember = @{
      Identity      = $RemGroup
      ErrorAction   = 'Stop'
      WarningAction = 'SilentlyContinue'
    }
    $NoUserPixx = (Get-ADGroupMember @paramGetADGroupMember | Select-Object -ExpandProperty samaccountname)
  }
  catch
  {
    $paramWriteError = @{
      Message     = ('Unable to find {0}' -f $AddGroup)
      ErrorAction = 'Stop'
    }
    Write-Error @paramWriteError
		
    return
  }
	
  function Test-ValidEmail
  {
    <#
        .SYNOPSIS
        Simple Function to check if a String is a valid Mail
	
        .DESCRIPTION
        Simple Function to check if a String is a valid Mail and return a Bool
	
        .PARAMETER address
        Address String to Check
	
        .EXAMPLE
        # Not a valid String
        PS C:\> Test-ValidEmail -address 'Joerg.Hochwald'
        False
	
        .EXAMPLE
        # Valid String
        PS C:\> Test-ValidEmail -address 'Joerg.Hochwald@outlook.com'
        True
	
        .NOTES
        Disclaimer: The code is provided 'as is,' with all possible faults, defects or errors, and without warranty of any kind.
		
        Author: Joerg Hochwald
    #>
		
    [OutputType([bool])]
    param
    (
      [Parameter(Mandatory,
      HelpMessage = 'Address String to Check')]
      [ValidateNotNullOrEmpty()]
      [string]
      $address
    )
		
    process
    {
      ($address -as [mailaddress]).Address -eq $address -and $address -ne $null
    }
  }
	
  #region License
  <#
      BSD 3-Clause License

      Copyright (c) 2018, enabling Technology <http://enatec.io>
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

      By using the Software, you agree to the License, Terms and Conditions above!
  #>
  #endregion License
	
  #region Hints
  <#
      This is a third-party Software!

      The developer(s) of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way

      The Software is not supported by Microsoft Corp (MSFT)!
  #>
  #endregion Hints
}

process
{
  if (-not ($AddUserPixx.samaccountname))
  {
    $paramWriteVerbose = @{
      Message = ('The AD Group {0} has no members.' -f $AddGroup)
    }
    Write-Verbose @paramWriteVerbose
  }
  else
  {
    # Add a counter
    $AddUserPixxCount = (($AddUserPixx.samaccountname).count)
		
    $paramWriteVerbose = @{
      Message = ('The AD Group {0} has {1} members.' -f $AddGroup, $AddUserPixxCount)
    }
    Write-Verbose @paramWriteVerbose
		
    foreach ($AddUser in $AddUserPixx.samaccountname)
    {
      if (($NoUserPixx.samaccountname) -notcontains $AddUser)
      {
        # Check the UPN and Fix it, if possible
        if (-not (Test-ValidEmail -address ($AddUser)))
        {
          if (-not ($UPNDomain))
          {
            # Whoopsie
            $paramWriteError = @{
              Message     = 'UPN Default Domain not set but needed!'
              ErrorAction = 'Stop'
            }
            Write-Error @paramWriteError
          }
          else
          {
            # Let us fix this
            $AddUserUPN = ($AddUser + '@' + $UPNDomain)
          }
        }
				
        # Build the Full Image Path
        $SingleUserPicture = ($PictureDir + $AddUser + '.' + $Extension)
				
        # Check if Picture exists
        $paramTestPath = @{
          Path          = $SingleUserPicture
          ErrorAction   = 'Stop'
          WarningAction = 'SilentlyContinue'
        }
				
        if (Test-Path @paramTestPath)
        {
          try
          {
            $paramSetUserPhoto = @{
              Identity      = $AddUserUPN
              PictureData   = ([IO.File]::ReadAllBytes($SingleUserPicture))
              Confirm       = $false
              ErrorAction   = 'Stop'
              WarningAction = 'SilentlyContinue'
            }
						
            $null = (Set-UserPhoto @paramSetUserPhoto)
          }
          catch
          {
            $paramWriteWarning = @{
              Message     = ('Unable to set Image {0} for User {1}' -f $SingleUserPicture, $AddUser)
              ErrorAction = 'SilentlyContinue'
            }
            Write-Warning @paramWriteWarning
          }
        }
        else
        {
          $paramWriteWarning = @{
            Message     = ('The Image {0} for User {1} was not found' -f $SingleUserPicture, $AddUser)
            ErrorAction = 'SilentlyContinue'
          }
          Write-Warning @paramWriteWarning
        }
      }
      else
      {
        $paramWriteVerbose = @{
          Message = ('Sorry, User {0} is member of {1} and {2}' -f $AddUser, $AddGroup, $RemGroup)
        }
        Write-Verbose @paramWriteVerbose
      }
    }
  }
	
  if (-not ($NoUserPixx.samaccountname))
  {
    $paramWriteVerbose = @{
      Message = ('The AD Group {0} has no members.' -f $RemGroup)
    }
    Write-Verbose @paramWriteVerbose
  }
  else
  {
    # Add a counter
    $NoUserPixxCount = (($NoUserPixx.samaccountname).count)
		
    $paramWriteVerbose = @{
      Message = ('The AD Group {0} has {1} members.' -f $RemGroup, $NoUserPixxCount)
    }
    Write-Verbose @paramWriteVerbose
		
    foreach ($NoUser in $NoUserPixx.samaccountname)
    {
      # Check the UPN and Fix it, if possible
      if (-not (Test-ValidEmail -address ($NoUser)))
      {
        if (-not ($UPNDomain))
        {
          # Whoopsie
          $paramWriteError = @{
            Message     = 'UPN Default Domain not set but needed!'
            ErrorAction = 'Stop'
          }
          Write-Error @paramWriteError
        }
        else
        {
          # Let us fix this
          $NoUserUPN = ($NoUser + '@' + $UPNDomain)
        }
      }
			
      $paramSetUserPhoto = @{
        Identity      = $NoUserUPN
        Confirm       = $false
        ErrorAction   = 'Stop'
        WarningAction = 'SilentlyContinue'
      }
			
      try
      {
        $null = (Remove-UserPhoto @paramSetUserPhoto)
      }
      catch
      {
        $paramWriteWarning = @{
          Message     = ('Unable to handle {0} - Check that this user has a valid Mailbox!' -f $NoUser)
          ErrorAction = 'SilentlyContinue'
        }
        Write-Warning @paramWriteWarning
      }
    }
  }
}

end
{
  # Cleaniup
  $AddUserPixx = $null
  $NoUserPixx = $null
  $AddUserPixxCount = $null
  $NoUserPixxCount = $null
	
  # Do a garbage collection: Call the .NET function to cleanup some stuff
  $null = ([GC]::Collect())
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURQjja8iKw0ALQmi3R80VSV3r
# ePCgggxZMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU4ST5E63vj8c/t17Pr6JxAPPMuigwDQYJKoZI
# hvcNAQEBBQAEggEAocuzEl9hen6kUocoA1IAYE4mAHDjmM5bUkGLFyHR+gIm5eAJ
# L4cF/Zxhm7wZUME6KkgwBfmDnnsoxaUeVrRzvdMhUZ2Aa/Ce9fxOR9TW4GpauRVw
# bJWM6ihedIacHxtkXLMfQddRH1k1A7n70EdsrF5HbBM4xEWldkRvOM4Ak/lZIGru
# gL53ALLcvVJ6hva1qUUnLvk1He/IpDigeE1ym2YmRX7r60IxY3oCp9feW0lu8uAI
# kZsyzrSX9CuX7OiiF9PPJ1O7kQA2mfW6JsCF/fJa9jtRHvBqFoKusDP/weXJV03B
# JpXiL0q3klUbC/eYR8QVA8fYmYwlIZxTO9ZGaw==
# SIG # End signature block
