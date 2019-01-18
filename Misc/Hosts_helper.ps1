function Add-HostsEntry
{
   <#
         .SYNOPSIS
         Add a single Hosts Entry to the HOSTS File

         .DESCRIPTION
         Add a single Hosts Entry to the HOSTS File, multiple are not supported yet!

         .PARAMETER Path
         The path to the hosts file where the entry should be set. Defaults to the local computer's hosts file.

         .PARAMETER Address
         The Address address for the hosts entry.

         .PARAMETER HostName
         The hostname for the hosts entry.

         .PARAMETER force
         Force (replace)

         .EXAMPLE
         PS C:\> Add-HostsEntry -Address '0.0.0.0' -HostName 'badhost'

         Add the host 'badhost' with the Adress '0.0.0.0' (blackhole) wo the Hosts.
         If an Entry for 'badhost' exists, the new one will be appended anyway (You end up with two entries)

         .EXAMPLE
         PS C:\> Add-HostsEntry -Address '0.0.0.0' -HostName 'badhost' -force

         Add the host 'badhost' with the Adress '0.0.0.0' (blackhole) wo the Hosts.
         If an Entry for 'badhost' exists, the new one will replace the existing one.

         .NOTES
         Internal Helper, inspired by an old GIST I found

         .LINK
         Get-HostsFile

         .LINK
         Remove-HostsEntry

         .LINK
         https://gist.github.com/markembling/173887/1824b370be3fe468faceaed5f39b12bad010a417
   #>

   [CmdletBinding(ConfirmImpact = 'Medium',
   SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            Position = 0,
      HelpMessage = 'The IP address for the hosts entry.')]
      [ValidateNotNullOrEmpty()]
      [Alias('ipaddress', 'ip')]
      [string]
      $Address,
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 1,
      HelpMessage = 'The hostname for the hosts entry.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Host', 'Name')]
      [string]
      $HostName,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 3)]
      [switch]
      $force = $false,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 2)]
      [ValidateNotNullOrEmpty()]
      [Alias('filename', 'Hosts', 'hostsfile', 'file')]
      [string]
      $Path = "$env:windir\System32\drivers\etc\hosts"
   )
   begin {
      Write-Verbose -Message 'Start'
   }

   process {
      if ($force)
      {
         try
         {
            $null = (Remove-HostsEntry -HostName $HostName -Path $Path -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)
         }
         catch
         {
            Write-Verbose -Message 'Looks like the entry was not there before'
         }
      }

      try
      {
         if ($pscmdlet.ShouldProcess('Target', 'Operation'))
         {
            # Get a clean (end of) file
            $paramGetContent = @{
               Path          = $Path
               Raw           = $true
               Force         = $true
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $HostsFileContent = (((Get-Content @paramGetContent ).TrimEnd()).ToString())

            $NewValue = "`n" + $Address + "`t`t" + $HostName
            $NewHostsFileContent = $HostsFileContent + $NewValue

            $paramSetContent = @{
               Path          = $Path
               Value         = $NewHostsFileContent
               Force         = $true
               Confirm       = $false
               Encoding      = 'UTF8'
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Set-Content @paramSetContent)
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

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end {
      Write-Verbose -Message 'Done'
   }
}

function Remove-HostsEntry
{
   <#
         .SYNOPSIS
         Removes a single Hosts Entry from the HOSTS File

         .DESCRIPTION
         Removes a single Hosts Entry from the HOSTS File, multiple are not supported yet!

         .PARAMETER Path
         The path to the hosts file where the entry should be set. Defaults to the local computer's hosts file.

         .PARAMETER HostName
         The hostname for the hosts entry.

         .EXAMPLE
         PS C:\> Remove-HostsEntry -HostName 'Dummy'

         Remove the entry for the host 'Dummy' from the HOSTS File

         .NOTES
         Internal Helper, inspired by an old GIST I found

         .LINK
         Get-HostsFile

         .LINK
         Add-HostsEntry

         .LINK
         https://gist.github.com/markembling/173887/1824b370be3fe468faceaed5f39b12bad010a417
   #>

   [CmdletBinding(ConfirmImpact = 'Medium',
   SupportsShouldProcess)]
   param
   (
      [Parameter(Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position = 0,
      HelpMessage = 'The hostname for the hosts entry.')]
      [ValidateNotNullOrEmpty()]
      [Alias('Host', 'Name')]
      [string]
      $HostName,
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [ValidateNotNullOrEmpty()]
      [Alias('Hosts', 'hostsfile', 'file', 'Filename')]
      [string]
      $Path = "$env:windir\System32\drivers\etc\hosts"
   )

   begin {
      Write-Verbose -Message 'Start'

      try
      {
         $paramGetContent = @{
            Path          = $Path
            Raw           = $true
            Force         = $true
            ErrorAction   = 'Stop'
            WarningAction = 'SilentlyContinue'
         }
         $HostsFileContent = (((Get-Content @paramGetContent ).TrimEnd()).ToString())
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

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }

      $newLines = @()
   }

   process {
      foreach ($line in $HostsFileContent)
      {
         $bits = [regex]::Split($line, '\t+')
         if ($bits.count -eq 2)
         {
            if ($bits[1] -ne $HostName)
            {
               $newLines += $line
            }
         }
         else
         {
            $newLines += $line
         }
      }

      # Write file
      try
      {
         if ($pscmdlet.ShouldProcess('Target', 'Operation'))
         {
            $paramClearContent = @{
               Path          = $Path
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Clear-Content @paramClearContent)

            $paramSetContent = @{
               Path          = $Path
               Value         = $newLines
               Force         = $true
               Confirm       = $false
               Encoding      = 'UTF8'
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $null = (Set-Content @paramSetContent)
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

         Write-Verbose -Message $info

         Write-Error -Message ($info.Exception) -ErrorAction Stop

         # Only here to catch a global ErrorAction overwrite
         break
      }
   }

   end {
      Write-Verbose -Message 'Done'
   }
}

function Get-HostsFile
{
   <#
         .SYNOPSIS
         Print the HOSTS File in a more clean format

         .DESCRIPTION
         Print the HOSTS File in a more clean format

         .PARAMETER Path
         The path to the hosts file where the entry should be set. Defaults to the local computer's hosts file.

         .PARAMETER raw
         Print raw Hosts File

         .EXAMPLE
         PS C:\> Get-HostsFile

         Print the HOSTS File in a more clean format

         .EXAMPLE
         PS C:\> Get-HostsFile -raw

         Print the HOSTS File in the regular format

         .NOTES
         Internal Helper, inspired by an old GIST I found

         .LINK
         Add-HostsEntry

         .LINK
         Remove-HostsEntry

         .LINK
         https://gist.github.com/markembling/173887/1824b370be3fe468faceaed5f39b12bad010a417
   #>

   [CmdletBinding(ConfirmImpact = 'None')]
   param
   (
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 0)]
      [ValidateNotNullOrEmpty()]
      [Alias('Hosts', 'hostsfile', 'file', 'filename')]
      [string]
      $Path = "$env:windir\System32\drivers\etc\hosts",
      [Parameter(ValueFromPipeline,
            ValueFromPipelineByPropertyName,
      Position = 1)]
      [Alias('plain')]
      [switch]
      $raw = $false
   )

   begin
   {
      $HostsFileContent = Get-Content -Path $Path
   }

   process
   {
      foreach ($line in $HostsFileContent)
      {
         if ($raw)
         {
            Write-Output -InputObject $line
         }
         else
         {
            $bits = [regex]::Split($line, '\t+')
            if ($bits.count -eq 2)
            {
               [string]$HostsFileLine = $bits

               if (-not ($HostsFileLine.StartsWith('#')))
               {
                  Write-Output -InputObject $HostsFileLine
               }
            }
         }
      }
   }
}

Get-HostsFile

break
try
{
   if ($args[0] -eq 'add')
   {
      if ($args.count -lt 3)
      {
         throw 'Not enough arguments for add.'
      }
      else
      {
         add-host $Path $args[1] $args[2]
      }
   }
   elseif ($args[0] -eq 'remove')
   {
      if ($args.count -lt 2)
      {
         throw 'Not enough arguments for remove.'
      }
      else
      {
         remove-host $file $args[1]
      }
   }
   elseif ($args[0] -eq 'show')
   {
      print-hosts $file
   }
   else
   {
      throw "Invalid operation '" + $args[0] + "' - must be one of 'add', 'remove'."
   }
}
catch
{
   Write-Host -Object $error[0]
   Write-Host -Object "`nUsage: hosts add <ip> <hostname>`n       hosts remove <hostname>`n       hosts show"
}
