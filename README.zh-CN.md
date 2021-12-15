# IPASigner

一个简单快速的重签名工具

[English](./README.md)

> IPASigner 使用 [CommandLine](https://github.com/Magic-Unique/CommandLine) 来解析参数和生成帮助信息

# 安装

1. 使用 git 克隆或者下载这个仓库的代码
2. 在根目录执行 `pod install`
3. 用 Xcode 打开 *IPASigner.xcworkspace*
4. 选择 **IPASigner (Release)** scheme 然后编译
5. 执行 `ipasigner`，你会得到：

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

当你看见这些信息时，意味着命令行工具已经安装在 */usr/local/bin* 目录下.

# 卸载

```shell
$ rm /usr/local/bin/ipasigner
```

# 使用

## 使用任意描述文件重签名

iOS 本身没有描述文件 bundle id 校验机制，所以可以使用任意描述文件来签名任意的 bundle id 的 app，同时 App 扩展、Watch App 也将使用相同的描述文件来签名。

IPASigner 提供 `resign` 命令来使用任意描述文件签名：

```bash
$ ipasigner resign --help
```

在此命令中，你必须传递描述文件参数 `-p <profile>`，其值可以是以下其中一个：

* path：描述文件的路径，这将直接指定一个描述文件
* name：描述文件名称，将从已经安装的描述文件列表中，筛选出此名称，并根据创建时间取最新的描述文件
* uuid：描述文件 UUID，将从已经安装的描述文件列表中，取出对应 UUID 的描述文件
* bundleid：描述文件 bundle id，将从已经安装的描述文件列表中，筛选出此 bundle id，并根据创建时间取最新的描述文件

同时你还需要传递一个输入 ipa 路径。输出 ipa 路径可传可不传（不传则为输入路径的同级目录下创建带有 .signed 名称的 ipa）

举例：

```bash
$ ipasigner resign -p Wildcard ./WeChat.ipa
# 使用一个通配符描述文件（苹果开发者后台填写的描述文件名称为 Wildcard）来签名当前目录的 WeChat.ipa
# 将会输出 WeChat.signed.ipa
```

```bash
$ ipasigner resign -p temp.mobileprovision ./QQ.ipa ./QQ_sign.ipa
# 使用当前目录下的 temp.mobileprovision 来签名当前目录的 QQ
# 将会输出 QQ_sign.ipa
```

`resign` 命令还带有别的参数，具体可以使用 `--help` 查看帮助信息。

## 使用标准模式重签名

标准模式指 Xcode 标准模式，签名时会自动校验 bundle id 的合法性，同时 App 扩展、Watch App 也将会使用不同的描述文件来签名。

IPASigner 提供 `sign` 命令来使用标准签名模式：

```bash
$ ipasigner sign development --help
$ ipasigner sign ad-hoc --help
$ ipasigner sign distribution--help
$ ipasigner sign in-house --help
```

由于是标准模式，将会严格审查 bundle id 的合法性，所以需要先输入签名类型：

* **development** 开发签名
* **ad-hoc** ADHoc 签名
* **distribution** 生产签名
* **in-house** 企业签名

同时你还需要传递一个输入 ipa 路径。输出 ipa 路径可传可不传（不传则为输入路径的同级目录下创建带有 .signed 名称的 ipa）。

签名前还可以通过 `--bundle-id` 参数来修改 bundle id，但是请注意：

1. 修改后，将会用新的 bundle id 来查找已经安装的描述文件
2. 所有 App 扩展、Watch App 也将会修改 bundle id，并使用对应新的 bundle id 来查找对应描述文件


举例：

```bash
$ ipasigner sign ad-hoc --bundle-id com.my.bundleid ./WeChat.ipa
# 将当前目录下的 WeChat.ipa 的 bundle id 改为 com.my.bundleid 并用此 id 的 ad-hoc 描述文件来签名
# 将会输出 WeChat.signed.ipa
```

```bash
$ ipasigner sign in-house ./QQ.ipa ./QQ_sign.ipa
# 使用当前 bundle id (com.tencent.xin) 的 in-house 签名来签名当前目录的 QQ.ipa
# 将会输出 QQ_sign.ipa
```

获取更详细的参数帮助信息，可以执行以下命令获取：

```bash
$ ipasigner sign <development|ad-hoc|distribution|in-house> --help
```

## 自定义修改包内容

### Info.plist

```bash

# 包名
--bundle-id <NEW_BUNDLE_ID>

# 版本号
--bundle-version <NEW_BUNDLE_VERSION>

# 构建号
--build-version <NEW_BUILD_VERSION>

# 桌面名称
--bundle-display-name <NEW_BUNDLE_DISPLAY_NAME>

# 删除 UISupportDevices 标记
--support-add-devices

# 打开或者关闭 iTunes 文件共享（访问 Documents 文件夹）
--file-sharing
--no-file-sharing

```

### 修改二进制

```bash

# 瘦身到单独的指令集
--thin arm64

# 注入动态库到主二进制
--inject /path/to/dylib1 --inject /path/to/dylib2 ...

# 自定义权限列表
--entitlements /path/to/.entitlements
--get-task-allow <1|0>

```

### 修改应用扩展

```bash

# 删除 PlugIns
--rm-plugins

# 删除 Watches
--rm-watched

# 删除 PlugIns & Watches
--rm-ext

```

### 主应用

```bash

# 修复白图标
--fix-icons

```