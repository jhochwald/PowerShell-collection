#requires -Version 5.0 -Modules CimCmdlets -RunAsAdministrator

<#
      .SYNOPSIS
      Set the Install Image in the Registry

      .DESCRIPTION
      Set the Install Image in the Registry.
      Save several infos to the registry, we use that with some tools later.

      .NOTES
      Changelog:
      1.0.2: Add Image Name & Version
      1.0.1: Fixed the site issue (Termination Error)
      1.0.0: Initial public beta

      Version 1.0.2

      .LINK
      http://beyond-datacenter.com
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

begin
{
	Write-Output -InputObject 'Set the Install Image in the Registry'

	#region GlobalDefaults
	$SCT = 'SilentlyContinue'

	$RegSz = 'String'
	$DefaultInfo = 'Unknown'

	$Company = 'enabling Technology'

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
			[string[]] $Properties = '*')

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

	$null = (Set-MpPreference -EnableControlledFolderAccess Disabled -Force -ErrorAction $SCT)
}

process
{
	# Create Path if needed
	if (-not (Test-Path -Path $RegistryPath -ErrorAction $SCT))
	{
		$null = (New-Item -Path $RegistryPath -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
	}

	# Set Date/Time
	$Date = (Get-Date -Format 'yyyy-MM-dd')
	$Time = (Get-Date -Format 'HH:mm')

	# Install Site
	$RegistrySite = 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'

	if (Test-Path -Path ($RegistrySite + 'DynamicSiteName') -WarningAction $SCT -ErrorAction $SCT)
	{
		$Site = (Get-ItemPropertyValue -Path $RegistrySite -Name 'DynamicSiteName' -WarningAction $SCT -ErrorAction $SCT)
	}
	else
	{
		$Site = $null
	}

	# Get system info
	$Hardware = (Get-CimData -Class Win32_ComputerSystem -WarningAction $SCT -ErrorAction $SCT)

	# Windows Info
	$WindowsVersionInfo = (Get-CimInstance -ClassName Win32_OperatingSystem -Property CSName, Caption, Version, OSArchitecture -WarningAction $SCT -ErrorAction $SCT | Select-Object -Property CSName, Caption, Version, OSArchitecture)

	# Release ID (e.g. 1903)
	$WindowsReleaseId = ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseId -WarningAction $SCT -ErrorAction $SCT).ReleaseId)

	# Network Info
	$WindowsNicInfo = (Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -select IPAddress -WarningAction $SCT -ErrorAction $SCT | Where-Object -FilterScript {
			$_.IPAddress
		} | Select-Object -ExpandProperty IPAddress | Where-Object -FilterScript {
			$_ -notlike '*:*'
		})

	#region
	$null = (New-ItemProperty -Path $RegistryPath -Name ImageName -PropertyType $RegSz -Value $(if ($ImageName)
			{
				$ImageName
			}
			else
			{
				'ETPOSD'
			}) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name ImageDescription -PropertyType $RegSz -Value $(if ($ImageDescription)
			{
				$ImageDescription
			}
			else
			{
				'enabling Technology progressive OS deployment'
			}) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name ImageVersion -PropertyType $RegSz -Value $(if ($ImageVersion)
			{
				$ImageVersion
			}
			else
			{
				'Test Build'
			}) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name KMSAware -PropertyType $RegSz -Value $(Test-Connection -ComputerName kms.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
	#endregion

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallDate -PropertyType $RegSz -Value $(if ($Date)
			{
				$Date
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallTime -PropertyType $RegSz -Value $(if ($Time)
			{
				$Time
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallHostname -PropertyType $RegSz -Value $(if ($Hardware.Name)
			{
				$Hardware.Name
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallIP -PropertyType $RegSz -Value $(if ($WindowsNicInfo)
			{
				$WindowsNicInfo
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallSite -PropertyType $RegSz -Value $(if (Test-Connection -ComputerName echo.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT)
			{
				'FRA1'
			}
			elseif (Test-Connection -ComputerName friend.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT)
			{
				'FRA2'
			}
			elseif (Test-Connection -ComputerName join.enatec.net -Quiet -WarningAction $SCT -ErrorAction $SCT)
			{
				'VPN'
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name HardwareManufacturer -PropertyType $RegSz -Value $(if ($Hardware.Manufacturer)
			{
				$Hardware.Manufacturer
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name HardwareModel -PropertyType $RegSz -Value $(if ($Hardware.Model)
			{
				$Hardware.Model
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallOperationsystem -PropertyType $RegSz -Value $(if ($WindowsVersionInfo.Caption)
			{
				$WindowsVersionInfo.Caption
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallArchitecture -PropertyType $RegSz -Value $(if ($WindowsVersionInfo.OSArchitecture)
			{
				$WindowsVersionInfo.OSArchitecture
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallReleaseId -PropertyType $RegSz -Value $(if ($WindowsReleaseId)
			{
				$WindowsReleaseId
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)

	$null = (New-ItemProperty -Path $RegistryPath -Name InstallVersion -PropertyType $RegSz -Value $(if ($WindowsVersionInfo.Version)
			{
				$WindowsVersionInfo.Version
			}
			else
			{
				$DefaultInfo
   }) -Force -Confirm:$false -WarningAction $SCT -ErrorAction $SCT)
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
