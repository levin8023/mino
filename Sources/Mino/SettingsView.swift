// SPDX-License-Identifier: MIT
import SwiftUI
import ServiceManagement
import MinoCore

private let accent = Color(red: 0.29, green: 0.36, blue: 0.90)

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    languageChoice
                    switch model.selectedTab {
                    case 1: behavior
                    case 2: about
                    case 3:
                        if model.usesNativeOverflow { nativeHelp } else { help }
                    default:
                        if model.usesNativeOverflow { nativeOverview } else { overview }
                    }
                }
                .padding(32)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 860, height: 602)
        .tint(accent)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 11) {
                BrandMark().frame(width: 38, height: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mino").font(.system(size: 21, weight: .bold, design: .rounded))
                    Text(model.t("少一点，刚刚好。", "A little less. Just right."))
                        .font(.system(size: 10)).foregroundStyle(.secondary)
                }
            }.padding(.bottom, 30).padding(.top, 12)
            navigationRow(0, "rectangle.topthird.inset.filled", model.t("菜单栏", "Menu bar"))
            navigationRow(1, "slider.horizontal.3", model.t("偏好设置", "Preferences"))
            navigationRow(3, "questionmark.circle", model.t("使用说明", "How to use"))
            navigationRow(2, "info.circle", model.t("关于 Mino", "About Mino"))
            Spacer()
            HStack(spacing: 6) {
                Circle().fill(model.usesNativeOverflow ? .orange : (model.isCollapsed ? accent : .green)).frame(width: 6, height: 6)
                Text(model.usesNativeOverflow ? model.t("由 macOS 管理", "Managed by macOS")
                    : model.t(model.isCollapsed ? "图标已收起" : "图标已展开", model.isCollapsed ? "Items hidden" : "Items visible"))
                    .font(.system(size: 11)).foregroundStyle(.secondary)
            }.padding(.leading, 10)
            Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.2.1") · MIT")
                .font(.system(size: 10, design: .monospaced)).foregroundStyle(.tertiary)
                .padding(.leading, 10).padding(.top, 6)
        }
        .padding(20)
        .frame(width: 192)
        .background(.regularMaterial)
    }

    private func navigationRow(_ index: Int, _ icon: String, _ label: String) -> some View {
        Button { model.selectedTab = index } label: {
            HStack(spacing: 10) {
                Image(systemName: icon).frame(width: 18)
                Text(label).font(.system(size: 13, weight: model.selectedTab == index ? .semibold : .regular))
                Spacer()
            }
            .padding(.horizontal, 10).padding(.vertical, 11)
            .foregroundStyle(model.selectedTab == index ? accent : .primary)
            .background(model.selectedTab == index ? accent.opacity(0.10) : .clear, in: RoundedRectangle(cornerRadius: 9))
            .contentShape(Rectangle())
        }.buttonStyle(.plain)
    }

    private var languageChoice: some View {
        HStack {
            Image(systemName: "globe").foregroundStyle(.secondary)
            Text("语言 / Language").font(.system(size: 11)).foregroundStyle(.secondary)
            Spacer()
            Picker("语言 / Language", selection: $model.preferences.language) {
                Text(model.t("跟随系统", "System default")).tag(AppLanguage.system)
                Text("简体中文").tag(AppLanguage.simplifiedChinese)
                Text("English").tag(AppLanguage.english)
            }
            .labelsHidden().frame(width: 150)
            .accessibilityIdentifier("mino.language")
        }
    }

    private var nativeOverview: some View {
        Group {
            heading(model.t("一个图标，不留大空隙。", "One icon. No oversized gaps."),
                    model.t("保留三竖条图标，已停用不兼容的分隔符。", "The three-bar icon stays. Incompatible spacers are disabled."))
            notice(model.t("macOS 27 兼容性限制", "macOS 27 compatibility limits"),
                   model.t("当前系统下，Mino 尚不能可靠地折叠其他应用的图标。现已移除额外分隔符，不再通过撑宽制造收纳空间。点击 Mino 打开设置，右键可查看说明或退出。",
                           "Mino cannot reliably collapse other apps’ icons on this system yet. Extra separators have been removed and no space is reserved for hiding. Click Mino for settings; right-click for help or quit."), icon: "info.circle")
            VStack(alignment: .leading, spacing: 16) {
                Label(model.t("管理菜单栏图标", "Manage menu bar icons"), systemImage: "menubar.rectangle")
                    .font(.system(size: 16, weight: .semibold))
                Text(model.t("在系统设置 → 菜单栏 →「允许在菜单栏中」选择哪些应用可以显示图标。这会关闭该应用的菜单栏入口，不等同于可随时展开的折叠分组。",
                             "In System Settings → Menu Bar → Allow in Menu Bar, choose which apps may show icons. Disabling an app removes its menu bar entry; it does not create a collapsible group."))
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                Button(model.t("打开系统菜单栏设置", "Open macOS Menu Bar Settings")) { model.openMenuBarSettings() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("mino.systemSettings")
            }.card()
            VStack(alignment: .leading, spacing: 12) {
                Label(model.t("折叠 / 始终隐藏", "Collapse / Always hide"), systemImage: "eye.slash")
                    .font(.system(size: 14, weight: .semibold))
                Text(model.t("在 Mino 内逐项选择常驻、折叠或始终隐藏尚未实现。旧版分区和自动收起在 macOS 27 上均已停用；原有偏好会保留。",
                             "Per-item choices for visible, collapsed, and always hidden are not implemented yet. Legacy sections and automatic hiding are disabled on macOS 27; existing preferences are preserved."))
                    .font(.system(size: 12)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }.card()
        }
    }

    private var nativeHelp: some View {
        Group {
            heading(model.t("Mino 使用说明", "Using Mino"),
                    model.t("菜单栏里的三根高低竖条就是 Mino。", "The three rising bars in your menu bar are Mino."))
            VStack(alignment: .leading, spacing: 18) {
                step("1", model.t("点击打开设置", "Click for settings"),
                     model.t("macOS 27 上折叠功能暂不可用，点击不会改变其他图标的显隐。", "Collapsing is currently unavailable on macOS 27. Clicking does not change other icons’ visibility."))
                step("2", model.t("右键打开菜单", "Right-click for the menu"),
                     model.t("提供使用说明、系统菜单栏设置、Mino 设置、语言和退出。", "Access help, macOS Menu Bar Settings, Mino settings, language, and quit."))
                step("3", model.t("自行选择语言", "Choose your language"),
                     model.t("页面顶部或右键菜单均可选择简体中文、English 或跟随系统，立即生效并保存在本机。", "Use the top of any page or the context menu to select 简体中文, English, or System default. Changes apply immediately and stay on this Mac."))
            }.card()
            notice(model.t(">> 是系统入口", ">> belongs to macOS"),
                   model.t("空间不足时 macOS 自动收纳图标。Apple 公开设置未提供单独关闭 >> 的选项。减少常驻图标可缓解收纳；Mino 不能保证系统入口消失，也不能将自己固定在其外。",
                           "macOS collects icons when space runs out. Apple’s documented settings provide no separate switch for >>. Reducing visible icons can relieve overflow; Mino cannot guarantee the indicator disappears or pin itself outside it."), icon: "menubar.arrow.up.rectangle")
            HStack {
                Link("README · 简体中文", destination: URL(string: "https://github.com/levin8023/mino/blob/main/README.md")!)
                Spacer()
                Link("README · English", destination: URL(string: "https://github.com/levin8023/mino/blob/main/README.en.md")!)
            }.font(.system(size: 12))
        }
    }

    private var overview: some View {
        Group {
            heading(model.t("给菜单栏，留点空白。", "Make room for what matters."),
                    model.t("常用的留下，其余的轻轻收起。", "Keep your essentials. Tuck everything else away."))
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Label(model.t("分区示意", "HOW IT WORKS"), systemImage: "rectangle.topthird.inset.filled")
                        .font(.system(size: 10, weight: .semibold)).tracking(1).foregroundStyle(.secondary)
                    Spacer()
                    Text(model.t("示例图标", "Illustrative icons"))
                        .font(.system(size: 10)).foregroundStyle(.tertiary)
                }
                HStack(spacing: 12) {
                    if model.preferences.alwaysHiddenEnabled {
                        Image(systemName: "externaldrive")
                            .opacity(model.isAlwaysHiddenRevealed || model.isArranging ? 1 : 0.15)
                        Image(systemName: "lock.fill").font(.system(size: 12)).foregroundStyle(accent)
                    }
                    HStack(spacing: 15) {
                        ForEach(["cloud", "headphones"], id: \.self) { name in
                            Image(systemName: name).font(.system(size: 16))
                        }
                    }
                    .foregroundStyle(.secondary)
                    .opacity(model.isCollapsed ? 0.15 : 1)
                    Spacer(minLength: 0)
                    Text("⋮").font(.system(size: 19)).foregroundStyle(accent)
                    Rectangle().fill(accent.opacity(0.25)).frame(width: 1, height: 25)
                    HStack(spacing: 3) {
                        ForEach(0..<3) { index in
                            Capsule().fill(accent).frame(width: 2, height: CGFloat(6 + index * 4))
                        }
                    }
                    Image(systemName: "wifi")
                    Image(systemName: "battery.100percent")
                    Text("9:41").font(.system(size: 12, weight: .medium, design: .monospaced))
                }
                .padding(18)
                .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 12))
                HStack {
                    Text(model.t(model.preferences.alwaysHiddenEnabled ? "← 始终隐藏 / 普通隐藏" : "← 可收起区域",
                                 model.preferences.alwaysHiddenEnabled ? "← Always hidden / Hidden" : "← Hidden section"))
                    Spacer()
                    Text(model.t("常驻区域 →", "Always visible →"))
                }.font(.system(size: 11)).foregroundStyle(.secondary)
            }.card()

            arrangementActions

            if model.layoutWarning {
                notice(model.t("请先调整分隔符位置", "Move the dividers first"),
                       model.t("按住 ⌘，从左到右排列为：锁形分隔符（启用时）、⋮、三竖条主按钮。位置异常时暂停折叠。",
                               "Hold ⌘ and arrange left to right: lock divider (if enabled), ⋮, three-bar control. Hiding pauses until the order is safe."), icon: "exclamationmark.triangle")
            }

            VStack(alignment: .leading, spacing: 18) {
                Text(model.t("三步，整理好。", "A calmer menu bar in three steps."))
                    .font(.system(size: 16, weight: .semibold))
                step("1", model.t("展开并开始整理", "Expand and arrange"),
                     model.t("点击「整理图标」，设置窗口会暂时收起。", "Choose Arrange items. This window steps out of the way."))
                step("2", model.t("按住 ⌘，拖动菜单栏图标", "Hold ⌘ and drag your menu bar items"),
                     model.t("把想收起的图标放到分隔符左侧，Mino 保持在右侧。", "Put occasional items left of the divider. Keep Mino on its right."))
                step("3", model.t("点击 Mino，随时展开或收起", "Click Mino to show or hide"),
                     model.t("整理后右键 Mino，选择「完成整理并收起」。", "Right-click Mino and choose Finish arranging and hide."))
            }.card()
            Label(model.t("基础功能无需辅助功能或屏幕录制权限。", "No Accessibility or Screen Recording permissions required."), systemImage: "lock.shield")
                .font(.system(size: 11)).foregroundStyle(.secondary)
        }
    }

    private var arrangementActions: some View {
        HStack(spacing: 10) {
            Button(model.t("整理图标", "Arrange items")) { model.onArrange?() }
                .buttonStyle(.borderedProminent).controlSize(.large)
            if !model.preferences.completedSetup || model.isArranging {
                Button(model.t("完成并收起", "Finish & hide")) { model.onFinishSetup?() }
                    .controlSize(.large)
            } else {
                Button(model.t(model.isCollapsed ? "展开图标" : "收起图标", model.isCollapsed ? "Show items" : "Hide items")) {
                    model.onToggle?()
                }.controlSize(.large)
            }
            Spacer()
            Text("⌃ ⌥ M").font(.system(size: 12, design: .monospaced)).foregroundStyle(.secondary)
        }
    }

    private var behavior: some View {
        Group {
            heading(model.t("按你的习惯来。", "Quietly, your way."),
                    model.t("几个简单选项，让 Mino 自然融入日常。", "A few thoughtful defaults, made to fit your day."))
            if model.supportsSectionHiding {
            VStack(alignment: .leading, spacing: 0) {
                setting(model.t("始终隐藏分区", "Always-hidden section"), model.t("日常展开时仍收起；开启后请重新整理锁形分隔符。", "Stays hidden during ordinary toggles. Arrange the lock divider after enabling.")) {
                    Toggle("", isOn: $model.preferences.alwaysHiddenEnabled).labelsHidden().toggleStyle(.switch)
                }
                Divider()
                setting(model.t("自动收起", "Automatically hide"), model.t("离开菜单栏交互区域后开始计时。", "Countdown starts after you leave the menu interaction area.")) {
                    Toggle("", isOn: $model.preferences.autoHide).labelsHidden().toggleStyle(.switch)
                }
                Divider()
                HStack {
                    Text(model.t("等待时间", "Hide after")).font(.system(size: 13))
                    Spacer()
                    Picker("", selection: $model.preferences.autoHideDelay) {
                        ForEach([3.0, 5, 10, 15, 30, 60], id: \.self) { seconds in
                            Text("\(Int(seconds)) \(model.t("秒", "seconds"))").tag(seconds)
                        }
                    }.labelsHidden().frame(width: 130).disabled(!model.preferences.autoHide)
                }.padding(.vertical, 16)
                Divider()
                setting(model.t("启动时收起", "Start with items hidden"), model.t("首次整理完成后生效。", "Takes effect after initial setup is complete.")) {
                    Toggle("", isOn: $model.preferences.startCollapsed).labelsHidden().toggleStyle(.switch)
                }
            }.card()
            }
            VStack(alignment: .leading, spacing: 0) {
                if model.supportsSectionHiding {
                setting(model.t("全局快捷键", "Global shortcut"), model.t("按 ⌃ ⌥ M 展开或收起图标。", "Press ⌃ ⌥ M to show or hide items.")) {
                    Toggle("", isOn: $model.preferences.hotkeyEnabled).labelsHidden().toggleStyle(.switch)
                }
                Divider()
                }
                setting(model.t("登录时启动", "Launch at login"), model.t("由 macOS 登录项管理，可随时关闭。", "Managed by macOS Login Items. Always optional.")) {
                    Toggle("", isOn: Binding(get: { model.launchAtLogin }, set: model.setLaunchAtLogin))
                        .labelsHidden().toggleStyle(.switch)
                }
                Divider()
                HStack {
                    Text(model.t("语言", "Language")).font(.system(size: 13))
                    Spacer()
                    Picker("", selection: $model.preferences.language) {
                        Text(model.t("跟随系统", "System default")).tag(AppLanguage.system)
                        Text("简体中文").tag(AppLanguage.simplifiedChinese)
                        Text("English").tag(AppLanguage.english)
                    }.labelsHidden().frame(width: 150)
                }.padding(.vertical, 16)
            }.card()
            if let error = model.hotkeyError { notice(model.t("快捷键不可用", "Shortcut unavailable"), error) }
            if let error = model.loginError { notice(model.t("登录项设置失败", "Login item error"), error) }
            if model.loginNeedsApproval {
                Button(model.t("在系统设置中批准登录项", "Approve in System Settings")) { SMAppService.openSystemSettingsLoginItems() }
            }
            if model.supportsSectionHiding {
            Text(model.t("使用图标时自动收起会暂停：指针位于屏幕顶部 400 点范围内、鼠标按下、整理模式或本窗口打开时。",
                         "Auto-hide pauses while the pointer is within 400 points of the screen top, a mouse button is held, arranging is active, or this window is open."))
                .font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            if model.usesNativeOverflow {
                notice(model.t("折叠设置暂不可用", "Hiding settings unavailable"),
                       model.t("macOS 27 上停用分区、自动收起和折叠快捷键。可在「菜单栏」页面打开系统设置管理应用图标。",
                               "Sections, auto-hide, and the hiding shortcut are disabled on macOS 27. Open system settings from the Menu bar page to manage app icons."))
            }
        }
    }

    private var about: some View {
        Group {
            heading(model.t("小工具，大空白。", "Small app. More breathing room."),
                    model.t("免费、开源、原生的 macOS 菜单栏管理工具。", "A free, open-source, native menu bar manager for macOS."))
            VStack(alignment: .leading, spacing: 20) {
                BrandMark().frame(width: 64, height: 64)
                Text("Mino").font(.system(size: 30, weight: .bold, design: .rounded))
                Text(model.t("用最少的操作，找回整洁的菜单栏。没有账户，没有广告，没有数据采集。",
                             "A tidy menu bar with fewer steps. No accounts, no ads, no analytics."))
                    .font(.system(size: 14)).foregroundStyle(.secondary)
                Divider()
                Label("Swift · AppKit · SwiftUI", systemImage: "swift")
                Label(model.t("MIT 开源许可证", "MIT licensed"), systemImage: "chevron.left.forwardslash.chevron.right")
                Label(model.t("设置仅保存在本机", "Preferences stay on your Mac"), systemImage: "internaldrive")
            }.font(.system(size: 13)).card()
            notice(model.t("当前版本的边界", "Early release, clear limits"),
                   model.t("macOS 27 上已停用分隔符和折叠功能。其他系统的分区模式仍属实验功能。暂不支持在 Mino 内逐项设置显隐、独立图标浮窗、图标搜索或自动搬移第三方图标。",
                           "Spacers and hiding are disabled on macOS 27. Section mode on earlier systems remains experimental. In-app per-item visibility, separate icon panels, search, and automatic rearrangement are not available yet."), icon: "info.circle")
            Text(model.t("Mino 独立开发，采用 MIT 许可证。名称尚未进行商标清查。",
                         "Mino is independently developed and MIT licensed. The name has not been trademark-cleared."))
                .font(.system(size: 11)).foregroundStyle(.secondary)
        }
    }

    private var help: some View {
        Group {
            heading(model.t("认准 Mino，轻松整理。", "Meet your Mino controls."),
                    model.t("主按钮是三根高低竖条，分隔符是竖向三点，都支持右键。", "The control has three rising bars. The divider is three vertical dots. Right-click either."))
            if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 27 {
                notice(model.t(">> 是系统自带的收纳入口", ">> is macOS's own overflow"),
                       model.t("Mino 也可能被系统收进去。点 >> 展开后，按住 ⌘ 将三竖条主按钮拖到常驻图标一侧（通常靠右）。Mino 无法关闭系统收纳或保证图标永不进入该入口。",
                               "Mino can be collected there too. Open >>, hold ⌘ and drag the three-bar control toward your visible essentials, usually on the right. Mino cannot disable system overflow or guarantee permanent visibility."), icon: "menubar.arrow.up.rectangle")
            }
            VStack(alignment: .leading, spacing: 18) {
                Label(model.t("三根高低竖条：主按钮", "Three rising bars: main control"), systemImage: "cursorarrow.click")
                    .font(.system(size: 14, weight: .semibold))
                Text(model.t("左键展开或收起图标。右键打开使用说明、设置和退出。按住 ⌥ 点击也能打开设置。",
                             "Click to show or hide items. Right-click for help, settings, and quit. Option-click also opens settings."))
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Divider()
                Text(model.t("⋮：Mino 分隔符", "⋮: Mino divider")).font(.system(size: 14, weight: .semibold))
                Text(model.t("按住 ⌘，把它拖到 Mino 主按钮左侧。想收起的图标放在它的左侧；常用图标留在右侧。左键打开此说明，右键打开菜单。",
                             "Hold ⌘ and drag it left of the Mino control. Put occasional items on its left and essentials on its right. Click for this guide or right-click for the menu."))
                    .font(.system(size: 12)).foregroundStyle(.secondary)
            }.card()
            VStack(alignment: .leading, spacing: 12) {
                Label(model.t("始终隐藏分区", "Always-hidden section"), systemImage: "lock.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text(model.t("在偏好设置启用后，从左到右排列：始终隐藏的图标 → 锁形分隔符 → 普通隐藏图标 → ⋮ → 主按钮 → 常驻图标。开启时会进入整理模式，请右键选择完成整理。",
                             "Enable it in Preferences, then arrange left to right: always-hidden items → lock divider → ordinary hidden items → ⋮ → main control → essentials. Finish arranging from the right-click menu."))
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Text(model.t("日常点击和 ⌃ ⌥ M 不会展开锁形分隔符左侧。需要访问时，右键选择「临时显示始终隐藏区」。系统 >> 仍可能显示其中图标，这不是隐私或安全隔离功能。",
                             "Ordinary clicks and ⌃ ⌥ M never reveal the lock section. Use Temporarily show always-hidden section from the right-click menu to access it. System overflow may still reveal these items; this is not a privacy or security boundary."))
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                if model.preferences.alwaysHiddenEnabled {
                    Button(model.t(model.isAlwaysHiddenRevealed ? "重新隐藏始终隐藏区" : "临时显示始终隐藏区",
                                   model.isAlwaysHiddenRevealed ? "Rehide always-hidden section" : "Temporarily show always-hidden section")) {
                        model.onRevealAlwaysHidden?()
                    }
                }
            }.card()
            VStack(alignment: .leading, spacing: 18) {
                step("1", model.t("点击整理图标", "Choose Arrange items"), model.t("暂时隐藏此窗口，并暂停自动收起。", "This window hides and automatic hiding pauses."))
                step("2", model.t("按住 ⌘ 拖动", "Hold ⌘ and drag"), model.t("从左到右：低频图标、⋮、Mino、常用图标。", "Left to right: occasional items, ⋮, Mino, essentials."))
                step("3", model.t("右键完成整理", "Finish from the right-click menu"), model.t("选择「完成整理并收起」。之后点击 Mino 或按 ⌃ ⌥ M 切换。", "Choose Finish arranging and hide, then click Mino or press ⌃ ⌥ M to toggle."))
                arrangementActions
            }.card()
            notice(model.t("需要退出时", "To quit"), model.t("右键 Mino 或 ⋮，选择「退出 Mino」。退出后分隔符会移除，不再占用菜单栏空间。", "Right-click Mino or ⋮ and choose Quit Mino. Its divider is removed and releases menu bar space."), icon: "power")
        }
    }

    private func heading(_ title: String, _ subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title).font(.system(size: 27, weight: .bold))
            Text(subtitle).font(.system(size: 13)).foregroundStyle(.secondary)
        }.padding(.bottom, 3)
    }

    private func step(_ number: String, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number).font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(accent).frame(width: 25, height: 25)
                .background(accent.opacity(0.08), in: Circle())
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 13, weight: .medium))
                Text(detail).font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func setting<Content: View>(_ title: String, _ subtitle: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 13, weight: .medium))
                Text(subtitle).font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            content()
        }.padding(.vertical, 16)
    }

    private func notice(_ title: String, _ detail: String, icon: String = "exclamationmark.circle") -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon).foregroundStyle(accent)
            VStack(alignment: .leading, spacing: 5) {
                Text(title).font(.system(size: 12, weight: .semibold))
                Text(detail).font(.system(size: 11)).foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            }
        }.padding(15).frame(maxWidth: .infinity, alignment: .leading)
            .background(accent.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

struct BrandMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14).fill(LinearGradient(colors: [accent, Color(red: 0.44, green: 0.32, blue: 0.87)], startPoint: .topLeading, endPoint: .bottomTrailing))
            HStack(spacing: 4) {
                Capsule().fill(.white.opacity(0.55)).frame(width: 5, height: 12)
                Capsule().fill(.white.opacity(0.8)).frame(width: 5, height: 20)
                Capsule().fill(.white).frame(width: 5, height: 28)
            }
        }
        .accessibilityLabel("Mino")
    }
}

private extension View {
    func card() -> some View {
        self.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.65), in: RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.primary.opacity(0.055)))
    }
}
