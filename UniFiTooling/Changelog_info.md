# Changelog information

All notable changes to the **UniFiTooling** project will be documented in [CHANGELOG.md](CHANGELOG.md).

The [CHANGELOG.md](CHANGELOG.md) is created and updated during the automated build process.

## Semantic Versioning

We follow the [Semantic Versioning](https://semver.org/spec/v2.0.0.html) 2.0.0 guidelines, whenever it is possible.

### Version numbering

* `MAJOR` version with incompatibilities and/or possible breaking changes,
* `MINOR` version that add functionality in a mostly backwards-compatible manner
* `PATCH` version mostly backwards-compatible bug fixes and small changes.

Sometimes, we use additional labels for pre-release and build metadata, e.g. `MAJOR.MINOR.PATCH-Beta`.

If we run a special build, we also might append this to the regular format, e.g. `MAJOR.MINOR.PATCH.BUILD`.

### Update information

- The patch number has changed (e.g. from 1.0.9 to 1.0.10) only minor changes are implemented or bugs are fixed. A patch version is mostly 100% backwards-compatible. Your script should work without any changes.

- The Minor version has changed (e.g. from 1.0.32 to 1.1.0) bigger changes are implemented or bugs are fixed. A minor version should be 100% backwards-compatible. Your script should work without any changes.

- The Major version has changed (e.g. from 1.9.99 to 2.0.0) major new functionality is introduced and it might not be fully backwards-compatible. That means that your existing script might not work without changing them. Please read this Release Notes very carefully.

## Information

The format is mostly based on the idea of [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

### Date Format

**`YYY-MM-DD`** (2018-12-02 for December 2nd, 2018)

### Changes

We group changes an describe there impact as follows:

**`Added`** for new features

**`Changed`** for changes in existing functionality

**`Deprecated`** for once-stable features removed in upcoming releases

**`Removed`** for deprecated features removed in this release

**`Fixed`** for any bug fixes

**`Security`** to invite users to upgrade in case of vulnerabilities

## Copyright

Copyright (c) 2019, [enabling Technology](http://www.enatec.io/)
All rights reserved.
