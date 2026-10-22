# Roadmap

## Current blocker: macOS 27

Native overflow invalidates the spacer-based hiding approach. Version 0.2.1 disables it entirely on macOS 27+ to avoid gaps and misleading success states. The system's documented controls provide app-level icon visibility but no separate overflow switch or supported cross-app per-item visibility API.

## Required before claiming full icon management

- Verify a working macOS 27 backend before exposing per-item controls.
- Use a single visible Mino boundary, with no manually arranged dividers.
- Let users choose visible, collapsed, or always hidden per item in settings; reflect actual applied state and failures.
- Preserve access to each item, including on notched and multiple displays.
- Evaluate narrowly scoped optional permissions only when a working implementation needs them; update privacy documentation before adding access.

## Further work

- Runtime verification on supported earlier systems and Intel hardware.
- Custom shortcuts, keyboard navigation, and accessibility checks.
- Developer ID signing and notarization when a publisher identity is available.
- Separate icon panel, search, and opt-in updates after the core backend works.

These are plans, not available features. English and Chinese interface/readme selection are available now.
