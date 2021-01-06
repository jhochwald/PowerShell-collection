function Get-IPv6InWindows
{
   <#
         .SYNOPSIS
         Get the configured IPv6 value from the registry

         .DESCRIPTION
         Get the configured IPv6 value from the registry
         Transforms the Registry value into human understandable values

         .EXAMPLE
         PS C:\> Get-IPv6InWindows
         All IPv6 components are enabled (0)

         .EXAMPLE
         PS C:\> Get-IPv6InWindows -verbose
         Prefer IPv4 over IPv6 (32)

         Get the configured IPv6 value from the registry, with verbose output

         .LINK
         Set-IPv6InWindows

         .LINK
         https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows

         .LINK
         https://docs.microsoft.com/en-us/troubleshoot/windows-server/networking/configure-ipv6-in-windows#reference

         .NOTES
         Just a wrapper to make the values more human readable.
         This is just a quick and dirty initial version!

         If you find any further values (other then the supported), please let me know!

         Want to modify your IPv6 configuration? Use its companion Set-IPv6InWindows
   #>
   [CmdletBinding(ConfirmImpact = 'None')]
   [OutputType([string])]
   param ()

   begin
   {
      # Cleanup
      $ComponentValue = $null
      $ComponentValueText = $null

      #region BoundParameters
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
   }

   process
   {
      # Get the Value from the registry
      try
      {
         $paramGetItemProperty = @{
            Path          = 'HKLM:\SYSTEM\CurrentControlSet\Services\tcpip6\Parameters'
            Name          = 'DisabledComponents'
            Debug         = $IsDebug
            Verbose       = $IsVerbose
            ErrorAction   = 'Stop'
            WarningAction = 'Continue'
         }
         $ComponentValue = (Get-ItemProperty @paramGetItemProperty | Select-Object -ExpandProperty DisabledComponents -ErrorAction Stop -WarningAction Continue)
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
         }
      }
   }

   end
   {
      # Dump the info
      $ComponentValueText
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
