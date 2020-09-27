$appEvents = (Get-WinEvent -LogName "Microsoft-Windows-Windows Defender/Operational" |  Where-Object { (($_.Id -eq "1123") -or ($_.Id -eq "1127")) })
$allBlockedProcesses = ($appEvents | ForEach-Object { (([xml]$_.ToXml()).Event.EventData.Data | Where-Object { $_.Name -eq "Process Name" }).'#text' } | Sort-Object -Unique)
$currentWhiteList = (Get-MpPreference).ControlledFolderAccessAllowedApplications

if (-not ($allBlockedProcesses)) {
    Write-Host -ForegroundColor Red "No Processes have been filtered"

    exit 3
}

if (-not ($currentWhiteList)) {
    $newProcesses = $allBlockedProcesses
}
else {
    $newProcesses = (Compare-Object -ReferenceObject $allBlockedProcesses -DifferenceObject $currentWhiteList | Where-Object { $_.SideIndicator -eq '<=' } | Select-Object -ExpandProperty InputObject)
}

if (-not ($newProcesses)) {
    Write-Host -ForegroundColor Green "All processes have already been added"

    exit 0
}

($newProcesses | Out-GridView -PassThru | ForEach-Object { Add-MpPreference -ControlledFolderAccessAllowedApplications $_ -Force -ErrorAction})