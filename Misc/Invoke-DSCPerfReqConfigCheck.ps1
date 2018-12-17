#requires -Version 2.0 -Modules CimCmdlets

function Invoke-DSCPerfReqConfigCheck
{
  <#
      .SYNOPSIS
      Perform Required Configuration Checks and suppress all outputs.

      .DESCRIPTION
      Run the DSCLocalConfigurationManager method PerformRequiredConfigurationChecks.

      .PARAMETER Silent
      The progress bar will be spressed. this is not the case by default.

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck
      True

      # Run without any error

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck -Silent
      True

      # Run without any error. Supress the progress bar.

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck
      False

      # The run had errors.

      .EXAMPLE
      PS C:\> Invoke-DSCPerfReqConfigCheck -Silent
      False

      # The run had errors. Supress the progress bar.

      .NOTES
      I do a lot of testing with several DSC configurations.
      I just want a TRUE or FALSE as return to see if its working, or not.
      You may guess why: I use this in a CI chain :-)

      You may want to have seperated EventLog entries for DSC (useful for the log-Resource):
      & "$env:windir\system32\wevtutil.exe" set-log 'Microsoft-Windows-Dsc/Analytic' /q:true /e:true
      & "$env:windir\system32\wevtutil.exe" set-log 'Microsoft-Windows-Dsc/Debug' /q:True /e:true

      I dedicate any and all copyright interest in this software to the public domain.
      I make this dedication for the benefit of the public at large and to the detriment of my heirs and successors.
      I intend this dedication to be an overt act of relinquishment in perpetuity of all present and future rights to this software under copyright law.

      .LINK
      Author http://jhochwald.com

      .LINK
      LICENSE http://unlicense.org

      .LINK
      Invoke-CimMethod
      Write-Verbose
      Get-WinEvent
  #>

  [OutputType([bool])]
  param
  (
    [Parameter(ValueFromPipeline,
    Position = 1)]
    [switch]
    $Silent = $null
  )

  BEGIN
  {
    $SC = 'SilentlyContinue'
		
    if ($Silent)
    {
      $ProgressPreference = $SC
    }
  }

  PROCESS
  {
    $InvokeCimMethodParams = @{
      Namespace     = 'root/Microsoft/Windows/DesiredStateConfiguration'
      ClassName     = 'MSFT_DSCLocalConfigurationManager'
      MethodName    = 'PerformRequiredConfigurationChecks'
      Arguments     = @{
        Flags = [uint32] 1
      }
      ErrorAction   = $SC
      WarningAction = $SC
    }

    try
    {
      $null = (Invoke-CimMethod @InvokeCimMethodParams)
			
      if ($Silent)
      {
        $ProgressPreference = $null
      }
    }
    catch
    {
      $paramWriteVerbose = @{
        Message       = "$_.Exception.Message - Line Number: $_.InvocationInfo.ScriptLineNumber"
        ErrorAction   = $SC
        WarningAction = $SC
      }
      Write-Verbose @paramWriteVerbose
    }

    $GetWinEventParams = @{
      LogName       = 'Microsoft-Windows-Dsc/*'
      ErrorAction   = $SC
      WarningAction = $SC
      Oldest        = $true
    }

    # TODO: That is fast, but the code looks bad!
    $SuccessResult = (Get-WinEvent @GetWinEventParams | Group-Object -Property {
        $_.Properties[0].value
    }).Group.LevelDisplayName -notcontains 'Error'
  }

  END
  {
    Return $SuccessResult
  }
}

Invoke-DSCPerfReqConfigCheck