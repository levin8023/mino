# Changelog

This project follows [Semantic Versioning](https://semver.org/) for its own releases. Pre-1.0 interfaces and behavior may change.

## 0.2.1 — 2026-10-22 (compatibility preview)

- Keep the original three-bar icon unchanged.
- On macOS 27+, create only the main control: remove dot/lock dividers and all inflated spacer widths.
- Disable unsupported hiding, section controls, auto-hide, and shortcut registration there; clicking opens settings and state reads Managed by macOS.
- Preserve older preferences without applying them on the incompatible system.
- Add language selection to every settings page and the context menu, plus explicit bilingual README and usage-guide links.
- Add a shortcut to the system's app-level menu bar settings; document that it differs from collapsible grouping.
- Per-item visible/collapsed/always-hidden selection and a single-control folding boundary are still unimplemented.

## 0.2.0 — 2026-10-22 (preview)

- Compact original three-bar menu icon, with its name in the tooltip and menu.
- Optional always-hidden section, with a lock divider and explicit temporary reveal action.
- Ordinary toggles and automatic rehide do not reveal the always-hidden section.
- Bounded divider widths on macOS 27 to cooperate with native menu bar overflow.
- Vertical-dot divider, with right-click menus on both controls.
- Built-in bilingual usage guide and direct Help, Settings, Quit menu actions.
- Direct menu presentation avoids re-entering the button action.
- Stop idle timers when auto-hide cannot act; avoid repeated geometry queries and image recreation.
- Correct universal architecture verification in the release workflow.

## 0.1.0 — 2026-10-22 (development snapshot)

- Independent native Swift/AppKit/SwiftUI menu bar app.
- Divider-based collapse, manual arrangement, and recovery on display changes.
- Fixed optional Control–Option–M hotkey with conflict feedback.
- Configurable auto-hide with interaction pauses.
- Optional login launch through SMAppService.
- English and Simplified Chinese UI.
- MIT license, privacy manifest, contribution and security documents.
- Local build/test/package scripts and GitHub Actions workflows.

This release does not include a separate icon panel for notched displays, search, per-item automation, or Developer ID notarization.
