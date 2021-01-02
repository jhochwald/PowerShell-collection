#requires -Version 5.0 -Modules CimCmdlets -RunAsAdministrator

<#
      .SYNOPSIS
      Set the Install Image in the Registry

      .DESCRIPTION
      Set the Install Image in the Registry.
      Save several infos to the registry, we use that with some tools later.

      .PARAMETER Company
      Name of the Company, used to create a registry Tree

      .PARAMETER ImageName
      Name of the Install Image

      .PARAMETER ImageDescription
      Description of the Install Image

      .PARAMETER ImageVersion
      Version of the Install Image.
      String is used here!

      .NOTES
      Changelog:
      2.0.0: Completly rewritten and renamed
      1.0.2: Add Image Name & Version
      1.0.1: Fixed the site issue (Termination Error)
      1.0.0: Initial public beta

      Version 2.0.0

      .LINK
      http://enatec.io
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('InstallCompany')]
   [string]
   $Company = 'enabling Technology',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('InstallImageName')]
   [string]
   $ImageName = 'ETPOSD',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('InstallImageDescription')]
   [string]
   $ImageDescription = 'enabling Technology progressive OS deployment',
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNullOrEmpty()]
   [Alias('InstallImageVersion')]
   [string]
   $ImageVersion = 'Test Build'
)

begin
{
   Write-Output -InputObject 'Set the Install Image in the Registry'

   #region GlobalDefaults
   $SCT = 'SilentlyContinue'

   $RegSz = 'String'
   $DefaultInfo = 'Unknown'

   # Target Path
   $RegistryPath = ('HKLM:\Software\' + $Company + '\BaseImage')
   #endregion GlobalDefaults

   #region HelperFunctions
   function Get-ComputerSplit
   {
      <#
            .SYNOPSIS
            Find the own name via DNS, use the Hostname as fallback

            .DESCRIPTION
            Find the own name via DNS, use the Hostname as fallback

            .PARAMETER ComputerName
            The Computer(s) to use

            .EXAMPLE
            Get-ComputerSplit -ComputerName Value
            Describe what this call does

            .NOTES
            Stolen from PsSharedGoods (MIT Licensed)

            .LINK
            https://github.com/EvotecIT/PSSharedGoods
      #>
      [CmdletBinding(ConfirmImpact = 'Low')]
      param(
         [string[]] $ComputerName = $ComputerName
      )

      begin
      {
         # Just in case
         if ($null -eq $ComputerName)
         {
            $ComputerName = ($Env:COMPUTERNAME)
         }
      }

      process
      {
         try
         {
            # Do we have a registered Hostname in DNS?
            $LocalComputerDNSName = ([Net.Dns]::GetHostByName($Env:COMPUTERNAME).HostName)
         }
         catch
         {
            # Fallback
            $LocalComputerDNSName = ($Env:COMPUTERNAME)
         }

         # Cleanup
         $ComputersLocal = $null

         [Array] $Computers = foreach ($_ in $ComputerName)
         {
            if ($_ -eq '' -or $null -eq $_)
            {
               $_ = ($Env:COMPUTERNAME)
            }

            if ($_ -ne $Env:COMPUTERNAME -and $_ -ne $LocalComputerDNSName)
            {
               $_
            }
            else
            {
               $ComputersLocal = ($_)
            }
         }
         , @($ComputersLocal, $Computers)
      }
   }

   function Get-CimData
   {
      <#
            .SYNOPSIS
            Get CIM Data

            .DESCRIPTION
            Get CIM Data

            .PARAMETER ComputerName
            Parameter description

            .PARAMETER Protocol
            'Default', 'Dcom', 'Wsman', default is 'Default'

            .PARAMETER Class
            CIM Class

            .PARAMETER Properties
            CIM Property or Properties

            .EXAMPLE
            Get-CimData -Class 'win32_bios' -ComputerName AD1,EVOWIN

            Get-CimData -Class 'win32_bios'

            # Get-CimClass to get all classes

            .NOTES
            Stolen from PsSharedGoods (MIT Licensed)

            .LINK
            https://github.com/EvotecIT/PSSharedGoods
      #>
      [CmdletBinding(ConfirmImpact = 'Low')]
      param([string] $Class,
         [string] $NameSpace = 'root\cimv2',
         [string[]] $ComputerName = $Env:COMPUTERNAME,
         [ValidateSet('Default', 'Dcom', 'Wsman')][string] $Protocol = 'Default',
         [string] $Properties = '*')

      begin
      {
         $SCT = 'SilentlyContinue'
         $ExcludeProperties = 'CimClass', 'CimInstanceProperties', 'CimSystemProperties', 'SystemCreationClassName', 'CreationClassName'
      }

      process
      {
         [Array] $ComputersSplit = (Get-ComputerSplit -ComputerName $ComputerName)
         $CimObject = @(# requires removal of this property for query
            [string[]] $PropertiesOnly = $Properties | Where-Object -FilterScript {
               $_ -ne 'PSComputerName'
            }

            $Computers = $ComputersSplit[1]

            if ($Computers.Count -gt 0)
            {
               if ($Protocol -eq 'Default')
               {
                  (Get-CimInstance -ClassName $Class -ComputerName $Computers -ErrorAction $SCT -Property $PropertiesOnly -Namespace $NameSpace | Select-Object -Property $Properties -ExcludeProperty $ExcludeProperties)
               }
               else
               {
                  $Option = (New-CimSessionOption -Protocol)
                  $Session = (New-CimSession -ComputerName $Computers -SessionOption $Option -ErrorAction $SCT)
                  $Info = (Get-CimInstance -ClassName $Class -CimSession $Session -ErrorAction $SCT -Property $PropertiesOnly -Namespace $NameSpace | Select-Object -Property $Properties -ExcludeProperty $ExcludeProperties)
                  $null = (Remove-CimSession -CimSession $Session -ErrorAction $SCT)

                  $Info
               }
            }

            $Computers = $ComputersSplit[0]

            if ($Computers.Count -gt 0)
            {
               $Info = (Get-CimInstance -ClassName $Class -ErrorAction $SCT -Property $PropertiesOnly -Namespace $NameSpace | Select-Object -Property $Properties -ExcludeProperty $ExcludeProperties)
               $Info | Add-Member -Name 'PSComputerName' -Value $Computers -MemberType NoteProperty -Force

               $Info
            }
         )

         $CimComputers = ($CimObject.PSComputerName | Sort-Object -Unique)

         foreach ($Computer in $ComputerName)
         {
            if ($CimComputers -notcontains $Computer)
            {
               Write-Warning -Message ('Get-CimData - No data for computer {0}. Most likely an error on receiving side.' -f $Computer)
            }
         }
      }

      end
      {
         return $CimObject
      }
   }
   #endregion HelperFunctions

   $paramSetMpPreference = @{
      EnableControlledFolderAccess = 'Disabled'
      Force                        = $true
      ErrorAction                  = $SCT
   }
   $null = (Set-MpPreference @paramSetMpPreference)
}

process
{
   # Create Path if needed
   $paramTestPath = @{
      Path          = $RegistryPath
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   if (-not (Test-Path @paramTestPath))
   {
      $paramNewItem = @{
         Path          = $RegistryPath
         Force         = $true
         Confirm       = $false
         WarningAction = $SCT
         ErrorAction   = $SCT
      }
      $null = (New-Item @paramNewItem)
   }

   # Set Date/Time
   $InstallDate = (Get-Date -Format 'yyyy-MM-dd')
   $InstallTime = (Get-Date -Format 'HH:mm')

   # Get system info
   $paramGetCimData = @{
      Class         = 'Win32_ComputerSystem'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $HardwareInfo = (Get-CimData @paramGetCimData)

   # Windows Info
   $paramGetCimInstance = @{
      ClassName     = 'Win32_OperatingSystem'
      Property      = 'CSName', 'Caption', 'Version', 'OSArchitecture'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $WindowsVersionInfo = (Get-CimInstance @paramGetCimInstance | Select-Object -Property CSName, Caption, Version, OSArchitecture)

   # Release ID (e.g. 1903)
   $paramGetItemProperty = @{
      Path          = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
      Name          = 'ReleaseId'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $WindowsReleaseId = ((Get-ItemProperty @paramGetItemProperty ).ReleaseId)

   # Network Info
   $paramGetCimInstance = @{
      ClassName     = 'Win32_NetworkAdapterConfiguration'
      select        = 'IPAddress'
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $WindowsNicInfo = (Get-CimInstance @paramGetCimInstance | Where-Object -FilterScript {
         $_.IPAddress
      } | Select-Object -ExpandProperty IPAddress | Where-Object -FilterScript {
         $_ -notlike '*:*'
      })

   #region ImageName
   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'ImageName'
      PropertyType  = $RegSz
      Value         = $ImageName
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion ImageName

   #region ImageDescription
   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'ImageDescription'
      PropertyType  = $RegSz
      Value         = $ImageDescription
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion ImageDescription

   #region ImageVersion
   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'ImageVersion'
      PropertyType  = $RegSz
      Value         = $ImageVersion
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion ImageVersion

   #region KMSAware
   $paramTestConnection = @{
      ComputerName  = 'kms.enatec.net'
      Quiet         = $true
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   [bool]$KMSAwareValue = (Test-Connection @paramTestConnection)

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'KMSAware'
      PropertyType  = $RegSz
      Value         = $KMSAwareValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion KMSAware

   #region InstallDate
   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallDate'
      PropertyType  = $RegSz
      Value         = $InstallDate
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallDate

   #region InstallTime
   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallTime'
      PropertyType  = $RegSz
      Value         = $InstallTime
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallTime

   #region InstallHostname
   if ((($HardwareInfo).Name))
   {
      $InstallHostnameValue = (($HardwareInfo).Name)
   }
   else
   {
      $InstallHostnameValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallHostname'
      PropertyType  = $RegSz
      Value         = $InstallHostnameValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallHostname

   #region InstallIP
   if ($WindowsNicInfo)
   {
      $InstallIPValue = $WindowsNicInfo
   }
   else
   {
      $InstallIPValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallIP'
      PropertyType  = $RegSz
      Value         = $InstallIPValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallIP

   #region InstallSite
   if (Test-Connection -ComputerName echo.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT)
   {
      $InstallSiteValue = 'FRA1'
   }
   elseif (Test-Connection -ComputerName friend.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT)
   {
      $InstallSiteValue = 'FRA2'
   }
   elseif (Test-Connection -ComputerName join.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT)
   {
      $InstallSiteValue = 'VPN'
   }
   else
   {
      $InstallSiteValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallSite'
      PropertyType  = $RegSz
      Value         = $InstallSiteValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallSite

   #region HardwareManufacturer
   if ((($HardwareInfo).Manufacturer))
   {
      $HardwareManufacturerValue = (($HardwareInfo).Manufacturer)
   }
   else
   {
      $HardwareManufacturerValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'HardwareManufacturer'
      PropertyType  = $RegSz
      Value         = $HardwareManufacturerValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion HardwareManufacturer

   #region HardwareModel
   if ((($HardwareInfo).Model))
   {
      $HardwareModelValue = (($HardwareInfo).Model)
   }
   else
   {
      $HardwareModelValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'HardwareModel'
      PropertyType  = $RegSz
      Value         = $HardwareModelValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion HardwareModel

   #region InstallOperationsystem
   if ((($WindowsVersionInfo).Caption))
   {
      $InstallOperationsystemValue = (($WindowsVersionInfo).Caption)
   }
   else
   {
      $InstallOperationsystemValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallOperationsystem'
      PropertyType  = $RegSz
      Value         = $InstallOperationsystemValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallOperationsystem

   #region InstallArchitecture
   if ((($WindowsVersionInfo).OSArchitecture))
   {
      $InstallArchitectureValue = (($WindowsVersionInfo).OSArchitecture)
   }
   else
   {
      $InstallArchitectureValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallArchitecture'
      PropertyType  = $RegSz
      Value         = $InstallArchitectureValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallArchitecture

   #region InstallReleaseId
   if ($WindowsReleaseId)
   {
      $InstallReleaseIdValue = $WindowsReleaseId
   }
   else
   {
      $InstallReleaseIdValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallReleaseId'
      PropertyType  = $RegSz
      Value         = $InstallReleaseIdValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallReleaseId

   #region InstallVersion
   if ((($WindowsVersionInfo).Version))
   {
      $InstallVersionValue = (($WindowsVersionInfo).Version)
   }
   else
   {
      $InstallVersionValue = $DefaultInfo
   }

   $paramNewItemProperty = @{
      Path          = $RegistryPath
      Name          = 'InstallVersion'
      PropertyType  = $RegSz
      Value         = $InstallVersionValue
      Force         = $true
      Confirm       = $false
      WarningAction = $SCT
      ErrorAction   = $SCT
   }
   $null = (New-ItemProperty @paramNewItemProperty)
   #endregion InstallVersion
}

end
{
   $paramSetMpPreference = @{
      EnableControlledFolderAccess = 'Enabled'
      Force                        = $true
      ErrorAction                  = $SCT
   }
   $null = (Set-MpPreference @paramSetMpPreference)
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
