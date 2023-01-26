function Get-OutdatedPowerShellModules
{
   <#
         .SYNOPSIS
         Get a list of outdates Modules installed from the PowerShell Gallery

         .DESCRIPTION
         Get a list of outdates Modules installed from the PowerShell Gallery

         .PARAMETER UsedDateString
         The Datestring (Display only)
         Valid values:
         German Datestring
         US Datestring
         ISO 8601 Datestring

         Default is: ISO 8601 Datestring

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules

         Get a list of outdates Modules installed from the PowerShell Gallery

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules | ForEach-Object -Process { Update-Module -Name $_.Name -Force -WhatIf -ErrorAction Continue }

         Do a dry-Run (WhatIf) to update all outdated modules

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules | ForEach-Object -Process { Update-Module -Name $_.Name -Force -Confirm:$false -ErrorAction Continue }

         Update all outdated modules. Mind the scope, you might need to run that in an elevated Shell to update the system-wide modules

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules | Select-Object -Property Name, InstalledVersion, AvailableVersion, AvailablePubDate

         Get a list of outdates Modules installed from the PowerShell Gallery

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules -UsedDateString MM/dd/yy | Select-Object -Property Name, InstalledVersion, AvailableVersion, AvailablePubDate

         Get a list of outdates Modules installed from the PowerShell Gallery, use the US-Dateformat instead of the default (ISO 8601 Datestring)

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules | Select-Object -Property Name, InstalledVersion, InstalledPubDate, AvailableVersion, AvailablePubDate

         Get a list of outdates Modules installed from the PowerShell Gallery

         .EXAMPLE
         PS C:\> Get-OutdatedPowerShellModules | Select-Object -Property * | Format-List

         Get a list of outdates Modules installed from the PowerShell Gallery



         .NOTES
         Minor helper
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([array])]
   param
   (
      [ValidateNotNullOrEmpty()]
      [ValidateSet('dd.MM.yyyy', 'MM/dd/yy', 'yyyy-MM-dd')]
      [Alias('DateString')]
      [string]
      $UsedDateString = 'yyyy-MM-dd'
   )

   BEGIN
   {
      # Get all the modules that are installed.
      $InstalledModules = (Get-InstalledModule -ErrorAction SilentlyContinue | Where-Object -FilterScript {
            ($_.Repository -eq 'PSGallery')
      })

      # Create a new object
      $ModuleReport = @()
   }

   PROCESS
   {
      # Loop through all the insatlled modules
      foreach ($Module in $InstalledModules)
      {
         Write-Verbose -Message ('Check the PSGallery for others versions of {0}' -f $Module.Name)

         $GalleryModule = (Find-Module -Name $Module.Name -ErrorAction SilentlyContinue)

         # Compare the installed version to the PSGallery version.
         if ($GalleryModule.Version -ne $Module.version)
         {
            Write-Verbose -Message ('PSGallery has another version for {0}' -f $Module.Name)

            $modversions = [pscustomobject]@{
               PSTypeName       = 'PSGalleryModule.Object'
               Name             = $($Module.name)
               InstalledVersion = $($Module.Version)
               InstalledPubDate = $($Module.PublishedDate.tostring($UsedDateString))
               AvailableVersion = $($GalleryModule.Version)
               AvailablePubDate = $($GalleryModule.PublishedDate.tostring($UsedDateString))
            }

            # Create a PSPropertySet with the default property names
            [string[]]$DefaultvisibleProperties = 'Name', 'InstalledVersion', 'AvailableVersion'
            [Management.Automation.PSMemberInfo[]]$VisibleProperties = ([Management.Automation.PSPropertySet]::new('DefaultDisplayPropertySet', $DefaultvisibleProperties))

            # Add to the report
            $null = ($ModuleReport += ($modversions | Add-Member -MemberType MemberSet -Name PSStandardMembers -Value $VisibleProperties -PassThru))
         }
         else
         {
            Write-Verbose -Message ('{0} is up-to-date' -f $Module.Name)
         }
      }
   }

   end
   {
      # Dump the report
      $ModuleReport
   }
}
