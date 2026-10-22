// SPDX-License-Identifier: MIT
import AppKit
import SwiftUI
import MinoCore

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSWindowDelegate {
    let model = AppModel()
    private var policy: VisibilityPolicy!
    private var control: NSStatusItem?
    private var divider: NSStatusItem?
    private var alwaysHiddenDivider: NSStatusItem?
    private var settingsWindow: NSWindow?
    private var timer: Timer?
    private let hotkey = HotkeyController()
    private var menuTracking = false
    private var startupCollapsed = false
    private let integrationTest = CommandLine.arguments.contains("--integration-test")
    private let smokeTest = CommandLine.arguments.contains("--smoke-test") || CommandLine.arguments.contains("--integration-test")

    private var now: TimeInterval { ProcessInfo.processInfo.systemUptime }
    private var usesNativeOverflow: Bool { model.usesNativeOverflow }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let mainMenu = NSMenu()
        let applicationItem = NSMenuItem()
        let applicationMenu = NSMenu()
        let quitItem = NSMenuItem(title: model.t("退出 Mino", "Quit Mino"), action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApp
        applicationMenu.addItem(quitItem)
        applicationItem.submenu = applicationMenu
        mainMenu.addItem(applicationItem)
        NSApp.mainMenu = mainMenu
        policy = VisibilityPolicy(preferences: model.preferences, now: now)
        startupCollapsed = model.supportsSectionHiding && policy.isCollapsed && !smokeTest
        policy.setCollapsed(false, now: now)
        createStatusItems()
        model.onToggle = { [weak self] in self?.toggle() }
        model.onArrange = { [weak self] in self?.arrange() }
        model.onFinishSetup = { [weak self] in self?.finishSetup() }
        model.onRevealAlwaysHidden = { [weak self] in self?.revealAlwaysHidden() }
        model.onPreferencesChanged = { [weak self] in self?.preferencesChanged() }
        hotkey.onPressed = { [weak self] in self?.toggle() }
        preferencesChanged()
        NotificationCenter.default.addObserver(self, selector: #selector(screenChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(wokeUp),
            name: NSWorkspace.didWakeNotification, object: nil)
        if !model.preferences.completedSetup || CommandLine.arguments.contains("--settings") {
            showSettings()
        }
        // Let AppKit restore saved positions before deciding whether collapse is safe.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            if self.model.supportsSectionHiding { self.checkLayout() }
            if self.startupCollapsed { self.setCollapsed(true) }
            if self.smokeTest {
                print("Mino smoke test: control=\(self.control?.button != nil), divider=\(self.divider?.button != nil), alwaysDivider=\(self.alwaysHiddenDivider?.button != nil), nativeOverflow=\(self.usesNativeOverflow), layoutWarning=\(self.model.layoutWarning)")
                print("Control window: \(String(describing: self.control?.button?.window?.frame)); bounds: \(String(describing: self.control?.button?.bounds))")
                print("Divider window: \(String(describing: self.divider?.button?.window?.frame)); bounds: \(String(describing: self.divider?.button?.bounds))")
                print("Converted frames: control=\(String(describing: self.statusFrame(self.control))), divider=\(String(describing: self.statusFrame(self.divider)))")
                if self.integrationTest { self.probeCollapse() }
                else { NSApp.terminate(nil) }
            }
        }
    }

    private func probeCollapse() {
        guard model.supportsSectionHiding else {
            print("Native overflow: no spacer created; collapse probe skipped.")
            NSApp.terminate(nil)
            return
        }
        // Explicit test mode only: always restore after this brief geometry probe.
        policy.setCollapsed(true, now: now)
        applyVisibility()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self else { return }
            print("Collapsed geometry: control=\(String(describing: self.control?.button?.window?.frame)), divider=\(String(describing: self.divider?.button?.window?.frame)), length=\(self.divider?.length ?? 0)")
            self.policy.setCollapsed(false, now: self.now)
            self.applyVisibility()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                print("Restored geometry: control=\(String(describing: self.control?.button?.window?.frame)), divider=\(String(describing: self.divider?.button?.window?.frame)), length=\(self.divider?.length ?? 0)")
                NSApp.terminate(nil)
            }
        }
    }

    private func createStatusItems() {
        // Creation order provides the initial layout; autosaveName preserves user placement.
        let control = NSStatusBar.system.statusItem(withLength: 24)
        control.autosaveName = "Mino.Control"
        control.behavior = []
        self.control = control
        if let button = control.button {
            button.image = StatusArtwork.control
            button.imagePosition = .imageOnly
            button.target = self
            button.action = #selector(controlClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.setAccessibilityIdentifier("mino.control")
        }
        if model.supportsSectionHiding {
            createDivider()
            if model.preferences.alwaysHiddenEnabled { createAlwaysHiddenDivider() }
        }
        applyVisibility()
    }

    private func createDivider() {
        let divider = NSStatusBar.system.statusItem(withLength: 22)
        divider.autosaveName = "Mino.Divider"
        divider.behavior = []
        self.divider = divider
        if let button = divider.button {
            button.image = StatusArtwork.divider
            button.target = self
            button.action = #selector(dividerClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.setAccessibilityIdentifier("mino.divider")
        }
        applyVisibility()
    }

    @objc private func controlClicked() {
        guard let event = NSApp.currentEvent else { return }
        if event.type == .rightMouseUp { showMenu(for: control) }
        else if event.modifierFlags.contains(.option) { showSettings() }
        else { toggle() }
    }

    @objc private func dividerClicked() {
        if NSApp.currentEvent?.type == .rightMouseUp { showMenu(for: divider) }
        else { showHelp() }
    }

    private func createAlwaysHiddenDivider() {
        let item = NSStatusBar.system.statusItem(withLength: 22)
        item.autosaveName = "Mino.AlwaysHiddenDivider"
        item.behavior = []
        alwaysHiddenDivider = item
        if let button = item.button {
            button.image = StatusArtwork.alwaysHiddenDivider
            button.target = self
            button.action = #selector(alwaysHiddenDividerClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.setAccessibilityIdentifier("mino.alwaysHiddenDivider")
        }
    }

    @objc private func alwaysHiddenDividerClicked() {
        if NSApp.currentEvent?.type == .rightMouseUp { showMenu(for: alwaysHiddenDivider) }
        else { showHelp() }
    }

    private func preferencesChanged() {
        if model.supportsSectionHiding && model.preferences.alwaysHiddenEnabled && alwaysHiddenDivider == nil {
            model.isArranging = true
            policy?.setCollapsed(false, now: now)
            createAlwaysHiddenDivider()
        } else if !model.preferences.alwaysHiddenEnabled, let item = alwaysHiddenDivider {
            item.length = 22
            NSStatusBar.system.removeStatusItem(item)
            alwaysHiddenDivider = nil
            policy?.setCollapsed(false, now: now)
        }
        if model.supportsSectionHiding && model.preferences.hotkeyEnabled {
            let status = hotkey.register()
            model.hotkeyError = status == noErr ? nil : model.t(
                "快捷键注册失败（\(status)），可能已被其他应用占用。可关闭快捷键后重新启用。",
                "Could not register shortcut (\(status)). It may be in use. Toggle the shortcut off and on to retry.")
        } else {
            hotkey.unregister()
            model.hotkeyError = nil
        }
        policy?.recordActivity(now: now)
        NSApp.mainMenu?.items.first?.submenu?.items.first?.title = model.t("退出 Mino", "Quit Mino")
        if policy != nil { applyVisibility() }
    }

    private func toggle() { setCollapsed(!policy.isCollapsed) }

    private func setCollapsed(_ value: Bool) {
        guard model.supportsSectionHiding else {
            policy.setCollapsed(false, now: now)
            applyVisibility()
            showSettings()
            return
        }
        if value && !policy.isCollapsed {
            checkLayout()
            guard !model.layoutWarning else {
                policy.setCollapsed(false, now: now)
                applyVisibility()
                showSettings()
                return
            }
        }
        policy.setCollapsed(value, now: now)
        applyVisibility()
    }

    private func applyVisibility() {
        if model.isCollapsed != policy.isCollapsed { model.isCollapsed = policy.isCollapsed }
        if model.isAlwaysHiddenRevealed != policy.isAlwaysHiddenRevealed {
            model.isAlwaysHiddenRevealed = policy.isAlwaysHiddenRevealed
        }
        let widths = NSScreen.screens.map { Double($0.frame.width) }
        let sections = model.preferences.alwaysHiddenEnabled ? 2 : 1
        let length = CGFloat(VisibilityPolicy.spacerLength(isCollapsed: policy.isCollapsed,
            screenWidths: widths, usesNativeOverflow: usesNativeOverflow, sectionCount: sections))
        if divider?.length != length { divider?.length = length }
        let hideAlways = model.preferences.completedSetup && !model.isArranging && !policy.isAlwaysHiddenRevealed
        let alwaysLength = CGFloat(VisibilityPolicy.spacerLength(isCollapsed: hideAlways,
            screenWidths: widths, usesNativeOverflow: usesNativeOverflow, sectionCount: sections))
        if alwaysHiddenDivider?.length != alwaysLength { alwaysHiddenDivider?.length = alwaysLength }
        let state = usesNativeOverflow ? model.t("由系统管理", "Managed by macOS")
            : model.t(policy.isCollapsed ? "已收起" : "已展开", policy.isCollapsed ? "Hidden" : "Visible")
        control?.button?.toolTip = usesNativeOverflow
            ? model.t("Mino · 点击打开设置，右键说明/设置/退出", "Mino · Click for settings; right-click for help, settings, quit")
            : model.t("Mino · \(state) · 左键切换，右键说明/设置/退出", "Mino · \(state) · Click to toggle; right-click for help, settings, quit")
        control?.button?.setAccessibilityLabel("Mino · \(state)")
        divider?.button?.toolTip = model.t("Mino 分隔符 · 按住 ⌘ 拖到 Mino 左边 · 右键打开菜单", "Mino divider · Hold ⌘ and drag left of Mino · Right-click for menu")
        alwaysHiddenDivider?.button?.toolTip = model.t("Mino 始终隐藏分隔符 · 放在普通分隔符左侧 · 日常点击不会展开此区", "Mino always-hidden divider · Place left of the normal divider · Ordinary toggles never reveal this section")
        refreshAutoHideTimer()
    }

    private func checkLayout() {
        guard let controlFrame = statusFrame(control),
              let dividerFrame = statusFrame(divider),
              controlFrame.width > 0, dividerFrame.width > 0 else {
            if !model.layoutWarning { model.layoutWarning = true }
            return
        }
        // A misplaced control could itself overflow. Never collapse in that layout.
        var warning = dividerFrame.maxX > controlFrame.minX + 2
            || abs(dividerFrame.maxY - controlFrame.maxY) > 4
        if let item = alwaysHiddenDivider, item.length <= 30, let frame = statusFrame(item) {
            warning = warning || frame.maxX > dividerFrame.minX + 2
                || abs(frame.maxY - dividerFrame.maxY) > 4
        }
        if warning != model.layoutWarning { model.layoutWarning = warning }
    }

    private func statusFrame(_ item: NSStatusItem?) -> NSRect? {
        guard let button = item?.button, let window = button.window else { return nil }
        return window.convertToScreen(button.convert(button.bounds, to: nil))
    }

    private func tick() {
        guard !smokeTest, !policy.isCollapsed else { return }
        let pointer = NSEvent.mouseLocation
        // Pause above the menu bar and in its 400pt menu interaction area below.
        let pointerNearMenu = NSScreen.screens.contains { screen in
            screen.frame.contains(pointer) && pointer.y >= screen.frame.maxY - 400
        }
        let interacting = pointerNearMenu || menuTracking || (settingsWindow?.isVisible ?? false)
            || model.isArranging || NSEvent.pressedMouseButtons != 0
        if policy.tick(now: now, preferences: model.preferences, interactionActive: interacting) {
            // Validate only at the actual transition, not on every timer wakeup.
            policy.setCollapsed(false, now: now)
            setCollapsed(true)
        }
    }

    private func refreshAutoHideTimer() {
        guard policy != nil else { return }
        let shouldRun = model.supportsSectionHiding && !smokeTest && !policy.isCollapsed && model.preferences.completedSetup
            && model.preferences.autoHide && !model.isArranging && !menuTracking
            && !(settingsWindow?.isVisible ?? false)
        guard shouldRun else {
            timer?.invalidate()
            timer = nil
            return
        }
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated { self?.tick() }
        }
        timer.tolerance = 0.3
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func arrange() {
        guard model.supportsSectionHiding else { showSettings(); return }
        model.isArranging = true
        setCollapsed(false)
        settingsWindow?.orderOut(nil)
    }

    private func finishSetup() {
        guard model.supportsSectionHiding else { showSettings(); return }
        checkLayout()
        guard !model.layoutWarning else { showSettings(); return }
        model.preferences.completedSetup = true
        model.isArranging = false
        setCollapsed(true)
    }

    private func revealAlwaysHidden() {
        guard model.supportsSectionHiding && model.preferences.alwaysHiddenEnabled else { return }
        if policy.isAlwaysHiddenRevealed { policy.setCollapsed(false, now: now) }
        else { policy.revealAlwaysHidden(now: now) }
        applyVisibility()
    }

    @objc private func screenChanged() {
        // Display changes can move status items. Expand and re-check rather than trap them.
        policy.setCollapsed(false, now: now)
        applyVisibility()
    }


    @objc private func wokeUp() {
        screenChanged()
        model.refreshLoginStatus()
    }

    @objc func showSettings() {
        model.refreshLoginStatus()
        if settingsWindow == nil {
            let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 860, height: 630),
                styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            window.title = "Mino"
            window.titlebarAppearsTransparent = true
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.contentView = NSHostingView(rootView: SettingsView(model: model))
            window.center()
            settingsWindow = window
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
        refreshAutoHideTimer()
    }

    @objc private func showHelp() {
        model.selectedTab = 3
        showSettings()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showSettings()
        return true
    }

    func windowWillClose(_ notification: Notification) {
        if usesNativeOverflow && !model.preferences.completedSetup { model.preferences.completedSetup = true }
        policy.recordActivity(now: now)
        DispatchQueue.main.async { [weak self] in self?.refreshAutoHideTimer() }
    }

    private func showMenu(for item: NSStatusItem?) {
        guard let button = item?.button else { showSettings(); return }
        let menu = NSMenu()
        menu.delegate = self
        menu.minimumWidth = 210
        let heading = NSMenuItem(title: "Mino", action: nil, keyEquivalent: "")
        heading.isEnabled = false
        menu.addItem(heading)
        menu.addItem(.separator())
        if model.supportsSectionHiding {
            add(model.t(policy.isCollapsed ? "展开图标" : "收起图标", policy.isCollapsed ? "Show items" : "Hide items"),
                action: #selector(toggleFromMenu), to: menu)
            add(model.t("整理图标…", "Arrange items…"), action: #selector(arrangeFromMenu), to: menu)
            if model.preferences.alwaysHiddenEnabled {
                add(model.t(policy.isAlwaysHiddenRevealed ? "重新隐藏始终隐藏区" : "临时显示始终隐藏区…",
                            policy.isAlwaysHiddenRevealed ? "Rehide always-hidden section" : "Temporarily show always-hidden section…"),
                    action: #selector(revealAlwaysFromMenu), to: menu)
            }
            if model.isArranging || !model.preferences.completedSetup {
                add(model.t("完成整理并收起", "Finish arranging and hide"), action: #selector(finishFromMenu), to: menu)
            }
        } else {
            add(model.t("系统菜单栏设置…", "macOS Menu Bar Settings…"), action: #selector(openSystemSettings), to: menu)
        }
        menu.addItem(.separator())
        add(model.t("使用说明…", "How to use Mino…"), action: #selector(showHelp), to: menu)
        add(model.t("设置…", "Settings…"), action: #selector(showSettings), key: ",", to: menu)
        let language = NSMenuItem(title: "语言 / Language", action: nil, keyEquivalent: "")
        let languages = NSMenu()
        for (title, value) in [(model.t("跟随系统", "System default"), AppLanguage.system), ("简体中文", .simplifiedChinese), ("English", .english)] {
            let entry = NSMenuItem(title: title, action: #selector(selectLanguage(_:)), keyEquivalent: "")
            entry.target = self
            entry.representedObject = value.rawValue
            entry.state = model.preferences.language == value ? .on : .off
            languages.addItem(entry)
        }
        language.submenu = languages
        menu.addItem(language)
        menu.addItem(.separator())
        add(model.t("退出 Mino", "Quit Mino"), action: #selector(quit), key: "q", to: menu)
        // Present directly: right-clicking must not re-enter the button's own action.
        menu.popUp(positioning: nil, at: NSPoint(x: 0, y: button.bounds.minY), in: button)
    }

    private func add(_ title: String, action: Selector, key: String = "", to menu: NSMenu) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        menu.addItem(item)
    }

    func menuWillOpen(_ menu: NSMenu) { menuTracking = true; refreshAutoHideTimer() }
    func menuDidClose(_ menu: NSMenu) {
        menuTracking = false
        policy.recordActivity(now: now)
        refreshAutoHideTimer()
    }
    @objc private func toggleFromMenu() { toggle() }
    @objc private func arrangeFromMenu() { arrange() }
    @objc private func finishFromMenu() { finishSetup() }
    @objc private func revealAlwaysFromMenu() { revealAlwaysHidden() }
    @objc private func openSystemSettings() { model.openMenuBarSettings() }
    @objc private func selectLanguage(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String, let language = AppLanguage(rawValue: rawValue) else { return }
        model.preferences.language = language
    }
    @objc private func quit() { NSApp.terminate(nil) }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        hotkey.unregister()
        // Release the oversized spacer before exiting, including while collapsed.
        divider?.length = 22
        alwaysHiddenDivider?.length = 22
        if let alwaysHiddenDivider { NSStatusBar.system.removeStatusItem(alwaysHiddenDivider) }
        if let divider { NSStatusBar.system.removeStatusItem(divider) }
        if let control { NSStatusBar.system.removeStatusItem(control) }
        NotificationCenter.default.removeObserver(self)
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
