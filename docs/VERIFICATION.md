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
