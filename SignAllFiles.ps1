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
