# Using Mino

[简体中文](USER_GUIDE.zh-CN.md) | [English](USER_GUIDE.en.md)

Mino is the three rising bars in your menu bar. The icon has no text; its tooltip and context menu show the name. Right-click for help, settings, or quit. Option-click also opens settings. Mino has no Dock icon; reopening the app shows its window.

## Language

Every settings page and the context menu include **语言 / Language**. Choose 简体中文, English, or System default. Your choice applies immediately, without restarting, and stays on this Mac.

## macOS 27 and later

Only one Mino item is created. There are no dot or lock dividers and no inflated spacer. Collapsing, always-hidden sections, auto-hide, and the hiding shortcut are currently unavailable. Clicking the icon opens settings.

`>>` is the system’s overflow indicator when space runs out. Apple’s documented settings provide no separate switch to disable it. Mino cannot guarantee it disappears or keep itself permanently outside overflow.

Choose **Open macOS Menu Bar Settings** to visit System Settings → Menu Bar. Under **Allow in Menu Bar**, choose which apps may show icons. Disabling an app removes its entry rather than creating a collapsible group. In-app per-item choices for visible, collapsed, or always hidden are not implemented yet.

## Experimental mode on macOS 13–26

Only earlier systems retain divider mode; runtime compatibility still needs verification. Choose Arrange items. Hold Command and place ordinary hidden items left of ⋮, with Mino and essentials on its right. Right-click and choose Finish arranging and hide. Then click Mino or press Control–Option–M to toggle.

For the optional always-hidden section, place the lock divider farther left of ⋮ and always-hidden items left of the lock. Ordinary toggles do not reveal this section; use the dedicated temporary reveal action. This is not a privacy boundary.

An invalid arrangement pauses hiding. Display changes and wake expand items for recovery. Auto-hide pauses for settings, arranging, pressed mouse buttons, and pointer interaction within the top 400 points. Quitting releases Mino’s spacer space.

See the [README](../README.en.md) for installation and limits.
