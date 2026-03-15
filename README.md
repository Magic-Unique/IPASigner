# IPASigner

A simple, quickly code sign tool for *.ipa file.

[中文](./README.zh-CN.md)

> IPASigner use [CommandLine](https://github.com/Magic-Unique/CommandLine) to parse arguments and print help banner.

# Install

1. clone or download this repo
2. do`$ pod install`
3. open *IPASigner.xcworkspace* with Xcode.app
4. Select **IPASigner (Release)** scheme and build.
5. do `$ ipasigner`, You will get:

```Usage:

    $ ipasigner [--sign <PROFILE>] [--replace] [Options] </path/to/input.ipa> [/path/to/output.ipa]

      SIGN/EDIT an ipa/app.

    $ ipasigner <COMMAND>

      SIGN/EDIT an ipa/app.

Commands:

    + provision                                  CRUD for *.mobileprovision

Arguments:

    </path/to/input.ipa>                         Input ipa path.
    [/path/to/output.ipa]                        Output ipa path.

Options:

    -s|--sign <PROFILE>                          Provision profile to sign or nil to edit-only.
                                                 NAME/UUID/BUNDLE_ID/FILE_PATH: Special profile to sign app and ext.
                                                 app-store/in-house/ad-hoc/development: Sign with match bundle-id profile.
                                                 -: sign with default profile. (env: IPASIGNER_DEFAULT_PROFILE)
    -i|--bundle-id <com.xxx.xxx>                 Modify CFBundleIdentifier
       --bundle-version <1.0.0>                  Modify CFBundleVersion
       --build-version <1000>                    Modify CFBundleShortVersionString
       --bundle-display-name <NAME>              Modify CFBundleDisplayName
       --bundle-icon </path/to/AppIcon.png>      Modify app icon
    -a|--support-all-devices                     Remove Info's value for keyed UISupportDevices.
       --file-sharing                            Enable iTunes file sharing
       --no-file-sharing                         Disable iTunes file sharing
       --file-place                              Enable opening documents in place
       --no-file-place                           Disable opening documents in place
       --fix-icons                               Fix icons-losing on high devices.
       --thin <armv7|arm64>                      Thin binary
    -I|--inject </path/to/dylib>, ...            Inject dylib(s) into binary.
    -r|--remove-extensions                       Delete all watch apps and plugins.
    -R|--replace                                 Sign and replace input file.
    -D|--get-task-allow <1|0>                    Modify `get-task-allow` in entitlements.

Enviroments:

    IPASIGNER_DEFAULT_PROFILE                    Default profile arguments, sign with `-s -`
    IPASIGNER_SUPPORT_ALL_DEVICES                Remove `UISupportDevices` key by default.
    IPASIGNER_ENABLE_FILE_SHARING                Enable iTunes file sharing by default.
    IPASIGNER_REMOVE_EXTENSIONS                  Remove all extensions by default.

Others:

    --silent                                     Show nothing
    --verbose                                    Show more debugging information
    --no-ansi                                    Show output without ANSI codes
    --help                                       Show help banner of specified command
    --version                                    Show the version of the tool

```

It's meaning that `ipasigner` has be installed in */usr/local/bin*.

# Uninstall

```shell
$ rm /usr/local/bin/ipasigner
```

# Usage

## Sign with Any Profile

iOS will not verify the bundle id, so you can sign with any profile (contains different bundle id). And ipasigner will sign App Extension、Watch App with the same profile.

IPASigner provide `resign` command to resign with any profile:

```bash
$ ipasigner -s 'Profile Name' INPUT.ipa
```

You must type-in a profile argument `-s <profile>` with one of follow values:

* path：Profile Path, A provision profile path.
* name：Profile Name, it will search in installed profiles, and select newest.
* uuid：Profile UUID, it will select one in installed profiles.
* bundleid：Profile Bundle ID, it will search in installed profiles, and select newest.

And it also requires an input path, and an optional output path.

Such as：

```bash
$ ipasigner -p 'Wildcard' ./WeChat.ipa
# Sign WeChat.ipa with a wildcard profile named `Wildcard`
# You will get WeChat.signed.ipa
```

```bash
$ ipasigner -p 'temp.mobileprovision' ./QQ.ipa ./QQ_sign.ipa
# Sign QQ.ipa with temp.mobileprovision
# You will get QQ_sign.ipa
```

For more detail informations and arguments, do `ipasigner resign --help`.

## Sign in Standard Mode

IPASigner will verify bundle id，and sign App Extensions, Watch Apps with different profile。

IPASigner provide `-s` argument to sign in standard mode：

```bash
$ ipasigner -s 'development' --help # Development profile
$ ipasigner -s 'ad-hoc' --help # AD-Hoc profile 
$ ipasigner -s 'app-store'--help # App Store profile
$ ipasigner -s 'in-house' --help # Enterprice profile
```

And it also requires an input path, and an optional output path.

You can modify bundle id with argument `--bundle-id`. Attention:

1. It will search profile with new bundle id
2. It will modify App Extensions, Watch Apps bundle id in the mean time, And search profile with new bundle id.

Such as：

```bash
$ ipasigner -s 'ad-hoc' --bundle-id com.my.bundleid ./WeChat.ipa
# Modify WeChat.ipa's bundle id as `com.my.bundleid` and sign with ad-hoc profile
# You will get WeChat.signed.ipa
```

```bash
$ ipasigner -s 'in-house' ./QQ.ipa ./QQ_sign.ipa
# Use default bundle id (com.tencent.xin) and sign with in-house profile
# You will get QQ_sign.ipa
```

For more detail informations and arguments, do

```bash
$ ipasigner -s <'development'|'ad-hoc'|'distribution'|'in-house'> --help
```

## Sign with custom package

### Info.plist

```bash

# Bundle identifier
--bundle-id <NEW_BUNDLE_ID>

# Bundle version
--bundle-version <NEW_BUNDLE_VERSION>

# Build version
--build-version <NEW_BUILD_VERSION>

# Bundle display name
--bundle-display-name <NEW_BUNDLE_DISPLAY_NAME>

# Remove UISupportDevices flag
--support-add-devices

# Enable or disable iTunes file sharing
--file-sharing
--no-file-sharing

# Enable or disable opening documents in place
--file-place
--no-file-place
```

### Binary

```bash

# Thin all binary to single platform
--thin arm64

# Inject dylib into main binary
--inject /path/to/dylib1 --inject /path/to/dylib2 ...

# Custom entitlements
--entitlements /path/to/.entitlements
--get-task-allow <1|0>

```

### App Extensions

```bash

# Remove PlugIns
--rm-plugins

# Remove Watches
--rm-watched

# Remove PlugIns & Watches
--rm-ext

```

### Main Bundle

```bash

# Fix Icon Error
--fix-icons

```
