function Invoke-SSHConnect
{
   <#
         .SYNOPSIS
         Connect to any of the known SSH Hosts
    
         .DESCRIPTION
         Connect to any of the known SSH Hosts, all hosts and further information is managed within an external JSON file
         BUG: Get-Help is broken, when using DynamicParam! - https://github.com/PowerShell/PowerShell/issues/6694
    
         .PARAMETER Computer
         Computer to connect to
    
         .EXAMPLE
         PS C:\> Invoke-SSHConnect -Computer Dummy1
         Open a SSH connection to the given host (Dummy1)
    
         .NOTES
         Check the JSON File within the DynamicParam below!

         Sample JSON (not nicly formated):
         [
         {
         "Name": "Dummy1",
         "Host": "dummy1.corp.contoso.com",
         "User": "john.doe",
         "Hint": "Info",
         "Message": "This is a sample host"
         },
         {
         "Name": "Dummy2",
         "Host": "1.1.1.1",
         "User": "root",
         "Hint": "Warning",
         "Message": "This is a DMZ host"
         },
         {
         "Name": "Dummy3",
         "Host": "1.1.1.2",
         "User": "root",
         "Hint": "Error",
         "Message": "Device no longer exists"
         }
         ]
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param ()
   DynamicParam {
      # Where to find the json file
      $JsonFile = ('{0}\sshhosts.json' -f $env:DOCUMENTS)
      
      if (Test-Path -Path $JsonFile -ErrorAction SilentlyContinue)
      {
         # Get the data from the Json file
         $SSHHostData = (Get-Content -Path $JsonFile -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop)
         # Store the hosts for dynamic check
         $ValidHosts = ($SSHHostData.Name)
         # DynamicParam related
         $RuntimeParameterDictionary = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary)
         $AttributeCollection = (New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute])
         $ParameterAttribute = (New-Object -TypeName System.Management.Automation.ParameterAttribute)
         $ParameterAttribute.Mandatory = $true
         $ParameterAttribute.HelpMessage = 'Host to connect to'
         $ParameterAttribute.ValueFromPipeline = $true
         $ParameterAttribute.ValueFromPipelineByPropertyName = $true
         $ParameterAttribute.ValueFromRemainingArguments = $true
         $ParameterAttribute.Position = 0
         $AttributeCollection.Add($ParameterAttribute)
         $ValidateSetAttribute = (New-Object -TypeName System.Management.Automation.ValidateSetAttribute -ArgumentList ($ValidHosts))
         $AttributeCollection.Add($ValidateSetAttribute)
         $RuntimeParameter = (New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter -ArgumentList ('Computer', [string], $AttributeCollection))
         $RuntimeParameterDictionary.Add('Computer', $RuntimeParameter)
         $ValidHosts = $null
         
         return $RuntimeParameterDictionary
      }
      else
      {
         $paramWriteError = @{
            Exception    = 'JSON File missing!'
            Message      = 'The configuration file could not be found'
            Category     = 'ObjectNotFound'
            TargetObject = $JsonFile
            ErrorAction  = 'Stop'
         }
         Write-Error @paramWriteError
      }
   }
    
   Begin
   {
      # Store the real name (because we use DynamicParam) in a variable
      $Computer = ($PSBoundParameters.Computer)
         
      # Select the matching entry
      $connectionHostEntry = ($SSHHostData | Where-Object -FilterScript {
            ($_.Name -eq $Computer)
      })
         
      # Did we find a match?
      if ($connectionHostEntry)
      {
         # Store the info
         $connectionHostName = $connectionHostEntry.Name
         $connectionHost = $connectionHostEntry.Host
         $connectionHostUser = $connectionHostEntry.User
         $connectionHostHint = $connectionHostEntry.Hint
         $connectionHostMessage = $connectionHostEntry.Message
         $connectionString = ('{0}@{1}' -f $connectionHostUser, $connectionHost)
      }
      else
      {
         # You should never reach this point anyway
         $paramWriteError = @{
            Exception         = 'Host not found'
            Message           = 'The given host was not found in the SSH configuration file'
            Category          = 'InvalidData'
            TargetObject      = $Computer
            RecommendedAction = 'Please check the Hostname'
            ErrorAction       = 'Stop'
         }
         Write-Error @paramWriteError
      }
   }
    
   Process
   {
      # Clear screen
      $null = (Clear-Host)
      
      #region HintSupport
      # New version of the connection file can contain hint's
      switch ($connectionHostHint) {
         Info 
         {
            Write-Output -InputObject ''
            Write-Output -InputObject $connectionHostMessage
            Write-Output -InputObject ''
         }
         Warning 
         {
            Write-Output -InputObject ''
            Write-Warning -Message $connectionHostMessage
            Write-Output -InputObject ''
         }
         Error 
         {
            Write-Output -InputObject ''
            Write-Error -Exception $connectionHostMessage -Message $connectionHostMessage -ErrorAction Stop
            Write-Output -InputObject ''
         }
         default 
         {
            Write-Output -InputObject ''
            Write-Verbose -Message ('Connection to {0}' -f $connectionHostName)
            Write-Output -InputObject ''
         }

      }
      #endregion HintSupport
      
      #region LegacyTerminalSupport
      if (!($env:WT_SESSION)) 
      {
         # Legacy shell support - Change the Terminal Title
         $TitleStore = $host.UI.RawUI.WindowTitle
         $SessionTitle = ('SSH: {0}' -f $connectionString)
         $host.UI.RawUI.WindowTitle = $SessionTitle
      }
      else
      {
         # TODO: Review this, check your terminal color schemes name
         # I use a tweaked version of this: https://www.thomasmaurer.ch/2020/06/my-windows-terminal-color-schemes/
         $from = 'PowerShellTom'
         $to = 'MySSHConnection'

         # Preview Package: Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe
         $settingsPath = ('{0}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json' -f $env:LocalAppData)
         # https://stackoverflow.com/a/30893960
         $content = [IO.File]::ReadAllText($settingsPath).Replace("`"colorScheme`": `"" + $from + "`"","`"colorScheme`": `"" + $to + "`"")
         [IO.File]::WriteAllText($settingsPath, $content)
      }
      #endregion LegacyTerminalSupport

      # TODO: Review the SSH parameters and ensure they are working nicly for you
      & "$env:windir\system32\openssh\ssh.exe" $connectionString -o ServerAliveInterval=10 -o KeepAlive=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -C

      #region LegacyTerminalSupport
      if (!($env:WT_SESSION)) 
      {
         # Legacy shell support - Change back the Terminal Title
         $host.UI.RawUI.WindowTitle = $TitleStore
      }
      else
      {
         # TODO: Review this, check your terminal color schemes name
         # I use a tweaked version of this: https://www.thomasmaurer.ch/2020/06/my-windows-terminal-color-schemes/
         $from = 'MySSHConnection'
         $to = 'PowerShellTom'

         # Preview Package: Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe
         $settingsPath = ('{0}\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json' -f $env:LocalAppData)
         # https://stackoverflow.com/a/30893960
         $content = [IO.File]::ReadAllText($settingsPath).Replace("`"colorScheme`": `"" + $from + "`"","`"colorScheme`": `"" + $to + "`"")
         [IO.File]::WriteAllText($settingsPath, $content)
      }
      #endregion LegacyTerminalSupport 
   }
    
   End
   {
      #region Cleanup
      $SSHHostData = $null
      $connectionHostEntry = $null
      $connectionHostName = $null
      $connectionHost = $null
      $connectionHostUser = $null

      [GC]::Collect()
      [GC]::WaitForPendingFinalizers()
      #endregion Cleanup
      
      # Clear screen
      $null = (Clear-Host)
   }
}
