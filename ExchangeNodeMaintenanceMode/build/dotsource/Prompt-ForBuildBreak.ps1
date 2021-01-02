Function Script:Prompt-ForBuildBreak {
    param (
        [Parameter(Position=0)]
        [System.Object]$LastError,
        [Parameter(Position=1)]
        $CustomError = $null
    )
    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "End the build."
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Stop the build."
    $ContinueBuildPrompt = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    if (($host.ui.PromptForChoice('Stop the build?', 'Should the build stop here?', $ContinueBuildPrompt, 0)) -eq 0) {
        if ($CustomError -ne $null) {
            throw $CustomError
        }
        else {
            throw $LastError
        }
    }
    else {
        Write-Output "Contining the build process despite the following error:"
        if ($CustomError -ne $null) {
            Write-Output $CustomError
        }
        else {
            Write-Output $LastError.Exception
        }
    }
}