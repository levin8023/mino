// SPDX-License-Identifier: MIT
import AppKit

@MainActor
enum StatusArtwork {
    static let control: NSImage = {
        let image = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { _ in
            NSColor.black.setFill()
            for (index, height) in [6.0, 10.0, 14.0].enumerated() {
                let rect = NSRect(x: 2 + Double(index) * 5, y: (18 - height) / 2, width: 3, height: height)
                NSBezierPath(roundedRect: rect, xRadius: 1.5, yRadius: 1.5).fill()
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Mino"
        return image
    }()

    static let divider: NSImage = {
        let image = NSImage(size: NSSize(width: 12, height: 18), flipped: false) { _ in
            NSColor.black.setFill()
            for y in [3.0, 8.0, 13.0] {
                NSBezierPath(ovalIn: NSRect(x: 5, y: y, width: 2, height: 2)).fill()
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Mino divider"
        return image
    }()

    static let alwaysHiddenDivider: NSImage = {
        let image = NSImage(size: NSSize(width: 14, height: 18), flipped: false) { _ in
            NSColor.black.setStroke()
            let shackle = NSBezierPath(roundedRect: NSRect(x: 4, y: 9, width: 6, height: 6), xRadius: 3, yRadius: 3)
            shackle.lineWidth = 1.5
            shackle.stroke()
            NSColor.black.setFill()
            NSBezierPath(roundedRect: NSRect(x: 2.5, y: 3, width: 9, height: 8), xRadius: 2, yRadius: 2).fill()
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = "Mino always-hidden divider"
        return image
    }()
}
