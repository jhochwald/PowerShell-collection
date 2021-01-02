#requires -Version 3.0 -Modules Pester

<#
		.SYNOPSIS
		Pester Unit Test

		.DESCRIPTION
		Pester is a BDD based test runner for PowerShell.

		.EXAMPLE
		PS C:\> Invoke-Pester

		.NOTES
		PESTER PowerShell Module must be installed!

		modified by     : Joerg Hochwald
		last modified   : 2016-08-14

		.LINK
		Pester https://github.com/pester/Pester
#>

# Current script path
[string]$ModulePath = (Split-Path -Path (Get-Variable -Name myinvocation -Scope script).value.Mycommand.Definition -Parent)
[string]$ModulePath = $ModulePath.Replace('\src\tests','')

# Current module name based on the directory
$ModuleName = ($ModulePath | Split-Path -Leaf)

# Legacy
$moduleCall = ($modulePath + '\' + $moduleName + '.psd1')

# Reload the Module
Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
Import-Module -Name $moduleCall -DisableNameChecking -Force -Scope Global -ErrorAction Stop -WarningAction SilentlyContinue

# Cleanup
$result = $null
$HelpFile = $null

Describe -Name "Check if XML Help exists for  $($moduleName)" -Fixture {
	Context -Name 'Must pass' -Fixture {
		It -name "Check if $($moduleName) XML Help exists" -test {
			$HelpFile = (Test-Path -Path $modulePath\en-US\$moduleName.psm1-Help.xml)

			if ($HelpFile -eq $True) {
				$result = 'Passed'
			} else {
				$result = 'Failed'
			}

			$result | Should Be Passed

			# Cleanup
			$result = $null
			$HelpFile = $null
		}
	}
}
