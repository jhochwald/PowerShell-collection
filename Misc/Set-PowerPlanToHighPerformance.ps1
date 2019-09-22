#Requires -RunAsAdministrator

<#
      .SYNOPSIS
      Set the Windows Power Plan to High Performance

      .DESCRIPTION
      Set the Windows Power Plan to High Performance, it also disables Hybernation and System Standby

      .EXAMPLE
      PS C:\> .\Set-PowerPlanToHighPerformance.ps1

      .NOTES
      Works fine on Windows Server 2016 (Developed for server use).
      Should also work on Windows 10, but I never tested it on a Windows 10 system!
#>
[CmdletBinding(ConfirmImpact = 'Low')]
param ()

process
{
   #region Cleanup
   $ActivePowerPlan = $null
   $PowerPlanHighPowerState = $null
   #endregion Cleanup

   #region InformationGathering
   # Splat the parameters
   $paramGetWmiObject = @{
      Namespace = 'root\cimv2\power'
      Class     = 'Win32_PowerPlan'
   }

   # Gather the PowerPlan information
   $ActivePowerPlan = (Get-WmiObject @paramGetWmiObject | Select-Object -Property ElementName, IsActive)

   # Filter the 'High Performance' plan info
   $PowerPlanHighPowerState = $ActivePowerPlan | Where-Object -FilterScript {
      $_.ElementName -eq 'High Performance'
   }
   #endregion InformationGathering

   #region CheckIfTheTweakIsNeeded
   if ($PowerPlanHighPowerState.IsActive -ne $true)
   {
      # Use the PowerPlan "High Performance"
      $paramGetWmiObject.Filter = "ElementName = 'High Performance'"
      $powerPlan = (Get-WmiObject @paramGetWmiObject)

      #region ActivateThePowerPlan
      $null = (Invoke-Command -ScriptBlock {
            $powerPlan.Activate()
      } -ErrorAction SilentlyContinue)
      <#
            This looks a bit crappy, but it works fine and I don't like to have any output of the activation
      #>
      #endregion ActivateThePowerPlan
   }
   #endregion CheckIfTheTweakIsNeeded

   #region Cleanup
   $PowerPlanHighPowerState = $null
   #endregion Cleanup
   
   #region Retest
   $PowerPlanHighPowerState = $ActivePowerPlan | Where-Object -FilterScript {
      $_.ElementName -eq 'High Performance'
   }

   # Filter the 'High Performance' plan info
   if ($PowerPlanHighPowerState.IsActive -ne $true)
   {
      Write-Warning -Message "Unable to set the PowerPlan to 'High Performance'"
   }
   #endregion Retest
   
   #region NoStandBy
   & "$env:windir\system32\powercfg.cpl" -change -standby-timeout-ac 0
   #endregion NoStandBy
   
   #region DisableHybernationSupport
   & "$env:windir\system32\powercfg.cpl" -change -hibernate-timeout-ac 0
   #endregion DisableHybernationSupport
}