function Set-IPv6InWindows
{
   <#
         .SYNOPSIS
         Configuring the IPv6 value in windows the registry

         .DESCRIPTION
         Configuring the IPv6 value in windows the registry
         Based on the Microsoft Information, Microsoft KB929852, RFC 3484, and RFC 4291

         .PARAMETER Force
         Forces the cmdlet to set a property on items that cannot otherwise be accessed by the user.

         .PARAMETER Value
         Specifies the value of the property.

         .EXAMPLE
         PS C:\> Set-IPv6InWindows -Value 0 -WhatIf

         Enable all IPv6 components

         .EXAMPLE
         PS C:\> Set-IPv6InWindows -Value 32 -verbose

         Prefer IPv4 over IPv6 will be set, with a verbose output

         .LINK
         Get-IPv6InWindows

         .LINK
         https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows

         .LINK
         https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows#reference

         .NOTES
         Next version might also support test inputs instead of the numbers (Dec).
         This is just a quick and dirty initial version!

         Want to knwo what is set in your registry? Use its companion Get-IPv6InWindows
   #>
   [CmdletBinding(ConfirmImpact = 'Medium',
      SupportsShouldProcess)]
   [OutputType([string])]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [ValidateNotNullOrEmpty()]
      [ValidateSet('32', '17', '16', '1', '10', '8', '4', '2', '255', '0')]
      [Alias('IPv6Configuration', 'IPv6Config')]
      [int]
      $Value = 0,
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName)]
      [switch]
      $Force
   )

   begin
   {
      #region BoundParameters
      if (($PSCmdlet.MyInvocation.BoundParameters['Force']).IsPresent)
      {
         $IsForced = $true
      }
      else
      {
         $IsForced = $false
      }

      if (($PSCmdlet.MyInvocation.BoundParameters['Verbose']).IsPresent)
      {
         $IsVerbose = $true
      }
      else
      {
         $IsVerbose = $false
      }

      if (($PSCmdlet.MyInvocation.BoundParameters['Debug']).IsPresent)
      {
         $IsDebug = $true
      }
      else
      {
         $IsDebug = $false
      }
      #endregion BoundParameters

      #region ValueSwitch
      switch ($Value)
      {
         0
         {
            $ValueText = ('Enable all IPv6 components ({0})' -f $Value)
         }
         255
         {
            $ValueText = ('Disable all IPv6 components ({0})' -f $Value)

            Write-Warning -Message 'This is not recommended, Think about 32 (Prefer IPv4 over IPv6) instead.'
         }
         2
         {
            $ValueText = ('Disable 6to4 ({0})' -f $Value)
         }
         4
         {
            $ValueText = ('Disable ISATAP ({0})' -f $Value)
         }
         8
         {
            $ValueText = ('Disable Teredo ({0})' -f $Value)
         }
         10
         {
            $ValueText = ('Disable Teredo and 6to4  ({0})' -f $Value)
         }
         1
         {
            $ValueText = ('Disable all tunnel interfaces ({0})' -f $Value)
         }
         16
         {
            $ValueText = ('Disable all LAN and PPP interfaces ({0})' -f $Value)
         }
         17
         {
            $ValueText = ('Disable all LAN, PPP and tunnel interfaces ({0})' -f $Value)
         }
         32
         {
            $ValueText = ('Prefer IPv4 over IPv6 ({0})' -f $Value)
         }
         default
         {
            $paramWriteError = @{
               Exception        = ('Unknown value found: {0}' -f $Value)
               Message          = ('Sorry, but this cmdlet does NOT support the value {0}' -f $Value)
               Category         = 'OperationStopped'
               CategoryActivity = 'Please check the supported values'
               TargetObject     = $Value
               ErrorAction      = 'Stop'
            }
            Write-Error @paramWriteError

            # Only here to catch a global ErrorAction overwrite
            exit 1
         }
      }

      Write-Verbose -Message ('New IPv6 configuration: {0}' -f $ValueText)
      #endregion ValueSwitch

      # Get the Value from the registry
      $paramGetItemProperty = @{
         Path          = 'HKLM:\SYSTEM\CurrentControlSet\Services\tcpip6\Parameters'
         Name          = 'DisabledComponents'
         Debug         = $IsDebug
         Verbose       = $IsVerbose
         ErrorAction   = 'Continue'
         WarningAction = 'Continue'
      }
      $ComponentValue = (Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty DisabledComponents)

      if ($Value -eq $ComponentValue)
      {
         # Don't go any further!
         $paramWriteError = @{
            Exception        = 'Old an new value are the same'
            Message          = 'The new value matches the existing IPv6 configuration!'
            Category         = 'OperationStopped'
            CategoryActivity = 'No further action is required'
            TargetObject     = $Value
            ErrorAction      = 'Stop'
         }
         Write-Error @paramWriteError

         # Only here to catch a global ErrorAction overwrite
         exit 1
      }

      #region
      switch ($ComponentValue)
      {
         0
         {
            $ComponentValueText = ('All IPv6 components are enabled ({0})' -f $ComponentValue)
         }
         255
         {
            $ComponentValueText = ('All IPv6 components are disabled ({0})' -f $ComponentValue)
         }
         2
         {
            $ComponentValueText = ('6to4 is disabled ({0})' -f $ComponentValue)
         }
         4
         {
            $ComponentValueText = ('ISATAP is disabled ({0})' -f $ComponentValue)
         }
         8
         {
            $ComponentValueText = ('Teredo is disabled ({0})' -f $ComponentValue)
         }
         10
         {
            $ComponentValueText = ('Teredo and 6to4 is disabled ({0})' -f $ComponentValue)
         }
         1
         {
            $ComponentValueText = ('All tunnel interfaces are disabled ({0})' -f $ComponentValue)
         }
         16
         {
            $ComponentValueText = ('All LAN and PPP interfaces are disabled ({0})' -f $ComponentValue)
         }
         17
         {
            $ComponentValueText = ('All LAN, PPP and tunnel interfaces are disabled ({0})' -f $ComponentValue)
         }
         32
         {
            $ComponentValueText = ('Prefer IPv4 over IPv6 ({0})' -f $ComponentValue)
         }
         default
         {
            $ComponentValueText = ('Unknown value found: {0}' -f $ComponentValue)

            Write-Warning -Message $ComponentValueText
         }
      }

      Write-Verbose -Message ('Existing IPv6 configuration: {0}' -f $ComponentValueText)
      #endregion
   }

   process
   {
      if ($PSCmdlet.ShouldProcess('Existing IPv6 configuration', 'modify'))
      {
         try
         {
            $paramSetItemProperty = @{
               Path          = 'HKLM:\SYSTEM\CurrentControlSet\Services\tcpip6\Parameters'
               Name          = 'DisabledComponents'
               Value         = $Value
               Force         = $IsForced
               Debug         = $IsDebug
               Verbose       = $IsVerbose
               Confirm       = $false
               ErrorAction   = 'Stop'
               WarningAction = 'Continue'
            }
            $null = (Set-ItemProperty @paramSetItemProperty)
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

            Write-Verbose -Message $info

            Write-Error -Message ($info.Exception) -ErrorAction Stop

            # Only here to catch a global ErrorAction overwrite
            exit 1
            #endregion ErrorHandler
         }

         # Get the Value from the registry
         $ComponentValue = $null
         $paramGetItemProperty = @{
            Path          = 'HKLM:\SYSTEM\CurrentControlSet\Services\tcpip6\Parameters'
            Name          = 'DisabledComponents'
            Debug         = $IsDebug
            Verbose       = $IsVerbose
            ErrorAction   = 'Continue'
            WarningAction = 'Continue'
         }
         $ComponentValue = (Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty DisabledComponents)

         if ($Value -eq $ComponentValue)
         {
            Write-Verbose -Message 'New IPv6 configuration was applied'
         }
         else
         {
            # Don't go any further!
            $paramWriteError = @{
               Exception        = 'Unable to apply IPv6 configuration'
               Message          = ('New IPv6 configuration was NOT applied! You requested {0}, but the set is {1}' -f $ValueText, $ComponentValue)
               Category         = 'OperationStopped'
               CategoryActivity = 'Please check the registry and your permissions'
               TargetObject     = $Value
               ErrorAction      = 'Stop'
            }
            Write-Error @paramWriteError

            # Only here to catch a global ErrorAction overwrite
            exit 1
         }
      }
   }

   end
   {
      ('New IPv6 configuration is set to: {0}' -f $ValueText)
   }
}
#region LICENSE
<#
      BSD 3-Clause License
      Copyright (c) 2021, enabling Technology
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
