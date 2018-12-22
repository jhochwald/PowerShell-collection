#requires -Version 3.0 -RunAsAdministrator

function Grant-LogOnAsService
{
  <#
      .SYNOPSIS
      Grant user log on as a service right in PowerShell
	
      .DESCRIPTION
      Grant user log on as a service right in PowerShell
	
      .PARAMETER Users
      The User that should get the grant
	
      .INPUTS
      String, Multi Value is OK here

      .OUTPUTS
      None
	
      .EXAMPLE
      PS C:\> Grant-LogOnAsService -Users 'johndoe'
	
      Grant user log on as a service right in PowerShell
	
      .LINK
      https://gist.github.com/ned1313/9143039
	
      .NOTES
      Just a minor refatoring of the original
  #>
	
  [CmdletBinding(ConfirmImpact = 'Low',
  SupportsShouldProcess)]
  param
  (
    [Parameter(Mandatory,
        ValueFromPipeline,
        ValueFromPipelineByPropertyName,
        Position = 1,
    HelpMessage = 'The User that should get the grant')]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $Users
  )
	
  process
  {
    if ($pscmdlet.ShouldProcess('Apply login as a service', "$Users"))
    {
      # Get list of currently used SIDs 
      & "$env:windir\system32\secedit.exe" /export /cfg tempexport.inf
      $curSIDs = (Select-String -Path .\tempexport.inf -Pattern 'SeServiceLogonRight')
      $Sids = $curSIDs.line
      $sidstring = ''

      foreach ($user in $Users)
      {
        $objUser = (New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList ($user))
        $strSID = $objUser.Translate([Security.Principal.SecurityIdentifier])

        if (!$Sids.Contains($strSID) -and !$Sids.Contains($user))
        {
          $sidstring += ",*$strSID"
        }
      }

      if ($sidstring)
      {
        $newSids = $Sids + $sidstring

        Write-Output -InputObject ('New Sids: {0}' -f $newSids)
        $tempinf = (Get-Content -Path tempexport.inf)
        $tempinf = $tempinf.Replace($Sids, $newSids)
        $null = (Add-Content -Path tempimport.inf -Value $tempinf -Force -Confirm:$false)

        & "$env:windir\system32\secedit.exe" /import /db secedit.sdb /cfg '.\tempimport.inf'
        & "$env:windir\system32\secedit.exe" /configure /db secedit.sdb
        & "$env:windir\system32\gpupdate.exe" /force
      }
      else
      {
        Write-Output -InputObject 'No new sids'
      }
    }
  }

  end
  {
    if ($pscmdlet.ShouldProcess('Cleanup', 'Tempfiles'))
    {
      # Splat the Defaults
      $paramRemoveItem = @{
        Force       = $true
        Confirm     = $false
        ErrorAction = 'SilentlyContinue'
      }

      $null = (Remove-Item -Path '.\tempimport.inf' @paramRemoveItem)
      $null = (Remove-Item -Path '.\secedit.sdb' @paramRemoveItem)
      $null = (Remove-Item -Path '.\tempexport.inf' @paramRemoveItem)
    }
  }
}
