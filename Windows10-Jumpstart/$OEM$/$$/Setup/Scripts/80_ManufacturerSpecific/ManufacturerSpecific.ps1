#requires -Version 5.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Install manufacturer/vendor specific software

      .DESCRIPTION
      Install manufacturer/vendor specific software
      For now, just

      .NOTES
      Version 1.0.0

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
   Write-Output -InputObject 'Bootstrap Windows 10 System'

   #region Defaults
   $SCT = 'SilentlyContinue'

   # Change this, if needed
   $Company = 'enabling Technology'

   # Do not change this!
   $RegistryPath = ('HKLM:\Software\' + $Company + '\BaseImage')

   # Get the Info
   $Manufacturer = (Get-ItemPropertyValue -Path $RegistryPath -Name HardwareManufacturer -ErrorAction $SCT -WarningAction $SCT)
   $ManufacturerModel = ((Get-WmiObject -Class Win32_Computersystem -ErrorAction $SCT -WarningAction $SCT).Model)

   # Set the Path Info
   $OemInfoPath = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation'

   # Read the Info from WMI
   $ManufacturerModel = ((Get-WmiObject -Class Win32_Computersystem -ErrorAction $SCT -WarningAction $SCT).Model)

   $null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)


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
            Write-Warning -Message 'Dell is not yet supported, but planned'
            Return
         }

         'LENOVO'
         {
            $ManufacturerTooling = 'LENOVO'
            Write-Warning -Message 'Lenovo support is in development'
            Return
         }

         'Microsoft Corporation'
         {
            $ManufacturerTooling = 'HYPERV'
            Write-Warning -Message 'Microsoft Hyper-V is not yet supported, but planned'
            Return
         }

         'VMware, Inc.'
         {
            $ManufacturerTooling = 'VMware'
            Write-Warning -Message 'VMware is not supported'
            Return
         }

         'Parallels Software International Inc.'
         {
            $ManufacturerTooling = 'Parallels'
            Write-Warning -Message 'Parallels is not supported'
            Return
         }

         Default
         {
            $ManufacturerTooling = $null
            Write-Output -InputObject 'Unknown and/or unsupported manufacturer'
            Return
         }
      }
   }
   else
   {
      $ManufacturerTooling = $null
      Write-Output -InputObject 'Unknown and/or unsupported manufacturer'
      Return
   }
   #endregion Defaults
}

process
{
   if ($ManufacturerTooling -eq 'HP')
   {
      # Cleanup the OEM Info
      if (Get-ItemPropertyValue -Path $OemInfoPath -Name SupportHours -ErrorAction $SCT -WarningAction $SCT) {
         $null = (& "$env:windir\system32\reg.exe" DELETE $OemInfoPath /v 'SupportHours' /f)
      }

      if (Get-ItemPropertyValue -Path $OemInfoPath -Name SupportPhone -ErrorAction $SCT -WarningAction $SCT) {
         $null = (& "$env:windir\system32\reg.exe" DELETE $OemInfoPath /v 'SupportPhone' /f)
      }

      if (Get-ItemPropertyValue -Path $OemInfoPath -Name Model -ErrorAction $SCT -WarningAction $SCT) {
         $null = (& "$env:windir\system32\reg.exe" DELETE $OemInfoPath /v 'Model' /f)
      }

      # Copy the OEM Logo
      if (Test-Path -Path 'hp\SYSTEM.BMP' -ErrorAction $SCT -WarningAction $SCT) {
         $null = (Copy-Item -Path 'hp\SYSTEM.BMP' -Destination 'C:\WINDOWS\SYSTEM32\' -Force -Confirm:$false -ErrorAction $SCT -WarningAction $SCT)
      }

      # Set the new OEM Info
      $null = (& "$env:windir\system32\reg.exe" ADD $OemInfoPath /v 'Model' /t Reg_SZ /d $ManufacturerModel /f)
      $null = (& "$env:windir\system32\reg.exe" ADD $OemInfoPath /v 'Manufacturer' /t REG_SZ /d 'HP Inc.' /f)
      $null = (& "$env:windir\system32\reg.exe" ADD $OemInfoPath /v 'Logo' /t REG_SZ /d 'C:\\WINDOWS\\SYSTEM32\\SYSTEM.BMP' /f)
      $null = (& "$env:windir\system32\reg.exe" ADD $OemInfoPath /v 'SupportAppURL' /t REG_SZ /d 'hpsupportassistant://GetAssist?LaunchPoint=51' /f)
      $null = (& "$env:windir\system32\reg.exe" ADD $OemInfoPath /v 'SupportURL' /t REG_SZ /d 'http://support.hp.com' /f)

      # Install the HP Tools
      if (Test-Path -Path 'hp\sp101423.exe' -ErrorAction $SCT -WarningAction $SCT) {
         $null = (Start-Process -FilePath 'hp\sp101423.exe' -ArgumentList '/s' -Wait -NoNewWindow -WarningAction Continue -ErrorAction Continue)
      }

      if (Test-Path -Path 'hp\sp101214.exe' -ErrorAction $SCT -WarningAction $SCT) {
         $null = (Start-Process -FilePath 'hp\sp101214.exe' -ArgumentList '/s /a /s /v" /qn"' -Wait -NoNewWindow -WarningAction Continue -ErrorAction Continue)
      }
   }
}

end
{
   $null = (Set-MpPreference -EnableControlledFolderAccess Enabled -Force -ErrorAction $SCT)
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, Beyond Datacenter
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
