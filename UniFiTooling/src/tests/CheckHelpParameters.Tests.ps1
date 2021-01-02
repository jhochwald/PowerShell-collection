
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

Describe -Name "Check $($moduleName) function" -Fixture {
	InModuleScope -ModuleName $moduleName -ScriptBlock {
		$ModuleCommandList = ((Get-Command -Module $ModuleName -CommandType Function).Name)

		foreach ($ModuleCommand in $ModuleCommandList) {
			# Cleanup
			$help = $null

			# Get the Help
			$help = (Get-Help -Name $ModuleCommand -Detailed)

			Context -Name "Check $ModuleCommand Help" -Fixture {
				It -name "Check $ModuleCommand Name" -test {
					$help.NAME | Should Not BeNullOrEmpty
				}

				It -name "Check $ModuleCommand Synopsis" -test {
					$help.SYNOPSIS | Should Not BeNullOrEmpty
				}

				It -name "Check $ModuleCommand Syntax" -test {
					$help.SYNTAX | Should Not BeNullOrEmpty
				}

				It -name "Check $ModuleCommand Description" -test {
					$help.description | Should Not BeNullOrEmpty
				}

				<#
						# No Function is an Island!
						It "Check $ModuleCommand Links" {
						$help.relatedLinks | Should Not BeNullOrEmpty
						}

						# For future usage
						It "Check $ModuleCommand has Values set" {
						$help.returnValues | Should Not BeNullOrEmpty
						}

						# Not all functions need that!
						It "Check $ModuleCommand has parameters set" {
						$help.parameters | Should Not BeNullOrEmpty
						}

						# Do the function have a note field?
						It "Check $ModuleCommand has a Note" {
						$help.alertSet | Should Not BeNullOrEmpty
						}
				#>

				It -name "Check $ModuleCommand Examples" -test {
					$help.examples | Should Not BeNullOrEmpty
				}

				It -name "Check that $ModuleCommand does not use default Synopsis" -test {
					$help.Synopsis.ToString() | Should not BeLike 'A brief description of the*'
				}

				It -name "Check that $ModuleCommand does not use default DESCRIPTION" -test {
					$help.DESCRIPTION.text | Should not BeLike 'A detailed description of the*'
				}

				It -name "Check that $ModuleCommand does not use default NOTES" -test {
					$help.alertSet.alert.text | Should not BeLike 'Additional information about the function.'
				}
			}
		}
	}
}
