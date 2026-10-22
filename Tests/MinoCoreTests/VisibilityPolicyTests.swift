// SPDX-License-Identifier: MIT
import Foundation
import MinoCore

let visibilityChecks: [Check] = [
    Check("First launch never hides before setup") {
        var preferences = Preferences()
        preferences.startCollapsed = true
        var policy = VisibilityPolicy(preferences: preferences, now: 0)
        try expect(!policy.isCollapsed)
        try expect(!policy.tick(now: 100, preferences: preferences, interactionActive: false))
        try expect(!policy.isCollapsed)
    },
    Check("Configured startup and exact auto-hide deadline") {
        var preferences = Preferences()
        preferences.completedSetup = true
        var policy = VisibilityPolicy(preferences: preferences, now: 5)
        try expect(policy.isCollapsed)
        policy.setCollapsed(false, now: 20)
        try expect(!policy.tick(now: 29.9, preferences: preferences, interactionActive: false))
        try expect(policy.tick(now: 30, preferences: preferences, interactionActive: false))
        try expect(policy.isCollapsed)
        try expect(!policy.tick(now: 40, preferences: preferences, interactionActive: false))
    },
    Check("Interaction resets the entire idle countdown") {
        var preferences = Preferences()
        preferences.completedSetup = true
        preferences.startCollapsed = false
        var policy = VisibilityPolicy(preferences: preferences, now: 0)
        try expect(!policy.tick(now: 20, preferences: preferences, interactionActive: true))
        try expect(!policy.tick(now: 29, preferences: preferences, interactionActive: false))
        try expect(policy.tick(now: 30, preferences: preferences, interactionActive: false))
    },
    Check("Disabled auto-hide stays expanded") {
        var preferences = Preferences()
        preferences.completedSetup = true
        preferences.startCollapsed = false
        preferences.autoHide = false
        var policy = VisibilityPolicy(preferences: preferences, now: 0)
        try expect(!policy.tick(now: 3600, preferences: preferences, interactionActive: false))
        try expect(!policy.isCollapsed)
    },
    Check("Large and invalid display widths") {
        try expect(VisibilityPolicy.spacerLength(isCollapsed: false, screenWidths: [6016]) == 22)
        try expect(VisibilityPolicy.spacerLength(isCollapsed: true, screenWidths: []) == 10000)
        try expect(VisibilityPolicy.spacerLength(isCollapsed: true, screenWidths: [6016, 6016]) == 24064)
        try expect(VisibilityPolicy.spacerLength(isCollapsed: true, screenWidths: [.nan, .infinity, -10]) == 10000)
    },
    Check("Ordinary toggles never reveal the always-hidden section") {
        var preferences = Preferences()
        preferences.completedSetup = true
        preferences.alwaysHiddenEnabled = true
        var policy = VisibilityPolicy(preferences: preferences, now: 0)
        policy.setCollapsed(false, now: 1)
        try expect(!policy.isAlwaysHiddenRevealed)
        policy.revealAlwaysHidden(now: 2)
        try expect(policy.isAlwaysHiddenRevealed && !policy.isCollapsed)
        policy.setCollapsed(true, now: 3)
        policy.setCollapsed(false, now: 4)
        try expect(!policy.isAlwaysHiddenRevealed)
    },
    Check("Auto-hide ends an explicit always-hidden reveal") {
        var preferences = Preferences()
        preferences.completedSetup = true
        var policy = VisibilityPolicy(preferences: preferences, now: 0)
        policy.revealAlwaysHidden(now: 2)
        try expect(!policy.tick(now: 11, preferences: preferences, interactionActive: false))
        try expect(policy.tick(now: 12, preferences: preferences, interactionActive: false))
        try expect(policy.isCollapsed && !policy.isAlwaysHiddenRevealed)
    },
    Check("Native overflow spacer budget remains below half a display") {
        let one = VisibilityPolicy.spacerLength(isCollapsed: true, screenWidths: [1512, 1920], usesNativeOverflow: true)
        let two = VisibilityPolicy.spacerLength(isCollapsed: true, screenWidths: [1512, 1920], usesNativeOverflow: true, sectionCount: 2)
        try expect(one > 22 && one < 1512 / 2)
        try expect(two > 22 && two * 2 < 1512 / 2)
        try expect(VisibilityPolicy.spacerLength(isCollapsed: false, screenWidths: [1512], usesNativeOverflow: true) == 22)
    }
]
