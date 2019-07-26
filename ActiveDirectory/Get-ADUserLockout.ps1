function Get-ADUserLockouts
{
   <#
         .SYNOPSIS
         Tracking down account lockout sources with PowerShell

         .DESCRIPTION
         Tracking down account lockout sources with PowerShell

         .PARAMETER Identity
         Just scan for a single User?

         .PARAMETER StartTime
         Startpoint

         .PARAMETER EndTime
         Endpoint

         .EXAMPLE
         PS C:\> Get-ADUserLockout

         Tracking down account lockout sources for all users for the last 7 days

         .EXAMPLE
         Get-ADUser -Filter {Department -eq 'Development'} | Get-ADUserLockout

         Tracking down account lockout sources for all users in the Development Department for the last 7 days

         .EXAMPLE
         Get-ADUserLockout -StartTime (Get-Date).AddDays(-2) -EndTime (Get-Date).AddDays(-1)

         Tracking down account lockout sources for all users for the last day

         .NOTES
         Original by Anthony Howell (@ThePoShWolf) - MIT Licenses
         Copyright (c) 2018 Anthony Howell

         .LINK
         https://theposhwolf.com/howtos/Get-ADUserLockouts/

         .LINK
         https://github.com/ThePoShWolf/Utilities/blob/master/ActiveDirectory/Get-ADUserLockouts.ps1
   #>

   [CmdletBinding(DefaultParameterSetName = 'All',
   ConfirmImpact = 'None')]
   [OutputType([pscustomobject])]
   param
   (
      [Parameter(ParameterSetName = 'ByUser',
      ValueFromPipeline)]
      [string]
      $Identity,
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('Start')]
      [datetime]
      $StartTime = (Get-Date).AddDays(-8),
      [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
      [Alias('End')]
      [datetime]
      $EndTime = (Get-Date).AddDays(-1)
   )

   begin
   {
      $filterHt = @{
         LogName = 'Security'
         ID      = 4740
      }

      if ($PSBoundParameters.ContainsKey('StartTime'))
      {
         $filterHt['StartTime'] = $StartTime
      }

      if ($PSBoundParameters.ContainsKey('EndTime'))
      {
         $filterHt['EndTime'] = $EndTime
      }

      try
      {
         $PDCEmulator = ((Get-ADDomain -ErrorAction Stop).PDCEmulator)

         Write-Verbose -Message ('Use {0} to find the lockout events' -f $PDCEmulator)

         # Query the event log just once instead of for each user if using the pipeline
         $events = (Get-WinEvent -ComputerName $PDCEmulator -FilterHashtable $filterHt -ErrorAction Stop)
      }
      catch
      {
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

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         Write-Error -Message $e.Exception.Message -ErrorAction Stop -Exception $e.Exception -TargetObject $e.CategoryInfo.TargetName

         break
      }

         Write-Verbose -Message 'Found the following events:'
         Write-Verbose -Message $events
   }

   process
   {
      if ($PSCmdlet.ParameterSetName -eq 'ByUser')
      {
         try
         {
            Write-Verbose -Message ('Querry AD Info for {0}' -f $Identity)

            $user = (Get-ADUser -Identity $Identity -ErrorAction Stop)

            Write-Verbose -Message ('Found the following AD Info for {0}:' -f $Identity)
            Write-Verbose -Message $user

            # Filter the events
            $output = $events | Where-Object -FilterScript {
               $_.Properties[0].Value -eq $user.SamAccountName
            }
         }
         catch
         {
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

            # output information. Post-process collected info, and log info (optional)
            $info | Out-String | Write-Verbose

            Write-Error -Message $e.Exception.Message -ErrorAction Stop -Exception $e.Exception -TargetObject $e.CategoryInfo.TargetName

            break
         }
      }
      else
      {
         $output = $events
      }

      foreach ($event in $output)
      {
         [pscustomobject]@{
            UserName       = $event.Properties[0].Value
            CallerComputer = $event.Properties[1].Value
            TimeStamp      = $event.TimeCreated
         }
      }
   }
}
