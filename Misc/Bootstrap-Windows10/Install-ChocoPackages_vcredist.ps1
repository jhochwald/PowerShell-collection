#requires -Version 1.0 -RunAsAdministrator

<#
      .SYNOPSIS
      Download and install some legacy Microsoft Visual C++ Redistributable

      .DESCRIPTION
      Download and install some legacy Microsoft Visual C++ Redistributable as chocolatey default packages

      .NOTES
      We install the following: 2005, 2008, 2010, 2010, 2013, and 2015

      Version 1.0.4

      .LINK
      http://beyond-datacenter.com

      .LINK
      https://chocolatey.org/docs
#>
[CmdletBinding(ConfirmImpact = 'Low',
SupportsShouldProcess)]
param ()

begin {
   try 
   {
      $null = ([Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor 3072)
   }
   catch 
   {
      Write-Verbose -Message 'Unable to set PowerShell to use TLS 1.2.'
   }

   # Use Windows built-in compression instead of downloading 7zip
   $env:chocolateyUseWindowsCompression = 'true'

   $AllChocoPackages = @(
      'vcredist2005'
      'vcredist2008'
      'vcredist2010'
      'vcredist2012'
      'vcredist2013'
      'vcredist2015'
   )

   # Initial Package Counter
   $PackageCounter = 1
}

process {
   foreach ($ChocoPackage in $AllChocoPackages)
   {
      try 
      {
         Write-Progress -Activity ('Installing ' + $ChocoPackage) -Status ('Package ' + $PackageCounter + ' of ' + $($AllChocoPackages.Count)) -PercentComplete (($PackageCounter / $AllChocoPackages.Count) * 100)

         if ($pscmdlet.ShouldProcess($ChocoPackage, 'Install'))
         {
            $null = (& "$env:ChocolateyInstall\bin\choco.exe" install $ChocoPackage -y --force --params 'ALLUSERS=1')
         }

         # Add Package Step
         $PackageCounter++
      }
      catch 
      {
         Write-Warning -Message ('Installation of ' + $ChocoPackage + ' failed!')
      
         # Add Package Step
         $PackageCounter++
      }
   }
}

#region LICENSE
<#
      BSD 3-Clause License

      Copyright (c) 2020, Beyond Datacenter
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