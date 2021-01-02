#requires -Version 5.0 -Modules BitsTransfer, CimCmdlets -RunAsAdministrator

<#
      .SYNOPSIS
      Install manufacturer/vendor specific software

      .DESCRIPTION
      Install manufacturer/vendor specific software
      For now, just HP is supported.

      .NOTES
      The OEM Info is no longer displayed in newer Builds of Windows 10!
      Starting with Windows 10 Build 20H2 the Logo and other OEM Info is no longer displayed.
      Focus will be the installation of Tools to support the vendor specific drivers and tooling

      Request:
      If you are interessted in Dell or Lenovo support, please open a issue/ticket.
      We look for pilot/beta users, due to missing hardware the development is a bit hard.

      Changelog:
      1.0.7: Download the latest HP versions and install it silently
      1.0.6: Fallback to older HP Support Assistant version (Due to Silent Install Issues)
      1.0.5: Moved the installer path
      1.0.4: Rewrite big parts and create a cleanup helper
      1.0.3: Replace old WMI call with CIM - Fix Write-Output
      1.0.2: Update HP tooling (Files)
      1.0.1: Update Lenovo tooling (Files)

      Version 1.0.7

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Manufacturer specific config and software installation'

   #region Defaults
   $SCT = 'SilentlyContinue'
   $STP = 'Stop'

   # Splat the defaults
   $paramSimpleDefaults = @{
      ErrorAction   = $SCT
      WarningAction = $SCT
   }

   # Change this, if needed
   $Company = 'enabling Technology'

   # Do not change this!
   $RegistryPath = ('HKLM:\Software\' + $Company + '\BaseImage')

   # Get the Info
   $Manufacturer = (Get-ItemPropertyValue -Path $RegistryPath -Name HardwareManufacturer @paramSimpleDefaults)

   # Set the Path Info
   $OemInfoPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'

   # Read the Info from CIM
   $ManufacturerModel = ((Get-CimInstance -ClassName Win32_Computersystem @paramSimpleDefaults) | Select-Object -ExpandProperty Model)

   $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force @paramSimpleDefaults)


   if (-not $ManufacturerModel)
   {
      $ManufacturerModel = 'Unknown'
   }

   if ($Manufacturer)
   {
      switch ($Manufacturer)
      {
         'HP'
         {
            $ManufacturerTooling = 'HP'
         }
         'Hewlett-Packard'
         {
            $ManufacturerTooling = 'HP'
         }
         'Dell'
         {
            $ManufacturerTooling = 'Dell'
            Write-Warning -Message 'Dell support is in still in development'
         }
         'LENOVO'
         {
            $ManufacturerTooling = 'LENOVO'
            Write-Warning -Message 'Lenovo support is in still in development'
         }
         'Microsoft Corporation'
         {
            $ManufacturerTooling = 'HYPERV'
            Write-Warning -Message 'Microsoft Hyper-V is not (yet) supported, but planned'
            Return
         }
         'VMware, Inc.'
         {
            $ManufacturerTooling = 'VMware'
            Write-Warning -Message 'VMware is not (yet) supported'
            Return
         }
         'Parallels Software International Inc.'
         {
            $ManufacturerTooling = 'Parallels'
            Write-Warning -Message 'Parallels is not (yet) supported'
            Return
         }
         Default
         {
            $ManufacturerTooling = $null
            Write-Warning -Message 'Unknown and/or unsupported manufacturer'
            Return
         }
      }
   }
   else
   {
      $ManufacturerTooling = $null
      Write-Warning -Message 'Unknown and/or unsupported manufacturer'
      Return
   }

   # Splat the defaults for New-ItemProperty
   $paramNewItemProperty = @{
      Path          = $OemInfoPath
      PropertyType  = 'String'
      Force         = $true
      Confirm       = $false
      WhatIf        = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }

   # Splat the defaults for Copy-Item
   $paramCopyItem = @{
      Destination   = "$env:windir\SYSTEM32\SYSTEM.BMP"
      Force         = $true
      Confirm       = $false
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   #endregion Defaults

   #region RemoveOEMInfo
   function Remove-OEMInfo
   {
      <#
            .SYNOPSIS
            Cleanup the OEM Info

            .DESCRIPTION
            Cleanup the OEM Info from the registry

            .PARAMETER Path
            The Registry Path

            .EXAMPLE
            PS C:\> Remove-OEMInfo

            .EXAMPLE
            PS C:\> Remove-OEMInfo -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'

            .NOTES
            Internal Helper
      #>
      [CmdletBinding(ConfirmImpact = 'None',
         SupportsShouldProcess)]
      param
      (
         [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0)]
         [ValidateNotNullOrEmpty()]
         [Alias('OemInfoPath')]
         [string]
         $Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'
      )

      begin
      {
         #region Defaults
         $SCT = 'SilentlyContinue'
         #endregion Defaults

         #region
         $ValuesToClean = @(
            'Model'
            'Manufacturer'
            'Logo'
            'SupportAppURL'
            'SupportURL'
            'SupportHours'
            'SupportPhone'
         )
         #endregion
      }

      process
      {
         if ($pscmdlet.ShouldProcess('OEM Info', 'Delete'))
         {
            # Cleanup the OEM Info
            foreach ($ValueToClean in $ValuesToClean)
            {
               $paramGetItemPropertyValue = @{
                  Path          = $Path
                  Name          = $ValueToClean
                  ErrorAction   = $SCT
                  WarningAction = $SCT
               }

               if (Get-ItemPropertyValue @paramGetItemPropertyValue)
               {
                  $paramRemoveItemProperty = @{
                     Path          = $Path
                     Name          = $ValueToClean
                     Force         = $true
                     WhatIf        = $false
                     ErrorAction   = $SCT
                     WarningAction = $SCT
                     Confirm       = $false
                  }
                  $null = (Remove-ItemProperty @paramRemoveItemProperty)
               }

               $ValueToClean = $null
            }
         }
      }
   }
   #endregion RemoveOEMInfo
}

process
{
   #region HP
   if ($ManufacturerTooling -eq 'HP')
   {
      # Cleanup the OEM Info
      $null = (Remove-OEMInfo @paramSimpleDefaults)

      # Copy the OEM Logo
      if (Test-Path -Path "$env:HOMEDRIVE\install\ManufacturerSpecific\hp\SYSTEM.BMP" @paramSimpleDefaults)
      {
         $null = (Copy-Item -Path "$env:HOMEDRIVE\install\ManufacturerSpecific\hp\SYSTEM.BMP" @paramCopyItem)
      }

      # Set the new OEM Info
      if ($ManufacturerModel)
      {
         $null = (New-ItemProperty -Name 'Model' -Value $ManufacturerModel @paramNewItemProperty)
      }

      $null = (New-ItemProperty -Name 'Manufacturer' -Value 'HP Inc.' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'Logo' -Value 'C:\\WINDOWS\\SYSTEM32\\SYSTEM.BMP' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'SupportAppURL' -Value 'hpsupportassistant://GetAssist?LaunchPoint=51' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'SupportURL' -Value 'http://support.hp.com' @paramNewItemProperty)

      # Install the HP Tools
      #region HPDefaults
      $BitsTransferPolicy = 'Always'
      $BitsTransferPriority = 'High'
      $HPSilentSwitchesExtractDefault = '/s /e /f'
      $HPSilentSwitchesDefault = '/s /a /s /v" /qn"'
      $PowerShellExecutable = ($PSHome + '\powershell.exe')
      $ErrorMessage = 'Installer not found!'
      $DriverTempDir = "$env:HOMEDRIVE\install\temp"
      #endregion HPDefaults

      #region sp108770
      $paramTestPath = @{
         Path        = $DriverTempDir
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path     = $DriverTempDir
            ItemType = 'Directory'
            Force    = $true
            Confirm  = $false
         }
         $null = (New-Item @paramNewItem)
      }

      $RequestContent = 'https://ftp.hp.com/pub/softpaq/sp108501-109000/sp108770.exe'

      $DriverExtractDest = "$env:HOMEDRIVE\install\sp108770"

      $paramTestPath = @{
         Path        = $DriverExtractDest
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path     = $DriverExtractDest
            ItemType = 'Directory'
            Force    = $true
            Confirm  = $false
         }
         $null = (New-Item @paramNewItem)
      }

      [string]$Installer = ($DriverTempDir + '\sp108770.exe')

      $paramTestPath = @{
         Path        = $Installer
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         # Use BitsTransfer to download the latest installer
         $paramStartBitsTransfer = @{
            Source         = $RequestContent
            Destination    = $Installer
            Priority       = $BitsTransferPriority
            TransferPolicy = $BitsTransferPolicy
            ErrorAction    = $STP
         }
         $null = (Start-BitsTransfer @paramStartBitsTransfer)
      }

      $HPSilentSwitchesExtract = ($HPSilentSwitchesExtractDefault + ' "' + $DriverExtractDest + '"')
      $paramStartProcess = @{
         FilePath         = $PowerShellExecutable
         WorkingDirectory = $DriverExtractDest
         ArgumentList     = ($Installer + ' ' + $HPSilentSwitchesExtract)
         NoNewWindow      = $true
         Wait             = $true
      }
      $null = (Start-Process @paramStartProcess)

      $HPInstaller = ($DriverExtractDest + '\InstallHPSA.exe')

      $paramTestPath = @{
         Path        = $HPInstaller
         ErrorAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $HPSilentSwitches = $HPSilentSwitchesDefault
         $paramStartProcess = @{
            FilePath         = $PowerShellExecutable
            WorkingDirectory = $DriverExtractDest
            ArgumentList     = ($HPInstaller + ' ' + $HPSilentSwitches)
            NoNewWindow      = $true
            Wait             = $true
         }
         $null = (Start-Process @paramStartProcess)
      }
      else
      {
         Write-Warning -Message $ErrorMessage
      }
      #endregion sp108770

      #region sp107493
      $RequestContent = 'https://ftp.hp.com/pub/softpaq/sp107001-107500/sp107493.exe'

      $DriverExtractDest = "$env:HOMEDRIVE\install\sp107493"

      $paramTestPath = @{
         Path        = $DriverExtractDest
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         $paramNewItem = @{
            Path     = $DriverExtractDest
            ItemType = 'Directory'
            Force    = $true
            Confirm  = $false
         }
         $null = (New-Item @paramNewItem)
      }

      [string]$Installer = ($DriverTempDir + '\sp107493.exe')

      $paramTestPath = @{
         Path        = $Installer
         ErrorAction = $SCT
      }
      if (-not (Test-Path @paramTestPath))
      {
         # Use BitsTransfer to download the latest installer
         $paramStartBitsTransfer = @{
            Source         = $RequestContent
            Destination    = $Installer
            Priority       = $BitsTransferPriority
            TransferPolicy = $BitsTransferPolicy
            ErrorAction    = $STP
         }
         $null = (Start-BitsTransfer @paramStartBitsTransfer)
      }

      $HPSilentSwitchesExtract = ($HPSilentSwitchesExtractDefault + ' "' + $DriverExtractDest + '"')
      $paramStartProcess = @{
         FilePath         = $PowerShellExecutable
         WorkingDirectory = $DriverExtractDest
         ArgumentList     = ($Installer + ' ' + $HPSilentSwitchesExtract)
         NoNewWindow      = $true
         Wait             = $true
      }
      $null = (Start-Process @paramStartProcess)

      $HPInstaller = ($DriverExtractDest + '\InstallCmdWrapper.exe')

      $paramTestPath = @{
         Path        = $HPInstaller
         ErrorAction = $SCT
      }
      if (Test-Path @paramTestPath)
      {
         $HPSilentSwitches = $HPSilentSwitchesDefault
         $paramStartProcess = @{
            FilePath         = $PowerShellExecutable
            WorkingDirectory = $DriverExtractDest
            ArgumentList     = ($HPInstaller + ' ' + $HPSilentSwitches)
            NoNewWindow      = $true
            Wait             = $true
         }
         $null = (Start-Process @paramStartProcess)
      }
      else
      {
         Write-Warning -Message $ErrorMessage
      }
      #endregion sp107493
   }
   #endregion HP

   #region LENOVO
   if ($ManufacturerTooling -eq 'LENOVO')
   {
      # Cleanup the OEM Info
      $null = (Remove-OEMInfo @paramSimpleDefaults)

      # Copy the OEM Logo
      if (Test-Path -Path 'Lenovo\SYSTEM.BMP' @paramSimpleDefaults)
      {
         $null = (Copy-Item -Path "$env:HOMEDRIVE\install\ManufacturerSpecific\Lenovo\SYSTEM.BMP" @paramCopyItem)
      }

      # Set the new OEM Info
      if ($ManufacturerModel)
      {
         $null = (New-ItemProperty -Name 'Model' -Value $ManufacturerModel @paramNewItemProperty)
      }

      $null = (New-ItemProperty -Name 'Manufacturer' -Value 'Lenovo' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'Logo' -Value 'C:\\WINDOWS\\SYSTEM32\\SYSTEM.BMP' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'SupportURL' -Value 'https://support.lenovo.com/' @paramNewItemProperty)
   }
   #endregion LENOVO

   #region Dell
   if ($ManufacturerTooling -eq 'Dell')
   {
      # Cleanup the OEM Info
      $null = (Remove-OEMInfo @paramSimpleDefaults)

      # Copy the OEM Logo
      if (Test-Path -Path "$env:HOMEDRIVE\install\ManufacturerSpecific\Dell\SYSTEM.BMP" @paramSimpleDefaults)
      {
         $null = (Copy-Item -Path "$env:HOMEDRIVE\install\ManufacturerSpecific\Dell\SYSTEM.BMP" @paramCopyItem)
      }

      # Set the new OEM Info
      if ($ManufacturerModel)
      {
         $null = (New-ItemProperty -Name 'Model' -Value $ManufacturerModel @paramNewItemProperty)
      }

      $null = (New-ItemProperty -Name 'Manufacturer' -Value 'Dell' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'Logo' -Value 'C:\\WINDOWS\\SYSTEM32\\SYSTEM.BMP' @paramNewItemProperty)
      $null = (New-ItemProperty -Name 'SupportURL' -Value 'https://www.dell.com/support/home/' @paramNewItemProperty)
   }
   #endregion Dell
}

end
{
   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force @paramSimpleDefaults)
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2021, enabling Technology
      All rights reserved.

      Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
      1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
      2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
      3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

      THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
      DISCLAIMER:
      - Use at your own risk, etc.
      - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
      - This is a third-party Software
      - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
      - The Software is not supported by Microsoft Corp (MSFT)
      - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
