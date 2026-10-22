// SPDX-License-Identifier: MIT
import AppKit

guard CommandLine.arguments.count == 2 else { fatalError("Usage: generate-icon.swift output.iconset") }
let directory = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let side = CGFloat(pixels)
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
              let context = NSGraphicsContext(bitmapImageRep: bitmap) else { fatalError("Cannot create icon bitmap") }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        let inset = side * 0.09
        let shape = NSBezierPath(roundedRect: NSRect(x: inset, y: inset, width: side - inset * 2, height: side - inset * 2),
                                 xRadius: side * 0.19, yRadius: side * 0.19)
        let gradient = NSGradient(starting: NSColor(srgbRed: 0.29, green: 0.36, blue: 0.90, alpha: 1),
                                  ending: NSColor(srgbRed: 0.44, green: 0.32, blue: 0.87, alpha: 1))!
        gradient.draw(in: shape, angle: -45)
        for index in 0..<3 {
            let height = side * [0.22, 0.36, 0.50][index]
            let width = side * 0.085
            let x = side * 0.29 + CGFloat(index) * side * 0.16
            NSColor.white.withAlphaComponent([0.55, 0.8, 1][index]).setFill()
            NSBezierPath(roundedRect: NSRect(x: x, y: (side - height) / 2, width: width, height: height),
                         xRadius: width / 2, yRadius: width / 2).fill()
        }
        NSGraphicsContext.restoreGraphicsState()
        let suffix = scale == 2 ? "@2x" : ""
        let url = directory.appendingPathComponent("icon_\(size)x\(size)\(suffix).png")
        guard let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("Cannot encode PNG") }
        try png.write(to: url)
    }
}
