# Kuando Busylight handler

bdcBusylight is my new pet project. Goal of bdcBusylight is to set the color of a connected Kuando Busylight based on the status of my Microsoft Teams Rooms (MTR) System.

## What is it

For now, only the following two functions are published:

**Set-bdcBusylightColor**
*Set the color of a connected Kuando Busylight device*

**Set-bdcBusylightStatus**
*Wrapper function for Set-bdcBusylightColor to set the color on a connected Kuando Busylight device*

### What is not published (yet)

I use a Microsoft Graph call to get the current status of my Microsoft Teams Rooms (MTR) System. I still have some issues with the Microsoft Graph Module, so I still use some handcrafted RESTful calls (based on the `Invoke-RestMethod` command). As soon as I get everything working as expected, I will remove all hard coded parts and I will create functions for it.

### Platform

For now just Windows. I have a mini PC that runs Windows, and bdcBusylight should run on a Microsoft Teams Rooms (MTR) System.
To make it more flexible, I will try to bring support for Linux. That would make it easier to use Single-Board-Computer (SBC) solutions like a Raspberry Pi, or others.

## Samples

Here are some Examples of the functions.

### Set-bdcBusylightColor

```powershell
Set-bdcBusylightColor
```
Turn the Busylight off.

```powershell
Set-bdcBusylightColor -Color green
```
Set the Busylight color to green.

Please see the help:

```powershell
Get-Help Set-bdcBusylightColor
```

### Set-bdcBusylightColor

```powershell
Set-bdcBusylightStatus -Status Available
```
Set the Busylight color to green, based on the status of a Microsoft Teams user.

Please see the help:

```powershell
Get-Help Set-bdcBusylightStatus
```

## Requirements

You will need the BusylightSDK.DLL, as the PowerShell scripts communicates with the device by calling functions in the DLL.
You can get it from the SDK, at https://www.plenom.com/support/develop/.

Windows! At least for now. I use the BusylightSDK.DLL and this will require Windows.

## License

### BSD 3-Clause License

Copyright (c) 2020, Joerg Hochwald
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
