Function Get-enDomainInfo
{
   <#
         .SYNOPSIS
         Retrieve domain information include site details

         .EXAMPLE
         Get-enDomainInfo

         .NOTES
   #>
   [CmdletBinding()]
   Param ()

   begin {
      $SelectProperties = 'Name', 'Forest', 'Parent', 'Children', 'DomainMode', 'DomainModeLevel', 'DomainControllers', 'PdcRoleOwner', 'RidRoleOwner', 'InfrastructureRoleOwner', 'Sites'
   }

   process {
      $CurrentDomain = [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
      $null = ($CurrentDomain | Add-Member -MemberType NoteProperty -Name Sites -Value ([DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().Sites))
      $Domain = ($CurrentDomain | Select-Object -Property $SelectProperties)

      <#
      switch($domainModeLevel)
      {
         {$domainModeLevel -like "0"} {"2000 Mixed/Native"}
         {$domainModeLevel -like "1"} {"2003 Interim"}
         {$domainModeLevel -like "2"} {"2003"}
         {$domainModeLevel -like "3"} {"2008"}
         {$domainModeLevel -like "4"} {"2008 R2"}
         {$domainModeLevel -like "5"} {"2012"}
         {$domainModeLevel -like "6"} {"2012 R2"}
         {$domainModeLevel -like "7"} {"2016"}
         default {"Unknown"}
      }
      #>
   }

   end {
      $Domain
   }
}

Get-enDomainInfo
