<#
      .SYNOPSIS
      Remove the Group Policy settings for BitLocker from the registry
   
      .DESCRIPTION
      Remove the Group Policy settings for BitLocker from the registry
   
      .EXAMPLE
      PS C:\> .\Invoke-RemoveBitLockerGroupPolicySettings.ps1
   
      .NOTES
      Internal PoC
#>
[CmdletBinding(ConfirmImpact = 'Low',
SupportsShouldProcess)]
[OutputType([string])]
param ()

begin
{
   $RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\FVE'
}

process
{
   if (Test-Path -Path $RegPath -ErrorAction SilentlyContinue)
   {
      if ($pscmdlet.ShouldProcess('Group Policy settings for BitLocker in the registry', 'Remove'))
      {
         <#
         foreach ($RegKey in ((Get-ItemProperty -Path $RegPath -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).PSObject.Properties) | Where-Object {(($_.Name -NotLike 'UseTPM*') -and ($_.Name -NotLike 'PS*') -and ($_.Name -ne 'DO_NOT_REMOVE_THIS_KEY'))}){
            $null = (Remove-ItemProperty -Path $RegPath -Name $RegKey.Name -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         }
         #>
         $null = (Remove-Item -Path $RegPath -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
      }
   }
   else
   {
      Write-Verbose -Message 'No action is required!'
   }
}

end
{
   $RegPath = $null
}

