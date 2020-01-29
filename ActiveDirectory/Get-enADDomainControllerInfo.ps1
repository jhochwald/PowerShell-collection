Function Get-enDomainControllerInfo
{
   <#
         .SYNOPSIS
         Get a list of domain controllers

         .DESCRIPTION
         Will provide a list of domain controllers in your current domain.
         Optionally you can also request a discovery of the "closest" one.

         .PARAMETER ComputerName
         Retrieve information about the specified domain controller.
         This is a RegEx match so you can match multiple domain controllers with your pattern.

         .PARAMETER Discover
         Use Discover to return the information of the closest domain controller.

         .EXAMPLE
         Get-enDomainControllerInfo

         Retrieve a list of all domain controllers in your domain.

         .EXAMPLE
         Get-enDomainControllerInfo -Computer 01

         Retrieve a list of all domain controlelrs with "01" in their name.

         .EXAMPLE
         Get-enDomainControllerInfo -Discover

         Retrieve the name of the closest domain controller.

         .NOTES
   #>
   [CmdletBinding(DefaultParameterSetName = 'all')]
   Param (
      [Parameter(Position = 0,ParameterSetName = 'dc')]
      [string]$ComputerName,
      [Parameter(ParameterSetName = 'all')]
      [switch]$Discover
   )

   begin {
      $DirectoryContext = [DirectoryServices.ActiveDirectory.DirectoryContext]::New('Domain')
      $SelectProperties = 'Name', 'Forest', 'Domain', 'SiteName', 'Roles', 'CurrentTime', 'HighestCommittedUsn', 'OSVersion'
   }

   process {
      If ($Discover)
      {
         $LocatorFlag = [DirectoryServices.ActiveDirectory.LocatorOptions]::ForceRediscovery
         $Info = ([DirectoryServices.ActiveDirectory.DomainController]::FindOne($DirectoryContext, $LocatorFlag) | Select-Object -Property $SelectProperties)
      } elseif ($ComputerName)
      {
         $Info = ([DirectoryServices.ActiveDirectory.DomainController]::FindAll($DirectoryContext) | Where-Object -Property Name -Match -Value $ComputerName | Select-Object -Property $SelectProperties)
      } else
      {
         $Info = ([DirectoryServices.ActiveDirectory.DomainController]::FindAll($DirectoryContext) | Select-Object -Property $SelectProperties)
      }
   }

   end {
      $Info
   }
}



Get-enDomainControllerInfo
