# Remediate: Revert Unsigned RDP File Warning (Remote Desktop Connection security warning)
# Remediation-RevertUnsignedRdpFileWarning.ps1

<#
      If you get the following warning (introduced with Windows Updates) and want to revert to the old behavior:
      Caution: Unknown remote connection

      This remote connection could harm the local or remote computer and may be used to steal passwords or files.
      We could not verify the publisher of this remote connection. Stop now unless youare certain you trust this connection.
      Contact your IT department if unsure, Learn more.
#>

$RegPath = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\Client'

if ((Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue) -ne $true)
{
   $paramNewItem = @{
      Path        = $RegPath
      Force       = $true
      Confirm     = $false
      ErrorAction = 'SilentlyContinue'
   }
   $null = (New-Item @paramNewItem)
   $paramNewItem = $null
}

$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   Name         = 'RedirectionWarningDialogVersion'
   Value        = 1
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
$null = (New-ItemProperty @paramNewItemProperty)
$paramNewItemProperty = $null
