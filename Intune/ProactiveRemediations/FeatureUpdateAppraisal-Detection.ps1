$Schedule = 36 # update based on the remediation schedule
$FeatureUpdate = 'GE25H2' # Windows 11 25H2
#$featureUpdate = 'GE24H2' # Windows 11 24H2
#$featureUpdate = 'NI23H2' # Windows 11 23H2

Try 
{
   $RegistryPath = ('HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers\{0}' -f $FeatureUpdate)
   # Checks if the key exists and the last run of the App Compat
   Try 
   {
      $LastRun = (Get-ItemPropertyValue -Path $RegistryPath -Name TimestampEpochString -ErrorAction SilentlyContinue)
   }
   Catch 
   {
      Write-Warning -Message ('App Compat not run for Windows 11 {0}' -f $FeatureUpdate)
      Exit 1
   }

   # if the key and dword exist checks the last run time
   if ($LastRun -lt (Get-Date -Date $((Get-Date).AddHours(-$Schedule)) -UFormat +%s)) 
   {
      Write-Warning -Message ('App Compat not run in last {0} hours' -f $Schedule)
      Exit 1
   }
   else 
   {
      Write-Output -InputObject ('App Compat run in last {0} hours' -f $Schedule)
      Exit 0
   }
}
Catch 
{
   Write-Error -Message $_.Exception
   Exit 2000
}
