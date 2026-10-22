// SPDX-License-Identifier: MIT
import Foundation

public enum AppLanguage: String, Codable, CaseIterable, Sendable {
    case system, english, simplifiedChinese

    public func usesChinese(preferredLanguages: [String] = Locale.preferredLanguages) -> Bool {
        switch self {
        case .system: return preferredLanguages.first?.hasPrefix("zh") ?? false
        case .english: return false
        case .simplifiedChinese: return true
        }
    }
}

public struct Preferences: Codable, Equatable, Sendable {
    public var autoHide = true
    public var autoHideDelay: TimeInterval = 10
    public var startCollapsed = true
    public var hotkeyEnabled = true
    public var language: AppLanguage = .system
    public var completedSetup = false
    public var alwaysHiddenEnabled = false

    public init() {}

    public mutating func normalize() {
        if !autoHideDelay.isFinite { autoHideDelay = 10 }
        autoHideDelay = min(60, max(3, autoHideDelay))
    }

    // Decode each field independently so adding settings doesn't erase existing ones.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.init()
        autoHide = (try? values.decode(Bool.self, forKey: .autoHide)) ?? autoHide
        autoHideDelay = (try? values.decode(Double.self, forKey: .autoHideDelay)) ?? autoHideDelay
        startCollapsed = (try? values.decode(Bool.self, forKey: .startCollapsed)) ?? startCollapsed
        hotkeyEnabled = (try? values.decode(Bool.self, forKey: .hotkeyEnabled)) ?? hotkeyEnabled
        language = (try? values.decode(AppLanguage.self, forKey: .language)) ?? language
        completedSetup = (try? values.decode(Bool.self, forKey: .completedSetup)) ?? completedSetup
        alwaysHiddenEnabled = (try? values.decode(Bool.self, forKey: .alwaysHiddenEnabled)) ?? alwaysHiddenEnabled
        normalize()
    }
}

public struct PreferencesStore {
    private let defaults: UserDefaults
    public static let key = "Mino.preferences.v1"

    public init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    public func load() -> Preferences {
        guard let data = defaults.data(forKey: Self.key),
              let value = try? JSONDecoder().decode(Preferences.self, from: data)
        else { return Preferences() }
        return value
    }

    public func save(_ preferences: Preferences) {
        var value = preferences
        value.normalize()
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
