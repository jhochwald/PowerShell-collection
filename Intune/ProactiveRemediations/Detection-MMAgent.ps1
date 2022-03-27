#region Check
$MMAgentSetup = (Get-MMAgent -ErrorAction SilentlyContinue)

If ($MMAgentSetup.ApplicationPreLaunch -ne $true)
{
   $null = (Enable-MMAgent -ApplicationPreLaunch -ErrorAction SilentlyContinue)
}

If ($MMAgentSetup.MaxOperationAPIFiles -lt 8192)
{
   $null = (Set-MMAgent -MaxOperationAPIFiles 8192 -ErrorAction SilentlyContinue)
}

If ($MMAgentSetup.MemoryCompression -ne $true)
{
   $null = (Enable-MMAgent -MemoryCompression -ErrorAction SilentlyContinue)
}

If ($MMAgentSetup.PageCombining -ne $true)
{
   $null = (Enable-MMAgent -PageCombining -ErrorAction SilentlyContinue)
}

return $true
#endregion Check