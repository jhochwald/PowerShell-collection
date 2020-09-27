#requires -Version 2.0 -Modules PackageManagement, PowerShellGet

<#
      .SYNOPSIS
      Check and install all prerequisites and dependencies, if they are needed

      .DESCRIPTION
      Check and install all prerequisites and dependencies, if they are needed

      .EXAMPLE
      PS C:\> .\Install-AutoPilotRelated.ps1

      # Check and install all prerequisites and dependencies, if they are needed

      .NOTES
      Additional information about the file.
#>
[CmdletBinding(ConfirmImpact = 'None')]
param ()

begin
{
	#region Global
	$IGN = 'Ignore'
	$SCT = 'SilentlyContinue'

	$paramFindPackageProvider = @{
		Name                = 'NuGet'
		ForceBootstrap      = $true
		IncludeDependencies = $true
		Force               = $true
		ErrorAction         = $SCT
	}

	$paramInstallModule = @{
		Force              = $true
		Scope              = 'AllUsers'
		AllowClobber       = $true
		SkipPublisherCheck = $true
		Confirm            = $false
		ErrorAction        = $SCT
	}

	$paramSetPSRepository = @{
		Name               = 'PSGallery'
		InstallationPolicy = 'Trusted'
		ErrorAction        = $SCT
	}

	$paramInstallScript = @{
		Name        = 'Get-WindowsAutoPilotInfo'
		Scope       = 'AllUsers'
		Force       = $true
		Confirm     = $false
		ErrorAction = $SCT
	}
	#endregion Global

	#region Cleanup
	$NuGetProvider = $null
	$WindowsAutopilotIntuneModule = $null
	$AzureADModule = $null
	$ScriptInfo = $null
	#endregion Cleanup

	#region GatherInfo
	$paramGetPackageProvider = @{
		Name        = 'NuGet'
		ErrorAction = $IGN
	}
	$NuGetProvider = (Get-PackageProvider @paramGetPackageProvider)

	$paramImportModule = @{
		NoClobber           = $true
		DisableNameChecking = $true
		PassThru            = $true
		ErrorAction         = $IGN
	}

	# Get the module info
	$WindowsAutopilotIntuneModule = (Import-Module -Name WindowsAutopilotIntune @paramImportModule)
	$AzureADModule = (Import-Module -Name AzureAD @paramImportModule)

	# Get the repository info
	$PSRepositoryInfo = (Get-PSRepository -Name PSGallery -ErrorAction $SCT)
	#endregion GatherInfo

	#region
	$paramGetInstalledScript = @{
		Name        = 'Get-WindowsAutoPilotInfo'
		ErrorAction = $SCT
	}
	$ScriptInfo = (Get-InstalledScript @paramGetInstalledScript)
	#endregion
}

process
{
	#region PackageProvider
	# Get the NuGet PackageProvider for the PowerShell Gallery, if needed
	if (-not $NuGetProvider)
	{
		$null = (Find-PackageProvider @paramFindPackageProvider)
	}
	#endregion PackageProvider

	#region PSRepository
	if (($PSRepositoryInfo | Select-Object -ExpandProperty InstallationPolicy) -ne $true)
	{

		$null = (Set-PSRepository @paramSetPSRepository)
	}
	#endregion PSRepository

	#region ModuleHandler
	# Get Azure AD module, if needed
	if (-not $AzureADModule)
	{
		$null = (Install-Module -Name AzureAD @paramInstallModule)
	}

	# Get WindowsAutopilotIntune module, if needed
	if (-not $WindowsAutopilotIntuneModule)
	{
		$null = (Install-Module -Name WindowsAutopilotIntune @paramInstallModule)
	}
	#endregion ModuleHandler

	#region ScriptHandler
	# Install the Helper script from the Gallery
	if (-not $ScriptInfo)
	{
		$null = (Install-Script @paramInstallScript)
	}
	#endregion ScriptHandler
}

end
{
	#region Cleanup
	$NuGetProvider = $null
	$WindowsAutopilotIntuneModule = $null
	$AzureADModule = $null
	$ScriptInfo = $null
	#endregion Cleanup
}
