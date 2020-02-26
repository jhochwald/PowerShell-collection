# Bootstrap Microsoft 10 Workstation

Bootstrap Microsoft 10 Workstation configuration, optimize and tweaks.

## What it does

Apply some basic configuration. Installs some Packages (chocolatey), and PowerShell Modules.

## Why

I do a basic Windows 10 Unattended for Windows 10 Professional or Windows 10 Enterprise. The unattended installation itself doesn't customize to much.

Then I mount an install Share (read only) and execute the `start.cmd` from this repository. This will will jumpstart the system with some basics I would like to have on all regular systems. For detached systems (not part of my network), I use an USB thumbdrive to jumpstart them.

I did a lot of the stuff this batches and script do with DSC in the past, but I would like to keep the DSC part plain and simple (or at least simpler).

## Installation

After the installation, or whenever you would like to apply it (again), just open an elevated PowerShell, change to the directory where the files of this directory are availible and execute the following:

```batch
start.cmd
```

### Workstation Addition

After the installation and the jumpstart, just open an elevated PowerShell and execute the following:

```powershell
C:\scripts\PowerShell\Install-ChocoPackages_Workstation.ps1
```

Please review the package selection in the `Install-ChocoPackages_Workstation.ps1` script.

#### Optional

If you like to have a clean desktop, just execute the following (in an elevated PowerShell

```powershell
C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1
```

### Developer Addition

After the installation and the jumpstart, just open an elevated PowerShell and execute the following:

```powershell
C:\scripts\PowerShell\Install-ChocoPackages_dev.ps1
```

Please review the package selection in the `Install-ChocoPackages_dev.ps1` script.

#### Optional

If you like to have a clean desktop, just execute the following (in an elevated PowerShell

```powershell
C:\scripts\PowerShell\Remove-AllPublicDesktopLinks.ps1
```

#### Please note

There is some legacy stuff in here. I need to cleanup a few things in the future!

## Missing peaces

Not everything is transfered to this process and therefore it's not here in this repository.

### PowerShell Profiles

During the process, my scripts creates empty profiles. This is just implemented to prevent any warnings or errors. After the Jumpstart process is done, I manually replace them with my default ones. Something I have to implement here, but they need some cleanup first :)

And, I still do all the distribution and updates via DSC

### PowerShell Scripts

My `C:\scripts\PowerShell\` directory contains some default scripts that I use a lot, some are also referenced in my PowerShell Profiles. These scripts are missing here!

Due to the sollowing reasons:

- Some might contain stuff that I will not publish to a public repository (*they do contain secrets, credentials or IP of others*)
- Many of them are old and need a refresh (or replacement)
- Some are outdated and should be replaced by functions that other PowerShell Modules now provide
- I still do all the distribution and updates via DSC

### PowerShell Modules

I use a lot of PowerShell Modules from the PowerShell Gallery. For now, I still install then via my existing DSC implementation. I plan to transfer this towards this step(s) towards this repository.

### Visual Studio Code stuff

I use a basic Setup for Visual Studio Code, that I apply via the [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) extension. To keep everything consistent, I remove all the extensions that I installed by chocolatey and then let the [Settings Sync](https://github.com/shanalikhan/code-settings-sync.git) extension take it from there.

The [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync) extension also maintain extensions, and Visual Studio Code itself handles to updates well now. So chocolatey is no longer needed to do this job.

But all the Visual Studio Code stuff here is something I would like to have on every single system.

## License

BSD 3-Clause License

Copyright (c) 2020, Beyond Datacenter
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Disclaimer

- Use at your own risk, etc.
- This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
- This is a third-party Software
- The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
- The Software is not supported by Microsoft Corp (MSFT)
- By using the Software, you agree to the License, Terms, and any Conditions declared and described above
- If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
