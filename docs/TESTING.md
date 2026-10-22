# Verification

## Automated

Run `./Scripts/test.sh` for the policy and persistence regression suite. Run `./Scripts/build.sh` for an optimized app build, plist validation, original icon generation, signing, and signature verification. Run `ARCH=universal ./Scripts/package.sh` to cross-compile both architectures, combine them and package a ZIP/checksum.

`build/Mino.app/Contents/MacOS/Mino --smoke-test` creates the real status items, reports their presence/relative layout, and exits. It never applies saved collapsed startup state and does not mark onboarding complete. On earlier systems it still registers the configured shortcut and initializes AppKit preferences, so run in a graphical desktop session without another Mino instance.

On macOS 27+, `--integration-test` skips the collapse probe and exits, because no spacers exist. On earlier systems it additionally applies a one-second oversized divider and restores it before exiting, printing both geometries. This is an explicit diagnostic probe, bypasses the normal layout guard, and can briefly hide menu bar items. A printed width transition alone is not proof that arbitrary third-party items were hidden correctly. Do not run while using another menu bar manager or while a user is interacting with the menu bar.

## macOS 27 compatibility checks

- [ ] Only the main status item is created, including when saved always-hidden preferences are enabled.
- [ ] No inflated width, divider, hiding timer, or hiding shortcut is active.
- [ ] Interface says Managed by macOS rather than reporting other items hidden.
- [ ] Clicking opens settings; right-click offers help/settings/language/quit.
- [ ] Every page switches languages immediately and the choice survives restart.
- [ ] System settings action opens Menu Bar without modifying any toggles.
- [ ] Native >> remains independent; no claim of disabling it or per-item grouping.

## Earlier-system manual release checklist

Record actual results instead of treating this checklist as proof of passing:

- [ ] First launch expands items and opens onboarding without a permission prompt.
- [ ] Command-drag actual third-party items across the divider; complete setup.
- [ ] Click and Control–Option–M both collapse and restore those items.
- [ ] Enable the always-hidden section, arrange lock → dot divider → control, and finish setup.
- [ ] Ordinary toggles never reveal the always-hidden section; dedicated temporary reveal and rehide both work.
- [ ] Native macOS 27 overflow remains independently accessible and is documented in the guide.
- [ ] Misplace the divider to the control's right: hiding is refused and settings explains recovery.
- [ ] Right-click menu, Option-click settings, and application reopen work.
- [ ] Auto-hide waits the selected full delay after leaving the menu area.
- [ ] Hovering within the top 400 points, holding the mouse, opening settings/menu, and arranging all pause it.
- [ ] Deliberate shortcut conflict produces an actionable message.
- [ ] English/Chinese and light/dark appearance fit without clipped controls.
- [ ] Enable/disable login launch from Applications and verify it after logout/login.
- [ ] Restart app and verify preferences/positions persist.
- [ ] Quit while collapsed and confirm icons regain available space.
- [ ] Sleep/wake and attach/detach displays, verify expanded recovery.
- [ ] Notched display, app menu overlap, full screen, Spaces, and multiple display layouts.
- [ ] Launch and basic interaction on an actual Intel Mac and the minimum supported OS.

Build/test logs and the current performed checks are recorded in `docs/VERIFICATION.md` for each preview. Compilation for an architecture is not a runtime test on that architecture.
