function Get-LocalGroupMembership
{
   <#
         .SYNOPSIS
         Get all local Groups a given User is a Member of

         .DESCRIPTION
         The the the membership of all local Groups for a given User.
         The Given User could be a local User (COMPUTER\USER) or a Domain User (DOMAIN\USER).

         .PARAMETER UserName
         Given User could be a local User (COMPUTER\USER) or a Domain User (DOMAIN\USER).
         Default is the user that executes the function.

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership

         Dump the Group Membership for the User that executes the function

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership -UserName 'CONTOSO\John.Doe'

         Dump the Group Membership for the User John.Doe in the Domain CONTOSO

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership -UserName "$env:COMPUTERNAME\John.Doe"

         Dump the Group Membership for the User John.Doe on the local computer

         .EXAMPLE
         PS C:\> Get-LocalGroupMembership -UserName 'CONTOSO\John.Doe' | Foreach-Object { Add-LocalGroupMember -Group $_ -Member "$env:COMPUTERNAME\John.Doe" -ErrorAction SilentlyContinue }

         Clone the Group Membership from User John.Doe in the Domain CONTOSO to User John.Doe on the local computer

         .NOTES
         This is just a quick and dirty solution for a problem I faced. (See last example)
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('User')]
      [string]
      $UserName = ("$env:USERDOMAIN" + '\' + "$env:USERNAME")
   )

   begin
   {
      # Create a new Object
      $LocalGroupMembership = @()
   }

   process
   {
      $AllGroups = (Get-LocalGroup -Name *)

      foreach ($LocalGroup in $AllGroups)
      {
         if (Get-LocalGroupMember -Group $LocalGroup.Name -ErrorAction SilentlyContinue | Where-Object -FilterScript {
               $_.name -eq $UserName
         })
         {
            $LocalGroupMembership += $LocalGroup.Name
         }
      }
   }
   end
   {
      # Dump the object to the console
      $LocalGroupMembership
   }
}

Get-LocalGroupMembership