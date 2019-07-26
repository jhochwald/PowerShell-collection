#requires -Version 1.0

<#
    .SYNOPSIS
    Uninstalls the old and retired Antispam Agents from an Exchange Server

    .DESCRIPTION
    Microsoft announced that they deprecated the support for the SmartScreen Antispam content filters for Exchange Servers. This script uninstalls the old an retired SmartScreen Antispam Agents from the local Exchange Server.
    This is an easy to use and light weight replacement for Uninstall-AntiSpamAgents.ps1 from the \Scripts of your Exchange Installation, it will remove just the dead parts and leave the rest as it is. Some find that it might be better to leave the rest intact.

    .EXAMPLE
    PS C:\> Remove-AntiSpamAgents

    .NOTES
    Find a suitable an solid replacement solution for your email hygiene. This could be any 3rd party solution on premise or cloud. Never use email without any good email hygiene!

    If you want, you might run the Uninstall-AntiSpamAgents.ps1 from the \Scripts folder created by Setup during Exchange installation. It removes erything related to the AntiSpamAgents.

    Taken from the links below.

    .LINK
    https://blogs.technet.microsoft.com/exchange/2016/09/01/deprecating-support-for-smartscreen-in-outlook-and-exchange/

    .LINK
    https://blogs.technet.microsoft.com/exchange/2017/03/23/exchange-server-edge-support-on-windows-server-2016-update/
#>
[CmdletBinding(ConfirmImpact = 'Medium',
SupportsShouldProcess = $true)]
param ()

begin
{
  # Constants
  $STP = 'SilentlyContinue'

  # Agents to remove
  $TransportAgentsToRemove = 'Content Filter Agent', 'Sender Id Agent', 'Protocol Analysis Agent'
}

process
{
  # Loop over the List
  foreach ($TransportAgentToRemove in $TransportAgentsToRemove)
  {
    # Do we have the agent we would like to remove?
    if (Get-TransportAgent -Identity $TransportAgentToRemove -ErrorAction $STP -WarningAction $STP)
    {
      Write-Verbose -Message "Try to remove $TransportAgentToRemove"

      try
      {
        # Do it, or dry run it?
        if ($pscmdlet.ShouldProcess("$TransportAgentToRemove", 'Remove TransportAgent'))
        {
          # Remove it...
          $paramUninstallTransportAgent = @{
            Identity      = $TransportAgentToRemove
            ErrorAction   = $STP
            WarningAction = $STP
            Confirm       = $false
          }
          $null = (Uninstall-TransportAgent @paramUninstallTransportAgent)
        }
      }
      catch
      {
        # Whoopsss
        Write-Warning -Message "Unable to remove $TransportAgentToRemove"
      }

      Write-Verbose -Message "$TransportAgentToRemove was removed"
    }
    else
    {
      Write-Verbose -Message "Sorry, $TransportAgentToRemove was not found..."
    }
  }

}

#region License
<#
    Copyright (c) 2016, Joerg Hochwald (http://jhochwald.com). All rights reserved.

    Redistribution and use in source and binary forms, with or without modification, are permitted
    provided that the following conditions are met:

    1.	Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

    2.	Redistributions in binary form must reproduce the above copyright notice, this list of
    conditions and the following disclaimer in the documentation and/or other materials
    provided with the distribution.

    3.	Neither the name of the copyright holder nor the names of its contributors may be used
    to endorse or promote products derived from this software without specific prior
    written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
    IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    By using the Software, you agree to the License, Terms and Conditions above!
#>

<#
    This is a third-party Software!

    The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way

    The Software is not supported by Microsoft Corp (MSFT)!
#>
