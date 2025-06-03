<#
      .SYNOPSIS
      Intune Compliance test script to check if unapproved apps are installed
   
      .DESCRIPTION
      Intune Compliance test script to check if unapproved apps are installed
   
      .PARAMETER UnapprovedAppList
      A list of Apps that is not allowed
   
      .EXAMPLE
      PS C:\> .\Invoke-CheckIfUnapprovedAppsAreInstalled.ps1
   
      .NOTES
      Reworked version to be used as Intune Compliance test script
#>
[CmdletBinding(ConfirmImpact = 'None')]
[OutputType([string])]
param
(
   [Parameter(ValueFromPipeline,
              ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('AppList')]
   [string]
   $UnapprovedAppList = 'Google Chrome'
)

begin
{
   [bool]$UnapprovedAppInstalled = $false
   
   function Get-InstalledApps
   {
   <#
         .SYNOPSIS
         Get a list of installed software

         .DESCRIPTION
         Get a list of installed software

         .EXAMPLE
         PS C:\> Get-InstalledApps

         .NOTES
         Original was found somewhere in a Reddit post
   #>
      [CmdletBinding(ConfirmImpact = 'None')]
      [OutputType([string])]
      param ()
      
      begin
      {
         if (![Environment]::Is64BitProcess)
         {
            [array]$RegistryPaths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
               'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*')
         }
         else
         {
            [array]$RegistryPaths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
               'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
               'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
               'HKCU:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*')
         }
         
         [PSCustomObject]$UninstallRegList = @()
      }
      
      process
      {
         foreach ($registryPath in $RegistryPaths)
         {
            if (Test-Path -Path $registryPath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
            {
               $UninstallRegList += Get-ItemProperty -Path $registryPath
            }
         }
         
         [PSCustomObject]$InstalledApps = @()
         
         foreach ($uninstallRegistration in $UninstallRegList)
         {
            if ($uninstallRegistration.DisplayName -ne $null)
            {
               $InstalledApps += $uninstallRegistration.DisplayName
            }
         }
         
         # Cleanup
         [PSCustomObject]$InstalledApps = ($InstalledApps | Sort-Object -Unique)
      }
      
      end
      {
         # Dump the result
         $InstalledApps
      }
   }
}

process
{
   
   foreach ($installedApplication in (Get-InstalledApps))
   {
      foreach ($unApprovedApplication in $UnapprovedAppList)
      {
         if ($installedApplication -eq $unApprovedApplication)
         {
            [bool]$UnapprovedAppInstalled = $true
         }
      }
   }
   
   if ($UnapprovedAppInstalled)
   {
      [Hashtable]$UnwantedAppStatus = @{
         'Installation status' = 'Unapproved app installed'
      }
   }
   else
   {
      [Hashtable]$UnwantedAppStatus = @{
         'Installation status' = 'No unapproved apps installed'
      }
   }
}

end
{
   # Return the result as compressed JSON for Intune
   $UnwantedAppStatus | ConvertTo-Json -Compress
}
