#requires -Version 3.0

<#
	.SYNOPSIS
		Start SysPrep

	.DESCRIPTION
		Start SysPrep

	.EXAMPLE
		PS C:\> .\BootOOBE.ps1

	.NOTES
		Additional information about the file.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
	$paramSetLocation = @{
		Path = $PSScriptRoot
	}
	$null = (Set-Location @paramSetLocation)

	function Stop-SysPrepProcess
	{
<#
	.SYNOPSIS
		Kill a running SysPrep Process

	.DESCRIPTION
		Kill a running SysPrep Process

	.PARAMETER Name
		Name of the process to stop.

		defaul is sysprep

	.EXAMPLE
				PS C:\> Stop-SysPrepProcess

	.NOTES
		Internal Helper
#>

		[CmdletBinding(ConfirmImpact = 'None')]
		param
		(
			[Parameter(ValueFromPipeline = $true,
						  ValueFromPipelineByPropertyName = $true,
						  Position = 0)]
			[ValidateNotNullOrEmpty()]
			[Alias('ProcessName')]
			[string]
			$Name = 'sysprep'
		)

		begin
		{
			$paramGetProcess = @{
				Name		   = 'sysprep'
				ErrorAction = 'SilentlyContinue'
			}
			$paramStopProcess = @{
				Force		   = $true
				Confirm	   = $false
				ErrorAction = 'SilentlyContinue'
			}
		}

		process
		{
			$null = (Get-Process @paramGetProcess | Stop-Process @paramStopProcess)
		}

		end
		{
			return
		}
	}
}

process
{
	# Kill SysPrep
	$null = (Stop-SysPrepProcess)

	# Cleanup
	$paramRemoveItem = @{
		Path		   = 'C:\Windows\Panther\unattend.xml'
		Confirm	   = $false
		Recurse	   = $true
		Force		   = $true
		ErrorAction = 'SilentlyContinue'
	}
	$null = (Remove-Item @paramRemoveItem)

	$paramRemoveItem = @{
		Path		   = 'C:\Windows\Setup\Scripts\init.ps1'
		Confirm	   = $false
		Recurse	   = $true
		Force		   = $true
		ErrorAction = 'SilentlyContinue'
	}
	$null = (Remove-Item @paramRemoveItem)

	# Kill SysPrep
	$null = (Stop-SysPrepProcess)

	# Make sure we wait a moment
	$null = (Start-Sleep -Seconds 2)

	# Init SysPrep
	$null = (Start-Process -FilePath 'C:\Windows\System32\Sysprep\sysprep.exe' -ArgumentList '/oobe /quiet /reboot /unattend:C:\Windows\system32\sysprep\unattend.xml' -Wait)
}

end
{
	# Make a clean exit
	exit (0)
}
