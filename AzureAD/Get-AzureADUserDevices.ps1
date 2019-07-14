#requires -Version 3.0 -Modules AzureAD
<#
      .SYNOPSIS
      Script to monitor and return large number of user devices in Azure Active Directory.
	
      .DESCRIPTION
      Script to monitor and return large number of user devices in Active Directory.
      The default limit in Azure is 20 devices
	
      .PARAMETER All
      If true, return all users.
	
      .PARAMETER HighDeviceCount
      Enter the threshold for devices that you want to return
	
      .EXAMPLE
      Get-AzureADUserDevices.ps1 -HighDeviceCount 15 -All $true

      .EXAMPLE
      Get-AzureADUserDevices.ps1 -HighDeviceCount 5 -All $true
	
      .NOTES
      Reworked version of Ben Whitmore Get-UserDevices that use the AzureAD module instead of the MsolService module
	
      .LINK
      https://github.com/byteben/AzureAD/blob/master/Get-UserDevices.ps1
#>
[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
   Position = 0)]
   [ValidateNotNullOrEmpty()]
   [int]
   $HighDeviceCount = 15,
   [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
   Position = 1)]
   [bool]
   $All
)

begin
{
   # Defaults
   $STP = 'Stop'
	
   # Set some default
   if (-not ($HighDeviceCount))
   {
      $HighDeviceCount = 15
   }
	
   # Connect to Azure Active Directory, if needed
   if ($AzureActiveDirectoryConnection.Account -eq $null)
   {
      try
      {
         $Global:AzureActiveDirectoryConnection = (Connect-AzureAD -ErrorAction $STP)
      }
      catch
      {
         #region ErrorHandler
         # get error record
         [Management.Automation.ErrorRecord]$e = $_
			
         # retrieve information about runtime error
         $info = [PSCustomObject]@{
            Exception = $e.Exception.Message
            Reason    = $e.CategoryInfo.Reason
            Target    = $e.CategoryInfo.TargetName
            Script    = $e.InvocationInfo.ScriptName
            Line      = $e.InvocationInfo.ScriptLineNumber
            Column    = $e.InvocationInfo.OffsetInLine
         }
			
         Write-Verbose -Message $info
			
         Write-Error -Message ($info.Exception) -ErrorAction $STP
			
         # Only here to catch a global ErrorAction overwrite
         break
         #endregion ErrorHandler
      }
   }
	
   # Initialize Array to hold users and number of devices
   $DeviceCountHigh = @()
	
   try
   {
      # Splatting
      $paramGetAzureADUser = @{
         filter      = "userType eq 'Member'"
         All         = $All
         ErrorAction = $STP
      }
		
      # Get list of users from Azure Active Directory
      $Users = (Get-AzureADUser @paramGetAzureADUser | Select-Object -Property UserPrincipalName, ObjectId)
		
      # Splatting
      $paramGetAzureADDevice = @{
         All         = $true
         ErrorAction = $STP
      }
		
      # Get a list of Devices and the ownership information from the Azure Active Directory
      $Devices = (Get-AzureADDevice @paramGetAzureADDevice | Get-AzureADDeviceRegisteredOwner -ErrorAction $STP)
   }
   catch
   {
      #region ErrorHandler
      # get error record
      [Management.Automation.ErrorRecord]$e = $_
		
      # retrieve information about runtime error
      $info = @{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }
		
      Write-Verbose -Message $info
		
      Write-Error -Message ($info.Exception) -ErrorAction $STP
		
      # Only here to catch a global ErrorAction overwrite
      break
      #endregion ErrorHandler
   }
}

process
{
   foreach ($User in $Users)
   {
      # For each user returned, count their Registered Devices
      $Device = ($Devices | Where-Object {
            $_.UserPrincipalName -eq $User.UserPrincipalName
      } | Measure-Object)
		
      # If the number of registered devices measured is high, create a new PSObject
      if ($Device.Count -ge $HighDeviceCount)
      {
         # Create a new PSObject
         $DeviceCountMember = @()
			
         # Fill the values
         $DeviceCountMember = (New-Object -TypeName PSObject)
         $DeviceCountMember | Add-Member -MemberType NoteProperty -Name 'UserPrincipalName' -Value $User.UserPrincipalName
         $DeviceCountMember | Add-Member -MemberType NoteProperty -Name 'DeviceCount' -Value $Device.Count
			
         # Add to the PSObject
         $DeviceCountHigh += $DeviceCountMember
      }
   }
}

end
{
   # Display Users with high number of devices
   $DeviceCountHigh | Sort-Object -Property DeviceCount -Descending
}



   