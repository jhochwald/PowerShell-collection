# Run this in an administrative PowerShell prompt to install the ExchangeNodeMaintenanceMode PowerShell module:
#
# 	iex (New-Object Net.WebClient).DownloadString("https://github.com/jhochwald/PowerShell-collection/raw/master/Install.ps1")

# Some general variables
$ModuleName = 'ExchangeNodeMaintenanceMode'
$DownloadURL = 'https://github.com/jhochwald/ExchangeNodeMaintenanceMode/raw/master/release/ExchangeNodeMaintenanceMode-current.zip'

# Download and install the module
$webclient = New-Object System.Net.WebClient
$file = "$($env:TEMP)\$($ModuleName).zip"

Write-Host "Downloading latest version of $ModuleName from $DownloadURL" -ForegroundColor Cyan
$webclient.DownloadFile($DownloadURL,$file)
Write-Host "File saved to $file" -ForegroundColor Green
$targetondisk = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\$($ModuleName)"
$null = New-Item -ItemType Directory -Force -Path $targetondisk
$shell_app=new-object -com shell.application
$zip_file = $shell_app.namespace($file)
Write-Host "Uncompressing the Zip file to $($targetondisk)" -ForegroundColor Cyan
$destination = $shell_app.namespace($targetondisk)
$destination.Copyhere($zip_file.items(), 0x10)

Write-Host "Module has been installed!" -ForegroundColor Green
Write-Host "You can now import the module with: Import-Module -Name $ModuleName"
