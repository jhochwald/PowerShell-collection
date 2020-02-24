#requires -Version 2.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Remove Windows 10 Stock Applications

      .DESCRIPTION
      Remove Windows 10 Stock Applications

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

#region AppList
$AllPackages = @(
'Microsoft.Windows.Cortana', 'Microsoft.Bing*', 'Microsoft.Xbox*', 'Microsoft.WindowsPhone', '*Solitaire*', 'Microsoft.People', 'Microsoft.Zune*', 'Microsoft.WindowsSoundRecorder', 'microsoft.windowscommunicationsapps', 'Microsoft.SkypeApp', 'officehub', '3dbuilder', 'windowscamera', '*Dell*', '*Dropbox*', '*Facebook*', 'Microsoft.WindowsFeedbackHub', 'Microsoft.Getstarted', '*Autodesk*', '*Keeper*', '*McAfee*', '*Minecraft*', '*Netflix*', 'Microsoft.MicrosoftOfficeHub', 'Microsoft.OneConnect', '*Plex*', 'Microsoft.SkypeApp', '*Solitaire*', 'Microsoft.Office.Sway', '*Twitter*', '*DisneyMagicKingdom*', '*Disney*', '*HiddenCityMysteryofShadows*', '*HiddenCity*')
#endregion AppList

#region AppListLoop
foreach ($item in $AllPackages)
{
   try 
   {
      $null = (Get-AppxPackage -ErrorAction $SCT -WarningAction $SCT | Where-Object -FilterScript {
            $_.name -like '*' + $item + '*'
      } | Remove-AppxPackage -Confirm:$false -PreserveApplicationData:$false -ErrorAction $SCT -WarningAction $SCT)
   } catch 
   {
      Write-Verbose -Message 'Whoopsie'
   }
   
   try 
   {
      $null = (Get-AppxPackage -AllUsers -ErrorAction $SCT -WarningAction $SCT | Where-Object -FilterScript {
            $_.name -like '*' + $item + '*'
      } | Remove-AppxPackage -AllUsers -ErrorAction $SCT -WarningAction $SCT)
   } catch 
   {
      Write-Verbose -Message 'Whoopsie'
   }

   try 
   {
      $null = (Get-AppxProvisionedPackage -Online -ErrorAction $SCT -WarningAction $SCT | Where-Object -FilterScript {
            $_.DisplayName -like '*' + $item + '*'
      } | Remove-AppxProvisionedPackage -Online -AllUsers -ErrorAction $SCT -WarningAction $SCT)
   } catch 
   {
      Write-Verbose -Message 'Whoopsie'
   }
}
#endregion AppListLoop

#region UninstallMcAfeeSecurity
$McAfeeSecurityApp = $null

$McAfeeSecurityApp = (Get-ChildItem -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' -ErrorAction $SCT -WarningAction $SCT | ForEach-Object -Process {
      Get-ItemProperty -Path $_.PSPath -ErrorAction $SCT -WarningAction $SCT
   } | Where-Object -FilterScript {
      $_ -match 'McAfee Security'
} | Select-Object -ExpandProperty UninstallString)

if ($McAfeeSecurityApp)
{
   $McAfeeSecurityApp = $McAfeeSecurityApp -Replace "$env:ProgramW6432\McAfee\MSC\mcuihost.exe", ''

   $null = (Start-Process -FilePath "$env:ProgramW6432\McAfee\MSC\mcuihost.exe" -ArgumentList $McAfeeSecurityApp -Wait -ErrorAction $SCT -WarningAction $SCT)
}
#endregion UninstallMcAfeeSecurity