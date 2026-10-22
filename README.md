# Mino

[**简体中文**](README.md) | [English](README.en.md) · [下载预览版](https://github.com/levin8023/mino/releases) · [MIT](LICENSE)

免费开源的原生 macOS 菜单栏工具。菜单栏主按钮保留三根高低竖条图标，不显示应用名称。

**0.2.1 是兼容性修复预览版，尚未实现全部图标管理功能。** 部署目标为 macOS 13+；实际验证范围见[验证记录](docs/VERIFICATION.md)。

## 系统兼容性

| 功能 | macOS 13–26 | macOS 27 及以上 |
| --- | --- | --- |
| 三竖条主按钮、右键说明/设置/退出 | 可用 | 可用 |
| 自选简体中文 / English / 跟随系统 | 可用 | 可用 |
| 分隔符分区、自动收起、折叠快捷键 | 实验功能，未完成跨版本实机验证 | **停用** |
| 在 Mino 内逐项选择常驻、折叠、始终隐藏 | 尚未实现 | 尚未实现 |
| 关闭系统 `>>`、保证 Mino 永远常驻 | 无此接口 | 无此公开接口 |

### macOS 27 上的变化

系统空间不足时会显示自己的 `>>` [溢出入口](https://support.apple.com/en-eg/148830)。之前通过分隔符撑宽的方案会留下大空隙，也无法可靠控制其他应用图标。**0.2.1 在 macOS 27 上完全不创建圆点或锁形分隔符，不撑宽菜单栏，只保留一个 Mino 图标。**

此系统下，点击 Mino 打开设置；右键提供使用说明、系统菜单栏设置、Mino 设置、语言和退出。界面显示“由 macOS 管理”，不把未发生的隐藏标为成功。旧版折叠、始终隐藏、自动收起和快捷键偏好保留，但不执行。

可从 Mino 打开系统设置 → 菜单栏 →「允许在菜单栏中」，选择允许显示图标的应用。该操作由用户在系统设置完成，**关闭一个应用的入口与可展开的折叠分组不同**。Apple [公开设置说明](https://support.apple.com/en-ie/guide/mac-help/mchlad96d366/27/mac/27)未列出单独关闭 `>>` 的选项；减少可见图标可能缓解溢出，无法保证箭头消失。

## 语言选择

- 设置窗口每一页顶部都有「语言 / Language」选择：简体中文、English、跟随系统。
- 右键 Mino →「语言 / Language」也可切换，即时生效并保存在本机。
- README 顶部可选[中文](README.md)或[英文](README.en.md)；使用说明也提供[中文](docs/USER_GUIDE.zh-CN.md)和[英文](docs/USER_GUIDE.en.md)。

## 安装

从 [Releases](https://github.com/levin8023/mino/releases) 下载 ZIP，验证 SHA-256，解压并将 Mino.app 放入 Applications。Mino 没有 Dock 图标，重新打开应用可进入设置。

预览包使用 ad-hoc 签名，**未经过 Developer ID 签名或 Apple 公证**。系统可能阻止打开；可自行构建，或核对来源后按照 [Apple 的逐应用打开说明](https://support.apple.com/en-us/102445)操作。

## macOS 13–26 的实验分区模式

仅旧系统保留原有的分隔符实现，尚未进行这些系统上的实机验证。选择「整理图标」，按住 `⌘` 从左到右排列：

```text
[始终隐藏图标] [锁形分隔符，按需启用] [普通隐藏图标] [⋮] [Mino] [常用图标]
```

右键选择「完成整理并收起」。点击 Mino 或按 `⌃ ⌥ M` 切换普通分区；始终隐藏区需用专门的临时显示菜单访问。主按钮在分隔符右侧时才允许收起。自动收起在设置、整理模式、菜单交互和屏幕顶部 400 点范围内暂停。退出会释放所有分隔符占用的空间。

该分区依赖系统排布，不是 Apple 保证的跨应用显隐接口；刘海、应用菜单、多个显示器和全屏可能影响效果。将分区改为单图标边界、在应用内逐项配置，仍需可验证的实现，当前不宣称支持。

## 从源码构建

需要 macOS 和 Swift 5.9+（Command Line Tools 或完整 Xcode），无远程 Swift 包依赖。

```sh
git clone https://github.com/levin8023/mino.git
cd mino
./Scripts/test.sh
./Scripts/build.sh
open build/Mino.app
```

生成 Apple silicon + Intel 通用 ZIP 与 SHA-256：

```sh
ARCH=universal ./Scripts/package.sh
```

输出在 `dist/`。构建缓存、包、密钥和个人 IDE 文件不进入 Git。编译 Intel 架构不等于完成 Intel 实机验证。

## 隐私、开源与贡献

无账户、广告、数据采集或应用主动发出的网络请求；不请求辅助功能、输入监控或屏幕录制权限。设置使用本机 UserDefaults，登录启动使用可选的 `SMAppService`。点击文档链接会通过浏览器打开网页。

本项目独立编写，采用 [MIT](LICENSE) 许可证；代码、界面和图标不含第三方源码或品牌素材，见 [NOTICE](NOTICE.md)。Mino 为暂定名称，未进行商标清查。

参见[贡献规范](CONTRIBUTING.md)、[隐私政策](PRIVACY.md)、[架构](docs/ARCHITECTURE.md)、[测试](docs/TESTING.md)和[路线图](docs/ROADMAP.md)。提交 issue 时请提供系统版本、显示器配置和复现步骤；不要提交私人截图、令牌或序列号。
