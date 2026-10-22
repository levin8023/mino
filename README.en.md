# Mino

**A little less. Just right.**

A free, open-source, native macOS menu bar manager. Keep essential items visible and tuck occasional items behind a divider.

[简体中文](README.md) · [Preview downloads](https://github.com/levin8023/mino/releases) · [Contributing](CONTRIBUTING.md) · [MIT](LICENSE)

**0.2.0 is an early preview.** macOS 13+ is the deployment target; not every OS and display combination has been tested.

macOS 27 has its own system overflow entry, which can collect Mino too. Arrange the dividers and control with Command-drag first. End-to-end behavior across OS/display configurations is not certified; see the [verification record](docs/VERIFICATION.md).

## Features

- Click the Mino button to show or hide items left of its divider.
- Arrange menu bar items using the native Command-drag gesture.
- Optional always-hidden section: ordinary toggles never reveal it; a dedicated menu action temporarily shows it.
- Optional global shortcut: Control–Option–M, with registration errors surfaced.
- Automatic hiding after 3–60 seconds outside the menu interaction area.
- Optional launch at login through Apple's `SMAppService` (off by default).
- English and Simplified Chinese, switchable in Preferences.
- A misplaced divider pauses hiding to protect access to the control.
- Display changes and wake expand the divider for recovery.
- No accounts, analytics, third-party dependencies, or app-initiated network traffic.
- No Accessibility, Input Monitoring, or Screen Recording permission required.

## Install and use

Download a ZIP from [Releases](https://github.com/levin8023/mino/releases), unzip, and move Mino.app to Applications. Mino runs in the menu bar without a Dock icon.

Preview builds are ad-hoc signed, **not Developer ID signed or notarized**. macOS may block them. Verify the checksum and source before following [Apple's opening instructions](https://support.apple.com/en-us/102445), or build locally. Do not disable Gatekeeper globally.

1. Quit other menu bar managers temporarily.
2. Choose **Arrange items** in Mino. The settings window hides and automatic hiding pauses.
3. Hold Command and move occasional items left of the divider. Keep the three-bar Mino button on its right.
4. Right-click Mino and choose **Finish arranging and hide**.

The main button shows a compact original three-bar icon without text. Click it or press Control–Option–M to toggle. Right-click either the three-bar Mino button or the vertical-dot divider for Help, Settings, and Quit. Option-click opens settings. Reopening the app also opens settings. Quitting removes Mino's divider and releases menu bar space.

## Build

Requires macOS and Swift 5.9+ (Command Line Tools or Xcode). No remote packages.

```sh
git clone https://github.com/levin8023/mino.git
cd mino
./Scripts/test.sh
./Scripts/build.sh
open build/Mino.app
```

For an Apple silicon + Intel archive with SHA-256 checksum:

```sh
ARCH=universal ./Scripts/package.sh
```

## Limits

Mino resizes its own `NSStatusItem` divider so items to its left overflow. No private APIs or third-party process modifications are used. **The resulting overflow behavior is controlled by macOS and is not a guaranteed cross-app hiding API.**

Notches, application menus, and screen width can still obscure expanded icons. There is no separate icon panel, search, per-app rules, automatic rearrangement, or auto-updater yet. Some system items cannot be moved. Independent per-display layouts are not supported.

Enable Always-hidden section in Preferences, then arrange left to right: always-hidden items → lock divider → ordinary hidden items → vertical-dot divider → three-bar control → essentials. Finish arranging from the menu. Ordinary clicks and the global shortcut reveal only the ordinary section. Use the dedicated context-menu action to temporarily reveal or rehide the always-hidden section. Auto-hide also ends a temporary reveal when enabled.

On macOS 27, [system overflow](https://support.apple.com/en-eg/148830) may collect or reveal any third-party item, including Mino. Bounded-width spacers replace oversized items there. Open the overflow and Command-drag the control toward visible essentials if needed. Public APIs do not let Mino disable system overflow or pin itself permanently. Always-hidden is a Mino interaction policy, not a privacy boundary.

Auto-hide pauses while the pointer is within 400 points of the screen top, a mouse button is held, Mino's menu/settings are open, or arranging is active. It cannot reliably detect every other app's menu; disable auto-hide for unusually long menus. Arranging mode ends only when you choose Finish arranging and hide. Settings must be closed before automatic hiding resumes. Manual toggling remains available.

Keep the app at a stable path before enabling login launch. OS approval, app movement, and signature changes can affect registration. The shortcut is fixed in this version and can be disabled if it conflicts.

See [testing](docs/TESTING.md), [architecture](docs/ARCHITECTURE.md), [release instructions](docs/RELEASING.md), [privacy](PRIVACY.md), and [roadmap](docs/ROADMAP.md).

## Credits

Independently implemented under MIT. The implementation, interface, and icon were created for this project. No third-party source code, logos, or artwork are included. See [NOTICE](NOTICE.md). Mino is a provisional name and has not been trademark-cleared.
