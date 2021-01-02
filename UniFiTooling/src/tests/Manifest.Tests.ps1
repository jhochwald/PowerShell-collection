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

Describe -Name "Check $($moduleName) Manifest" -Fixture {
	Context -Name "Manifest check for $($moduleName)" -Fixture {
		$manifestPath = ($moduleCall)
		$manifestHash = (Invoke-Expression -Command (Get-Content -Path $manifestPath -Raw))

		It -name "$($moduleName) have a valid manifest" -test { { $null = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue } | Should Not Throw
		}

		It -name "$($moduleName) have a valid Root Module" -test {
			$manifestHash.RootModule | Should Be "$moduleName.psm1"
		}

		It -name "$($moduleName) have no more ModuleToProcess entry" -test {
			$manifestHash.ModuleToProcess | Should BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid description" -test {
			$manifestHash.Description | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid PowerShell Version Requirement" -test {
			$manifestHash.PowerShellVersion | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid PowerShell CLR Version Requirement" -test {
			$manifestHash.CLRVersion | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid author" -test {
			$manifestHash.Author | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid Company" -test {
			$manifestHash.CompanyName | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid guid" -test { {
				[guid]::Parse($manifestHash.Guid)
			} | Should Not throw
		}

		It -name "$($moduleName) have a valid copyright" -test {
			$manifestHash.CopyRight | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) have a valid Version" -test {
			$manifestHash.ModuleVersion | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) exports Functions" -test {
			$manifestHash.FunctionsToExport | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) exports Cmdlets" -test {
			$manifestHash.CmdletsToExport | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) exports Variables" -test {
			$manifestHash.VariablesToExport | Should Not BeNullOrEmpty
		}

		It -name "$($moduleName) exports Aliases" -test {
			$manifestHash.AliasesToExport | Should Not BeNullOrEmpty
		}

		It -name "Online Galleries: $($moduleName) have Categories" -test {
			$manifestHash.PrivateData.PSData.Category | Should Not BeNullOrEmpty
		}

		It -name "Online Galleries: $($moduleName) have Tags" -test {
			$manifestHash.PrivateData.PSData.Tags | Should Not BeNullOrEmpty
		}

		It -name "Online Galleries: $($moduleName) have a license URL" -test {
			$manifestHash.PrivateData.PSData.LicenseUri | Should Not BeNullOrEmpty
		}

		It -name "Online Galleries: $($moduleName) have a Project URL" -test {
			$manifestHash.PrivateData.PSData.ProjectUri | Should Not BeNullOrEmpty
		}

		It -name "Online Galleries: $($moduleName) have a Icon URL" -test {
			$manifestHash.PrivateData.PSData.IconUri | Should Not BeNullOrEmpty
		}

		It -name "Online Galleries: $($moduleName) have ReleaseNotes" -test {
			$manifestHash.PrivateData.PSData.ReleaseNotes | Should Not BeNullOrEmpty
		}

		It -name "NuGet: $($moduleName) have Info for Prerelease" -test {
			$manifestHash.PrivateData.PSData.IsPrerelease | Should Not BeNullOrEmpty
		}

		It -name "NuGet: $($moduleName) have Module Title" -test {
			$manifestHash.PrivateData.PSData.ModuleTitle | Should Not BeNullOrEmpty
		}

		It -name "NuGet: $($moduleName) have Module Summary" -test {
			$manifestHash.PrivateData.PSData.ModuleSummary | Should Not BeNullOrEmpty
		}

		It -name "NuGet: $($moduleName) have Module Language" -test {
			$manifestHash.PrivateData.PSData.ModuleLanguage | Should Not BeNullOrEmpty
		}

		It -name "NuGet: $($moduleName) have License Acceptance Info" -test {
			$manifestHash.PrivateData.PSData.ModuleRequireLicenseAcceptance | Should Not BeNullOrEmpty
		}
	}
}
