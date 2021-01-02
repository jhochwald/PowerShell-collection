# Increases the UDP packet size to 1500 bytes for FastSend
# http://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=2040065
$blnIncreaseFastSendDatagramThreshold = $true

if ($blnIncreaseFastSendDatagramThreshold)
{
   #Inform user
   Write-Output -InputObject 'Increasing UDP FastSend threshold'

   $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\AFD\Parameters'
   $RegistryName = 'FastSendDatagramThreshold'
   $RegistryValue = '1500'

   If (Test-Path -Path $RegistryPath)
   {
      $null = (New-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -PropertyType DWORD -Force -Confirm:$false)
      Write-Output -InputObject '(CREATED)'
   }
   else
   {
      $null = (Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -Force -Confirm:$false)
      Write-Output -InputObject '(MODIFIED)'
   }
}
else
{
   Write-Warning -Message '(skipped)'
}

# Set multiplication factor to the default UDP scavenge value (MaxEndpointCountMult)
# http://support.microsoft.com/kb/2685007/en-us
$lbnSetMaxEndpointCountMult = $true

if ($lbnSetMaxEndpointCountMult)
{
   #Inform user
   Write-Output -InputObject 'Set multiplication factor to the default UDP scavenge value'

   $RegistryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\BFE\Parameters'
   $RegistryName = 'MaxEndpointCountMult'
   $RegistryValue = '0x10'

   If (Test-Path -Path $RegistryPath)
   {
      $null = (New-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -PropertyType DWORD -Force -Confirm:$false)

      Write-Output -InputObject '(CREATED)'
   }
   else
   {
      $null = (Set-ItemProperty -Path $RegistryPath -Name $RegistryName -Value $RegistryValue -Force -Confirm:$false)

      Write-Output -InputObject '(MODIFIED)'
   }
}
else
{
   Write-Warning -Message '(skipped)'
}
