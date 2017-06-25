#Requires -Version 5
[CmdletBinding(DefaultParameterSetName = 'Build')]
param (
	[parameter(Position = 0, ParameterSetName = 'Build')]
	[switch]$BuildModule,
	[parameter(Position = 2, ParameterSetName = 'Build')]
	[switch]$UploadPSGallery,
	[parameter(Position = 3, ParameterSetName = 'Build')]
	[switch]$InstallAndTestModule,
	[parameter(Position = 4, ParameterSetName = 'Build')]
	[version]$NewVersion,
	[parameter(Position = 5, ParameterSetName = 'Build')]
	[string]$ReleaseNotes,
	[parameter(Position = 6, ParameterSetName = 'CBH')]
	[switch]$InsertCBH
)

function PrerequisitesLoaded 
{
	# Install required modules if missing
	try 
	{
		if ((Get-Module -Name InvokeBuild -ListAvailable) -eq $null) 
		{
			Write-Output -InputObject 'Attempting to install the InvokeBuild module...'
			$null = Install-Module -Name InvokeBuild -Scope:CurrentUser
		}
		if (Get-Module -Name InvokeBuild -ListAvailable) 
		{
			Write-Output -InputObject 'Importing InvokeBuild module'
			Import-Module -Name InvokeBuild -Force
			Write-Output -InputObject '...Loaded!'
			return $true
		}
		else 
		{
			return $false
		}
	}
	catch 
	{
		return $false
	}
}

function CleanUp 
{
	try 
	{
		Write-Output -InputObject ''
		Write-Output -InputObject 'Attempting to clean up the session (loaded modules and such)...'
		Invoke-Build -Task BuildSessionCleanup
		Remove-Module -Name InvokeBuild
	}
	catch 
	{
Write-Warning 'Whoopsie'
	}
}

if (-not (PrerequisitesLoaded)) 
{
	throw 'Unable to load InvokeBuild!'
}

switch ($psCmdlet.ParameterSetName) {
	'CBH' 
	{
		if ($InsertCBH) 
		{
			try 
			{
				Invoke-Build -Task InsertMissingCBH
			}
			catch 
			{
				throw
			}
		}

		CleanUp
	}
	'Build' 
	{
		if ($NewVersion -ne $null) 
		{
			try 
			{
				Invoke-Build -Task UpdateVersion -NewVersion $NewVersion -ReleaseNotes $ReleaseNotes
			}
			catch 
			{
				throw $_
			}
		}
		# If no parameters were specified or the build action was manually specified then kick off a standard build
		if (($psboundparameters.count -eq 0) -or ($BuildModule)) 
		{
			try 
			{
				Invoke-Build
			}
			catch 
			{
				Write-Output -InputObject 'Build Failed with the following error:'
				Write-Output -InputObject $_
			}
		}

		# Install and test the module?
		if ($InstallAndTestModule) 
		{
			try 
			{
				Invoke-Build -Task InstallAndTestModule
			}
			catch 
			{
				Write-Output -InputObject 'Install and test of module failed:'
				Write-Output -InputObject $_
			}
		}

		# Upload to gallery?
		if ($UploadPSGallery) 
		{
			try 
			{
				Invoke-Build -Task PublishPSGallery
			}
			catch 
			{
				throw 'Unable to upload project to the PowerShell Gallery!'
			}
		}

		CleanUp
	}
}
