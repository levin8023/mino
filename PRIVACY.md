# Privacy

Mino 0.2.0 runs locally. It has no account system, advertising, telemetry, analytics SDK, remote logging, or app-initiated network requests. It does not collect, upload, screenshot, enumerate, or store other applications' menu bar contents.

Preferences are saved in the app's local UserDefaults domain (`io.github.levin8023.Mino`). macOS manages the positions of Mino's own status items and optional login-item registration. Mino reads display geometry and current pointer/button state to avoid collapsing during menu interaction, and uses system uptime for a local countdown. These values are not retained as a history or sent elsewhere.

The optional fixed global shortcut is registered with Carbon's system hotkey service. Mino does not install a keyboard event tap or log keystrokes. No Accessibility, Input Monitoring, Screen Recording, or Full Disk Access permission is requested.

`Resources/PrivacyInfo.xcprivacy` declares no tracking or collected data. Required-reason APIs declare local preferences (`CA92.1`) and elapsed time (`35F9.1`). Future use of new APIs must update the manifest.

GitHub downloads, issue reporting, CI, and publishing happen outside the application and are governed by their respective services. If you voluntarily share screenshots or logs in an issue, remove private information first.

To remove Mino, turn off Launch at login in Mino, quit it, and delete the app. Optional local settings removal: `defaults delete io.github.levin8023.Mino` after quitting. Do not remove unrelated preference domains.
