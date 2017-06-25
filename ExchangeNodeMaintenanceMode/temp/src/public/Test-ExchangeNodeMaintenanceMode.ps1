function Test-ExchangeNodeMaintenanceMode
{
	<#
    .EXTERNALHELP ExchangeNodeMaintenanceMode-help.xml
    .LINK
        https://github.com/jhochwald/PowerShell-collection/tree/master/release/1.0.0.7/docs/Functions/Test-ExchangeNodeMaintenanceMode.md
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
