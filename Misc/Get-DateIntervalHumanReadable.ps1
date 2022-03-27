function Get-DateIntervalHumanReadable
{
   <#
         .SYNOPSIS
         Make a given Repetition Pattern/DateInterval string HumanReadable

         .DESCRIPTION
         Make a given Repetition Pattern/DateInterval string HumanReadable

         .PARAMETER DateInterval
         The Repetition Pattern/DateInterval as string.
         Format must be something like P<days>DT<hours>H<minutes>M<seconds>S

         Please see https://docs.microsoft.com/en-us/windows/win32/taskschd/repetitionpattern?redirectedfrom=MSDN#properties

         .EXAMPLE
         PS C:\> Get-DateIntervalHumanReadable -DateInterval 'P24DT3H59M17S'
         24d 03h 59m 17s

         .EXAMPLE
         PS C:\> Get-DateIntervalHumanReadable -DateInterval 'PT29M10S'
         00d 00h 29m 10s

         .EXAMPLE
         PS C:\> Get-DateIntervalHumanReadable -DateInterval '24DT3H59M17S'
         Unknown

         .LINK
         https://msdn.microsoft.com/en-us/library/windows/desktop/aa382117%28v=vs.85%29.aspx#properties

         .LINK
         https://devblogs.microsoft.com/scripting/working-with-task-scheduler-xml/

         .LINK
         https://jdhitsolutions.com/blog/powershell/4414/converting-timespans-to-repetition-patterns/

         .NOTES
         Very quick and dirty hack to convert a DateInterval string in an CSV file
         It might still need some love to get more robust.
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param
   (
      [Parameter(Mandatory, HelpMessage = 'Format must be something like P<days>DT<hours>H<minutes>M<seconds>S',
         ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [Alias('TimeDateString')]
      [string]
      $DateInterval
   )

   process
   {
      if ($DateInterval -match '^[P]')
      {
         $days = $null
         $hours = $null
         $minutes = $null
         $seconds = $null
         $AllTime = $null

         # Remove the leading "P"
         $DateInterval = $DateInterval.Split('P')[1]

         # Does it start with a Number?
         if ($DateInterval -match '^\d')
         {
            if ($DateInterval -match '[D]')
            {
               # Do we have a day value?
               $days = $DateInterval.Split('D')[0]
               $DateInterval = $DateInterval.Split('D')[1]
            }
         }

         if ($DateInterval -match '^[T]')
         {
            # Remove the leading "T"
            $DateInterval = $DateInterval.Split('T')[1]
         }

         # Does it start with a Number?
         if ($DateInterval -match '^\d')
         {
            if ($DateInterval -match '[H]')
            {
               # Do we have a hour value?
               $hours = $DateInterval.Split('H')[0]
               $DateInterval = $DateInterval.Split('H')[1]
            }
         }

         if ($DateInterval -match '^[T]')
         {
            # Remove the leading "T"
            $DateInterval = $DateInterval.Split('T')[1]
         }

         # Does it start with a Number?
         if ($DateInterval -match '^\d')
         {
            if ($DateInterval -match '[M]')
            {
               # Do we have a minutes value?
               $minutes = $DateInterval.Split('M')[0]
               $DateInterval = $DateInterval.Split('M')[1]
            }
         }

         if ($DateInterval -match '^[T]')
         {
            # Remove the leading "T"
            $DateInterval = $DateInterval.Split('T')[1]
         }

         # Does it start with a Number?
         if ($DateInterval -match '^\d')
         {
            if ($DateInterval -match '[S]')
            {
               # Do we have a seconds value?
               $seconds = $DateInterval.Split('S')[0]

               if ($DateInterval.EndsWith('S'))
               {
                  $null = (Remove-Variable -Name DateInterval -Force -Confirm:$false -ErrorAction SilentlyContinue)
               }
            }
         }

         if ($DateInterval)
         {
            # We have some leftovers, this is not good and we will not continue!
            'Unknown'
         }
         else
         {
            $paramNewTimeSpan = @{
               ErrorAction = 'SilentlyContinue'
            }

            if ($days)
            {
               $paramNewTimeSpan.Add('Days', $days)
            }

            if ($hours)
            {
               $paramNewTimeSpan.Add('Hours', $hours)
            }

            if ($minutes)
            {
               $paramNewTimeSpan.Add('Minutes', $minutes)
            }

            if ($seconds)
            {
               $paramNewTimeSpan.Add('Seconds', $seconds)
            }

            $AllTime = (New-TimeSpan @paramNewTimeSpan)
            '{0:dd}d {0:hh}h {0:mm}m {0:ss}s' -f $AllTime
         }

         $days = $null
         $hours = $null
         $minutes = $null
         $seconds = $null
         $AllTime = $null
      }
      else
      {
         # The string seems to be wrong or unknown
         'Unknown'
      }
   }
}
