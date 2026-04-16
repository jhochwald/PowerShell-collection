# Check: Revert Unsigned RDP File Warning (Remote Desktop Connection security warning)
# Detection-RevertUnsignedRdpFileWarning.ps1

<#
      If you get the following warning (introduced with Windows Updates) and want to revert to the old behavior:
      Caution: Unknown remote connection

      This remote connection could harm the local or remote computer and may be used to steal passwords or files.
      We could not verify the publisher of this remote connection. Stop now unless youare certain you trust this connection.
      Contact your IT department if unsure, Learn more.
#>


try
{
   $RegPath = 'HKLM:\Software\Policies\Microsoft\Windows NT\Terminal Services\Client'
   $paramTestPath = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }
   if (!(Test-Path @paramTestPath))
   {
      exit 1
   }
   $paramTestPath = $null

   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      Name        = 'RedirectionWarningDialogVersion'
      ErrorAction = 'SilentlyContinue'
   }
   if (!((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
   $paramGetItemPropertyValue = $null
}
catch
{
   exit 1
}

exit 0
