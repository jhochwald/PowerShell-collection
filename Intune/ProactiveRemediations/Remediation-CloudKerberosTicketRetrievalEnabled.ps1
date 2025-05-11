#requires -Version 1.0

# Remediation: Optimize CloudKerberosTicket for Entra Global Secure Access
# https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-kerberos-sso

# The main path in the registry
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'

#region CheckMainRegistryPath
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
#endregion CheckMainRegistryPath

#region paramNewItemProperty
$paramNewItemProperty = @{
   LiteralPath  = $RegPath
   PropertyType = 'DWord'
   Force        = $true
   Confirm      = $false
   ErrorAction  = 'SilentlyContinue'
}
#endregion paramNewItemProperty

# CloudKerberosTicketRetrievalEnabled
$null = (New-ItemProperty -Name 'CloudKerberosTicketRetrievalEnabled' -Value 1 @paramNewItemProperty)

# FarKdcTimeout
$null = (New-ItemProperty -Name 'FarKdcTimeout' -Value 0 @paramNewItemProperty)

# Cleanup
$paramNewItemProperty = $null
