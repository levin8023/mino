# Mino

[简体中文](README.md) | [**English**](README.en.md) · [Preview downloads](https://github.com/levin8023/mino/releases) · [MIT](LICENSE)

A free, open-source, native macOS menu bar utility. The main button keeps its original three rising bars, without an app-name label.

**0.2.1 is a compatibility-fix preview. Full icon management is not implemented.** The deployment target is macOS 13+; see the [verification record](docs/VERIFICATION.md) for actual testing.

## Compatibility

| Feature | macOS 13–26 | macOS 27 and later |
| --- | --- | --- |
| Three-bar control; right-click help/settings/quit | Available | Available |
| Select English / Simplified Chinese / System default | Available | Available |
| Divider sections, auto-hide, hiding shortcut | Experimental; cross-version runtime testing pending | **Disabled** |
| Choose visible, collapsed, or always hidden per item inside Mino | Not implemented | Not implemented |
| Disable system `>>` or guarantee Mino stays visible | No such interface | No public interface |

### What changes on macOS 27

macOS shows its own [overflow indicator](https://support.apple.com/en-eg/148830) when space runs out. Inflating dividers leaves large gaps and does not reliably control other apps’ icons. **On macOS 27, version 0.2.1 creates no dot or lock separators and reserves no hiding space. Only the Mino control remains.**

Click Mino for settings. Right-click for help, macOS Menu Bar Settings, Mino settings, language, and quit. The interface says “Managed by macOS”; it does not report successful hiding when none occurred. Legacy section, always-hidden, auto-hide, and shortcut preferences are preserved but inactive.

Mino can open System Settings → Menu Bar → Allow in Menu Bar, where you can choose which apps may show icons. You make the change in System Settings. **Removing an app’s menu bar entry differs from a collapsible group.** Apple’s [documented settings](https://support.apple.com/en-ie/guide/mac-help/mchlad96d366/27/mac/27) list no separate switch to disable `>>`. Reducing visible icons may relieve overflow, but cannot guarantee the arrow disappears.

## Choose a language

- Every settings page has a **语言 / Language** picker: 简体中文, English, or System default.
- The main icon’s right-click **语言 / Language** menu also switches immediately and saves your choice locally.
- Select the [Chinese](README.md) or [English](README.en.md) README above. Usage guides are available in [Chinese](docs/USER_GUIDE.zh-CN.md) and [English](docs/USER_GUIDE.en.md).

## Install

Download a ZIP from [Releases](https://github.com/levin8023/mino/releases), verify its SHA-256, unzip, and move Mino.app to Applications. Mino has no Dock icon. Reopening the app opens settings.

Preview builds are ad-hoc signed, **not Developer ID signed or Apple notarized**. macOS may block opening. Build locally, or verify the source and follow [Apple’s per-app opening instructions](https://support.apple.com/en-us/102445).

## Experimental sections on macOS 13–26

Only earlier systems retain the original divider implementation; runtime testing on those systems is pending. Choose Arrange items, then hold Command and arrange left to right:

```text
[Always-hidden items] [Optional lock divider] [Ordinary hidden items] [⋮] [Mino] [Essentials]
```

Right-click and choose Finish arranging and hide. Click Mino or press Control–Option–M to toggle the ordinary section. Use the dedicated temporary reveal action for the always-hidden section. The control must remain right of the divider before hiding is allowed. Auto-hide pauses for settings, arranging, menu interaction, and pointer activity in the top 400 points. Quitting releases all spacer space.

This relies on OS layout rather than a guaranteed cross-app visibility API. Notches, application menus, multiple displays, and full screen can affect results. A single-control boundary and in-app per-item configuration still require a verified implementation and are not claimed as supported.

## Build

Requires macOS and Swift 5.9+ (Command Line Tools or Xcode). No remote packages.

```sh
git clone https://github.com/levin8023/mino.git
cd mino
./Scripts/test.sh
./Scripts/build.sh
open build/Mino.app
```

Build an Apple silicon + Intel ZIP with SHA-256:

```sh
ARCH=universal ./Scripts/package.sh
```

Output is in `dist/`. Build caches, archives, keys, and personal IDE files are excluded from Git. Intel cross-compilation does not establish runtime compatibility.

## Privacy and contributing

No accounts, ads, analytics, or app-initiated network traffic. No Accessibility, Input Monitoring, or Screen Recording permission is requested. Preferences use local UserDefaults; optional login launch uses `SMAppService`. Documentation links open in your browser.

Independently implemented under [MIT](LICENSE), without third-party source code or brand assets; see [NOTICE](NOTICE.md). Mino is a provisional name and has not been trademark-cleared.

See [contributing](CONTRIBUTING.md), [privacy](PRIVACY.md), [architecture](docs/ARCHITECTURE.md), [testing](docs/TESTING.md), and [roadmap](docs/ROADMAP.md). Include OS version, display configuration, and reproduction steps in issues; omit private screenshots, tokens, and serial numbers.
