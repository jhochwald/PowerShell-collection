# Windows 10 Client System Bootstrapper

enabling Technology progressive OS deployment (ETPOSD)

Client System Bootstrapper for Windows 10 Enterprise Installations

**This will be moved to a separate repository soon.**

## What is this?

It is part of an internal enabling Technology Project.

We had to deploy a lot of new clients and with this approach we just had to provide an ISO Image/USB-Stick to get that going.

After the installation, you can use the pre deployed PowerShell scripts to upload the AutoPilot Info to your Microsoft 365 Tenant, that will speed up future installations!

## How-To

If you apply _all_ the Files to you Windows 10 ISO file and create a bootable image from it, you will have a Jump started Windows 10 Image.

Rename the `Autounattend_Legacy.xml` or `Autounattend_UEFI.xml` file to `Autounattend.xml` if you want to have a fully unattend installation until the login to your Microsoft 365 tenant (See the hints, notes, and remarks below)!

It will do a plain installation and enroll to AzureAD and Intune (AutoPilot).

When the Installation is finished, login with a Microsoft 365 user that have Admin permissions on the local System and execute `c:\install\start.cmd`.

The `c:\install\start.cmd` file is a wrapper that will do all the magic in the background for you.

Please remember to download the Office 365 Click-2-Run sources before you start the installation! You can download them before you create your install image, this will speed up the process and you don't have to download the sources for each client system!

The Office Suite will be removed soon from the scripts! We use Intune to deploy the Office 365 Suite and Microsoft 365 to activate it.

## Please Note

1st of all: Please review the `c:\install\start.cmd`! Skip the parts that you don't want to be applied. We are not Batch experts, as you might see very quickly.

We decided to stay with the Batch, because this was in use way before we established this new approach and all the users knew about the directory and this file!

1. Please review all the XML, Batch, and PowerShell Files before you apply them!
2. Download Office 365 (See the Batch) - Review the XML
3. Download the Lenovo specific files (Removed to prevent any kind of licensing issues)
4. Review `\srources\$OEM$\$$\System32\sysprep\unattend.xml` very careful
5. The `\srources\$OEM$\$$\System32\Autopilot\AutopilotConfigurationFile.json` will enroll your system to Intune in our test Tenant - Modify or remove this file!
6. The `\ENATEC.ppkg` file will bind your system to AzureAD in our test Tenant - Replace or remove this file!
7. The `\ENATEC.ppkg` file will rename your system - Replace or remove this file!
8. Replace the KMS Server **kms.enatec.net** with your own KMS server. You can also use Microsoft 365 to activate your Microsoft Windows 10 and/or your Office 365 Office Suite, and that is recommended for future use.

### Office 365 - Click-to-Run

The XML is still using KMS to activate the Office Suite! You might want to change this to met you own licensing. We will change everything towards online activation in the future!

## Change-log

Public Change-log (no longer maintained):

- 1.4.7: Add KMS Ping checks for Windows and Office activation
- 1.4.6: Test Release - ALL
- 1.4.5: Change the logging and add errorlevel to all enties - JHO
- 1.4.4: Rewrite this Wrapper Batch file to make it more robust - JHO
- 1.4.3: Tweak the BitLocker part and add auto upload to AzureAD/Intune - JHO
- 1.4.2: Add Storage Sense part - PDU
- 1.4.1: Test Release - ALL
- 1.4.0: Bugfix Release (Error handling) - PDU
- 1.3.12: Test Release - ALL
- 1.3.11: Hardware Vendor handling changed - PDU
- 1.3.10: Hardware Vendor handling online test - JHO
- 1.3.9: Automated Driver installer added - PDU
- 1.3.8: WinGet added - JHO
- 1.3.7: Test with Windows 10 Enterprise Release 2009 - ALL
- 1.3.6: Add the BitLocker part - JHO
- 1.3.5: Remove the Office sources after installation - PDU
- 1.3.4: Change the Autoupdate handling - PDU
- 1.3.3: Remove the WinGet Test - JHO
- 1.3.2: Test Release - ALL
- 1.3.1: Add a WinGet Test - PDU
- 1.3.0: Test Release - ALL
- 1.2.6: Removed all Batch Modules - JHO
- 1.2.5: Test Release - ALL
- 1.2.4: Bugfix for the Modules - JHO
- 1.2.3: Test Release - ALL
- 1.2.2: Removed AutoPilot automated Upload due to login issues - JHO
- 1.2.1: Automated AutoPilot info upload to Intune introduced - JHO
- 1.2.0: Rewrite the complete Wrapper: Use Batch Modules - PDU
- 1.1.3: Test Release - ALL
- 1.1.2: Remove the WiFi Setup - JHO
- 1.1.1: Remove the Ping and VPN Test - JHO
- 1.1.0: Remove the local Domain login - JHO
- 1.0.8: Test Release - ALL
- 1.0.7: Rename the Log File (Now the Module Name) - RBU
- 1.0.6: Change the Log format (Add Time Stamps) - RDU
- 1.0.5: Change Naming convention (Removed here, no in the Provisioning package) - JHO
- 1.0.4: Test Release - ALL
- 1.0.3: Add Intune/AzureAD Provisioning package - JHO
- 1.0.2: Test Release - ALL
- 1.0.1: Hardcoded AutoPilot Info added - JHO
- 1.0.0: Changed to this Wrapper - JHO
- Older: Internal test Releases - ALL

Changes for the scripts should be documented in the scripts file itself.

## License

### BSD 3-Clause License

Copyright (c) 2021, enabling Technology - All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

**THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.**

## Disclaimer

- Use at your own risk, etc.
- This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
- This is a third-party Software
- The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
- The Software is not supported by Microsoft Corp (MSFT)
- By using the Software, you agree to the License, Terms, and any Conditions declared and described above
- If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
