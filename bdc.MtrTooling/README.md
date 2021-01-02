# bdc.MtrTooling

Microsoft Teams Room (MTR) System tools and utilities as PowerShell Module

## Status

![CI](https://github.com/jhochwald/bdc.MtrTooling/workflows/CI/badge.svg)

## EXAMPLES

```powershell
New-MtrConfigrationFile -ThemeName Custom -CustomThemeImageUrl 'wallpaper.jpg' -RedComponent 100 -BlueComponent 100 -GreenComponent 100
```

Generate a  Microsoft Teams Room (MTR) System configuration file with a custom wallpaper and color settings

```powershell
New-MtrConfigrationFile -Devices -MicrophoneForCommunication 'Microsoft LifeChat LX-6000' -SpeakerForCommunication 'Realtek High Definition Audio' -DefaultSpeaker 'Polycom CX5100' -ContentCameraId 'USB\VID_046D&PID_0843&amp;MI_00\7&17446CF2&0&0000' -ContentCameraInverted $false -ContentCameraEnhancement $true
```

Generate a  Microsoft Teams Room (MTR) System configuration file with custom devices

```powershell
New-MtrConfigrationFile -UserAccount -SkypeSignInAddress 'RanierConf@contoso.com' -ExchangeAddress 'RanierConf@contoso.com' -DomainUsername 'Seattle\RanierConf' -Password 'password' -ConfigureDomain 'domain1, domain2'
```

Generate a  Microsoft Teams Room (MTR) System configuration file with configured user information (Accounts)

```powershell
New-MtrWallpaper
```

Picks a random image, copies to the root folder, and writes XML file

```powershell
Test-MtrWallpaper -Path 'Z:\Desktop\wallpaper\TheBeachView.jpg'
```

## License

### BSD 3-Clause License

Copyright (c) 2020, enabling Technology
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*By using the Software, you agree to the License, Terms and Conditions above!*

---

**DISCLAIMER**

- Use at your own risk, etc.
- This is open-source software, if you find an issue try to fix it yourself. There is no support and/or warranty in any kind
- This is a third-party Software
- The developer of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way
- The Software is not supported by Microsoft Corp (MSFT)
- By using the Software, you agree to the License, Terms, and any Conditions declared and described above
- If you disagree with any of the Terms, and any Conditions declared: Just delete it and build your own solution
