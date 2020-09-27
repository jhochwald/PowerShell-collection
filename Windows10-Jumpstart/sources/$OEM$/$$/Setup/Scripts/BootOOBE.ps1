Set-Location $PSScriptRoot
Get-Process sysprep -ea SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

#Cleanup
Remove-Item C:\Windows\Panther\unattend.xml -Force -ea SilentlyContinue
Remove-Item C:\Windows\Setup\Scripts\init.ps1 -Recurse -Force -ea SilentlyContinue #Prevent loop after OOBE
Rename-Item C:\Windows\Setup\Scripts\init2.ps1 init.ps1 -ea SilentlyContinue #Run Cleanup after OOBE

Get-Process sysprep -ea SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2

#old &C:\Windows\System32\Sysprep\sysprep.exe /oobe /shutdown /unattend:c:\windows\system32\sysprep\unattend.xml
Start-Process -FilePath "C:\Windows\System32\Sysprep\sysprep.exe" -ArgumentList "/oobe /quiet /reboot /unattend:C:\Windows\system32\sysprep\unattend.xml" -Wait
exit(0)
