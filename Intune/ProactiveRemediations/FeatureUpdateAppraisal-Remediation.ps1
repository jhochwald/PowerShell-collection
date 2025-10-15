Try 
{
   $CompatTelRunnerPath = ('{0}\system32\CompatTelRunner.exe' -f $env:windir)
   $CompatTelRunnerArgs = '-m:appraiser.dll -f:DoScheduledTelemetryRun'

   if (Test-Path -Path $CompatTelRunnerPath -ErrorAction SilentlyContinue)
   {
      Start-Process -WindowStyle Hidden -FilePath $CompatTelRunnerPath -ArgumentList $CompatTelRunnerArgs -Wait
      Write-Output -InputObject 'App Compat Assessment started'
      Exit 0
   }
   else
   {
      Write-Output -InputObject 'Unable to start App Compat Assessment'
      Exit 1
   }
}
Catch
{
   Write-Error -Message $_.Exception
   Exit 2000
}
