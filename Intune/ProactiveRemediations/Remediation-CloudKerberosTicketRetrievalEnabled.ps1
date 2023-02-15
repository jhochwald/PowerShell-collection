# Allow retrieving the cloud Kerberos ticket during the logon
# https://learn.microsoft.com/en-us/windows/client-management/mdm/policy-csp-kerberos

try
{
   $paramTestPath = @{
      Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
      ErrorAction = 'SilentlyContinue'
      WarningAction = 'SilentlyContinue'
   }
   if ((Test-Path @paramTestPath) -ne $true)
   {
      $paramNewItem = @{
         Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
         Force = $True
         Confirm = $false
         ErrorAction = 'Stop'
         WarningAction = 'SilentlyContinue'
      }
      $null = (New-Item @paramNewItem)
   }

   $paramNewItemProperty = @{
      Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
      Name = 'CloudKerberosTicketRetrievalEnabled'
      Value = 1
      PropertyType = 'DWord'
      Force = $True
      Confirm = $false
      ErrorAction = 'Stop'
      WarningAction = 'SilentlyContinue'
   }
   $null = (New-ItemProperty @paramNewItemProperty)
}
catch
{
   exit 1
}
