# Architecture

## Targets

- `MinoCore`: Foundation-only Codable preferences, migration/defaulting, safe delay normalization, and a pure visibility/idle policy.
- `Mino`: AppKit lifecycle, two status items plus an optional always-hidden divider, Carbon global hotkey registration, SMAppService login items, and SwiftUI settings.
- `MinoCoreChecks` (sources in `Tests/MinoCoreTests`): a dependency-free regression runner for timing, interaction, first-launch protection, settings recovery, migration, and screen-width edge cases. Unlike XCTest it also works with a Command Line Tools-only installation.

There are no external packages. Deployment target: macOS 13. Swift language compatibility: 5.9+. AppKit integration is main-actor isolated. A one-second main-run-loop timer (with 0.3-second tolerance) supplies monotonic uptime only while automatic hiding is actionable. It is stopped while collapsed, onboarding, arranging, settings/menu open, or auto-hide disabled. Geometry is checked only at startup and collapse transitions, not on every timer wakeup. No background polling thread is used.

## Status items

The intended left-to-right order is always-hidden items, optional lock divider, ordinary hidden items, dot divider, main control, essentials. Dividers are 22 points wide while expanded. On macOS 13–26, collapsed dividers grow beyond display width. On macOS 27+, a bounded spacer budget (45% of the smallest display, shared across active dividers) cooperates with system overflow instead of creating a mega-item. These are OS layout behaviors, not supported APIs for explicitly setting another app's item visibility. Do not promise every item is hidden on every OS/display configuration or that Mino can pin itself outside native overflow.

Ordinary toggles always clear `isAlwaysHiddenRevealed`. Only the explicit reveal action sets it. Automatic rehide clears it too. Arranging expands both dividers and pauses auto-hide. The optional always-hidden section is off by default; enabling creates its lock divider and enters arranging mode. It is not a privacy/security boundary: macOS's own overflow can reveal any item independently.

AppKit chooses initial positions and persists actual user placement with stable autosave names. The app never writes undocumented preferred-position defaults or edits another application's defaults. A frame check at the normal divider width prevents collapse if the control appears left of the divider or they are on mismatched menu-bar rows. It does not compare the deliberately oversized host frame while collapsed. Display/wake events expand as a recovery measure. Quitting releases both items.

The app starts expanded during onboarding. Once setup is complete, the optional collapsed startup state is applied after AppKit has restored positions. Arranging pauses auto-hide until the user finishes explicitly. The hotkey and click can still manually toggle; settings, menu tracking, pointer proximity and pressed mouse buttons pause automatic changes.

## Privacy and distribution

Preferences are local UserDefaults JSON under a versioned key. Per-field decoding preserves compatible preferences when new fields arrive. Hotkeys use RegisterEventHotKey, without an event tap. Login items use SMAppService rather than manually installing LaunchAgents. No AX enumeration, screenshots, synthetic clicks, private symbols, or network client is included.

The app bundle is generated from a SwiftPM executable and checked-in plist resources. A code-generated icon becomes an ICNS file. Universal binaries use separate arm64/x86_64 Swift builds and `lipo`. The default signature is ad-hoc; Developer ID signing can be supplied explicitly at packaging time. See RELEASING.md for notarization and identity limitations.
