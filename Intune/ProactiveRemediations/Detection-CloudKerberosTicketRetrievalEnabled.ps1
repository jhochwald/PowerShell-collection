#requires -Version 5.0

# Detection: Optimize CloudKerberosTicket for Entra Global Secure Access
# https://learn.microsoft.com/en-us/entra/global-secure-access/how-to-configure-kerberos-sso

# The main path in the registry
$RegPath = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'

try
{
   #region CheckMainRegistryPath
   if (!(Test-Path -LiteralPath $RegPath -ErrorAction SilentlyContinue))
   {
      exit 1
   }
   #endregion CheckMainRegistryPath
   
   #region paramGetItemPropertyValue
   $paramGetItemPropertyValue = @{
      LiteralPath = $RegPath
      ErrorAction = 'SilentlyContinue'
   }
   #endregion paramGetItemPropertyValue
   
   #region CloudKerberosTicketRetrievalEnabled
   if (!((Get-ItemPropertyValue -Name 'CloudKerberosTicketRetrievalEnabled' @paramGetItemPropertyValue) -eq 1))
   {
      exit 1
   }
   #endregion CloudKerberosTicketRetrievalEnabled
   
   #region FarKdcTimeout
   if (!((Get-ItemPropertyValue -Name 'FarKdcTimeout' @paramGetItemPropertyValue) -eq 0))
   {
      exit 1
   }
   #endregion FarKdcTimeout
   
   # Cleanup
   $paramGetItemPropertyValue = $null
}
catch
{
   # Something went wrong
   exit 1
}

# We are good
exit 0
