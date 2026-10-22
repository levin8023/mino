Mino 0.2.1 — compatibility preview / 兼容性修复预览

保留原三竖条图标。macOS 27 上移除圆点和锁形分隔符，不再撑宽留下大空隙；只创建一个主按钮。由于系统接口限制，此系统上的折叠、始终隐藏、自动收起和折叠快捷键均停用。点击打开设置，右键提供使用说明、系统设置、语言和退出。

Keeps the original three-bar icon. On macOS 27+, only one control is created; dot/lock dividers and inflated widths are removed. Unsupported hiding, always-hidden sections, auto-hide, and hiding shortcuts are disabled. Click for settings; right-click for help, system settings, language, and quit.

每个设置页顶部和右键菜单均可选择简体中文、English 或跟随系统。README 和使用说明提供中英文互选入口。Every settings page and the context menu include a persistent language picker. READMEs and usage guides link both languages.

**Not implemented / 尚未实现:** in-app per-item visible/collapsed/always-hidden selection; folding all items left of the main control without dividers. System >> cannot be disabled through a documented setting. A link to macOS Menu Bar Settings lets you manage app-level visibility manually; this differs from collapsible grouping. Earlier systems retain experimental divider mode, without completed runtime certification.

Download the universal ZIP, verify SHA-256, unzip, and move Mino.app to Applications. Preview builds are ad-hoc signed, **not Developer ID signed or Apple notarized**. See the README and verification record for actual compatibility and installation guidance.
