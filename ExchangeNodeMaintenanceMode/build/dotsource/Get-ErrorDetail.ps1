function Get-ErrorDetail
{
  param
  (
    [Parameter(Mandatory,ValueFromPipeline)]
    $e
  )
  process
  {
    if ($e -is [Management.Automation.ErrorRecord])
    {
      [PSCustomObject]@{
        Reason    = $e.CategoryInfo.Reason
        Exception = $e.Exception.Message
        Target    = $e.CategoryInfo.TargetName
        Script    = $e.InvocationInfo.ScriptName
        Line      = $e.InvocationInfo.ScriptLineNumber
        Column    = $e.InvocationInfo.OffsetInLine
        Datum     = Get-Date
        User      = $env:USERNAME
      }
    }
  }
}