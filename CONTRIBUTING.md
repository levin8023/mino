# Contributing to Mino

Small, focused issues and pull requests are welcome. Chinese and English are both fine.

## Development

Use macOS and Swift 5.9+. Run `./Scripts/test.sh` and `./Scripts/build.sh`. Use `open build/Mino.app --args --settings` to inspect settings. Xcode can open `Package.swift`; the scripts produce the distributable `.app`.

Keep the application UI on the main actor. Put testable timing/preferences policy in `MinoCore`, and AppKit integration in `Mino`. Add meaningful regression tests for policy bugs. Perform relevant manual checks from [docs/TESTING.md](docs/TESTING.md), and state exactly which checks ran in the PR.

Follow existing Swift formatting (4 spaces, descriptive names), standard Apple APIs, and the local-first privacy model. Update both README languages and localized UI text when behavior changes. Avoid private APIs, synthetic event injection, or new permission requests without a documented design discussion.

No dependency is preferred over a dependency for small utilities. Any imported code, dependency, or asset needs a compatible license and attribution in NOTICE.md. Contributions are submitted under this repository's MIT license. Do not import incompatible code or assets.

Never commit signing certificates, tokens, provisioning profiles, `.env` files, user-specific settings, or private logs. Use GitHub noreply email addresses if you want to keep commit email private.

## Issues and reviews

Describe the observed behavior, expected behavior, OS version, display layout/notch, other menu bar managers, and reproducible steps. Redact screenshots. Keep feedback focused on the code and respect contributors. Harassment and sharing private information are not acceptable; maintainers may remove such content.

For vulnerabilities, follow SECURITY.md instead of a public issue.
