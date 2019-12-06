# IPASigner

A simple, quickly code sign tool for *.ipa file.

[中文](./README.zh-CN.md)

> IPASigner use [CommandLine](https://github.com/Magic-Unique/CommandLine) to parse command line arguments and print help banner.

# Install

## Homebrew

```bash
$ brew tap magic-unique/tap && brew install ipasigner
```

## Build

1. clone or download this repo
2. do`pod install`
3. open *IPASigner.xcworkspace* with Xcode.app
4. Select **IPASigner (Release)** scheme and build.
5. do `ipasigner`

```bash
$ ipasigner
```

You will get:

```
Usage:

    $ ipasigner <COMMAND>

    An signer tools for ipa file.

Commands:

    + sign        Sign IPA with standard mode.
    + resign      Sign IPA with custom mode.
    + provision   Lookin for local provision profiles.

Options:

    --version     Show the version of the tool
    --verbose     Show more information
    --help        Show help banner of specified command
    --silent      Show nothing
    --no-ansi     Show output without ANSI codes
```

It's meaning that `ipasigner` has be installed in */usr/local/bin*.

# Usage

## Sign with Any Profile

iOS will not verify the bundle id, so you can sign with any profile (contains different bundle id). And ipasigner will sign App Extension、Watch App with the same profile.

IPASigner provide `resign` command to resign with any profile:

```bash
$ ipasigner resign --help
```

You must type-in a profile argument `-p <profile>` with one of follow values:

* path：Profile Path, A provision profile path.
* name：Profile Name, it will search in installed profiles, and select newest.
* uuid：Profile UUID, it will select one in installed profiles.
* bundleid：Profile Bundle ID, it will search in installed profiles, and select newest.

And it also requires an input path, and an optional output path.

Such as：

```bash
$ ipasigner resign -p Wildcard ./WeChat.ipa
# Sign WeChat.ipa with a wildcard profile named `Wildcard`
# You will get WeChat.signed.ipa
```

```bash
$ ipasigner resign -p temp.mobileprovision ./QQ.ipa ./QQ_sign.ipa
# Sign QQ.ipa with temp.mobileprovision
# You will get QQ_sign.ipa
```

For more detail informations and arguments, do `ipasigner resign --help`.

## Sign in Standard Mode

IPASigner will verify bundle id，and sign App Extensions, Watch Apps with different profile。

IPASigner provide `sign` command to sign in standard mode：

```bash
$ ipasigner sign development --help
$ ipasigner sign ad-hoc --help
$ ipasigner sign distribution--help
$ ipasigner sign in-house --help
```

You must type-in **SIGN_TYPE** follow `sign`:

* **development** Development Profile
* **ad-hoc** AD Hoc Profile 
* **distribution** Distribution Profile
* **in-house** Enterprice Profile

And it also requires an input path, and an optional output path.

You can modify bundle id with argument `--bundle-id`. Attention:

1. It will search profile with new bundle id
2. It will modify App Extensions, Watch Apps bundle id in the mean time, And search profile with new bundle id.


Such as：

```bash
$ ipasigner sign ad-hoc --bundle-id com.my.bundleid ./WeChat.ipa
# Modify WeChat.ipa's bundle id as `com.my.bundleid` and sign with ad-hoc profile
# You will get WeChat.signed.ipa
```

```bash
$ ipasigner sign in-house ./QQ.ipa ./QQ_sign.ipa
# Use default bundle id (com.tencent.xin) and sign with in-house profile
# You will get QQ_sign.ipa
```

For more detail informations and arguments, do

```bash
ipasigner sign <development|ad-hoc|distribution|in-house> --help
```