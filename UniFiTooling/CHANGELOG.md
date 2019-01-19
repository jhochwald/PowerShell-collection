# Changelog

All notable changes to the **UniFiTooling** project will be documented in this file.

---

### 1.0.8 - 2019-01-19

Mainly a bugfix and refactoring release

#### Added

- `Get-UniFiIsAlive` - Use a simple API call to see if the session is alive (internal not exported function)
- `ConvertTo-UnixTimeStamp` - ConvertTo-UnixTimeStamp (Helper)
- `ConvertFrom-UnixTimeStamp` - Converts a Timestamp (Epochdate) into Datetime (Helper)
- `Get-HostsFile` - Print the HOSTS File in a more clean format (Helper)
- `Remove-HostsEntry` - Removes a single Hosts Entry from the HOSTS File (Helper)
- `Add-HostsEntry` - Add a single Hosts Entry to the HOSTS File (Helper)
- `Get-UnifiSpeedTestResult` - Get the UniFi Security Gateway (USG) Speed Test results

#### Changed

- `Get-UnifiSpeedTestResult` has now filtering and returns values human readable
- All commands now use `Get-UniFiIsAlive` internally. That should make it easier for new users.
- Refactored some of the code that handles all errors.

### 1.0.7 - 2019-01-14

Mainly a bugfix and refactoring release

#### Fixed

- Position numbers corrected (Now starts with 0 instead off 1)
- Found the following issue: Even if an obejct is not found (e.g. network) the UniFi API returns OK (200) with null bytes in Data. That is OK, but we need a workaround. Added the Workaround to `Get-UnifiFirewallGroupDetails` and `Get-UnifiNetworkDetails` for testing.

#### Added

- `Get-UnifiFirewallGroupDetails` -Related to #10
- Git Attributes File
- Editor Config
- Add `License.md`, a Markdown version of `LICENSE`

#### Changed

- Markdown Documents tweaked (Header)
- Git Ignore extended
- Add Multi valued inputs to `Get-UnifiNetworkDetails`
- Add `-Id` parameter to `Get-UnifiNetworkDetails`. This replaced the -UnifiNetworkName` parameter - Related to #9
 - `-UnifiNetworkName` is now a legacy alias, necessary to make it a non breaking change
 - For the parameter `-UnifiNetworkName` an ID (`network_id`) must be used, necessary to make it a non breaking change
- Add `-name` parameter to `Get-UnifiNetworkDetails` - Related to #9
- Moved `Get-UnifiFirewallGroupBody` from Public to Private (No longer exported as command)

### 1.0.6 - 2019-01-13

Mainly a bugfix and refactoring release

#### Added

- Set `$ProgressPreference` to `'SilentlyContinue'` - #7
- `CHANGELOG.md` (this file) is back
- New function `New-UniFiConfig` - #1

#### Changed

- Build Process optimized
- Add Verbose messages to `Get-UniFiConfig`

### 1.0.5 - 2019-01-12

Mostly build related changes

#### Changed

- Changed the Build System - #3
- Describe the config.json handling #2
- `Invoke-UniFiCidrWorkaround` now has the parameter `-6` to handle IPv6 CIDR data - #5

#### Removed

- `Invoke-UniFiCidrWorkaroundV6` is now part of `Invoke-UniFiCidrWorkaround` - #5

### 1.0.4 - 2019-01-08

Mostly build related changes

#### Changed

- Tweak the build system
- Samples optimized

### 1.0.3 - 2019-01-07

Mostly Sample Use case related

#### Added

- Sample: `UpdateUniFiWithLatestExchangeOnlineEndpoints` - Update existing UniFi Firewall Groups with the latest Exchange Online Endpoints.
- Sample: `UpdateUniFiVpnPeerIP` - Update a VPN PeerIp for a given UniFi Network (IPSec VPN with dynamic IP)

#### Fixed

- Debug output removed

### 1.0.2 - [Unreleased]

Rework some stuff (caused by naming issues)

### 1.0.1 - 2019-01-07

Initial public release

#### Added

- `Invoke-UniFiCidrWorkaroundV6` for CIDR handling
- `Invoke-UniFiCidrWorkaround` for CIDR handling

### 1.0.0 - [Unreleased]

Migrate to a real PowerShell Module

#### Added

- Samples
- XML/MAML Documentation
- `SYNOPSIS` for all functions
- `config.json` instead of hardcoded configuration

#### Changed

- Removed all internal systems (hardcoded for internal use)

### 0.9.1 - [Unreleased]

Internal Test Build - No change to the codebase

#### Deprecated

- `Invoke-UBNT*` is now `Invoke-UniFi*`

### 0.9.0 - [Unreleased]

Initial internal Release

#### Added

- Controller Parameter (URI) in the Header of the PS1 File

#### Changed

- Migrated `Invoke-UBNTApiLogin` and `Invoke-UBNTApiLogout` from Invoke-WebRequest to Invoke-RestMethod
- Better Session handling for `Invoke-UBNTApiRequest`

### 0.9.0 - [Unreleased]

Initial internal Release

#### Added

- `Invoke-UBNTApiLogin` - With harcoded credentials and Controller info
- `Invoke-UBNTApiLogout` - With harcoded Controller info
- `Invoke-UBNTApiRequest` - Universal Invoke-RestMethod wrapper, tweaked for UBNT Equipment

---

### Semantic Versioning

We follow the [Semantic Versioning](https://semver.org/spec/v2.0.0.html) 2.0.0 guidelines, whenever possible.

#### Version numbering

* `MAJOR` version with incompatibilities and/or possible breaking changes,
* `MINOR` version that add functionality in a mostly backwards-compatible manner
* `PATCH` version mostly backwards-compatible bug fixes and small changes.

Sometimes, we use additional labels for pre-release and build metadata, e.g. `MAJOR.MINOR.PATCH-Beta`.
If we run a special build, we also might append this to the regular format, e.g. `MAJOR.MINOR.PATCH.BUILD`.

---

### Changelog Information

The format is mostly based on the idea of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

#### Date Format

**`YYY-MM-DD`** (2018-12-02 for December 2nd, 2018)

#### Changes

We group changes an describe there impact as follows:

**`Added`** for new features

**`Changed`** for changes in existing functionality

**`Deprecated`** for once-stable features removed in upcoming releases

**`Removed`** for deprecated features removed in this release

**`Fixed`** for any bug fixes

**`Security`** to invite users to upgrade in case of vulnerabilities

#### Not released

We mark internal Releases and test builds with **`[Unreleased]`**

#### Yanked Releases

Yanked releases are versions that had to be pulled because of a serious bug or security issue.

We mark yanked Releases with **`[YANKED]`**

---

### Copyright

Copyright (c) 2019, [enabling Technology](http://www.enatec.io/)
All rights reserved.
