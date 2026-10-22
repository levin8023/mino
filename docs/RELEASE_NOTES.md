Mino is a small, free, MIT-licensed menu bar manager for macOS 13+.

Mino 是免费开源的原生 macOS 菜单栏管理工具：分隔符折叠、⌃⌥M 快捷键、自动收起、登录启动、中英双语。

0.2.0 adds a compact original three-bar icon, a vertical-dot divider, an optional lock divider for the always-hidden section, right-click Help/Settings/Quit, and a built-in guide. The menu bar uses icons only; the app name appears in the tooltip and context menu. Idle timers stop when automatic hiding cannot act. macOS 27 uses a bounded spacer budget to cooperate with native overflow.

Download the universal ZIP for Apple silicon or Intel, verify its SHA-256, unzip, and move Mino.app to Applications. Hold Command and drag occasional items left of the divider; keep Mino's control on the right.

**Early preview:** the app is ad-hoc signed, not Developer ID signed or Apple notarized. macOS may block opening it. Verify the source/checksum and follow Apple's documented per-app opening flow, or build locally. Do not disable system security protections globally.

**Always hidden:** enable it in Preferences and arrange the lock divider left of the ordinary divider. Ordinary toggles never reveal it; use the dedicated context-menu action to temporarily show it. macOS 27's own overflow may still collect or reveal any third-party item, including Mino itself. This is not a privacy boundary.

**Limitations:** divider overflow depends on macOS layout; a notch or app menus may still obscure expanded items. No separate icon panel, search, automatic item rearrangement, or automatic updates yet. Cross-compilation does not establish runtime support for all OS and hardware combinations. See the repository's verification record and manual checklist.

The local macOS 27 host initially placed the divider to the control's right; the app refuses hiding in that configuration. Command-drag the divider to the left first. End-to-end third-party item hiding has not yet been certified on this host. Treat this as an experimental development preview.

无需辅助功能或屏幕录制权限。刘海屏展开空间仍受系统限制，当前是实验预览版本。
