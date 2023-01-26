20# Contribution Guide

This is a guide for everyone interested in contributing to our open source projects. It's based on well known community workflows.

I love PowerShell, and I love to share knowledge, you are encouraged to fork all my open source repositories and make adjustments according to your own preferences. If you really want to contribute, you should consider a [pull request](https://github.com/jhochwald/PowerShell-collection/pulls), this will help me to improve and to share this improvement with the community.

## General Bug Report

If you report a bug, please try to:

- Perform a web / GitHub search to avoid creating a duplicate ticket.
- Include enough information to reproduce the problem.
- Mention the exact version (including our Build) of the project causing you problems, as well as any related software and versions (such as operating system, PowerShell version, dotNET Version, etc.).
- Test against the latest version of the project (and if possible also the master branch) to see if the problem has already been fixed.
- Include as many information as possible and needed to understand the issue.
- Include a link to a gist you provided (if applicable).

For a guide to submitting good bug reports, please read [Painless Bug Tracking](http://www.joelonsoftware.com/articles/fog0000000029.html).

## Asking Questions

Depending on the nature and urgency of your question, pick one of the following channels for it:

- Search the web for it, you've done that already, right?
- StackOverflow, or other sites
- GitHub Issues from this and other projects (_The best option in my opinion_)
- Search the GitHub Gist repository
- Use the corresponding Gist and place a comment there, if exists
- Use the corresponding Blog Post and place a comment there, if exists
- Any major PowerShell related site

Do not email me directly, unless you have a very good reason. The only one that make sense to me: If you found a security related issue!

## Contributing Code

If you want to contribute code, please try to:

- Follow the same coding style as used in the project. Pay attention to the usage of tabs, spaces, newlines and brackets. Try to copy the aesthetics the best you can.
- When possible, add an automated ([Pester](https://github.com/pester/Pester)) test that verifies your change.
- Write [good commit messages](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html), explain what your patch does, and why it is needed.
- Keep it simple: Any patch that changes a lot of code or is difficult to understand should be discussed before you put in the effort. We can discuss that right here in the Issue tracker.

Once you have tried the above, create a GitHub [pull request](https://github.com/jhochwald/PowerShell-collection/pulls) to notify me of your changes.

### Code Signing

If you have a valid codesigning certificate, please sign the contributed file within the `signed` directory.
If you don't have a valid codesigning certificate, just go ahead and contribute. I will take care about the signing for you.

## License

Please specify your license terms! This only applies for new modules and/or scripts. You are not allowed to change the license terms of the existing code! There should be enough options out there.

Please use a valid license, best one that is approved by the Free Software Foundation.

If you do not specify any other License or Terms, I apply the following default:

### License Terms

Copyright (c) 2023, enabling Technology <[http://enatec.io](http://enatec.io)>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#### BSD-3-Clause

This is the **BSD-3-Clause** license.

### Your Name

I will publish your name to mention you as the contributor. If you don't want that, please let us know.

## Further reading

You might also read these two blog posts about contributing code:

- [Open Source Contribution Etiquette](http://tirania.org/blog/archive/2010/Dec-31.html) by _Miguel de Icaza_
- [Don’t "Push" Your Pull Requests](https://www.igvita.com/2011/12/19/dont-push-your-pull-requests/) by _Ilya Grigorik_
