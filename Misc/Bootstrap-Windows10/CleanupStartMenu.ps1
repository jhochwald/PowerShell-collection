#requires -Version 1.0 -RunAsAdministrator

<#
.SYNOPSIS
Cleanup the Windows 10 Start Menu

.DESCRIPTION
Cleanup the Windows 10 Start Menu
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

$StartMenuContent = @'
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
<LayoutOptions StartTileGroupCellWidth="6" />
<DefaultLayoutOverride>
<StartLayoutCollection>
<defaultlayout:StartLayout GroupCellWidth="6" />
</StartLayoutCollection>
</DefaultLayoutOverride>
</LayoutModificationTemplate>
'@

$StartMenuFile = "$env:windir\StartMenuLayout.xml"

# Delete layout file if it already exists
if (Test-Path -Path $StartMenuFile -ErrorAction $SCT)
{
	$null = (Remove-Item -Path $StartMenuFile -Force -Confirm:$false -ErrorAction $SCT)
}

# Creates the blank layout file
$null = ($StartMenuContent | Out-File -FilePath $StartMenuFile -Encoding ASCII -Force -ErrorAction $SCT)

$RegistryAliases = @('HKLM', 'HKCU')

# Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($RegistryAlias in $RegistryAliases)
{
	$RegistryBasePath = ($RegistryAlias + ':\SOFTWARE\Policies\Microsoft\Windows')
	$RegistryKeyPath = ($RegistryBasePath + '\Explorer')
	
	if (-not (Test-Path -Path $RegistryKeyPath -ErrorAction $SCT))
	{
		$null = (New-Item -Path $RegistryBasePath -Name 'Explorer' -Force -Confirm:$false -ErrorAction $SCT)
	}
	
	$null = (Set-ItemProperty -Path $RegistryKeyPath -Name 'LockedStartLayout' -Value 1 -Force -Confirm:$false -ErrorAction $SCT)
	$null = (Set-ItemProperty -Path $RegistryKeyPath -Name 'StartLayoutFile' -Value $StartMenuFile -Force -Confirm:$false -ErrorAction $SCT)
}

# Restart Explorer, open the start menu (necessary to load the new layout)
Stop-Process -name explorer

# Give it a few seconds to process
Start-Sleep -Seconds 5

$WScriptShell = (New-Object -ComObject wscript.shell)
$WScriptShell.SendKeys('^{ESCAPE}')

# Give it a few seconds to process
Start-Sleep -Seconds 5

# Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($RegistryAlias in $RegistryAliases)
{
	$RegistryBasePath = $RegistryAlias + ':\SOFTWARE\Policies\Microsoft\Windows'
	$RegistryKeyPath = $RegistryBasePath + '\Explorer'
	$null = (Set-ItemProperty -Path $RegistryKeyPath -Name 'LockedStartLayout' -Value 0 -Force -Confirm:$false -ErrorAction $SCT)
}

# Restart Explorer and delete the layout file
Stop-Process -name explorer

# Uncomment the next line to make clean start menu default for all new users
# Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\
$null = (Remove-Item -Path $StartMenuFile -Force -Confirm:$false -ErrorAction $SCT)
