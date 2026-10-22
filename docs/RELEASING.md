# Releasing Mino

## Preview releases

1. Update Info.plist's short version/build number, CHANGELOG, and verification record.
2. Run tests, build, and the relevant manual checklist in TESTING.md.
3. Commit on `main`, then tag `v<short-version>` (for example `v0.2.0`).
4. Push the branch and tag. The release workflow runs tests, builds both architectures, verifies their presence, and creates a **GitHub prerelease** with ZIP and SHA-256 checksum.
5. Inspect the workflow, downloads and release notes. Do not claim a stable or notarized release unless verified.

CI uses read-only contents permission. Only the tag release job receives `contents: write`. Third-party actions are pinned to full commits. Pull-request jobs never receive signing credentials or execute via `pull_request_target`.

The default package is ad-hoc signed, not Developer ID signed or notarized. This is explicitly stated in the README and release notes. Do not label a successful `codesign --verify` check as notarization or as proof of publisher identity.

## Developer ID and notarization

Requires an Apple Developer Program membership, a Developer ID Application certificate in the local keychain, and working `xcrun notarytool`/`stapler`. These credentials are not included in this repository.

```sh
SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' ARCH=universal ./Scripts/package.sh
xcrun notarytool submit dist/Mino-0.2.0-universal.zip --keychain-profile MinoNotary --wait
xcrun stapler staple build/Mino.app
xcrun stapler validate build/Mino.app
spctl --assess --type execute --verbose build/Mino.app
```

After successful notarization, **do not rebuild**: rebuilding would replace the signed/stapled app. Recreate the ZIP and checksum from the stapled bundle:

```sh
ditto -c -k --sequesterRsrc --keepParent build/Mino.app dist/Mino-0.2.0-universal.zip
(cd dist && shasum -a 256 Mino-0.2.0-universal.zip > Mino-0.2.0-universal.zip.sha256)
```

Replace preview assets only with the exact verified artifacts and correct release notes. If automating signing later, use a temporary keychain, secret-scoped trusted jobs, cleanup on failure, and no credentials in PR workflows. Do not commit certificates, keys, passwords, profiles, or tokens.
