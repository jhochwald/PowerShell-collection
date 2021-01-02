Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\ -name AllowTelemetry -Value 0
Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\ -name AllowTelemetry

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack\ -name Start -Value 4
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\DiagTrack\ -name Start

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener\ -name Start -Value 0
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\WMI\Autologger\AutoLogger-Diagtrack-Listener\ -name Start

Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv\ -name Start -Value 4
Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\wuauserv\ -name Start

New-NetFirewallRule -DisplayName "BlockDiagTrack" -Name "BlockDiagTrack" -Direction Outbound -Program "%SystemRoot%\System32\utc_myhost.exe" -Action Block

