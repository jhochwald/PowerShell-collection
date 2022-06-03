#region Remediation
$MMAgentSetup = (Get-MMAgent -ErrorAction SilentlyContinue)

If ($MMAgentSetup.ApplicationPreLaunch -ne $true)
{
   exit 1
}

If ($MMAgentSetup.MaxOperationAPIFiles -lt 8192)
{
   exit 1
}

If ($MMAgentSetup.MemoryCompression -ne $true)
{
   exit 1
}

If ($MMAgentSetup.PageCombining -ne $true)
{
   exit 1
}

exit 0
#endregion Remediation

