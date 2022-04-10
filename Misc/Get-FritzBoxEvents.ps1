function Get-FritzBoxEvents
{
   <#
      .SYNOPSIS
      Get the Events from a FritzBox router

      .DESCRIPTION
      Get the Events from a FritzBox router

      .PARAMETER FritzBoxUser
      Username to use for the FritzBox login

      .PARAMETER FritzBoxPassword
      FritzBox Password in plain text (might be changed to a secure string soon)

      .PARAMETER FritzBoxHost
      The URI that contains the FQDN or IP of your FritzBox,
      e.g. http://fritz.box or http://192.168.178.1

      .PARAMETER Hours
      Hours to get, e.g. 24

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' -Hours 24 | Where-Object {(($PSItem.ipv4 -ne $null) -or ($PSItem.ipv6 -ne $null))}

      Get only entries with IPv4 or IPv6 values, of the last 24 hours

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' -Hours 48 | Where-Object {($PSItem.ipv6 -ne $null)}

      Get only entries with IPv6 values, of the last 48 hours

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like 'Die Systemzeit wurde erfolgreich aktualisiert von Zeitserver*')}

      Get all events where the time was set via a time server, no time limit

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like 'Die Systemzeit wurde erfolgreich aktualisiert von Zeitserver*')} | Select-Object -ExpandProperty IPv4

      Get all events where the time was set via a time server, only return the IPv4 addresses, no time limit

      .EXAMPLE
      PS C:\> ((Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like 'Die Systemzeit wurde erfolgreich aktualisiert von Zeitserver*')})[0] | Select-Object -ExpandProperty IPv4)

      Get all events where the time was set via a time server, only return the IPv4 address of the latest (youngest) event

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like '*main-repeater*')}

      Only return events from a repeater with the name main-repeater, no time limit

      .EXAMPLE
      PS C:\> (Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like '*main-repeater*')})[0]

      Only return the latest (youngest) events from a repeater with the name main-repeater, no time limit

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like '*Zeitserver * antwortet nicht.')}

      Only return events where the Timeserver does NOT answer, no time limit

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like '*verschlüsselten DNS-Servern*')}

      All events related to encrypted DNS, no time limit

      .EXAMPLE
      PS C:\> Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' -Hours 24 | Where-Object {($PSItem.Message -like '*Authentifizierungsfehler*')}

      Only events with authentication errors, of the last 24 hours

      .EXAMPLE
      PS C:\> ((Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like '*(verfügbare Bitrate)*')})[0] | Select-Object -ExpandProperty Message)

      The latest (youngest) event that has the bitrate info (capacity)

      .EXAMPLE
      PS C:\> ((Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like 'Internetverbindung wurde erfolgreich hergestellt.*')})[0] | Select-Object -ExpandProperty IPv4)

      Get the public IPv4 address

      .EXAMPLE
      PS C:\> ((Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {($PSItem.Message -like 'Internetverbindung IPv6 wurde erfolgreich hergestellt.*')})[0] | Select-Object -ExpandProperty IPv6)

      Get the public IPv6 address

      .EXAMPLE
      PS C:\> ((Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {(($PSItem.Message -like '*IPv6-Präfix wurde erfolgreich bezogen.*') -and ($PSItem.ipv6 -ne $null))})[0] | Select-Object -ExpandProperty IPv6)

      Get the latest public IPv6 prefix (CIDR)

      .EXAMPLE
      PS C:\> ((Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {(($PSItem.Message -like 'Freigabe als Exposed Host auf * (*) hinzugefügt.') -and ($PSItem.ipv4 -ne $null))})[0] | Select-Object -ExpandProperty IPv4)

      get the exposed host IPv4

      .EXAMPLE
      PS C:\> $IPv6TMP = (Get-FritzBoxEvents -FritzBoxUser 'myFritz' -FritzBoxPassword 'ThePassw0rd' -FritzBoxHost 'http://myfritz.box' | Where-Object {(($PSItem.Message -like 'Freigabe als Exposed Host auf * (*) hinzugefügt.') -and ($PSItem.ipv4 -eq $null))} | Select-Object -ExpandProperty Message)
      PS C:\> $regex = [regex]'(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))'
      PS C:\> $regex.Matches($IPv6TMP) | ForEach-Object{ $PSItem.value }

      Get the exposed host IPv6 address and/or IPv6 CIDR (of exists)

      .LINK
      https://github.com/jangeisbauer/FritzBox2Sentinel

      .LINK
      https://gist.github.com/joasch/e48738417ec1efcc963a96bbb3f34cba

      .LINK
      https://www.ip-phone-forum.de/threads/ereignisprotokoll-der-fritz-box-auf-linux-server-sichern.280328/page-5

      .NOTES
      All tests in the examples are only valid if your FritzBox has a german UI!
      For other languages, dump all events and search for the matches in your own language

      If you have issues with german umlauts, use the following before stating the command:
      [console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(1252)

      I had issues on macOS and Linux with german umlauts, never happened on Windows!

      Idea is stolen from https://github.com/jangeisbauer/FritzBox2Sentinel (No license was applied)
      So, @jangeisbauer is considered as a contributor
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([array])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [Alias('FBUser', 'user')]
      [string]
      $FritzBoxUser = $null,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [Alias('Password', 'fbpassword')]
      [string]
      $FritzBoxPassword = $null,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNull()]
      [ValidateNotNullOrEmpty()]
      [Alias('fbhost', 'host', 'fritzbox')]
      [string]
      $FritzBoxHost = 'http://fritz.box',
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [int]
      $Hours = $null
   )

   begin
   {
      # Garbage Collection
      [GC]::Collect()

      #region Helper
      function Get-MD5Hash
      {
         <#
         .SYNOPSIS
         Return a MD5 hash of a given String

         .DESCRIPTION
         Return a MD5 hash of a given String

         .PARAMETER Text
         String to convert

         .EXAMPLE
         PS C:\> Get-MD5Hash -Text 'Value1'

         .LINK
         https://github.com/jangeisbauer/FritzBox2Sentinel

         .NOTES
         Cheap internal helper

         Stolen from https://github.com/jangeisbauer/FritzBox2Sentinel (No license was applied)
      #>
         [CmdletBinding(ConfirmImpact = 'None')]
         [OutputType([string])]
         param
         (
            [Parameter(Mandatory,
               ValueFromPipeline,
               ValueFromPipelineByPropertyName,
               HelpMessage = 'String to convert')]
            [ValidateNotNull()]
            [ValidateNotNullOrEmpty()]
            [string]
            $Text
         )

         begin
         {
            $md5 = (New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider)
         }

         process
         {
            $md5.ComputeHash([Text.Encoding]::utf8.getbytes($Text)) | ForEach-Object -Process {
               $HC = ''
            } {
               $HC += $PSItem.tostring('x2')
            } {
               $HC
            }
         }
      }
      #endregion Helper
   }

   process
   {
      try
      {
         # Convert the plain text password to a secure string
         $FritzBoxSecurePassword = ($FritzBoxPassword | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop)

         # FritzBox Pages to get
         $FritzBoxLoginPage = '/login_sid.lua'
         $FritzBoxEventPage = '/query.lua?mq_log=logger:status/log&sid='

         # Secret handler
         $SecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($FritzBoxSecurePassword)
         $PtrToStringAuto = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($SecureStringToBSTR)

         # Get the challenge from the FritzBox Login Page
         $ChallengeRequest = (Invoke-WebRequest -Uri ($FritzBoxHost + $FritzBoxLoginPage) -UseBasicParsing -ErrorAction Stop)

         # Save the recived challenge
         $Challenge = ([xml]$ChallengeRequest).sessioninfo.challenge

         # Create the input for the HEX code
         $Code1 = ($Challenge + '-' + $PtrToStringAuto)

         # Create the HEX data string
         $Code2 = ([char[]]$Code1 | ForEach-Object -Process {
               $Code2 = ''
            } {
               $Code2 += $_ + [Char]0
            } {
               $Code2
            })

         # Create the body part for the next request (includes the MD5 hash of the HEX from above)
         $SIDRequestBody = ('response=' + $Challenge + '-' + $(Get-MD5Hash -text ($Code2)) + '&username=' + $FritzBoxUser)

         # Do the real Login
         $SIDRequest = (Invoke-WebRequest -Uri ($FritzBoxHost + $FritzBoxLoginPage) -Method Post -Body $SIDRequestBody -ErrorAction Stop)

         # Extract the SID from the Login request
         $SID = ((([xml]($SIDRequest.Content)).ChildNodes).sid)

         # Get the Events

         $FritzBoxEvents = (Invoke-WebRequest -Uri ($FritzBoxHost + $FritzBoxEventPage + $SID) -UseBasicParsing -ErrorAction Stop)

         # Do we have a time limit?
         if ($Hours -ne 0)
         {
            # Create a filter
            $Filterhours = ((Get-Date).AddHours(-$Hours))
         }
         else
         {
            # No filter needed
            $Filterhours = $null
         }

         # Create a new Array
         $FritzEvents = @()

         # loop over the events we have (and extract the JSON return that contains all events)
         foreach ($FritzBoxEvent in ($FritzBoxEvents.Content | ConvertFrom-Json -ErrorAction Stop).mq_log)
         {
            try
            {
               # Cleanup
               $EventDate = $null
               $IPv6 = $null
               $IPv4 = $null
               $EventEntry = $null

               # Transform the Data
               $EventDate = [regex]::Matches($FritzBoxEvent, '\d\d\.\d\d\.\d\d \d\d:\d\d:\d\d')[0].Value

               # This REGEX should match IPv6 and IPv6 CIDR
               $IPv6 = [regex]::Matches($FritzBoxEvent[0], '((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]d|1dd|[1-9]?d)(.(25[0-5]|2[0-4]d|1dd|[1-9]?d)){3}))|:)))(%.+)?s*(\/([0-9]|[1-9][0-9]|1[0-1][0-9]|12[0-8]))?$')[0].Value

               # Simple IPv4 REGEX
               $IPv4 = [regex]::Matches($FritzBoxEvent[0], '(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)')[0].Value

               # Do we have a DATE in the event?
               if ($EventDate -ne '')
               {
                  # Transform the Event DATE
                  $EventEntry = $FritzBoxEvent[0].replace($EventDate, '')

                  # Ensure we have the correct format, just in case
                  #$EventDate = (Get-Date -Date $EventDate)
               }

               # Apply the Limit, if needed
               if (($Filterhours) -and ($EventDate -ge $Filterhours))
               {
                  # Cleanup the event message (remove leading or trailing whitespaces)
                  $EventEntry = $EventEntry.trim()

                  # Add the Event to the list
                  $FritzEvents += [PSCustomObject]@{
                     Date    = $EventDate
                     Message = $EventEntry
                     IPv4    = $IPv4
                     IPv6    = $IPv6
                  }
               }

               # Cleanup
               $EventDate = $null
               $IPv6 = $null
               $IPv4 = $null
               $EventEntry = $null
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

               # output information. Post-process collected info, and log info (optional)
               $info | Out-String | Write-Verbose

               Write-Warning -Message $e.Exception.Message -WarningAction Continue
               #endregion ErrorHandler
            }
         }
      }
      catch
      {
         # Cleanup
         $FritzEvents = $null
         $FritzBoxSecurePassword = $null
         $FritzBoxLoginPage = $null
         $FritzBoxEventPage = $null
         $SecureStringToBSTR = $null
         $PtrToStringAuto = $null
         $ChallengeRequest = $null
         $Challenge = $null
         $Code1 = $null
         $Code2 = $null
         $SIDRequestBody = $null
         $SIDRequest = $null
         $SID = $null
         $FritzBoxEvents = $null
         $Hours = $null
         $Filterhours = $null

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

         # output information. Post-process collected info, and log info (optional)
         $info | Out-String | Write-Verbose

         $paramWriteError = @{
            Message      = $e.Exception.Message
            ErrorAction  = 'Stop'
            Exception    = $e.Exception
            TargetObject = $e.CategoryInfo.TargetName
         }
         Write-Error @paramWriteError

         # Only here to catch a global ErrorAction overwrite
         exit 1
         #endregion ErrorHandler
      }
      finally
      {
         # Garbage Collection
         [GC]::Collect()
      }
   }

   end
   {
      # Dump to the Terminal
      $FritzEvents

      # Cleanup
      $FritzEvents = $null
      $FritzBoxSecurePassword = $null
      $FritzBoxLoginPage = $null
      $FritzBoxEventPage = $null
      $SecureStringToBSTR = $null
      $PtrToStringAuto = $null
      $ChallengeRequest = $null
      $Challenge = $null
      $Code1 = $null
      $Code2 = $null
      $SIDRequestBody = $null
      $SIDRequest = $null
      $SID = $null
      $FritzBoxEvents = $null
      $Hours = $null
      $Filterhours = $null

      # Garbage Collection
      [GC]::Collect()
   }
}

#region LICENSE
<#
   BSD 3-Clause License
   Copyright (c) 2022, enabling Technology
   All rights reserved.
   Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
   1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>
#endregion LICENSE

#region DISCLAIMER
<#
   DISCLAIMER:
   - Use at your own risk, etc.
   - This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
   - This is a third-party Software
   - The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
   - The Software is not supported by Microsoft Corp (MSFT)
   - By using the Software, you agree to the License, Terms, and any Conditions declared and described above
   - If you disagree with any of the terms, and any conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
