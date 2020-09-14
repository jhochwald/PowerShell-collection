#requires -Version 2.0 -Modules Provisioning

<#
      .SYNOPSIS
      Install Windows 10 ProvisioningPackage directly

      .DESCRIPTION
      Install Windows 10 ProvisioningPackage directly

      .PARAMETER ProvisioningPackage
      Name of the Windows 10 ProvisioningPackage

      Format: contoso.ppkg

      Default is ENATEC.ppkg

      .EXAMPLE
      PS C:\> .\PolicyPPKG.ps1

      .NOTES
      Based on an idea of Roger Zander (@rzander)

      .LINK
      https://github.com/rzander/mOSD
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0)]
   [ValidateNotNullOrEmpty()]
   [Alias('ppkg')]
   [string]
   $ProvisioningPackage = 'ENATEC.ppkg'
)

begin
{
   # Just in case
   if (-not $ProvisioningPackage)
   {
      $ProvisioningPackage = 'ENATEC.ppkg'
   }

   # Full name (plus path)
   $ProvisioningPackagePath = ($env:SystemDrive + '\install\' + $ProvisioningPackage)

   # Where does the Log File go
   $ProvisioningPackageLog = ($env:SystemDrive + '\Temp\')
}

process
{
   # Do we have a provisioning package
   if (Test-Path -Path $ProvisioningPackagePath -ErrorAction SilentlyContinue)
   {
      try
      {
         # Splat
         $paramInstallProvisioningPackage = @{
            PackagePath       = $ProvisioningPackagePath
            LogsDirectoryPath = $ProvisioningPackageLog
            ForceInstall      = $true
            QuietInstall      = $true
            ErrorAction       = 'Stop'
         }

         # Install the package
         $null = (Install-ProvisioningPackage @paramInstallProvisioningPackage)

         # Cleanup
         $null = (Remove-Item -Path $ProvisioningPackagePath -Force -Confirm:$false -ErrorAction SilentlyContinue)
      }
      catch
      {
         Write-Error -Message 'Unable to install ProvisioningPackage' -ErrorAction Continue

         Exit 1
      }
   }
   else
   {
      Write-Error -Message 'No ProvisioningPackage found' -ErrorAction Continue

      Exit 1
   }
}

end
{
   Exit 0
}
