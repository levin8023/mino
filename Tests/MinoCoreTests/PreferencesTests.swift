// SPDX-License-Identifier: MIT
import Foundation
import MinoCore

let preferencesChecks: [Check] = [
    Check("Partial/future preferences preserve compatible settings") {
        let data = Data(#"{"autoHide":false,"autoHideDelay":999,"language":"future","unknown":true}"#.utf8)
        let value = try JSONDecoder().decode(Preferences.self, from: data)
        try expect(!value.autoHide)
        try expect(value.autoHideDelay == 60)
        try expect(value.language == .system)
        try expect(!value.completedSetup)
    },
    Check("Persistence round-trip and corrupted data recovery") {
        let suite = "io.github.mino.tests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suite) else { throw CheckFailure(message: "Cannot create isolated preferences") }
        defer { defaults.removePersistentDomain(forName: suite) }
        let store = PreferencesStore(defaults: defaults)
        var preferences = Preferences()
        preferences.language = .simplifiedChinese
        preferences.completedSetup = true
        preferences.autoHideDelay = 30
        store.save(preferences)
        try expect(store.load() == preferences)
        defaults.set(Data("broken".utf8), forKey: PreferencesStore.key)
        try expect(store.load() == Preferences())
    },
    Check("Invalid timing values are normalized") {
        var value = Preferences()
        value.autoHideDelay = .nan
        value.normalize()
        try expect(value.autoHideDelay == 10)
        value.autoHideDelay = -100
        value.normalize()
        try expect(value.autoHideDelay == 3)
    },
    Check("System language honors the first preferred language") {
        try expect(AppLanguage.system.usesChinese(preferredLanguages: ["zh-Hans-CN", "en-US"]))
        try expect(!AppLanguage.system.usesChinese(preferredLanguages: ["en-US", "zh-Hans"]))
        try expect(AppLanguage.simplifiedChinese.usesChinese(preferredLanguages: ["en-US"]))
        try expect(!AppLanguage.english.usesChinese(preferredLanguages: ["zh-CN"]))
    }
]
