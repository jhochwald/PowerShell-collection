<#
    .SYNOPSIS
    Sign all scripts of the PowerShell-collection project
	
    .DESCRIPTION
    Sign all scripts of the PowerShell-collection project with the default certificate. We import the complete chain.
	
    .EXAMPLE
    PS C:\> .\SignAllFiles.ps1

    Sign all scripts of the PowerShell-collection project

    .EXAMPLE
    PS C:\> .\SignAllFiles.ps1 -verbose

    Sign all scripts of the PowerShell-collection project with verbose parameter
	
    .NOTES
    We import the complete certificate chain. and use a Timestamp Server
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
  try
  {
  Write-Verbose -Message 'Get the code signing certificate'

    $paramGetChildItem = @{
      Path            = 'cert:\CurrentUser\My'
      CodeSigningCert = $true
      ErrorAction     = 'Stop'
      WarningAction   = 'SilentlyContinue'
    }
    $Cert = (Get-ChildItem @paramGetChildItem)[0]

    Write-Verbose -Message ('We found the following certificate: {0}' -f $Cert)
  }
  catch
  {
    $paramWriteError = @{
      Message           = 'No Code Signing Certificate was found!'
      Category          = 'ObjectNotFound'
      TargetObject      = 'CodeSigningCert'
      RecommendedAction = 'Check your certificate store.'
      ErrorAction       = 'Stop'
    }
    Write-Error @paramWriteError
		
    break
  }
}

process
{
  $BaseDirs = 'Misc', 'Exchange', 'ActiveDirectory', 'Office_Related', 'ExchangeOnline', 'WSUS', 'Office365', 'Skype_for_Business', 'Skype_for_Business\rms4bcert'
	
  foreach ($BaseDir in $BaseDirs)
  {
    $SignDir = 'Y:\dev\Clones\new\PowerShell-collection\' + $BaseDir + '\signed\*.ps1'

    Write-Verbose -Message ('Processing: {0}' -f $SignDir)
		
    try
    {
      $AllFiles = $null
			
      $paramGetChildItem = @{
        Path          = $SignDir
        ErrorAction   = 'Stop'
        WarningAction = 'SilentlyContinue'
      }
      $AllFiles = (Get-ChildItem @paramGetChildItem)
    }
    catch
    {
      $AllFiles = $null
    }
		
    if ($AllFiles)
    {
      foreach ($item in $AllFiles)
      {
        try
        {
        Write-Verbose -Message ('Signing {0}' -f $item)

          $paramSetAuthenticodeSignature = @{
            FilePath        = $item
            Certificate     = $Cert
            IncludeChain    = 'All'
            TimestampServer = 'http://timestamp.digicert.com'
            Force           = $true
            Confirm         = $false
            ErrorAction     = 'Stop'
            WarningAction   = 'SilentlyContinue'
          }
          $null = (Set-AuthenticodeSignature @paramSetAuthenticodeSignature)

          Write-Verbose -Message ('Signed {0}' -f $item)
        }
        catch
        {
          Write-Warning -Message ('Unable to Sign {0}' -f $item)
        }
      }
    }
    else
    {
      Write-Warning -Message ('Sorry {0} caused issues...' -f $SignDir)
    }
  }
}

end
{
  Write-Verbose -Message 'We are done'
}

# SIG # Begin signature block
# MIIeOgYJKoZIhvcNAQcCoIIeKzCCHicCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwqdJ87YQExW45z3243KiOPIo
# 0jegghmYMIIFLzCCBBegAwIBAgIVAJ0OATHCEQYLKXlMtSRrPmYvJ3aiMA0GCSqG
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
# X8APvLfCqwdFuIe9ehI5O0ZMkJO4WsDthgSw6mtqm1y5Ihz7Gu1u8dQwggZqMIIF
# UqADAgECAhADAZoCOv9YsWvW1ermF/BmMA0GCSqGSIb3DQEBBQUAMGIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMTAeFw0x
# NDEwMjIwMDAwMDBaFw0yNDEwMjIwMDAwMDBaMEcxCzAJBgNVBAYTAlVTMREwDwYD
# VQQKEwhEaWdpQ2VydDElMCMGA1UEAxMcRGlnaUNlcnQgVGltZXN0YW1wIFJlc3Bv
# bmRlcjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKNkXfx8s+CCNeDg
# 9sYq5kl1O8xu4FOpnx9kWeZ8a39rjJ1V+JLjntVaY1sCSVDZg85vZu7dy4XpX6X5
# 1Id0iEQ7Gcnl9ZGfxhQ5rCTqqEsskYnMXij0ZLZQt/USs3OWCmejvmGfrvP9Enh1
# DqZbFP1FI46GRFV9GIYFjFWHeUhG98oOjafeTl/iqLYtWQJhiGFyGGi5uHzu5uc0
# LzF3gTAfuzYBje8n4/ea8EwxZI3j6/oZh6h+z+yMDDZbesF6uHjHyQYuRhDIjegE
# YNu8c3T6Ttj+qkDxss5wRoPp2kChWTrZFQlXmVYwk/PJYczQCMxr7GJCkawCwO+k
# 8IkRj3cCAwEAAaOCAzUwggMxMA4GA1UdDwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAA
# MBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMIMIIBvwYDVR0gBIIBtjCCAbIwggGhBglg
# hkgBhv1sBwEwggGSMCgGCCsGAQUFBwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5j
# b20vQ1BTMIIBZAYIKwYBBQUHAgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBm
# ACAAdABoAGkAcwAgAEMAZQByAHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABp
# AHQAdQB0AGUAcwAgAGEAYwBjAGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAg
# AEQAaQBnAGkAQwBlAHIAdAAgAEMAUAAvAEMAUABTACAAYQBuAGQAIAB0AGgAZQAg
# AFIAZQBsAHkAaQBuAGcAIABQAGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAg
# AHcAaABpAGMAaAAgAGwAaQBtAGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBu
# AGQAIABhAHIAZQAgAGkAbgBjAG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBp
# AG4AIABiAHkAIAByAGUAZgBlAHIAZQBuAGMAZQAuMAsGCWCGSAGG/WwDFTAfBgNV
# HSMEGDAWgBQVABIrE5iymQftHt+ivlcNK2cCzTAdBgNVHQ4EFgQUYVpNJLZJMp1K
# Knkag0v0HonByn0wfQYDVR0fBHYwdDA4oDagNIYyaHR0cDovL2NybDMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwOKA2oDSGMmh0dHA6Ly9j
# cmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3JsMHcGCCsG
# AQUFBwEBBGswaTAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MEEGCCsGAQUFBzAChjVodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRBc3N1cmVkSURDQS0xLmNydDANBgkqhkiG9w0BAQUFAAOCAQEAnSV+GzNNsiaB
# XJuGziMgD4CH5Yj//7HUaiwx7ToXGXEXzakbvFoWOQCd42yE5FpA+94GAYw3+pux
# nSR+/iCkV61bt5qwYCbqaVchXTQvH3Gwg5QZBWs1kBCge5fH9j/n4hFBpr1i2fAn
# PTgdKG86Ugnw7HBi02JLsOBzppLA044x2C/jbRcTBu7kA7YUq/OPQ6dxnSHdFMoV
# XZJB2vkPgdGZdA0mxA5/G7X1oPHGdwYoFenYk+VVFvC7Cqsc21xIJ2bIo4sKHOWV
# 2q7ELlmgYd3a822iYemKC23sEhi991VUQAOSK2vCUcIKSK+w1G7g9BQKOhvjjz3K
# r2qNe9zYRDCCBs0wggW1oAMCAQICEAb9+QOWA63qAArrPye7uhswDQYJKoZIhvcN
# AQEFBQAwZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcG
# A1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJl
# ZCBJRCBSb290IENBMB4XDTA2MTExMDAwMDAwMFoXDTIxMTExMDAwMDAwMFowYjEL
# MAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3
# LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0x
# MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA6IItmfnKwkKVpYBzQHDS
# nlZUXKnE0kEGj8kz/E1FkVyBn+0snPgWWd+etSQVwpi5tHdJ3InECtqvy15r7a2w
# cTHrzzpADEZNk+yLejYIA6sMNP4YSYL+x8cxSIB8HqIPkg5QycaH6zY/2DDD/6b3
# +6LNb3Mj/qxWBZDwMiEWicZwiPkFl32jx0PdAug7Pe2xQaPtP77blUjE7h6z8rwM
# K5nQxl0SQoHhg26Ccz8mSxSQrllmCsSNvtLOBq6thG9IhJtPQLnxTPKvmPv2zkBd
# XPao8S+v7Iki8msYZbHBc63X8djPHgp0XEK4aH631XcKJ1Z8D2KkPzIUYJX9BwSi
# CQIDAQABo4IDejCCA3YwDgYDVR0PAQH/BAQDAgGGMDsGA1UdJQQ0MDIGCCsGAQUF
# BwMBBggrBgEFBQcDAgYIKwYBBQUHAwMGCCsGAQUFBwMEBggrBgEFBQcDCDCCAdIG
# A1UdIASCAckwggHFMIIBtAYKYIZIAYb9bAABBDCCAaQwOgYIKwYBBQUHAgEWLmh0
# dHA6Ly93d3cuZGlnaWNlcnQuY29tL3NzbC1jcHMtcmVwb3NpdG9yeS5odG0wggFk
# BggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBz
# ACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBz
# ACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAARABpAGcAaQBD
# AGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAAUgBlAGwAeQBp
# AG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBo
# ACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4AZAAgAGEAcgBl
# ACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkAbgAgAGIAeQAg
# AHIAZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMVMBIGA1UdEwEB/wQIMAYB
# Af8CAQAweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5k
# aWdpY2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0
# LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4
# oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJv
# b3RDQS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2Vy
# dEFzc3VyZWRJRFJvb3RDQS5jcmwwHQYDVR0OBBYEFBUAEisTmLKZB+0e36K+Vw0r
# ZwLNMB8GA1UdIwQYMBaAFEXroq/0ksuCMS1Ri6enIZ3zbcgPMA0GCSqGSIb3DQEB
# BQUAA4IBAQBGUD7Jtygkpzgdtlspr1LPUukxR6tWXHvVDQtBs+/sdR90OPKyXGGi
# nJXDUOSCuSPRujqGcq04eKx1XRcXNHJHhZRW0eu7NoR3zCSl8wQZVann4+erYs37
# iy2QwsDStZS9Xk+xBdIOPRqpFFumhjFiqKgz5Js5p8T1zh14dpQlc+Qqq8+cdkvt
# X8JLFuRLcEwAiR78xXm8TBJX/l/hHrwCXaj++wc4Tw3GXZG5D2dFzdaD7eeSDY2x
# aYxP+1ngIw/Sqq4AfO6cQg7PkdcntxbuD8O9fAqg7iwIVYUiuOsYGk38KiGtSTGD
# R5V3cdyxG0tLHBCcdxTBnU8vWpUIKRAmMIIHIjCCBgqgAwIBAgICAOYwDQYJKoZI
# hvcNAQEFBQAwPTELMAkGA1UEBhMCR0IxETAPBgNVBAoTCEFzY2VydGlhMRswGQYD
# VQQDExJBc2NlcnRpYSBSb290IENBIDIwHhcNMDkwNDIxMTIxNTE3WhcNMjgwNDE0
# MjM1OTU5WjA/MQswCQYDVQQGEwJHQjERMA8GA1UEChMIQXNjZXJ0aWExHTAbBgNV
# BAMTFEFzY2VydGlhIFB1YmxpYyBDQSAxMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
# MIIBCgKCAQEAz1jyM8Sz2R35TxHbuOO21rynITdXLnupDJSzyxLwR1rOIXBeE4Oc
# Psyj/p69U9bYMGQ/im5dxBtSsBH12QjQTvYET/7/JHJfDay0qnw0+NsKWCZrNLus
# aTQozPGFa5IXkJXen4vx36OK1RBIVnhxOV40nWi7mrMJ8/1kDiddiJ46zsTnbvH7
# 8h1R7euH1tO5wTCPjafJzV0P635/BJtfRsYHsz/NupWxV/Sbb+a0ihhlKuAPQAAO
# RHDAfvgGerVqMxf0mzEZNUS9GwY5+pZp56JVlGnfIY3B0Qn2nuuYpnMgodWZdwgi
# ufzpHbPoWfDSEHCaKQ4tzuxEOHMXckE3ZQIDAQABo4IEKDCCBCQwDgYDVR0PAQH/
# BAQDAgEGMBIGA1UdEwEB/wQIMAYBAf8CAQIwgfAGA1UdIASB6DCB5TCB4gYKKwYB
# BAH8SQEBATCB0zCB0AYIKwYBBQUHAgIwgcMagcBXYXJuaW5nOiBDZXJ0aWZpY2F0
# ZXMgYXJlIGlzc3VlZCB1bmRlciB0aGlzIHBvbGljeSB0byBpbmRpdmlkdWFscyB0
# aGF0IGhhdmUgbm90IGhhZCB0aGVpciBpZGVudGl0eSBjb25maXJtZWQuIERvIG5v
# dCB1c2UgdGhlc2UgY2VydGlmaWNhdGVzIGZvciB2YWx1YWJsZSB0cmFuc2FjdGlv
# bnMuIE5PIExJQUJJTElUWSBJUyBBQ0NFUFRFRC4wggEzBgNVHQ4EggEqBIIBJjCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM9Y8jPEs9kd+U8R27jjtta8
# pyE3Vy57qQyUs8sS8EdaziFwXhODnD7Mo/6evVPW2DBkP4puXcQbUrAR9dkI0E72
# BE/+/yRyXw2stKp8NPjbClgmazS7rGk0KMzxhWuSF5CV3p+L8d+jitUQSFZ4cTle
# NJ1ou5qzCfP9ZA4nXYieOs7E527x+/IdUe3rh9bTucEwj42nyc1dD+t+fwSbX0bG
# B7M/zbqVsVf0m2/mtIoYZSrgD0AADkRwwH74Bnq1ajMX9JsxGTVEvRsGOfqWaeei
# VZRp3yGNwdEJ9p7rmKZzIKHVmXcIIrn86R2z6Fnw0hBwmikOLc7sRDhzF3JBN2UC
# AwEAATBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vd3d3LmFzY2VydGlhLmNvbS9P
# bmxpbmVDQS9jcmxzL0FzY2VydGlhUm9vdENBMi9Bc2NlcnRpYVJvb3RDQTIuY3Js
# MD0GCCsGAQUFBwEBBDEwLzAtBggrBgEFBQcwAYYhaHR0cDovL29jc3AuZ2xvYmFs
# dHJ1c3RmaW5kZXIuY29tMIIBNwYDVR0jBIIBLjCCASqAggEmMIIBIjANBgkqhkiG
# 9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlje+nuDZPqaGExf2SvOpB/MWaNV/RBZH8yGf
# ffzk/6T0C77N9MIGA+LsoUQUxZChn9HR9x4ys9TfUhSbndHqm8bR92D6/K1Ix5MY
# 619+C8QhVgTaI+E9xcNyxp06RnjusRGhAwHb3SJ5twSb6RuFVhEt2e0ibXmiG5DZ
# qg59A4UaTBV4jSoGSjViHCTNWRlvfjmTu78VGazjwX3HqZVoO9E6K3PEwWC+z79f
# 4OpLmQjuw8dZxemoIvRgiB0ZDK3I4LiKpIPKki/ilscFriovGBwRuIu7yILxzii9
# pZ5naHut1kQBvcFB2+vHbsAXNbSAD6mpvdDEKzMoUxs4cCO2gwIDAQABMA0GCSqG
# SIb3DQEBBQUAA4IBAQCUlJehoxOZuoZKXItliz6CTKxvdEwC24oBmUtc02C7CMFM
# X8dFZ3YUf2FO3VEH+bxT4c0H/ZsJvb4nU/VsHeloNIZg4k/C4ecu0+F8qo7jCjd3
# Ke3gxZK0glIb0/C4Np/6sXniTA94IbRYaMl7SOQP+gpjxwZHDTLUGQITkSo6SeNc
# Emvrx+r9U8wvKLcPsbsYMgJDv4UZppgSIBg7sMSny63QUEWVngUZlqh+4K0JRNIG
# GKQRUuBZaK8Aao4iA6ehR+djqy0vYC1dn9XpsTEAJcIdyzAZsL1LU0LPvvDPKF9h
# KV2QiB3qDhBRDG85hL+CPPMqKBycXEy9Nur3Jf9SMYIEDDCCBAgCAQEwWDA/MQsw
# CQYDVQQGEwJHQjERMA8GA1UEChMIQXNjZXJ0aWExHTAbBgNVBAMTFEFzY2VydGlh
# IFB1YmxpYyBDQSAxAhUAnQ4BMcIRBgspeUy1JGs+Zi8ndqIwCQYFKw4DAhoFAKB4
# MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQB
# gjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkE
# MRYEFN5BZUZ5u3BiYw7eLkqMRHwx3VXZMA0GCSqGSIb3DQEBAQUABIIBADNNSL2n
# i/kTmRDpTnVBCvbl0RYSWIcqTnnKeYWzTfZoQRNh52lU2KUvqrwg4YKM1VsiTVLX
# D6AoGBS9By1vZxokzISngqqG1sz318oMxB07dmsfxPs58XivMGZncnqX5qu8Ax0C
# nMn8rbiLAvYVu8LMZAn+fM57bmgBQ1p6yLSnI4Khbqwmi6mu0mM6ZijNULoVFgNx
# OyoqNpKXZZOOYHM4K8b5ncfWJNRSAnecq+jRCwQ3FuVXgTBz4138KxQ2RbgDel9g
# 8xijFYheJWeCEoUnGBKdQfYXYqcgLICPpLUp4pZqnIQBKDJIGeYNVRFY8oTCj4Sp
# TqevRDjFYvoCktqhggIPMIICCwYJKoZIhvcNAQkGMYIB/DCCAfgCAQEwdjBiMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEC
# EAMBmgI6/1ixa9bV6uYX8GYwCQYFKw4DAhoFAKBdMBgGCSqGSIb3DQEJAzELBgkq
# hkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE5MDEwNDIwNDkxMVowIwYJKoZIhvcN
# AQkEMRYEFOeSlymwdfPTU6Gb7Zq+XZzy+SgYMA0GCSqGSIb3DQEBAQUABIIBAEwS
# 6yW758msRTetUEV41wVvWAl1n/Y3d2MSQRCgiI5Vit6SmvKSbzD110dpn7Toni81
# 8p/FBfncz1+z1taVHb9/iWawGo+1HXXS0vxIpUiVKP8spik/0eOpruwfsW/YwKcF
# uNm6BN5x9VDj2KzTzsSZyTkHSMkeMmapAAM7jjr6TxzCzQLnSISrWgt98A7DY3vx
# WQJzAGrDyeYiV8NJ9Plvkxj1s7Sd+v0kEskaBI3nsMNj1Qso7AwAjI88edS6TksK
# 7vpzcL9KoARcGIdoHdFwxva6OZjZv/cecdqvkC06V/TE2/bIYBjnxJG9g/bFBYwJ
# KHCKJOh6eLlhs/qyA/w=
# SIG # End signature block
