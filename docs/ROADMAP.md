# Roadmap

## Before a stable 1.0

- Real-device checks on macOS 13–current, Intel, notched Apple silicon laptops, multi-display, Spaces, full screen, and display hot-plug.
- Verify Command-drag persistence and overflow behavior on those systems.
- Developer ID signing and notarized release pipeline when credentials are available.
- Configurable shortcut and improved keyboard/accessibility audit.
- Naming/trademark review before broader promotion.

## Candidate features

- A separate panel for icons obscured by the notch. Requires a design and permission/API investigation; no implementation promise yet.
- Per-item rules and richer placement feedback.
- Optional hover reveal and richer arrangement feedback.
- Signed update delivery with explicit user controls.
- Homebrew cask after stable, verified downloads exist.

The first principle is a small local utility. Proposed features that require screen capture, Accessibility, private APIs, remote services, or extra dependencies must document why and how those costs are justified.
