#requires -Version 3.0

<#
    .SYNOPSIS
    List all active Lync/Skype for Business conferences
	
    .DESCRIPTION
    List all active Lync/Skype for Business conferences
	
    .PARAMETER FrontendPool
    Please enter the Lync/Skype for Business Frontend Pool FQDN
	
    .EXAMPLE
    PS C:\> .\Get-CsActiveConferences.ps1 -FrontendPool 'atl-cs-001.litwareinc.com'
	
    .NOTES
    Originally written by Richard Brynteson

    .LINK
    https://masteringlync.com/2013/11/19/list-all-active-conferences-via-powershell/
#>
[CmdletBinding(ConfirmImpact = 'None',
SupportsShouldProcess)]
param
(
  [Parameter(Mandatory,
      ValueFromPipeline,
      ValueFromPipelineByPropertyName,
      Position = 1,
  HelpMessage = 'Please enter the Frontend Pool FQDN')]
  [ValidateNotNullOrEmpty()]
  [Alias('PoolFQDN')]
  [string]
  $FrontendPool
)

begin
{
  # Convert UTC to Local timezone
  function Convert-UTCtoLocal
  {
    <#
        .SYNOPSIS
        Convert UTC to Local timezone
	
        .DESCRIPTION
        Convert UTC to Local timezone
	
        .PARAMETER UTCTime
        UTC Time Format datetime
	
        .EXAMPLE
        PS C:\> Convert-UTCtoLocal -UTCTime Value
        Convert UTC to Local timezone
	
        .OUTPUTS
        datetime
	
        .INPUTS
        datetime

        .NOTES
        Just a small internal Helper Script
    #>
		
    [CmdletBinding(ConfirmImpact = 'None')]
    [OutputType([datetime])]
    param
    (
      [Parameter(Mandatory,
          ValueFromPipeline,
          ValueFromPipelineByPropertyName,
          Position = 1,
      HelpMessage = 'UTC Time Format datetime')]
      [ValidateNotNullOrEmpty()]
      [datetime]
      $UTCTime
    )
		
    begin
    {
      # Cleanup
      $LocalTime = $null
    }
		
    process
    {
      # Transform the Format
      $paramGetWmiObject = @{
        Class         = 'win32_timezone'
        ErrorAction   = 'Stop'
        WarningAction = 'SilentlyContinue'
      }
      $strCurrentTimeZone = ((Get-WmiObject @paramGetWmiObject).StandardName)
      $TZ = [TimeZoneInfo]::FindSystemTimeZoneById($strCurrentTimeZone)
      $LocalTime = [TimeZoneInfo]::ConvertTimeFromUtc($UTCTime, $TZ)
    }
		
    end
    {
      # Dump it
      return $LocalTime
    }
  }
	
  # Create a Dummy Object
  $Results = @()
}

process
{
  if ($pscmdlet.ShouldProcess('FrontendPool', 'Get A List of Computers that are members'))
  {
    try
    {
      # Cleanup
      $FrontendPoolComputers = $null
			
      # Get all member servers of the Lync pool
      $paramGetCsPool = @{
        Identity      = $FrontendPool
        ErrorAction   = 'Stop'
        WarningAction = 'SilentlyContinue'
      }
      $FrontendPoolComputers = ((Get-CsPool @paramGetCsPool).Computers)
    }
    catch
    {
      # Get error record
      [Management.Automation.ErrorRecord]$e = $_
			
      # Retrieve information about the error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
			
      # Do some verbose stuff for troubleshooting
      $info | Out-String | Write-Verbose
			
      # Thow the error and go...
      Write-Error -Message "$info.Exception" -ErrorAction Stop
			
      # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
      break
			
      # OK, now we have reached a point the we would never, never ever, see
      exit 1
    }
		
    if (-not $FrontendPoolComputers)
    {
      # Get error record
      [Management.Automation.ErrorRecord]$e = $_
			
      # Retrieve information about the error
      $info = [PSCustomObject]@{
        Exception = $e.Exception.Message
        Reason    = $e.CategoryInfo.Reason
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
      }
			
      # Do some verbose stuff for troubleshooting
      $info | Out-String | Write-Verbose
			
      # Thow the error and go...
      Write-Error -Message 'No members of the Lync Pool found...' -ErrorAction Stop
			
      # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
      break
			
      # OK, now we have reached a point the we would never, never ever, see
      exit 1
    }
  }
	
  if ($pscmdlet.ShouldProcess('FrontendPool', 'Get A List of Computers that are members'))
  {
    #Loop Through Front-End Pool
    foreach ($Computer in $FrontendPoolComputers)
    {
      try
      {
        # Create the Object with a SQL command
        $paramInvokeSQLCmd = @{
          ServerInstance = "$Computer\rtclocal"
          Database       = 'rtcdyn'
          Query          = "SELECT ActiveConference.ConfId AS 'Conference ID', ActiveConference.Locked, Participant.UserAtHost AS  'Participant', Participant.JoinTime AS 'Join Time', Participant.EnterpriseId, ActiveConference.IsLargeMeeting AS 'Large Meeting' FROM   ActiveConference INNER JOIN Participant ON ActiveConference.ConfId = Participant.ConfId;"
          ErrorAction    = 'Stop'
          WarningAction  = 'SilentlyContinue'
        }
        $Result = (Invoke-SQLCmd @paramInvokeSQLCmd)
        $Result | Add-Member -NotePropertyName 'Frontend' -NotePropertyValue $Computer
        $Result.'Join Time' = Convert-UTCtoLocal -UTCTime $Result.'Join Time'
				
        # Append
        $Results += $Result
      }
      catch
      {
        # Get error record
        [Management.Automation.ErrorRecord]$e = $_
				
        # Retrieve information about the error
        $info = [PSCustomObject]@{
          Exception = $e.Exception.Message
          Reason    = $e.CategoryInfo.Reason
          Target    = $e.CategoryInfo.TargetName
          Script    = $e.InvocationInfo.ScriptName
          Line      = $e.InvocationInfo.ScriptLineNumber
          Column    = $e.InvocationInfo.OffsetInLine
        }
				
        # Do some verbose stuff for troubleshooting
        $info | Out-String | Write-Verbose
				
        # A simple warning is OK here
        Write-Warning -Message "$info.Exception" -WarningAction Continue -ErrorAction Continue
      }
    }
  }
}

end
{
  if ($Results)
  {
    # Dump it
    $Results
  }
  else
  {
    # Thow the error and go...
    Write-Error -Message 'No Results found!' -ErrorAction Stop
		
    # This is a point the code should never reach (You told PowerShell to Ignore the ErrorAction above!)
    break
		
    # OK, now we have reached a point the we would never, never ever, see
    exit 1
  }
}