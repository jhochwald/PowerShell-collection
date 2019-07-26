function Get-enADGPOReplication
{
   <#
         .SYNOPSIS
         Retrieve one or all the GPO and report their DSVersions and SysVolVersions
	
         .DESCRIPTION
         Retrieve one or all the GPO and report their DSVersions and SysVolVersions (Users and Computers)
	
         .PARAMETER GPOName
         Specify the name of the GPO
	
         .PARAMETER All
         Specify that you want to retrieve all the GPO (slow if you have a lot of Domain Controllers)
	
         .EXAMPLE
         Get-enADGPOReplication -GPOName "Default Domain Policy"

         Retrieve one GPO and report their DSVersions and SysVolVersions (Users and Computers)
	
         .EXAMPLE
         Get-enADGPOReplication -All

         Retrieve all the GPO and report their DSVersions and SysVolVersions (Users and Computers)
	
         .NOTES
         Version: 1.0.1
		
         GUID: 3b7d48e2-3cc9-4cfa-8664-2d9ffa425415
		
         Author: Joerg Hochwald
		
         Companyname: enabling Technology
		
         Copyright: Copyright (c) 2ß18-2019, enabling Technology - All rights reserved.
		
         License: https://opensource.org/licenses/BSD-3-Clause
		
         Releasenotes:
         1.0.1 2019-07-26 Refactored, License change to BSD 3-Clause
         1.0.0 2019-01-01 Initial Version
		
         THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
		
         Dependencies:
         Active Directory PowerShell Module
	
         .LINK
         https://www.enatec.io

         .LINK
         Get-ADDomainController

         .LINK
         Get-GPO
   #>
	
   [CmdletBinding(DefaultParameterSetName = 'All',
   ConfirmImpact = 'None')]
   param
   (
      [Parameter(ParameterSetName = 'One',HelpMessage = 'Specify the name of the GPO',
            Mandatory,
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('GPO')]
      [String[]]
      $GPOName,
      [Parameter(ParameterSetName = 'All',
            ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Switch]
      $All = $true
   )

   process
   {
      foreach ($DomainController in ((Get-ADDomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetDC -Filter *).hostname))
      {
         try
         {
            if ($psBoundParameters['GPOName'])
            {
               foreach ($GPOItem in $GPOName)
               {
                  $GPO = (Get-GPO -Name $GPOItem -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPO)
						
                  [pscustomobject][ordered] @{
                     GroupPolicyName       = $GPOItem
                     DomainController      = $DomainController
                     UserVersion           = $GPO.User.DSVersion
                     UserSysVolVersion     = $GPO.User.SysvolVersion
                     ComputerVersion       = $GPO.Computer.DSVersion
                     ComputerSysVolVersion = $GPO.Computer.SysvolVersion
                  }
               }
            }
				
            if ($psBoundParameters['All'])
            {
               $GPOList = (Get-GPO -All -Server $DomainController -ErrorAction Stop -ErrorVariable ErrorProcessGetGPOAll)
					
               foreach ($GPO in $GPOList)
               {
                  [pscustomobject][ordered] @{
                     GroupPolicyName       = $GPO.DisplayName
                     DomainController      = $DomainController
                     UserVersion           = $GPO.User.DSVersion
                     UserSysVolVersion     = $GPO.User.SysvolVersion
                     ComputerVersion       = $GPO.Computer.DSVersion
                     ComputerSysVolVersion = $GPO.Computer.SysvolVersion
                  }
               }
            }
         }
         catch
         {
            Write-Warning -Message '[PROCESS] Something wrong happened'

            if ($ErrorProcessGetDC)
            {
               Write-Warning -Message '[PROCESS] Error while running retrieving Domain Controllers with Get-ADDomainController'
            }

            if ($ErrorProcessGetGPO)
            {
               Write-Warning -Message '[PROCESS] Error while running Get-GPO'
            }

            if ($ErrorProcessGetGPOAll)
            {
               Write-Warning -Message '[PROCESS] Error while running Get-GPO -All'
            }

            Write-Warning -Message "[PROCESS] $($Error[0].exception.message)"
         }
      }
   }
}
