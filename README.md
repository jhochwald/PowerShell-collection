# Josh's PowerShell collection

A collection of PowerShell Scripts, Tools, and Modules. Mostly related to some of my projects, my work, or just a blog post of me.

Most of the stuff here is also available as a [Gist](https://gist.github.com/jhochwald) or on my personal [blog](http://hochwald.net).

## What is here?

The stuff here is mostly related to:

- [ActiveDirectory](ActiveDirectory) (Active Directory related) **Legacy**
- [AdvancedInstaller](AdvancedInstaller) (AdvancedInstaller related)
- [AzureAD](AzureAD) (Azure Active Directory related)
- [Exchange](Exchange) (On Premises) **Legacy**
- [ExchangeOnline](ExchangeOnline) (Exchange Online, part of Office 365)
- [MicrosoftTeams](MicrosoftTeams) (Part of Office 365)
- [Misc](Misc) (Misc Tools and Scripts that might come handy)
- [Office365](Office365) (All other Office 365 related)
- [Office_Related](Office_Related) (Stuff Office 201x and 365 Client related) **Legacy**
- [Skype_for_Business](Skype_for_Business) (On Premises Server and Client) **Legacy**
- [UniFiTooling](UniFiTooling) (UBNT UniFi SDN) **Legacy**
- [WSUS](WSUS) (Windows Server Update Services related) **Legacy**

### Legacy Notice

I no longer run Exchange, Skype for Business, or any other Office Server on Premises.
This is my personal [reaction](https://hochwald.net/microsoft-rolls-back-decision-to-take-away-internal-usage-rights-from-partners/) to the changes that Microsoft [announced](https://hochwald.net/microsoft-is-going-to-kill-internal-use-rights-benefit-for-partners/) for the Internal Use Rights (IUR) program. I know that they decided to reverse that changes and in theory, I could still legally use the software. However, I decided to decommission everything licensed under the terms of the Internal Use Rights (IUR) program.
In my opinion, the community always should have some benefits from the Internal Use Rights (IUR) program and/or Action Pack. Now that I decided to drop out, there will be no more such benefits.

I will _no longer maintain_ the scripts related to the Microsoft Office (on Premises) servers. They will remain here, but unmaintained. Fork the repository and maintain or extend them if you like to. The [License](https://github.com/jhochwald/PowerShell-collection/blob/master/LICENSE) allows that easily.

### Please note

Some, or better most, of the stuff here was a function. This is because I like functions more (my personal preference). I converted most to single files. You can convert them back if you like.

#### Why so detailed?

I was asked why all my scripts contain so many comments, and why they are so well formatted... I hope you do not just download them and let them run (What is dangerous anyway). They should show you how to build and create your own tooling! That is the main reason why I try to avoid the usage of aliases within my scripts and use splatting to make them more human readable.

#### Why in general?

Many ask me that question!
The answer is simple: "*I like to contribute back to the community!*"
The long answer: "*I still try to automate all the things! And I love to show what PowerShell can do... As a result, I started to publish a lot of code. Things I build, things I like, or just things I found interesting to build :-)*"

### Found a bug or Issue?

If you find something bad (like a bug, error, or any issue), please report it here by open an [Issue](https://github.com/jhochwald/PowerShell-collection/issues).

Or even better: Fork the Repository, fix it and submit a [pull request](https://github.com/jhochwald/PowerShell-collection/pulls), so others can participate too!

See the [Contribution Guide](CONTRIBUTING.md) for more details!

### Contribution

More then welcome! Please see the [Contribution Guide](CONTRIBUTING.md) for more details!

### Signed Code

~~I will sign all scripts with a valid certificate soon, again.~~

~~In the meantime, I use a test certificate from [Ascertia.com](https://www.ascertia.com) for testing everything.
Please note: The [Ascertia.com](https://www.ascertia.com) might throw error, caused by a missing root certificate trust! This is a known issue, but for mow I need a test certificate!~~

~~I sign all files with a time stamp from an official [Timestamp Server](http://timestamp.digicert.com). A time stamp prevents the script from failing if the certificate expires because users and programs can verify that the certificate was valid at the time of signing.~~

~~I sign all scripts, modules, executables, and installers. In addition, all scripts and modules will be available plain (without signature).~~

#### Any ideas?

I still search for a free code signing certificate for my open-source projects. So, does anyone know a source?

Even if there is no "free" version for my open-source projects, I would also pay for a valid certificate (again). However, most of the sources I found are not cheap! Does anyone know a cheap source for a signing certificate?

### Installers

In the past, I published a few things with a (signed) MSI installer package. These MSI installers were very basic; I know!

~~But there is hope: The [Advanced Installer Team](http://www.advancedinstaller.com/) sponsored a _free_ [Advanced Installer Professional](https://www.advancedinstaller.com/top-professional-features.html) license for my open-source work. So things will change soon, and I will provide (much better) installers again in the very near future.~~
I no longer have a license for [Advanced Installer Professional](https://www.advancedinstaller.com/top-professional-features.html). 

I, still, highly recommend [Advanced Installer](http://www.advancedinstaller.com/), because it's they have a great set of [features](https://www.advancedinstaller.com/top-exclusive-features.html), and it fits perfect to my tooling and existing workflow. I used the [free version](https://www.advancedinstaller.com/top-freeware-features.html) to build some of my basic installers before. I switched to the [Professional](https://www.advancedinstaller.com/top-professional-features.html) version only because it can do a few more things I really needed. ~~Mainly the automated handling of digital signatures and the integration into my existing Continuous Integration chain.~~

### Continuous Deployment

~~I will transfer this project to my existing [TeamCity](https://www.jetbrains.com/teamcity/) Continuous Integration (CI) chain soon. As part of that I started to tweak a bit further (under the hood), like creating a few basic pester tests. I will publish all the stuff that I use for it as well.~~

~~My goal is to automate the complete Continuous Integration (CI) and Continuous Delivery (CD) process like we did it within my old company. As a result, much better code should land here very soon.
But: There is no timeframe planned, at least not yet!~~

### Default License

In my opinion: All the stuff here should be free, and the license should be as flexible as possible.

**BSD 3-Clause License**

Copyright (c) 2019, enabling Technology <[http://enatec.io](http://enatec.io)>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*By using the Software, you agree to the License, Terms and Conditions above!*

---

**This is a third-party Software!**

The developer(s) of this Software is NOT sponsored by or affiliated with Microsoft Corp (MSFT) or any of its subsidiaries in any way

The Software is not supported by Microsoft Corp (MSFT)!
