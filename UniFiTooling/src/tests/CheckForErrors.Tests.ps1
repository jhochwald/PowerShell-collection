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

Describe -Name "Check $($moduleName) for errors" -Fixture {
	It -name "$($moduleName) is valid PowerShell (has no script errors)" -test {
		# Cleanup
		$errors = $null
		$content = $null

		# Read the File
		$content = (Get-Content -Path $moduleCall -ErrorAction Stop)

		# Check the File
		$null = [Management.Automation.PSParser]::Tokenize($content,[ref]$errors)

		# Should have no errors!
		$errors.Count | Should Be 0
	}
}
