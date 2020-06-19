function Set-PublishUserActivities
{
   <#
      .SYNOPSIS
      Enable or Disable the collection of Activity History

      .DESCRIPTION
      Enable or Disable the collection of Activity History in Windows 10. The default is to disable it!

      .PARAMETER enable
      Enable the collection of Activity History in Windows 10

      .EXAMPLE
      PS C:\> Set-PublishUserActivities

      Disable the collection of Activity History in Windows 10

      .EXAMPLE
      PS C:\> Set-PublishUserActivities -enable

      Enable the collection of Activity History in Windows 10

      .NOTES
      Quick and diry function

      .LINK
      https://lifehacker.com/windows-10-collects-activity-data-even-when-tracking-is-1831054394

      .LINK
      https://www.tenforums.com/tutorials/100341-enable-disable-collect-activity-history-windows-10-a.html#option2s2
   #>
   [CmdletBinding(ConfirmImpact = 'None',
      SupportsShouldProcess)]
   param
   (
      [Parameter(ValueFromPipeline,
         ValueFromPipelineByPropertyName,
         Position = 1)]
      [switch]
      $enable = $false
   )

   begin
   {
      $RegistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
      $RegistryName = 'PublishUserActivities'

      if ($enable)
      {
         $RegistryValue = '1'
         $SetAction = 'Enable'
         Write-Verbose -Message 'Enable the collection of Activity History'
      }
      else
      {
         $RegistryValue = '0'
         $SetAction = 'Disable'
         Write-Verbose -Message 'Disable the collection of Activity History'
      }
   }

   process
   {
      if ($pscmdlet.ShouldProcess('Collection of Activity History', $SetAction))
      {
         try
         {
            $SetPublishUserActivitiesParams = @{
               Path          = $RegistryPath
               Name          = $RegistryName
               Value         = $RegistryValue
               PropertyType  = 'DWORD'
               Force         = $true
               Confirm       = $false
               ErrorAction   = 'Stop'
               WarningAction = 'SilentlyContinue'
            }
            $null = (New-ItemProperty @SetPublishUserActivitiesParams)
            Write-Verbose -Message 'Collection of Activity History value modified.'
         }
         catch
         {
            Write-Warning -Message 'Unable to modify the collection of Activity History value!'
         }
      }
   }
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, enabling Technology
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
      - If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
#>
#endregion DISCLAIMER
