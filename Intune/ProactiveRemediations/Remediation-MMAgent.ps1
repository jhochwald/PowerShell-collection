#region Remediation
$MMAgentSetup = (Get-MMAgent -ErrorAction SilentlyContinue)

If ($MMAgentSetup.ApplicationPreLaunch -ne $true)
{
   return $false
}

If ($MMAgentSetup.MaxOperationAPIFiles -lt 8192)
{
   return $false
}

If ($MMAgentSetup.MemoryCompression -ne $true)
{
   return $false
}

If ($MMAgentSetup.PageCombining -ne $true)
{
   return $false
}

return $true
#endregion Remediation