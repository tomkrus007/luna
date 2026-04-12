import AppKit
import Foundation

let fileManager = FileManager.default
let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let iconSetURL = rootURL.appendingPathComponent("Resources/Assets.xcassets/AppIcon.appiconset", isDirectory: true)

let icons: [(filename: String, pixels: Int)] = [
    ("AppIcon-16.png", 16),
    ("AppIcon-16@2x.png", 32),
    ("AppIcon-32.png", 32),
    ("AppIcon-32@2x.png", 64),
    ("AppIcon-128.png", 128),
    ("AppIcon-128@2x.png", 256),
    ("AppIcon-256.png", 256),
    ("AppIcon-256@2x.png", 512),
    ("AppIcon-512.png", 512),
    ("AppIcon-512@2x.png", 1024)
]

func roundedPath(in rect: NSRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func drawCalendarGlyph(in rect: NSRect, foreground: NSColor) {
    let lineWidth = max(1.2, rect.width * 0.05)
    let radius = rect.width * 0.11
    let outlineRect = rect.insetBy(dx: rect.width * 0.07, dy: rect.height * 0.08)

    foreground.setStroke()
    let outline = roundedPath(in: outlineRect, radius: radius)
    outline.lineWidth = lineWidth
    outline.stroke()

    let binderWidth = max(1.2, rect.width * 0.055)
    let binderHeight = rect.height * 0.16
    let binderY = outlineRect.maxY - rect.height * 0.05
    let leftBinder = NSRect(x: outlineRect.minX + outlineRect.width * 0.2, y: binderY, width: binderWidth, height: binderHeight)
    let rightBinder = NSRect(x: outlineRect.maxX - outlineRect.width * 0.2 - binderWidth, y: binderY, width: binderWidth, height: binderHeight)

    foreground.setFill()
    roundedPath(in: leftBinder, radius: binderWidth / 2).fill()
    roundedPath(in: rightBinder, radius: binderWidth / 2).fill()

    let separatorY = outlineRect.maxY - outlineRect.height * 0.24
    let separator = NSBezierPath()
    separator.move(to: NSPoint(x: outlineRect.minX + rect.width * 0.03, y: separatorY))
    separator.line(to: NSPoint(x: outlineRect.maxX - rect.width * 0.03, y: separatorY))
    separator.lineWidth = max(1.0, rect.width * 0.04)
    separator.stroke()

    let dotSize = max(1.0, rect.width * 0.085)
    let startX = outlineRect.minX + outlineRect.width * 0.18
    let startY = outlineRect.minY + outlineRect.height * 0.17
    let gapX = outlineRect.width * 0.24
    let gapY = outlineRect.height * 0.21

    for row in 0..<3 {
        for col in 0..<3 {
            if row == 2 && col == 2 { continue }
            let dotRect = NSRect(
                x: startX + CGFloat(col) * gapX,
                y: startY + CGFloat(row) * gapY,
                width: dotSize,
                height: dotSize
            )
            roundedPath(in: dotRect, radius: dotSize * 0.28).fill()
        }
    }
}

func makeBitmapRep(pixels: Int) -> NSBitmapImageRep? {
    NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )
}

func makeAppIconRep(pixels: Int) -> NSBitmapImageRep? {
    guard let rep = makeBitmapRep(pixels: pixels) else { return nil }

    let context = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = context

    let canvas = NSRect(x: 0, y: 0, width: pixels, height: pixels)
    NSColor.clear.setFill()
    canvas.fill()

    let inset = canvas.width * 0.08
    let bgRect = canvas.insetBy(dx: inset, dy: inset)
    let bgRadius = canvas.width * 0.22

    let background = NSGradient(colors: [
        NSColor(calibratedRed: 0.19, green: 0.44, blue: 0.78, alpha: 1),
        NSColor(calibratedRed: 0.12, green: 0.31, blue: 0.61, alpha: 1)
    ])
    background?.draw(in: roundedPath(in: bgRect, radius: bgRadius), angle: -90)

    let topBarHeight = bgRect.height * 0.22
    let topBarRect = NSRect(x: bgRect.minX, y: bgRect.maxY - topBarHeight, width: bgRect.width, height: topBarHeight)
    NSColor(calibratedWhite: 1, alpha: 0.18).setFill()
    roundedPath(in: topBarRect, radius: bgRadius * 0.5).fill()

    let highlightRect = NSRect(
        x: bgRect.minX + bgRect.width * 0.11,
        y: bgRect.minY + bgRect.height * 0.1,
        width: bgRect.width * 0.78,
        height: bgRect.height * 0.78
    )
    let highlight = NSGradient(colors: [
        NSColor(calibratedWhite: 1, alpha: 0.08),
        NSColor(calibratedWhite: 1, alpha: 0.0)
    ])
    highlight?.draw(in: roundedPath(in: highlightRect, radius: bgRect.width * 0.18), angle: -90)

    let glyphRect = bgRect.insetBy(dx: bgRect.width * 0.18, dy: bgRect.height * 0.16)
    drawCalendarGlyph(in: glyphRect, foreground: .white)

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let text = NSAttributedString(
        string: "初三",
        attributes: [
            .font: NSFont.monospacedDigitSystemFont(ofSize: max(4, canvas.width * 0.085), weight: .semibold),
            .foregroundColor: NSColor(calibratedWhite: 1, alpha: 0.92),
            .paragraphStyle: paragraph
        ]
    )
    let textSize = text.size()
    let textRect = NSRect(
        x: bgRect.midX - textSize.width / 2,
        y: bgRect.minY + bgRect.height * 0.07,
        width: textSize.width,
        height: textSize.height
    )
    text.draw(in: textRect)

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

func writePNG(_ rep: NSBitmapImageRep, to url: URL) throws {
    guard let png = rep.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "IconGeneration", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode PNG"])
    }
    try png.write(to: url, options: .atomic)
}

guard fileManager.fileExists(atPath: iconSetURL.path) else {
    fputs("AppIcon.appiconset not found at \(iconSetURL.path)\n", stderr)
    exit(1)
}

for icon in icons {
    guard let rep = makeAppIconRep(pixels: icon.pixels) else {
        fputs("Failed to draw \(icon.filename)\n", stderr)
        exit(2)
    }
    let outputURL = iconSetURL.appendingPathComponent(icon.filename)
    try writePNG(rep, to: outputURL)
    print("Generated \(icon.filename) [\(icon.pixels)x\(icon.pixels)]")
}

print("Done: placeholder app icons generated in \(iconSetURL.path)")
