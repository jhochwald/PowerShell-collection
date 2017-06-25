param (
	[parameter(Position = 0)]
	[string]$BuildFile = (Join-Path -Path $BuildRoot -ChildPath 'build\ExchangeNodeMaintenanceMode.buildenvironment.ps1'),
	[parameter(Position = 1)]
	[version]$NewVersion = $null,
	[parameter(Position = 2)]
	[string]$ReleaseNotes,
	[parameter(Position = 3)]
	[switch]$Force
)

# Basic indented descriptive build output.
Function Write-Description 
{
	param (
		[string]$color = 'White',
		[string]$Description = '',
		[int]$Level = 0,
		[int]$indent = 1,
		[switch]$accent,
		[string]$AccentL = '* ',
		[string]$AccentR = ''
	)

	$thisindent = (' ' * $indent) * $Level
	if ($accent) 
	{
		$accentleft = $AccentL
		$accentright = $AccentR
	}
	Write-Build $color "$accentleft$thisindent$Description$accentright"
}

if (Test-Path $BuildFile) 
{
	. $BuildFile
}
else 
{
	throw 'Without a build environment file we are at a loss as to what to do!'
}

if ($Script:BuildEnv.OptionTranscriptEnabled) 
{
	Write-Output -InputObject 'Transcript logging: TRUE'
	$BuildToolPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BuildToolFolder
	$TranscriptLog = Join-Path -Path $BuildToolPath -ChildPath $Script:BuildEnv.OptionTranscriptLogFile
	Write-Output -InputObject "TranscriptLog: $($TranscriptLog)"
	Start-Transcript -Path $TranscriptLog -Append -WarningAction:SilentlyContinue
}

#Synopsis: Validate system requirements are met
task ValidateRequirements {
	Write-Description White 'Validating System Requirements for Build' -accent
	assert ($PSVersionTable.PSVersion.Major.ToString() -eq '5') 'Powershell 5 is required for this build to function properly (you can comment this assert out if you are able to work around this requirement)'
}

#Synopsis: Load required modules if available. Otherwise try to install, then load it.
task LoadRequiredModules {
	Write-Description White 'Loading all required modules for the build framework' -accent

	# These are required for a full build process and will be automatically installed if they aren't available
	$Script:RequiredModules = @('PlatyPS')

	# Some optional modules
	if ($Script:BuildEnv.OptionAnalyzeCode) 
	{
		$Script:RequiredModules += 'PSScriptAnalyzer'
	}

	if ($Script:BuildEnv.OptionGenerateReadTheDocs) 
	{
		$Script:RequiredModules += 'Powershell-YAML'
	}
	$Script:RequiredModules | ForEach-Object -Process {
		if ((Get-Module $_ -ListAvailable) -eq $null) 
		{
			Write-Description White "Installing $($_) Module" -Level 2
			$null = Install-Module $_ -Scope:CurrentUser
		}
		if (Get-Module $_ -ListAvailable) 
		{
			Write-Description White "Importing $($_) Module" -Level 2
			Import-Module $_ -Force
		}
		else 
		{
			throw 'How did you even get here?'
		}
	}
}

#Synopsis: Load dot sourced functions into this build session
task LoadBuildTools {
	Write-Description White 'Sourcing all of the required build functions' -accent
	$BuildToolPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BuildToolFolder
	$BuildTools = Join-Path -Path $BuildToolPath -ChildPath 'dotSource'
	# Dot source any build script functions we need to use
	Get-ChildItem $BuildTools -Recurse -Filter '*.ps1' -File | ForEach-Object -Process {
		Write-Description White "Dot sourcing script file: $($_.Name)" -Level 2
		. $_.FullName
	}
}

# Synopsis: Create new module manifest with explicit function exports included
task CreateModuleManifest CreateModulePSM1, {
	Write-Description White 'Module manifest file updates' -accent

	$ModuleManifestFullPath = (Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.ModuleToBuild).psd1")
	$StageReleasePath = (Join-Path -Path (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder) -ChildPath $Script:BuildEnv.BaseReleaseFolder)
	$PSD1OutputFile = (Join-Path -Path $StageReleasePath -ChildPath "$($Script:BuildEnv.ModuleToBuild).psd1")
	$ThisPSD1OutputFile = ".\$($Script:BuildEnv.ScratchFolder)\$($Script:BuildEnv.BaseReleaseFolder)\$($Script:BuildEnv.ModuleToBuild).psd1"
	Write-Description White "Attempting to update the release module manifest file:  $ThisPSD1OutputFile" -Level 2

	$null = (Copy-Item -Path $ModuleManifestFullPath -Destination $PSD1OutputFile -Force)

	Update-ModuleManifest -Path $PSD1OutputFile -FunctionsToExport $Script:FunctionsToExport
}

# Synopsis: Load the module project
task LoadModule {
	Write-Description White 'Attempting to load the project module.' -Accent

	$ModuleFullPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.ModuleToBuild).psm1"
	try 
	{
		$Script:Module = Import-Module $ModuleFullPath -Force -PassThru
	}
	catch 
	{
		throw "Unable to load the project module: $($ModuleFullPath)"
	}
}

# Synopsis: Import the current module manifest file for processing
task LoadModuleManifest {
	Write-Description White 'Loading the existing module manifest for this module' -accent

	$ModuleManifestFullPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.ModuleToBuild).psd1"
	assert (Test-Path $ModuleManifestFullPath) "Unable to locate the module manifest file: $ModuleManifestFullPath"
	$Script:Manifest = Test-ModuleManifest -Path $ModuleManifestFullPath
}

# Synopsis: Valiates there is no version mismatch.
task VersionCheck LoadModuleManifest, {
	Write-Description White 'Validating manifest, build, and gallery module versions.' -accent

	assert ( ($Script:Manifest).Version.ToString() -eq (($Script:BuildEnv.ModuleVersion)) ) "The module manifest version ( $(($Script:Manifest).Version.ToString()) ) and release version ($($Script:BuildEnv.ModuleVersion)) are mismatched. These must be the same before continuing. Consider running the UpdateRelease task to make the module manifest version the same as the release version."
	Write-Description White 'Manifest version and the release version in the build configuration file are the same.' -Level 2
	$GalleryVersion = Find-Module ($Script:BuildEnv.ModuleToBuild) -ErrorAction:SilentlyContinue
	if ($null -ne $GalleryVersion) 
	{
		assert ( ($GalleryVersion.Version -lt [version]($Script:BuildEnv.ModuleVersion)) -and (-not $Force) ) "The current module version is less than or equal to the one published in powershell gallary. You should bump up your module version to be at least greater than $($GalleryVersion.Version.ToString()) before building this module."
	}
	else 
	{
		Write-Description White 'This module has not been published to the gallery so any version is ok to build at this point.' -Level 2
	}
}

#Synopsis: Validate script requirements are met, load required modules, load project manifest and module, and load additional build tools.
task Configure ValidateRequirements, PreBuildTasks, LoadRequiredModules, LoadModuleManifest, LoadModule, VersionCheck, LoadBuildTools, {
	# If we made it this far then we are configured!
	Write-Description White 'Configuring build environment' -accent
}

# Synopsis: Set a new version of the module
task NewVersion LoadBuildTools, LoadModuleManifest, {
	Write-Description White 'Updating module build version' -accent
	$ModuleManifestFullPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.ModuleToBuild).psd1"
	$ReleasePath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BaseReleaseFolder
	$AllReleases = @((Get-ChildItem $ReleasePath -Directory | Where-Object -FilterScript {
				$_.Name -match '^([0-9].[0-9].[0-9])$'
		} | Select-Object).Name | ForEach-Object -Process {
			[version]$_
	})

	# if a new version wasn't passed as a parameter then prompt for one
	if ($null -eq $NewVersion) 
	{
		do 
		{
			$NewVersion = Read-Host -Prompt 'Enter the version (ie 0.0.8) for your build release'
			if ([string]::IsNullOrEmpty($NewVersion)) 
			{
				Write-Build Red 'You need to enter a valid module version (ie. 1.2.0)' -level 2
			}
		}
		while ( [string]::IsNullOrEmpty($NewVersion) -and ($NewVersion -notmatch '\d+\.\d+\.\d+') )
	}
	if (($AllReleases -contains $NewVersion) -and (-not $Force)) 
	{
		Write-Build Red 'The module version already has been released (the folder exists within the releases folder. In order to set your build project to this version you will need to pass the -Force switch to this build script with the -NewVersion parameter' -Level 2
		throw 'Unable to update build project version!'
	}

	$Script:BuildEnv.ModuleVersion = $NewVersion.ToString()

	Write-Description White 'Saving persistent build file with new module version' -level 2
	Save-BuildData

	Write-Description White 'Updating module manifest with new module version' -level 2
	try 
	{
		Update-ModuleManifest -Path $ModuleManifestFullPath -ModuleVersion $NewVersion
	}
	catch 
	{
		throw $_
	}
}

# Synopsis: Update current module manifest with the version defined in the build config file (if they differ)
task UpdateRelease LoadBuildTools, LoadModuleManifest, {
	Write-Description White 'Updating the release notes of this module' -accent

	$ModuleManifestFullPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.ModuleToBuild).psd1"
	# If there is a version mismatch then we need to put in some release notes and update the module manifest
	if ($null -eq $ReleaseNotes) 
	{
		do 
		{
			$ReleaseNotes = Read-Host -Prompt 'Enter brief release notes for this new version'
			if ([string]::IsNullOrEmpty($ReleaseNotes)) 
			{
				Write-Build Red 'You need to enter some kind of notes for your new release to update the manifest with!' -level 2
			}
		}
		while ([string]::IsNullOrEmpty($ReleaseNotes))
	}

	try 
	{
		Update-ModuleManifest -Path $ModuleManifestFullPath -ReleaseNotes $ReleaseNotes
	}
	catch 
	{
		throw $_
	}
}

# Synopsis: Update the current working module version and release notes
task UpdateVersion NewVersion, UpdateRelease

# Synopsis: Regenerate scratch staging directory
task Clean {
	Write-Description White "Clean up our scratch/staging directory $($Script:BuildEnv.ScratchFolder)" -accent

	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$null = Remove-Item $ScratchPath -Force -Recurse -ErrorAction 0
	$null = New-Item $ScratchPath -ItemType:Directory -Force
}

# Synopsis: Create base content tree in scratch staging area
task PrepareStage {
	Write-Description White 'Creating staging folder structure' -accent

	$BuildDocsPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.BuildToolFolder)\docs\"
	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.BaseReleaseFolder

	# Create the directories
	$null = New-Item -Path "$($ScratchPath)\src" -ItemType:Directory -Force
	$null = New-Item $StageReleasePath -ItemType:Directory -Force

	Copy-Item -Path "$($BuildRoot)\*.psm1" -Destination $ScratchPath
	Copy-Item -Path "$($BuildRoot)\*.psd1" -Destination $ScratchPath
	Copy-Item -Path "$($BuildRoot)\$($Script:BuildEnv.PublicFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($Script:BuildEnv.PublicFunctionSource)"
	Copy-Item -Path "$($BuildRoot)\$($Script:BuildEnv.PrivateFunctionSource)" -Recurse -Destination "$($ScratchPath)\$($Script:BuildEnv.PrivateFunctionSource)"
	Copy-Item -Path "$($BuildRoot)\$($Script:BuildEnv.OtherModuleSource)" -Recurse -Destination "$($ScratchPath)\$($Script:BuildEnv.OtherModuleSource)"
	Copy-Item -Path (Join-Path -Path $BuildDocsPath -ChildPath 'en-US') -Recurse -Destination $ScratchPath
	$Script:BuildEnv.AdditionalModulePaths | ForEach-Object -Process {
		Copy-Item -Path $_ -Recurse -Destination $ScratchPath -Force
	}
}

# Synopsis: Update public functions to include a template comment based help.
task UpdateCBHtoScratch {
	Write-Description White 'Attempting to insert comment based help into functions' -accent

	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$CBHPattern = '(?ms)(^\s*\<#.*\.SYNOPSIS.*?#>)'
	$CBHUpdates = 0

	# Create the directories
	$null = New-Item (Join-Path -Path $ScratchPath -ChildPath 'src') -ItemType:Directory -Force
	$null = New-Item (Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.PublicFunctionSource) -ItemType:Directory -Force
	Get-ChildItem (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.PublicFunctionSource) -Filter *.ps1 | ForEach-Object -Process {
		$FileName = $_.Name
		$FullFilePath = $_.FullName
		Write-Description White "Public function - $($FileName)" -level 2
		$currscript = Get-Content $FullFilePath -Raw
		$CBH = $currscript | New-CommentBasedHelp
		$currscriptblock = [scriptblock]::Create($currscript)
		. $currscriptblock
		$currfunct = Get-Command $CBH.FunctionName


		if ($currfunct.definition -notmatch $CBHPattern) 
		{
			$CBHUpdates++
			Write-Description White "Inserting template CBH and writing to : $($Script:BuildEnv.ScratchFolder)\$($Script:BuildEnv.PublicFunctionSource)\$($FileName)" -Level 3
			$UpdatedFunct = 'Function ' + $currfunct.Name + ' {' + "`r`n" + $CBH.CBH + "`r`n" + $currfunct.definition + "`r`n" + '}'
			$UpdatedFunct | Out-File -FilePath "$($ScratchPath)\$($Script:BuildEnv.PublicFunctionSource)\$($FileName)" -Encoding $Script:BuildEnv.Encoding -Force
		}
		else 
		{
			Write-Description Yellow 'Comment based help already exists!' -Level 2
		}

		Remove-Item -Path Function:\$($currfunct.Name)
	}
	Write-Build White ''
	Write-Build  Yellow '****************************************************************************************************'
	Write-Build  Yellow "  Updated Functions: $CBHUpdates"
	if ($CBHUpdates -gt 0) 
	{
		Write-Build White ''
		Write-Build Yellow "  Updated Function Location: $($ScratchPath)\$($Script:BuildEnv.PublicFunctionSource)"
		Write-Build White ''
		Write-Build Yellow '  NOTE: Please inspect these files closely. If they look good merge them back into your project'
	}
	Write-Build  Yellow '****************************************************************************************************'
	$null = Read-Host -Prompt 'Press Enter to continue...'
}

# Synopsis:  Collect a list of our public methods for later module manifest updates
task GetPublicFunctions {
	Write-Description White 'Parsing for public (exported) function names' -accent
	$Exported = @()
	Get-ChildItem (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.PublicFunctionSource) -Recurse -Filter '*.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
		$Exported += ([Management.Automation.Language.Parser]::ParseInput((Get-Content -Path $_.FullName -Raw), [ref]$null, [ref]$null)).FindAll( {
				$args[0] -is [Management.Automation.Language.FunctionDefinitionAst]
		}, $false) | ForEach-Object -Process {
			$_.Name
		}
	}

	if ($Exported.Count -eq 0) 
	{
		Write-Error -Message 'There are no public functions to export!'
	}
	$Script:FunctionsToExport = $Exported
	Write-Description White "Number of exported functions found = $($Exported.Count)" -Level 2
}

# Synopsis: Assemble the module for release
task CreateModulePSM1 RemoveScriptSignatures, UpdateCBH, {
	Write-Description White 'Assembling module psm1 file' -Accent
	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.BaseReleaseFolder
	$ReleaseModule = "$($StageReleasePath)\$($Script:BuildEnv.ModuleToBuild).psm1"

	if ($Script:BuildEnv.OptionCombineFiles) 
	{
		Write-Description White 'Option to combine PSM1 is enabled, combining source files now...' -Level 2

		$CombineFiles = ''
		$PreloadFilePath = (Join-Path -Path $ScratchPath -ChildPath "$($Script:BuildEnv.OtherModuleSource)\PreLoad.ps1")

		if (Test-Path $PreloadFilePath) 
		{
			Write-Description White 'Starting with Preload.ps1' -Level 3
			$CombineFiles += "## Pre-Loaded Module code ##`r`n`r`n"
			Get-ChildItem $PreloadFilePath | ForEach-Object -Process {
				$CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
			}
		}
		Write-Description White 'Adding the private source files:' -Level 3

		$CombineFiles += "## PRIVATE MODULE FUNCTIONS AND DATA ##`r`n`r`n"

		Get-ChildItem  (Join-Path -Path $ScratchPath -ChildPath "$($Script:BuildEnv.PrivateFunctionSource)\*.ps1") | ForEach-Object -Process {
			Write-Description White $_.Name -Level 4
			$CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
		}

		Write-Description White 'Adding the public source files:' -Level 3

		$CombineFiles += "## PUBLIC MODULE FUNCTIONS AND DATA ##`r`n`r`n"
		Get-ChildItem  (Join-Path -Path $ScratchPath -ChildPath "$($Script:BuildEnv.PublicFunctionSource)\*.ps1") | ForEach-Object -Process {
			Write-Description White $_.Name -Level 4
			$CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
		}

		Write-Description White 'Finishing with Postload.ps1' -Level 3
		$CombineFiles += "## Post-Load Module code ##`r`n`r`n"
		$PostLoadPath = (Join-Path -Path $ScratchPath -ChildPath "$($Script:BuildEnv.OtherModuleSource)\PostLoad.ps1")
		if (Test-Path $PostLoadPath) 
		{
			Get-ChildItem  $PostLoadPath | ForEach-Object -Process {
				$CombineFiles += (Get-Content $_ -Raw) + "`r`n`r`n"
			}
		}

		Set-Content -Path $ReleaseModule -Value $CombineFiles -Encoding $Script:BuildEnv.Encoding
	}
	else 
	{
		Write-Description White 'Option to combine PSM1 is NOT enabled, copying over file structure now...' -Level 2
		Copy-Item -Path (Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.OtherModuleSource) -Recurse -Destination $StageReleasePath -Force
		Copy-Item -Path (Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.PrivateFunctionSource) -Recurse -Destination $StageReleasePath -Force
		Copy-Item -Path (Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.PublicFunctionSource) -Recurse -Destination $StageReleasePath -Force
		Copy-Item -Path (Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.ModuleToBuild) -Destination $StageReleasePath -Force
	}

	if (($Script:BuildEnv.AdditionalModulePaths).Count -gt 0) 
	{
		Write-Description White 'Copying over additional module paths now.' -Level 2
		$Script:BuildEnv.AdditionalModulePaths | ForEach-Object -Process {
			Write-Description White "Copying $_" -Level 3
			Copy-Item -Path $_ -Recurse -Destination $StageReleasePath -Force
		}
	}
}

# Synopsis: Removes script signatures before creating a combined PSM1 file
task RemoveScriptSignatures {
	Write-Description White 'Removing any script signatures for function files (if they exist)' -Accent

	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder

	if ($Script:BuildEnv.OptionCombineFiles) 
	{
		Write-Description White 'Remove script signatures from all files' -Level 2
		Get-ChildItem -Path "$($ScratchPath)\$($Script:BuildEnv.BaseSourceFolder)" -Recurse -File | ForEach-Object -Process {
			Remove-Signature -FilePath $_.FullName
		}
	}
}

# Synopsis: Validate that sensitive strings are not found in your code
task SanitizeCode -if {
	$Script:BuildEnv.OptionSanitizeSensitiveTerms
} {
	Write-Description White 'Attempting to find sensitive terms in the code' -accent
	$ScratchPath = (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder)
	$StageReleasePath = (Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.BaseReleaseFolder)

	ForEach ($Term in $Script:BuildEnv.OptionSensitiveTerms) 
	{
		Write-Description White "Checking Files for sensitive string: $Term" -level 2
		$TermsFound = Get-ChildItem -Path $ScratchPath -Recurse -File | Where-Object -FilterScript {
			$_.FullName -notlike "$($StageReleasePath)*"
		} | Select-String -Pattern $Term
		if ($TermsFound.Count -gt 0) 
		{
			Write-Description white 'Sensitive string found in the following files:' -Level 3
			$TermsFound | ForEach-Object -Process {
				Write-Description yellow $_ -level 4
			}
			throw 'Sensitive Terms found!'
		}
	}
}

# Synopsis: Replace comment based help with external help in all public functions for this project
task UpdateCBH {
	Write-Description White 'Updating Comment Based Help in functions to point to external help links' -accent

	$ExternalHelp = @"
<#
    .EXTERNALHELP $($Script:BuildEnv.ModuleToBuild)-help.xml
    .LINK
        {{LINK}}
    #>
"@

	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$CBHPattern = '(?ms)(\<#.*\.SYNOPSIS.*?#>)'
	Get-ChildItem -Path "$($ScratchPath)\$($Script:BuildEnv.PublicFunctionSource)\*.ps1" -File | ForEach-Object -Process {
		$FormattedOutFile = $_.FullName
		$FileName = $_.Name
		Write-Description White "Replacing CBH in file: $($FileName)" -level 2
		$FunctionName = $FileName -replace '.ps1', ''
		$NewExternalHelp = $ExternalHelp -replace '{{LINK}}', ($Script:BuildEnv.ModuleWebsite + "/tree/master/$($Script:BuildEnv.BaseReleaseFolder)/$($Script:BuildEnv.ModuleVersion)/docs/Functions/$($FunctionName).md")
		$UpdatedFile = (Get-Content  $FormattedOutFile -Raw) -replace $CBHPattern, $NewExternalHelp
		$UpdatedFile | Out-File -FilePath $FormattedOutFile -Force -Encoding $Script:BuildEnv.Encoding
	}
}

# Synopsis: Run PSScriptAnalyzer against the assembled module
task AnalyzeModuleRelease -if {
	$Script:BuildEnv.OptionAnalyzeCode
} {
	Write-Description White 'Analyzing the project with ScriptAnalyzer' -accent
	$StageReleasePath = Join-Path -Path (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder) -ChildPath $Script:BuildEnv.BaseReleaseFolder
	$Analysis = Invoke-ScriptAnalyzer -Path $StageReleasePath
	$AnalysisErrors = @($Analysis | Where-Object -FilterScript {
			@('Information', 'Warning') -notcontains $_.Severity
	})
	if ($AnalysisErrors.Count -ne 0) 
	{
		Write-Build White 'The following errors came up in the script analysis:' -level 2
		$AnalysisErrors
		Write-Build
		Write-Build White "Note that this was from the script analysis run against $StageReleasePath" -Level 2
		Prompt-ForBuildBreak -CustomError $AnalysisErrors
	}
}

# Synopsis: Run PSScriptAnalyzer against the public source files.
task AnalyzePublic {
	Write-Description White 'Analyzing the public source files with ScriptAnalyzer.' -accent
	$Analysis = Invoke-ScriptAnalyzer -Path (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.PublicFunctionSource)
	$AnalysisErrors = @($Analysis | Where-Object -FilterScript {
			@('Information', 'Warning') -notcontains $_.Severity
	})

	if ($AnalysisErrors.Count -ne 0) 
	{
		Write-Description White 'The following errors came up in the script analysis:' -level 2
		$AnalysisErrors
		Write-Description
		Write-Description White "Note that this was from the script analysis run against $($Script:BuildEnv.PublicFunctionSource)" -level 2
	}
}

# Synopsis: Build help files for module
task CreateHelp CreateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, CreateProjectHelp, AddAdditionalDocFiles

# Synopsis: Build the markdown help files with PlatyPS
task CreateMarkdownHelp GetPublicFunctions, {
	Write-Description White 'Creating markdown documentation with PlatyPS' -accent

	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.BaseReleaseFolder
	Copy-Item -Path (Join-Path -Path $ScratchPath -ChildPath 'en-US') -Recurse -Destination $StageReleasePath -Force
	$OnlineModuleLocation = "$($Script:BuildEnv.ModuleWebsite)/$($Script:BuildEnv.BaseReleaseFolder)"
	$FwLink = "$($OnlineModuleLocation)/$($Script:BuildEnv.ModuleToBuild)/docs/$($Script:BuildEnv.ModuleToBuild).md"
	$ModulePage = "$($StageReleasePath)\docs\$($Script:BuildEnv.ModuleToBuild).md"

	# Create the function .md files and the generic module page md as well for the distributable module
	$null = New-MarkdownHelp -module $Script:BuildEnv.ModuleToBuild -OutputFolder "$($StageReleasePath)\docs\" -Force -WithModulePage -Locale 'en-US' -FwLink $FwLink -HelpVersion $Script:BuildEnv.ModuleVersion -Encoding ([Text.Encoding]::($Script:BuildEnv.Encoding))

	# Replace each missing element we need for a proper generic module page .md file
	$ModulePageFileContent = Get-Content -Raw $ModulePage
	$ModulePageFileContent = $ModulePageFileContent -replace '{{Manually Enter Description Here}}', $Script:Manifest.Description
	$Script:FunctionsToExport | ForEach-Object -Process {
		Write-Description White "Updating definition for the following function: $($_)" -Level 2
		$TextToReplace = "{{Manually Enter $($_) Description Here}}"
		$ReplacementText = (Get-Help -Detailed -Name $_).Synopsis
		$ModulePageFileContent = $ModulePageFileContent -replace $TextToReplace, $ReplacementText
	}
	$ModulePageFileContent | Out-File $ModulePage -Force -Encoding $Script:BuildEnv.Encoding

	$MissingDocumentation = Select-String -Path "$($StageReleasePath)\docs\*.md" -Pattern '({{.*}})'

	if ($MissingDocumentation.Count -gt 0) 
	{
		Write-Build Yellow ''
		Write-Build Yellow '   The documentation that got generated resulted in missing sections which should be filled out.'
		Write-Build Yellow '   Please review the following sections in your comment based help, fill out missing information and rerun this build:'
		Write-Build Yellow '   (Note: This can happen if the .EXTERNALHELP CBH is defined for a function before running this build.)'
		Write-Build White ''
		Write-Build Yellow "Path of files with issues: $($StageReleasePath)\docs\"
		Write-Build White ''
		$MissingDocumentation | Select-Object -Property FileName, Matches | Format-Table -AutoSize
		Write-Build Yellow ''
		Pause

		throw 'Missing documentation. Please review and rebuild.'
	}
}

# Synopsis: Build the markdown help files with PlatyPS
task CreateExternalHelp {
	Write-Description White 'Creating markdown help files' -accent
	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.BaseReleaseFolder

	$PlatyPSVerbose = @{}
	if ($Script:BuildEnv.OptionRunPlatyPSVerbose) 
	{
		$PlatyPSVerbose.Verbose = $true
	}
	$null = New-ExternalHelp "$($StageReleasePath)\docs" -OutputPath "$($StageReleasePath)\en-US\" -Force @PlatyPSVerbose
}

# Synopsis: Build the help file CAB with PlatyPS
task CreateUpdateableHelpCAB {
	Write-Description White 'Creating updateable help cab file' -accent

	$ScratchPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder
	$StageReleasePath = Join-Path -Path $ScratchPath -ChildPath $Script:BuildEnv.BaseReleaseFolder

	$PlatyPSVerbose = @{}
	if ($Script:BuildEnv.OptionRunPlatyPSVerbose) 
	{
		$PlatyPSVerbose.Verbose = $true
	}
	$LandingPage = "$($StageReleasePath)\docs\$($Script:BuildEnv.ModuleToBuild).md"
	$null = New-ExternalHelpCab -CabFilesFolder "$($StageReleasePath)\en-US\" -LandingPagePath $LandingPage -OutputFolder "$($StageReleasePath)\en-US\" @PlatyPSVerbose
}

# Synopsis: Build help files for module and ignore missing section errors
task TestCreateHelp Configure, CreateMarkdownHelp, CreateExternalHelp, CreateUpdateableHelpCAB, {
	Write-Description White 'Create help files' -accent
}

# Synopsis: Create a new version release directory for our release and copy our contents to it
task PushVersionRelease {
	Write-Description White 'Attempting to push a version release of the module' -accent

	$ReleasePath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BaseReleaseFolder
	$ThisReleasePath = Join-Path -Path $ReleasePath -ChildPath $Script:BuildEnv.ModuleVersion
	$ThisBuildReleasePath = ".\$($Script:BuildEnv.BaseReleaseFolder)\$($Script:BuildEnv.ModuleVersion)"
	$StageReleasePath = Join-Path -Path (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder) -ChildPath $Script:BuildEnv.BaseReleaseFolder

	$null = Remove-Item $ThisReleasePath -Force -Recurse -ErrorAction 0
	$null = New-Item $ThisReleasePath -ItemType:Directory -Force
	Copy-Item -Path "$($StageReleasePath)\*" -Destination $ThisReleasePath -Recurse
	#Out-Zip $StageReleasePath (Join-Path $ReleasePath "$($Script:BuildEnv.ModuleToBuild)-$($Script:BuildEnv.ModuleVersion).zip") -overwrite
}

# Synopsis: Create the current release directory and copy this build to it.
task PushCurrentRelease {
	Write-Description White 'Attempting to push a current release of the module' -accent

	$ReleasePath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BaseReleaseFolder
	$CurrentReleasePath = Join-Path -Path $ReleasePath -ChildPath $Script:BuildEnv.ModuleToBuild
	$ThisBuildCurrentReleasePath = ".\$($Script:BuildEnv.BaseReleaseFolder)\$($Script:BuildEnv.ModuleToBuild)"
	$StageReleasePath = Join-Path -Path (Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.ScratchFolder) -ChildPath $Script:BuildEnv.BaseReleaseFolder

	$MostRecentRelease = (Get-ChildItem $ReleasePath -Directory | Where-Object -FilterScript {
			$_.Name -like '*.*.*'
	} | Select-Object -Property Name).name | ForEach-Object -Process {
		[version]$_
	} | Sort-Object -Descending | Select-Object -First 1
	$ProcessCurrentRelease = $true
	if ($MostRecentRelease) 
	{
		if ($MostRecentRelease -gt [version]$Script:BuildEnv.ModuleVersion) 
		{
			$ProcessCurrentRelease = $false
		}
	}
	if ($ProcessCurrentRelease -or $Force) 
	{
		Write-Description White "Pushing a version release to $($ThisBuildCurrentReleasePath)" -level 2
		$null = Remove-Item $CurrentReleasePath -Force -Recurse -ErrorAction 0
		$null = New-Item $CurrentReleasePath -ItemType:Directory -Force
		Copy-Item -Path "$($StageReleasePath)\*" -Destination $CurrentReleasePath -Recurse -Force
		Out-Zip $StageReleasePath "$ReleasePath\$($Script:BuildEnv.ModuleToBuild)-current.zip" -overwrite
	}
	else 
	{
		Write-Warning -Message 'Unable to push this version as a current release as it is not the most recent version in the release directory! Re-run this task with the -Force flag to overwrite it.'
	}
}

# Synopsis: Populate the function markdown help for the project documentation
task CreateProjectFunctionHelp LoadRequiredModules, {
	Write-Description -color White -Description 'Creating markdown documentation with PlatyPS for the core project' -accent
	if ((Test-Path -Path $Script:CurrentReleasePath)) 
	{
		$OnlineModuleLocation = "$($Script:BuildEnv.ModuleWebsite)/tree/master/docs"

		$FwLink = "$($OnlineModuleLocation)/docs/Functions/$($Script:BuildEnv.ModuleToBuild).md"
		$ProjectDocPath = Join-Path -Path $BuildRoot -ChildPath 'docs\Functions\'

		# Create the function .md files for the core project documentation
		$null = New-MarkdownHelp -module $Script:BuildEnv.ModuleToBuild -OutputFolder $ProjectDocPath -Force -Locale 'en-US' -FwLink $FwLink -HelpVersion $Script:BuildEnv.ModuleVersion -Encoding ([Text.Encoding]::($Script:BuildEnv.Encoding)) #-OnlineVersionUrl "$($Script:BuildEnv.ModuleWebsite)/docs/Functions"
	}
	else 
	{
		Write-Build Yellow 'There is no current release to pull the documents from. First build the project at least once.' -Level 2
	}
}

# Synopsis: Build the markdown help for the functions using PlatyPS for the core project docs.
task BuildProjectHelpFiles {
	Write-Description White 'Creating markdown documentation with PlatyPS for the core project' -accent
	$OnlineModuleLocation = "$($Script:BuildEnv.ModuleWebsite)/$($Script:BuildEnv.BaseReleaseFolder)"
	$FwLink = "$($OnlineModuleLocation)/docs/Functions/$($Script:BuildEnv.ModuleToBuild).md"

	# Create the function .md files for the core project documentation
	$null = New-MarkdownHelp -module $Script:BuildEnv.ModuleToBuild -OutputFolder "$($BuildRoot)\docs\Functions\" -Force -Locale 'en-US' -FwLink $FwLink -HelpVersion $Script:BuildEnv.ModuleVersion -Encoding ([Text.Encoding]::($Script:BuildEnv.Encoding)) #-OnlineVersionUrl "$($Script:BuildEnv.ModuleWebsite)/docs/Functions"
}

# Synopsis: Add additional doc files to the final project document folder
task AddAdditionalDocFiles {
	Write-Description White 'Add additional doc files to the project document folder' -accent

	$BuildDocsPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.BuildToolFolder)\docs\"
	Copy-Item -Path (Join-Path -Path $BuildDocsPath -ChildPath 'Additional\*.md') -Destination (Join-Path -Path $BuildRoot -ChildPath 'docs') -Force
}

# Synopsis: Update ReadTheDocs project documentation
task UpdateReadTheDocs -if {
	$Script:BuildEnv.OptionGenerateReadTheDocs
} {
	Write-Description White 'Copy ReadTheDocs markdown files to project root document folder' -accent

	$BuildDocsPath = Join-Path -Path $BuildRoot -ChildPath "$($Script:BuildEnv.BuildToolFolder)\docs\"
	$ProjectDocsPath = Join-Path -Path $BuildRoot -ChildPath 'docs'
	$ReadTheDocsPath = Join-Path -Path $BuildDocsPath -ChildPath 'ReadTheDocs'
	$DocsReleasePath = Join-Path -Path $Script:BuildEnv.BaseReleaseFolder -ChildPath $Script:BuildEnv.ModuleToBuild

	$RTDFolders = Get-ChildItem -Path $ReadTheDocsPath -Directory | Sort-Object -Property Name

	ForEach ($RTDFolder in $RTDFolders) 
	{
		# First copy over to our project document root
		Copy-Item -Path $RTDFolder.FullName -Destination $ProjectDocsPath -Force -Recurse
	}
}

# Synopsis: Build ReadTheDocs yml file
task CreateReadTheDocsYML -if {
	$Script:BuildEnv.OptionGenerateReadTheDocs
} Configure, {
	Write-Description White 'Create ReadTheDocs definition file and saving to the root project site.' -accent

	$DocsReleasePath = Join-Path -Path $Script:BuildEnv.BaseReleaseFolder -ChildPath $Script:BuildEnv.ModuleToBuild
	$ProjectDocsPath = Join-Path -Path $BuildRoot -ChildPath 'docs'

	$YMLFile = Join-Path -Path $BuildRoot -ChildPath 'mkdocs.yml'

	try
	{
		$Pages = [ordered]@{}

		$RTDFolders = Get-ChildItem -Path $ProjectDocsPath -Directory | Sort-Object -Property Name
		$RTDPages = Get-ChildItem -Path $ProjectDocsPath -File -Filter '*.md' | Sort-Object -Property Name

		ForEach ($RTDFolder in $RTDFolders) 
		{
			$RTDocs = @(Get-ChildItem -Path $RTDFolder.FullName -Filter '*.md' | Sort-Object -Property Name)
			if ($RTDocs.Count -gt 1) 
			{
				$NewSection = @()
				Foreach ($RTDDoc in $RTDocs) 
				{
					$NewSection += @{
						$RTDDoc.Basename = "$($RTDFolder.Name)\$($RTDDoc.Name)"
					}
				}
				$Pages[$RTDFolder.Name] = $NewSection
			}
			else 
			{
				$Pages[$RTDFolder.Name] = "$($RTDFolder.Name)\$($RTDocs.Name)"
			}
		}

		ForEach ($RTDPage in $RTDPages) 
		{
			$Pages[$RTDPage.BaseName] = $RTDPage.Name
		}

		$RTD = @{
			site_name   = "$($Script:BuildEnv.ModuleToBuild) Docs"
			repo_url    = $Script:BuildEnv.ModuleWebsite
			site_author = $Script:BuildEnv.ModuleAuthor
			edit_uri    = 'edit/master/docs/'
			theme       = 'readthedocs'
			copyright   = "$($Script:BuildEnv.ModuleToBuild) is licensed under the <a href='$($Script:BuildEnv.ModuleWebsite)/master/LICENSE.md'> license"
			Pages       = $Pages
		}

		$RTD | ConvertTo-Yaml | Out-File -Encoding $Script:BuildEnv.Encoding -FilePath $YMLFile -Force
	}
	catch 
	{
		Write-Warning -Message "Skipping ReadTheDocs manifest file creation as it already exists. Please remove the following file if you want it to be regenerated: $YMLFile"
	}
}

# Synopsis: Put together all the various projecet help files
task CreateProjectHelp BuildProjectHelpFiles, AddAdditionalDocFiles, UpdateReadTheDocs, CreateReadTheDocsYML

# Synopsis: Push the current release of the project to PSScriptGallery
task PublishPSGallery LoadBuildTools, InstallModule, {
	Write-Description White 'Publishing recent module release to the PowerShell Gallery' -accent

	$ReleasePath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BaseReleaseFolder
	$CurrentReleasePath = Join-Path -Path $ReleasePath -ChildPath $Script:BuildEnv.ModuleToBuild
	if (Get-Module -Name $Script:BuildEnv.ModuleToBuild) 
	{
		# If the module is already loaded then unload it.
		Remove-Module -Name $Script:BuildEnv.ModuleToBuild
	}

	# Try to import the current module
	$CurrentModule = Join-Path -Path $CurrentReleasePath -ChildPath "$($Script:BuildEnv.ModuleToBuild).psd1"
	if (Test-Path $CurrentModule) 
	{
		Import-Module -Name $CurrentModule

		Write-Description White "Uploading project to PSGallery: $($Script:BuildEnv.ModuleToBuild)"
		Upload-ProjectToPSGallery -Name $Script:BuildEnv.ModuleToBuild -NuGetApiKey $Script:BuildEnv.NuGetApiKey
	}
	else 
	{
		Write-Warning -Message "Unable to publish the module as a current release is not available in $CurrentModule"
	}
}

# Synopsis: Install the current built module to the local machine
task InstallModule VersionCheck, {
	Write-Description White 'Attempting to install the current module' -accent
	$CurrentModulePath = Join-Path -Path $Script:BuildEnv.BaseReleaseFolder -ChildPath $Script:BuildEnv.ModuleVersion
	assert (Test-Path $CurrentModulePath) 'The current version module has not been built yet!'

	$MyModulePath = "$($env:USERPROFILE)\Documents\WindowsPowerShell\Modules\"
	$ModuleInstallPath = "$($MyModulePath)$($Script:BuildEnv.ModuleToBuild)"
	if (Test-Path $ModuleInstallPath) 
	{
		Write-Description White "Removing installed module $($Script:BuildEnv.ModuleToBuild)" -Level 2
		$null = (Remove-Item -Path $ModuleInstallPath -Recurse -Force)
		assert (-not (Test-Path $ModuleInstallPath)) 'Module already installed and you opted not to remove it. Cancelling install operation!'
	}

	Write-Description White 'Installing current module:' -Level 2
	Write-Description White "Source - $($CurrentModulePath)" -Level 3
	Write-Description White "Destination - $($ModuleInstallPath)" -Level 3
	$null = (Copy-Item -Path $CurrentModulePath -Destination $ModuleInstallPath -Recurse)
	$null = (Get-Module -ListAvailable -Refresh)
}

# Synopsis: Test import the current module
task TestInstalledModule VersionCheck, {
	Write-Description White "Test importing the current module version $($Script:BuildEnv.ModuleVersion)" -accent

	$InstalledModules = @(Get-Module -ListAvailable -Name $Script:BuildEnv.ModuleToBuild)
	assert ($InstalledModules.Count -gt 0) 'Unable to find that the module is installed!'
	if ($InstalledModules.Count -gt 1) 
	{
		Write-Warning -Message 'There are multiple installed modules found for this project (shown below). Be aware that this may skew the test results: '
	}
	Import-Module -Name $Script:BuildEnv.ModuleToBuild -MinimumVersion $Script:BuildEnv.ModuleVersion -Force
}

# Synopsis: Run pre-build scripts (such as other builds)
task PreBuildTasks {
	Write-Description White 'Running any Pre-Build scripts' -accent
	$BuildToolPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BuildToolFolder
	$PreBuildPath = Join-Path -Path $BuildToolPath -ChildPath 'startup'
	# Dot source any pre build scripts.
	Get-ChildItem -Path $PreBuildPath -Recurse -Filter '*.ps1' -File | ForEach-Object -Process {
		Write-Description White "Dot sourcing pre-build script file: $($_.Name)" -level 2
		. $_.FullName
	}
}

# Synopsis: Remove session artifacts like loaded modules and variables
task BuildSessionCleanup {
	Write-Description White 'Cleaning up the build session' -accent

	$BuildToolPath = Join-Path -Path $BuildRoot -ChildPath $Script:BuildEnv.BuildToolFolder
	# Clean up loaded modules if they are loaded
	Write-Description White 'Removing modules' -Level 2
	$Script:RequiredModules | ForEach-Object -Process {
		Write-Description White "Removing $($_) module (if loaded)." -Level 3
		Remove-Module $_ -ErrorAction Ignore
	}

	Write-Description White "Removing $($Script:BuildEnv.ModuleToBuild) module  (if loaded)." -Level 3
	Remove-Module -Name $Script:BuildEnv.ModuleToBuild -ErrorAction Ignore

	# Dot source any post build cleanup scripts.
	Write-Description White 'Runing post-build scripts' -Level 2
	$CleanupPath = Join-Path -Path $BuildToolPath -ChildPath 'shutdown'
	Get-ChildItem -Path $CleanupPath -Recurse -Filter '*.ps1' -File | ForEach-Object -Process {
		Write-Description White "Dot sourcing shutdown script file: $($_.Name)" -Level 3
		. $_.FullName
	}
	if ($Script:BuildEnv.OptionTranscriptEnabled) 
	{
		Stop-Transcript -WarningAction:Ignore
	}
}

# Synopsis: Push with a version tag.
task GitPushRelease VersionCheck, {
	$changes = exec {
		git.exe status --short
	}
	assert (-not $changes) 'Please, commit changes.'

	exec {
		git.exe push
	}
	exec {
		git.exe tag -a "v$($Script:BuildEnv.ModuleVersion)" -m "v$($Script:BuildEnv.ModuleVersion)"
	}
	exec {
		git.exe push origin "v$($Script:BuildEnv.ModuleVersion)"
	}
}

# Synopsis: Push to github
task GithubPush VersionCheck, {
	exec {
		git.exe add .
	}
	if ($ReleaseNotes -ne $null) 
	{
		exec {
			git.exe commit -m "$ReleaseNotes"
		}
	}
	else 
	{
		exec {
			git.exe commit -m "$($Script:BuildEnv.ModuleVersion)"
		}
	}
	exec {
		git.exe push origin master
	}
	$changes = exec {
		git.exe status --short
	}
	assert (-not $changes) 'Please, commit changes.'
}

# Synopsis: Install and test load the module.
task InstallAndTestModule InstallModule, TestInstalledModule

# Synopsis: The default build
task . Configure, Clean, PrepareStage, GetPublicFunctions, SanitizeCode, CreateHelp, CreateModulePSM1, CreateModuleManifest, AnalyzeModuleRelease, PushVersionRelease, PushCurrentRelease, CreateProjectHelp, BuildSessionCleanup

# Synopsis: Instert Comment Based Help where it doesn't already exist (output to scratch directory)
task InsertMissingCBH Configure, Clean, UpdateCBHtoScratch, BuildSessionCleanup
