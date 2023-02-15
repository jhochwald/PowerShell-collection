# Allow retrieving the cloud Kerberos ticket during the logon
# https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-kerberos

try
{
   $paramTestPath = @{
      Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
      ErrorAction = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   if (-not (Test-Path @paramTestPath))
   {
      exit 1
   }

   $paramGetItemPropertyValue = @{
      Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
      Name = 'CloudKerberosTicketRetrievalEnabled'
      ErrorAction = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   if ((Get-ItemPropertyValue @paramGetItemPropertyValue) -eq 1)
   {
      exit 0
   }
   else
   {
      exit 1
   }
}
catch
{
   exit 1
}
