# 0.2.1 compatibility verification

Date: 2026-10-22 (Asia/Shanghai). Host: Apple silicon, macOS 27.0.1, Swift 6.4 Command Line Tools.

- Core regression suite: **12/12 passed**, including a replacement native-overflow check that forbids width inflation for normal, collapsed, invalid-display and multiple-section inputs.
- Optimized arm64 build: passed; Info.plist/privacy manifest lint and ad-hoc signature verification passed.
- Real AppKit startup diagnostic: `control=true, divider=false, alwaysDivider=false, nativeOverflow=true, layoutWarning=false`. This ran with existing always-hidden preferences, confirming the compatibility guard creates no divider.
- Native settings UI launched as version 0.2.1. Chinese overview and live English switch were observed; English overview, preferences, and help were inspected. Controls fit the settings window. Unsupported section/auto-hide/shortcut controls are absent on macOS 27. The retained icon artwork source was not changed.
- The in-app system-settings button opened the actual Menu Bar pane, including Allow in Menu Bar. No system switches were changed.
- No claim of working macOS 27 third-party hiding, per-item grouping, a single-control folding boundary, or disabling native overflow. Those remain unavailable, rather than being counted as passing tests.

- Universal arm64 + x86_64 package built; `lipo -archs` reports both. ZIP SHA-256 and final bundle ad-hoc signature verified. The installed toolchain still warns about its arm64-only compatibility-pack archive when cross-linking x86_64; no Intel runtime verification is claimed.
- English language selection persisted across app restart. The UI test then restored the original System default choice; the final control label returned to Chinese.
- The final universal app starts headlessly after its compatibility notice has been acknowledged. A single main control was exposed by the menu bar host. Automated right-click remained blocked by stale off-screen AX coordinates, so the new context-menu language submenu is not counted as a passing end-to-end UI test.

Remote build/release checks are reported by the per-tag Actions run. Earlier observations below are historical and do not describe the 0.2.1 native-overflow behavior.

---

# Preview verification record

Date: 2026-10-22 (Asia/Shanghai). Preview version: 0.2.0.

## Performed locally

- Host: Apple silicon (arm64), macOS 27.0.1, Apple Swift 6.4 Command Line Tools, without full Xcode.
- Dependency-free core regression checks: **12/12 passed**. Covers onboarding protection, startup state, exact idle deadline, interaction resets, disabled auto-hide, screen-size edge cases, settings migration/corruption, delay normalization, language ordering, always-hidden reveal isolation, automatic rehide, and native overflow spacer budgets.
- Optimized arm64 application compilation: passed.
- arm64 + x86_64 cross-compilation and `lipo` combination: passed on the initial preview; repeat for each final release artifact. The local x86_64 link warned about an arm64-only compatibility-pack archive in this installed toolchain. An Intel machine has not been used for runtime verification.
- App bundle Info.plist and privacy manifest: `plutil -lint` passed.
- Local ad-hoc `codesign --verify --strict`: passed. This is not Developer ID signing or notarization.
- ZIP SHA-256 generation and validation: passed on the initial archive.
- Real AppKit/SwiftUI settings window launched and inspected on the host, including the main, preferences and about pages. No Accessibility/Screen Recording prompt was requested by Mino.
- Current 0.2.0 UI: the always-hidden preference switch was enabled successfully, creating the optional divider and entering arranging mode. The user confirmed the actual main-icon right-click menu contains Help, Settings, Quit, and the temporary always-hidden reveal action. Menu-bar automation could not click the overflow-hosted icon because the system exposed its old off-screen coordinates; this limitation is not counted as a passing automated interaction test.
- Status-item smoke diagnostic: both items created. This host initially placed the divider to the right of the control; **the layout guard correctly refused normal collapse and showed recovery guidance**. Initial placement is not certified as correct automatically.
- Explicit geometry probe: the divider accepted a 10,000-point length and returned to 22 points after a one-second test. This does not establish that all third-party items were hidden or restored correctly.
- Follow-up investigation confirmed macOS 27 has native menu bar overflow. The current version uses a bounded spacer budget there; the earlier 10,000-point probe describes the initial diagnostic, not the current macOS 27 policy.
- Baseline resource sampling before the idle-timer changes measured Mino at 0.0% CPU and about 33 MB physical footprint. A two-second stack sample showed waiting in the event loop. WindowServer remained around 105–132% CPU after Mino exited. This short comparison did not identify Mino as the primary sustained CPU consumer, but does not rule out indirect effects. Raw process/system logs remain local and are not included in this repository.

## Not yet certified

- End-to-end third-party item hiding after manually arranging the divider on this host.
- Login launch across an actual logout/login, shortcut conflict with another application, and OS approval changes.
- Automatic hiding during actual third-party long menus.
- Runtime on macOS 13–26, actual Intel hardware, multiple displays, Spaces/full screen, display hot-plug, and sleep/wake.
- Apple Developer ID signature, notarization, trademark clearance, and Homebrew distribution.

This is a development preview, not a compatibility certification. Do not turn checklist items in TESTING.md into passing claims without observing them. The per-tag GitHub Actions run is the authoritative result for the artifact it produces; inspect it separately from this local record.

For v0.2.0, both the [CI run](https://github.com/levin8023/mino/actions/runs/39763627715) and [release run](https://github.com/levin8023/mino/actions/runs/39763640388) passed. The downloaded release ZIP's SHA-256 and extracted app's ad-hoc signature were independently checked locally. This verifies packaging, not Apple notarization or every third-party menu-bar layout.
