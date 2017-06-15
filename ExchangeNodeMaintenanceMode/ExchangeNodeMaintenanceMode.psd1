@{
	
	# Script module or binary module file associated with this manifest
	RootModule = 'ExchangeNodeMaintenanceMode.psm1'
	
	# Version number of this module.
	ModuleVersion = '1.0.0.1'
	
	# ID used to uniquely identify this module
	GUID = '1293bb34-f68a-46cb-ad98-11ab9dff2f07'
	
	# Author of this module
	Author = 'Joerg Hochwald'
	
	# Company or vendor of this module
	CompanyName = 'Enabling Technology'
	
	# Copyright statement for this module
	Copyright = '(c) 2017 Enabling Technology. All rights reserved.'
	
	# Description of the functionality provided by this module
	Description = 'Exchange Cluster Node Maintenance Mode Utilities'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '3.0'
	
	# Name of the Windows PowerShell host required by this module
	PowerShellHostName = ''
	
	# Minimum version of the Windows PowerShell host required by this module
	PowerShellHostVersion = ''
	
	# Minimum version of the .NET Framework required by this module
	DotNetFrameworkVersion = '3.0'
	
	# Minimum version of the common language runtime (CLR) required by this module
	CLRVersion = '2.0.50727'
	
	# Processor architecture (None, X86, Amd64, IA64) required by this module
	ProcessorArchitecture = 'None'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules = @()
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @()
	
	# Script files (.ps1) that are run in the caller's environment prior to
	# importing this module
	ScriptsToProcess = @()
	
	# Type files (.ps1xml) to be loaded when importing this module
	TypesToProcess = @()
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @()
	
	# Modules to import as nested modules of the module specified in
	# ModuleToProcess
	NestedModules = @()
	
	# Functions to export from this module
	FunctionsToExport = @('Invoke-Exchange2016Workaround, Set-ExchangeNodeMaintenanceModeOn, Set-ExchangeNodeMaintenanceModeOff, Test-ExchangeNodeMaintenanceMode')
	
	# Cmdlets to export from this module
	CmdletsToExport = @('Invoke-Exchange2016Workaround, Set-ExchangeNodeMaintenanceModeOn, Set-ExchangeNodeMaintenanceModeOff, Test-ExchangeNodeMaintenanceMode')
	
	# Variables to export from this module
	VariablesToExport = '*'
	
	# Aliases to export from this module
	AliasesToExport = '*'
	
	# List of all modules packaged with this module
	ModuleList = @()
	
	# List of all files packaged with this module
	FileList = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags = @('Exchange','ExchangeServer','ExchangeCluster')
			
			# A URL to the license for this module.
			LicenseUri = 'https://github.com/jhochwald/PowerShell-collection/blob/master/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri = 'https://github.com/jhochwald/PowerShell-collection'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			ReleaseNotes = 'Initial Release'
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}
