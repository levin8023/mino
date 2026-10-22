// SPDX-License-Identifier: MIT
import Foundation

/// Pure policy; AppKit owns the actual status items and supplies monotonic time.
public struct VisibilityPolicy: Sendable {
    public private(set) var isCollapsed = false
    public private(set) var isAlwaysHiddenRevealed = false
    public private(set) var lastActivity: TimeInterval

    public init(preferences: Preferences, now: TimeInterval) {
        isCollapsed = preferences.completedSetup && preferences.startCollapsed
        lastActivity = now
    }

    public mutating func setCollapsed(_ collapsed: Bool, now: TimeInterval) {
        isCollapsed = collapsed
        isAlwaysHiddenRevealed = false
        lastActivity = now
    }

    /// Only this explicit action reveals the always-hidden section.
    public mutating func revealAlwaysHidden(now: TimeInterval) {
        isCollapsed = false
        isAlwaysHiddenRevealed = true
        lastActivity = now
    }

    public mutating func recordActivity(now: TimeInterval) { lastActivity = now }

    public mutating func tick(now: TimeInterval, preferences: Preferences, interactionActive: Bool) -> Bool {
        guard !isCollapsed else { return false }
        if interactionActive || !preferences.completedSetup || !preferences.autoHide {
            lastActivity = now
            return false
        }
        guard now - lastActivity >= preferences.autoHideDelay else { return false }
        isCollapsed = true
        isAlwaysHiddenRevealed = false
        lastActivity = now
        return true
    }

    /// The legacy spacer technique is disabled with native overflow: inflating
    /// status items there leaves a gap and does not reliably hide other items.
    public static func spacerLength(isCollapsed: Bool, screenWidths: [Double],
                                    usesNativeOverflow: Bool = false, sectionCount: Int = 1) -> Double {
        guard isCollapsed && !usesNativeOverflow else { return 22 }
        let validWidths = screenWidths.filter { $0.isFinite && $0 > 0 }
        return max(10_000, validWidths.reduce(0, +) * 2)
    }
}
