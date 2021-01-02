function Get-UnifiFirewallGroupBody
{
   <#
         .SYNOPSIS
         Build a Body for Set-UnifiFirewallGroup call

         .DESCRIPTION
         Build a JSON based Body for Set-UnifiFirewallGroup call

         .PARAMETER UnfiFirewallGroup
         Existing Unfi Firewall Group

         .PARAMETER UnifiCidrInput
         IPv4 or IPv6 input List

         .EXAMPLE
         PS C:\> Get-UnifiFirewallGroupBody -UnfiFirewallGroup $value1 -UnifiCidrInput $value2

         Build a Body for Set-UnifiFirewallGroup call

         .NOTES
         This is an internal helper function only

         . LINK
         Set-UnifiFirewallGroup
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([psobject])]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'Existing Unfi Firewall Group')]
      [ValidateNotNullOrEmpty()]
      [Alias('FirewallGroup')]
      [psobject]
      $UnfiFirewallGroup,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'IPv4 or IPv6 input List')]
      [ValidateNotNullOrEmpty()]
      [Alias('CidrInput')]
      [psobject]
      $UnifiCidrInput
   )

   begin
   {
      Write-Verbose -Message 'Start Get-UnifiFirewallGroupBody'

      # Call meta function
      $null = (Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)

      Write-Verbose -Message 'Cleanup exitsing Group'
      Write-Verbose -Message "Old Values: $UnfiFirewallGroup.group_members"

      $UnfiFirewallGroup.group_members = $null
   }

   process
   {
      try
      {
         Write-Verbose -Message 'Create a new Object'

         $NewUnifiCidrItem = @()

         foreach ($UnifiCidrItem in $UnifiCidrInput)
         {
            $NewUnifiCidrItem = $NewUnifiCidrItem + $UnifiCidrItem
         }

         # Add the new values
         $paramAddMember = @{
            MemberType = 'NoteProperty'
            Name       = 'group_members'
            Value      = $NewUnifiCidrItem
            Force      = $true
         }
         $UnfiFirewallGroup | Add-Member @paramAddMember

         # Cleanup
         $NewUnifiCidrItem = $null

         # Create a new Request Body
         $paramConvertToJson = @{
            InputObject   = $UnfiFirewallGroup
            Depth         = 5
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $UnfiFirewallGroupJson = (ConvertTo-Json @paramConvertToJson)
      }
      catch
      {
         $null = (Invoke-InternalScriptVariables)

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

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end
   {
      # Dump
      $UnfiFirewallGroupJson

      Write-Verbose -Message 'Done Get-UnifiFirewallGroupBody'
   }
}
