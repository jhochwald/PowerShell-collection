#requires -Version 3.0 -Modules Pester, PSScriptAnalyzer

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

<#
		The 3rd party Module must be here!

		Install it:
		PS> Save-Module -Name PSScriptAnalyzer -Path <path>
		PS> Install-Module -Name PSScriptAnalyzer
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

Describe -Name "Check $($moduleName) with ScriptAnalyzer" -Fixture {
	It -name "$($moduleName) should pass the basic ScriptAnalyzer tests" -test {
		# Check the Module
		# We disable a few rules until all modules are re-factored...
		(Invoke-ScriptAnalyzer -Path $moduleCall -ExcludeRule 'PSAvoidGlobalVars', 'PSAvoidUsingCmdletAliases', 'PSAvoidUsingUserNameAndPassWordParams', 'PSUseBOMForUnicodeEncodedFile', 'PSAvoidUsingInvokeExpression', 'PSAvoidUsingWriteHost', 'PSUseApprovedVerbs', 'PSAvoidUsingWMICmdlet', 'PSAvoidDefaultValueSwitchParameter', 'PSUseSingularNouns', 'PSShouldProcess', 'PSAvoidUsingPlainTextForPassword')
	}
}
