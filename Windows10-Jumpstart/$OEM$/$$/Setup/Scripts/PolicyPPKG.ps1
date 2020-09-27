#Install ProvisioningPackage from USB/DVD
Get-PSDrive | Where-Object { ($_.used -eq 0) -and -not ($_.CurrentLocation) } | ForEach-Object { if (Test-Path ($_.Root + 'ENATEC.ppkg')) { Install-ProvisioningPackage ($_.Root + 'ENATEC.ppkg') -ForceInstall -QuietInstall } }
Start-Sleep 3
