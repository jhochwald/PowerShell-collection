$LinkFilter = '*postman*.lnk'

#region Defaults
$SCT = 'SilentlyContinue'
#endregion Defaults

#region SetExecutionPolicy
$null = (Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force -ErrorAction $SCT)
$null = (Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass  -Force -ErrorAction $SCT)
#endregion SetExecutionPolicy

#region Cleanup
if ($LinkFilter) {
   $paramGetChildItem = @{
      Path          = [Environment]::GetFolderPath('Desktop')
      Filter        = $LinkFilter
      Force         = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $paramRemoveItem = @{
      Force         = $true
      ErrorAction   = $SCT
      WarningAction = $SCT
   }
   $null = (Get-ChildItem @paramGetChildItem | Remove-Item @paramRemoveItem)
   $paramGetChildItem = $null
   $paramRemoveItem = $null
}
#endregion Cleanup

