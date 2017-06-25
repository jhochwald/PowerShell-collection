<#
	Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it 
	will work in testing and after being built
#>
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable -Name MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path -Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))

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
#endregion Module Cleanup

# Non-function exported public module members might go here.
#Export-ModuleMember -Variable SomeVariable -Function  *

# This file cannot be completely empty. Even leaving this comment is good enough.
