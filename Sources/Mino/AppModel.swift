// SPDX-License-Identifier: MIT
import AppKit
import SwiftUI
import ServiceManagement
import MinoCore

@MainActor
final class AppModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var preferences: Preferences {
        didSet {
            store.save(preferences)
            onPreferencesChanged?()
        }
    }
    @Published var isCollapsed = false
    @Published var hotkeyError: String?
    @Published var launchAtLogin = false
    @Published var loginNeedsApproval = false
    @Published var loginError: String?
    @Published var layoutWarning = false
    @Published var isArranging = false
    @Published var isAlwaysHiddenRevealed = false

    var onPreferencesChanged: (() -> Void)?
    var onToggle: (() -> Void)?
    var onArrange: (() -> Void)?
    var onFinishSetup: (() -> Void)?
    var onRevealAlwaysHidden: (() -> Void)?
    let store = PreferencesStore()

    init() {
        preferences = store.load()
        refreshLoginStatus()
    }

    var chinese: Bool { preferences.language.usesChinese() }
    func t(_ chinese: String, _ english: String) -> String { self.chinese ? chinese : english }

    func refreshLoginStatus() {
        launchAtLogin = SMAppService.mainApp.status == .enabled
        loginNeedsApproval = SMAppService.mainApp.status == .requiresApproval
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled { try SMAppService.mainApp.register() }
            else { try SMAppService.mainApp.unregister() }
            loginError = nil
        } catch {
            loginError = error.localizedDescription
        }
        refreshLoginStatus()
    }
}
