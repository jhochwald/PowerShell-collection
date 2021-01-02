## Pre-Loaded Module code ##

<#
 Put all code that must be run prior to function dot sourcing here.

 This is a good place for module variables as well. The only rule is that no 
 variable should rely upon any of the functions in your module as they 
 will not have been loaded yet. Also, this file cannot be completely
 empty. Even leaving this comment is good enough.
#>

## PRIVATE MODULE FUNCTIONS AND DATA ##

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]$SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]$Name
    )

    begin {
        $filterHash = @{}
    }
    
    process {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator()) {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name))) {
                
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable) {
                    if ($SessionState -eq $ExecutionContext.SessionState) {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered') {
            foreach ($varName in $filterHash.Keys) {
                if (-not $vars.ContainsKey($varName)) {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }
    }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

function Get-ExchangeAdminExecution
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Get-ExchangeAdminExecution.md
    #>
	
	[CmdletBinding()]
	param ()
	
	If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator'))
	{
		$paramWriteError = @{
			Message     = 'You need to start the PowerShell session as Admin (Elevated)'
			ErrorAction = 'Stop'
		}
		Write-Error @paramWriteError
	}
	else
	{
		Write-Verbose -Message 'OK, you are Admin and the shell is elevated...'
	}
}



function Get-ExchangeExecutionPolicy
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Get-ExchangeExecutionPolicy.md
    #>
	
	[CmdletBinding()]
	param ()
	
	# Define some defaults
	$SC = 'SilentlyContinue'

	# Cleanup
	$ExecutionPolicy = $null
	
	# Get the Infos
	$paramGetExecutionPolicy = @{
		ErrorAction   = $SC
		WarningAction = $SC
	}
	$ExecutionPolicy = (Get-ExecutionPolicy @paramGetExecutionPolicy)

	if ((-not ($ExecutionPolicy -eq 'Bypass')) -or (-not ($ExecutionPolicy -eq 'Bypass')))
	{
		$paramWriteError = @{
			Message     = "Your PowerShell Execution Policy is $ExecutionPolicy and it should be Unrestricted or Bypass"
			ErrorAction = 'Stop'
		}
		Write-Error @paramWriteError 
	}
	else 
	{
		Write-Verbose -Message "Your Execution Policy is $ExecutionPolicy"
	}
}



function Invoke-ApplyExchangeCumulativeUpdate
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Invoke-ApplyExchangeCumulativeUpdate.md
    #>
	
	[CmdletBinding(ConfirmImpact = 'Medium',
	SupportsShouldProcess = $true)]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$Source = 'E:\',
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 2)]
		[switch]
		$Prepare = $true,
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 3)]
		[switch]
		$UMLangHandling = $null,
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 4)]
		[string]
		$UMLangSource = 'F:\',
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 5)]
		[string]
		$UMLanguages = 'de-DE,en-GB'
	)
	
	BEGIN
	{

		# Are we admin and elevated?
		if (Get-Command -Name Get-ExchangeAdminExecution -ErrorAction SilentlyContinue) 
		{
			try 
			{
				if ($pscmdlet.ShouldProcess('PowerShell Session', 'Check if execution is elevated'))
				{
					Get-ExchangeAdminExecution
				}
			}
			catch 
			{
				break
			}
		}
		else 
		{
			Write-Warning -Message 'Unable to check if this is an elevated Session!'
			break
		}

		# Check the Exeution Policy
		if (Get-Command -Name Get-ExchangeExecutionPolicy -ErrorAction SilentlyContinue) 
		{
			try 
			{
				if ($pscmdlet.ShouldProcess('PowerShell Session', 'Check Execution Policy'))
				{
					Get-ExchangeExecutionPolicy
				}
			}
			catch 
			{
				break
			}
		}
		else 
		{
			Write-Warning -Message 'Unable to check your PowerShell Execution Policy. Please do it by yourself!' -ErrorAction Stop
			break
		}

		# Check if the given Directory conains the setup
		if ($UMLangHandling)
		{
			# Check if the given directory exists
			If (-not (Test-Path -Path $UMLangSource -ErrorAction Stop))
			{
				Write-Error -Message "The given Directory ($UMLangSource) does NOT exist!" -ErrorAction Stop
				break
			}
		}
		
		if ($Prepare)
		{
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			if ($pscmdlet.ShouldProcess('AD Schema', 'Prepare'))
			{
				Write-Verbose -Message 'Prepare AD Schema'
				.\Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
			}

			if ($pscmdlet.ShouldProcess('Active Directory', 'Prepare'))
			{
				Write-Verbose -Message 'Prepare AD'
				.\Setup.exe /PrepareAD /IAcceptExchangeServerLicenseTerms
			}

			if ($pscmdlet.ShouldProcess('Active Directory Domain', 'Prepare'))
			{
				Write-Verbose -Message 'Prepare AD Domain'
				.\Setup.exe /PrepareDomain /IAcceptExchangeServerLicenseTerms
			}

			# Return
			Pop-Location
		}
	}
	
	PROCESS
	{
		if ($UMLangHandling)
		{
			# Remove the old UM Languages
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			if ($pscmdlet.ShouldProcess('UM Language Pack(s)', 'Remove'))
			{
				Write-Verbose -Message 'Remove UM Language Pack'
				.\Setup.exe /RemoveUMLanguagePack:$UMLanguages
			}

			# Return
			Pop-Location
		}
		
		# Default installation
		# Change to the Installer location
		Push-Location -Path $Source
			
		# Start the Setup
		if ($pscmdlet.ShouldProcess('Exchange Installation', 'upgrade'))
		{
			Write-Verbose -Message 'Start the Update: Now is the perfect time to get yourself a coffee...'
			.\Setup.exe /m:upgrade /IAcceptExchangeServerLicenseTerms
		}
		
			
		# Return
		Pop-Location
		
		if ($UMLangHandling)
		{
			#
			# Change to the Installer location
			Push-Location -Path $Source
			
			# Start the Setup
			if ($pscmdlet.ShouldProcess('UM language(s)', "Installation of $UMLanguages from $UMLangSource"))
			{
				Write-Verbose -Message 'Ok, now we update the UM language(s).'
				#.\Setup.exe /AddUMLanguagePack:$UMLanguages /s:$UMLangSource /IAcceptExchangeServerLicenseTerms
				Write-Warning -Message 'The UM language pack installation is delayed! In most cases a reboot if needed before installing these.'
				Write-Output -InputObject "Please reboot an then execute this command: .\Setup.exe /AddUMLanguagePack:$UMLanguages /s:$UMLangSource /IAcceptExchangeServerLicenseTerms"
			}

			# Return
			Pop-Location
		}
	}
	
	END
	{
		# Cleanup will come soon.
		Write-Verbose -Message 'You are a hero! You have updated your Exchange Node.'
	}
}



function Invoke-Exchange2016Workaround
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Invoke-Exchange2016Workaround.md
    #>
	
	$paramGetCommand = @{
		Name          = 'Get-MailboxDatabaseCopyStatus'
		ErrorAction   = 'SilentlyContinue'
		WarningAction = 'SilentlyContinue'
	}
	if (-not (Get-Command @paramGetCommand )) 
	{
		try 
		{
			$paramAddPSSnapin = @{
				Name = 'Microsoft.Exchange.Management.PowerShell.SnapIn'
			}
			Add-PSSnapin @paramAddPSSnapin
		}
		catch 
		{
			$paramWriteError = @{
				Message       = 'Sure that this is a Exchange Server?'
				ErrorAction   = 'Stop'
				WarningAction = 'SilentlyContinue'
			}
			Write-Error @paramWriteError 
		}
	}
}



function Restart-ExchangeClusterNode
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Restart-ExchangeClusterNode.md
    #>
	
	[CmdletBinding(ConfirmImpact = 'Low',
	SupportsShouldProcess = $true)]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	PROCESS
	{
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Enable Maintenance Mode'))
		{
			try
			{
				$EnableMaintenanceMode = $null
				
				if (Get-Command -Name Set-ExchangeNodeMaintenanceModeOn -ErrorAction SilentlyContinue) 
				{
					try 
					{
						$paramSetExchangeNodeMaintenanceModeOn = @{
							ComputerName  = $ComputerName
							Confirm       = $false
							ErrorAction   = 'Stop'
							WarningAction = 'SilentlyContinue'
						}
						$EnableMaintenanceMode = (Set-ExchangeNodeMaintenanceModeOn @paramSetExchangeNodeMaintenanceModeOn)
					}
					catch 
					{
						break
					}
				}
			}
			catch
			{
				$paramWriteError = @{
					Message     = "Unable to activate Maintenance Mode on $ComputerName"
					ErrorAction = 'Stop'
				}
				Write-Error @paramWriteError 
				break
			}
		}
		
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Reboot'))
		{
			if ($EnableMaintenanceMode)
			{
				$paramRestartComputer = @{
					ComputerName  = $ComputerName
					Force         = $true
					Confirm       = $false
					ErrorAction   = 'SilentlyContinue'
					WarningAction = 'SilentlyContinue'
				}
				Restart-Computer @paramRestartComputer 
			}
		}
	}
}



function Set-ExchangeNodeMaintenanceModeOff
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Set-ExchangeNodeMaintenanceModeOff.md
    #>
	
	[CmdletBinding(ConfirmImpact = 'Low',
	SupportsShouldProcess = $true)]
	[OutputType([bool])]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate Maintenance'))
		{
			if (Get-Command -Name Invoke-Exchange2016Workaround -ErrorAction SilentlyContinue) 
			{
				try 
				{
					Invoke-Exchange2016Workaround
				}
				catch 
				{
					break
				}
			}
		}

		# Are we admin and elevated?
		if (Get-Command -Name Get-ExchangeAdminExecution -ErrorAction SilentlyContinue) 
		{
			try 
			{
				if ($pscmdlet.ShouldProcess('PowerShell Session', 'Check if execution is elevated'))
				{
					Get-ExchangeAdminExecution
				}
			}
			catch 
			{
				break
			}
		}
		else 
		{
			Write-Warning -Message 'Unable to check if this is an elevated Session!'
			break
		}
	}
	
	Process
	{
		try
		{
			# Activate the components
			$paramSetServerComponentState = @{
				identity  = $ComputerName
				Component = 'ServerWideOffline'
				State     = 'Active'
				Requester = 'Maintenance'
			}
			if ($pscmdlet.ShouldProcess("$ComputerName", 'Deactivate Maintenance'))
			{
				$null = (Set-ServerComponentState @paramSetServerComponentState)
			}
			
			# Activate the Cluster Node
			$paramResumeClusterNode = @{
				Name          = $ComputerName
				ErrorAction   = 'Stop'
				WarningAction = 'SilentlyContinue'
			}
			if ($pscmdlet.ShouldProcess("$ComputerName", 'Resume Cluster Node'))
			{
				$null = (Resume-ClusterNode @paramResumeClusterNode)
			}
			
			# Activate the Databases
			$paramSetMailboxServer = @{
				identity                                 = $ComputerName
				DatabaseCopyAutoActivationPolicy         = 'Unrestricted'
				DatabaseCopyActivationDisabledAndMoveNow = $false
				ErrorAction                              = 'Stop'
				WarningAction                            = 'SilentlyContinue'
			}
			if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate default MailboxServer operation'))
			{
				$null = (Set-MailboxServer @paramSetMailboxServer)
			}
		}
		catch
		{
			return $false
		}

		# Default
		return $true
	}
}



function Set-ExchangeNodeMaintenanceModeOn
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Set-ExchangeNodeMaintenanceModeOn.md
    #>
	
	[CmdletBinding(ConfirmImpact = 'Low',
	SupportsShouldProcess = $true)]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate Maintenance'))
		{
			if (Get-Command -Name Invoke-Exchange2016Workaround -ErrorAction SilentlyContinue) 
			{
				try 
				{
					Invoke-Exchange2016Workaround
				}
				catch 
				{
					break
				}
			}
		}

		# Are we admin and elevated?
		if (Get-Command -Name Get-ExchangeAdminExecution -ErrorAction SilentlyContinue) 
		{
			try 
			{
				if ($pscmdlet.ShouldProcess('PowerShell Session', 'Check if execution is elevated'))
				{
					Get-ExchangeAdminExecution
				}
			}
			catch 
			{
				break
			}
		}
		else 
		{
			Write-Warning -Message 'Unable to check if this is an elevated Session!'
			break
		}
	}
	
	Process
	{
		# Draining the server
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Draining'
			Requester = 'Maintenance'
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Set-ServerComponentState'))
		{
			$null = (Set-ServerComponentState @paramSetServerComponentState)
		}
		
		# Restart of the Sertvices enforces the draining
		$paramRestartService = @{
			Name          = 'MSExchangeTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Restart MSExchangeTransport Service'))
		{
			$null = (Restart-Service @paramRestartService)
		}
		
		$paramRestartService = @{
			Name          = 'MSExchangeFrontEndTransport'
			Force         = $true
			ErrorAction   = 'SilentlyContinue'
			WarningAction = 'SilentlyContinue'
			Confirm       = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Restart MSExchangeFrontEndTransport Service'))
		{
			$null = (Restart-Service @paramRestartService)
		}
		
		# Suspend the cluster node
		$paramSuspendClusterNode = @{
			Name    = $ComputerName
			Confirm = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Suspend-ClusterNode'))
		{
			$null = (Suspend-ClusterNode @paramSuspendClusterNode)
		}
		
		# Move all databases to the other servers
		$paramSetMailboxServer = @{
			identity                                 = $ComputerName
			DatabaseCopyActivationDisabledAndMoveNow = $true
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Set-MailboxServer'))
		{
			$null = (Set-MailboxServer @paramSetMailboxServer)
		}
		
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Get-ClusterNode'))
		{
			# Get the Cluster Twin
			$PartnerNode = (Get-ClusterNode | Where-Object -FilterScript {
					$_.Name -ne $ComputerName
			} | Select-Object -ExpandProperty name)
		}
		
		$paramResolveDnsName = @{
			Name = $PartnerNode
			Type = 'A'
		}
		if ($pscmdlet.ShouldProcess("$ComputerName Node Partner", 'Resolve-DnsName'))
		{
			$PartnerNodeFQDN = ((Resolve-DnsName @paramResolveDnsName).name)
		}
		
		$paramSetServerComponentState = @{
			identity  = $ComputerName
			Component = 'ServerWideOffline'
			State     = 'Inactive'
			Requester = 'Maintenance'
		}
		if ($pscmdlet.ShouldProcess("$ComputerName", 'Activate Maintenance'))
		{
			$null = (Set-ServerComponentState @paramSetServerComponentState)
		}
		
		$paramRedirectMessage = @{
			Server  = $ComputerName
			Target  = $PartnerNodeFQDN
			Confirm = $false
		}
		if ($pscmdlet.ShouldProcess("$ComputerName Cluster Partner", 'Redirect'))
		{
			$null = (Redirect-Message @paramRedirectMessage)
		}
	}
}



function Test-ExchangeNodeMaintenanceMode
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/ExchangeNodeMaintenanceMode/tree/master/release/1.0.0.19/docs/Functions/Test-ExchangeNodeMaintenanceMode.md
    #>
	
	[OutputType([bool])]
	param
	(
		[Parameter(ValueFromPipeline = $true,
				ValueFromPipelineByPropertyName = $true,
		Position = 1)]
		[ValidateNotNullOrEmpty()]
		[string]
		$ComputerName = $env:COMPUTERNAME
	)
	
	Begin
	{
		# Workaround for Exchange 2016 on Windows Server 2016
		Invoke-Exchange2016Workaround
		
		# Set the Default
		$IsFalse = $false
	}
	
	Process
	{
		# Wait until all databases are moved
		$paramGetMailboxDatabaseCopyStatus = @{
			server        = $ComputerName
			ErrorAction   = 'Stop'
			WarningAction = 'SilentlyContinue'
		}
		try
		{
			$ActiveDBs = $null
			$ActiveDBs = (Get-MailboxDatabaseCopyStatus @paramGetMailboxDatabaseCopyStatus | Where-Object -FilterScript {
					$_.Status -eq 'Mounted'
			})
		}
		catch
		{
			$IsFalse = $true
		}
		
		if ($ActiveDBs)
		{
			$IsFalse = $false
		}
		else
		{
			# Build the URL to check
			$URL = 'https://' + $ComputerName + '/owa/healthcheck.htm'
			
			# Ignore certificate warning (Will not match anyway)
			try 
			{
				Add-Type -TypeDefinition @'
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
'@
			}
			catch
			{
				Write-Verbose -Message 'Unable to add new Type'
			}
			
			$paramNewObject = @{
				TypeName      = 'TrustAllCertsPolicy'
				ErrorAction   = 'SilentlyContinue'
				WarningAction = 'SilentlyContinue'
			}
			
			[Net.ServicePointManager]::CertificatePolicy = (New-Object @paramNewObject)
			
			try
			{
				$result = $null
				
				# Get the result
				$paramInvokeWebRequest = @{
					Uri           = $URL
					ErrorAction   = 'Stop'
					WarningAction = 'SilentlyContinue'
				}
				$result = $null
				$result = (Invoke-WebRequest @paramInvokeWebRequest)
			}
			catch
			{
				$IsFalse = $true
			}
			
			# Check the result
			if ($result.StatusCode -eq '200')
			{
				$IsFalse = $false
			}
		}
	}
	
	End
	{
		# Default
		return $IsFalse
	}
}


## Post-Load Module code ##


# Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it will work in testing and after being built
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
        }
    }

    Get-ScriptPath
)

#region Module Cleanup
$ExecutionContext.SessionState.Module.OnRemove = {
    # Action to take if the module is removed
}

$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
}

# Use this in your scripts to check if the function is being called from your module or independantly.
$ThisModuleLoaded = $true

# Non-function exported public module members might go here.
#Export-ModuleMember -Variable SomeVariable -Function  *

# This file cannot be completely empty. Even leaving this comment is good enough.



