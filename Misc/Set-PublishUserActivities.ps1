function Set-PublishUserActivities
{
  <#
      .SYNOPSIS
      Enable or Disable the collection of Activity History

      .DESCRIPTION
      Enable or Disable the collection of Activity History in Windows 10. The default is to disable it!

      .PARAMETER enable
      Enable the collection of Activity History in Windows 10

      .EXAMPLE
      PS C:\> Set-PublishUserActivities

      Disable the collection of Activity History in Windows 10

      .EXAMPLE
      PS C:\> Set-PublishUserActivities -enable

      Enable the collection of Activity History in Windows 10

      .NOTES
      Quick and diry function

      .LINK
      https://lifehacker.com/windows-10-collects-activity-data-even-when-tracking-is-1831054394

      .LINK
      https://www.tenforums.com/tutorials/100341-enable-disable-collect-activity-history-windows-10-a.html#option2s2
  #>
  [CmdletBinding(ConfirmImpact = 'None',
  SupportsShouldProcess)]
  param
  (
    [Parameter(ValueFromPipeline,
        ValueFromPipelineByPropertyName,
    Position = 1)]
    [switch]
    $enable = $false
  )

  begin
  {
    $RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
    $RegistryName = 'PublishUserActivities'

    if ($enable)
    {
      $RegistryValue = '1'
      $SetAction = 'Enable'
      Write-Verbose -Message 'Enable the collection of Activity History'
    }
    else
    {
      $RegistryValue = '0'
      $SetAction = 'Disable'
      Write-Verbose -Message 'Disable the collection of Activity History'
    }
  }

  process
  {
    if ($pscmdlet.ShouldProcess('Collection of Activity History', $SetAction))
    {
      try
      {
        $SetPublishUserActivitiesParams = @{
          Path          = $RegistryPath
          Name          = $RegistryName
          Value         = $RegistryValue
          PropertyType  = 'DWORD'
          Force         = $true
          Confirm       = $false
          ErrorAction   = 'Stop'
          WarningAction = 'SilentlyContinue'
        }
        $null = (New-ItemProperty @SetPublishUserActivitiesParams)
        Write-Verbose -Message 'Collection of Activity History value modified.'
      }
      catch
      {
        Write-Warning -Message 'Unable to modify the collection of Activity History value!'
      }
    }
  }
}
