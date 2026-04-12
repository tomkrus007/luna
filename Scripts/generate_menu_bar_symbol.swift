import AppKit
import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

let fileManager = FileManager.default
let rootURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
let imageSetURL = rootURL.appendingPathComponent("Resources/Assets.xcassets/MenuBarSymbol.imageset", isDirectory: true)

func roundedPath(in rect: CGRect, radius: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
}

func withBitmapContext(size: Int, draw: (CGContext, CGRect) -> Void) -> CGImage? {
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else {
        return nil
    }

    let rect = CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size))
    context.setAllowsAntialiasing(true)
    draw(context, rect)
    return context.makeImage()
}

func drawMenuBarSymbol(in context: CGContext, rect: CGRect, color: CGColor) {
    context.setStrokeColor(color)
    context.setFillColor(color)

    let lineWidth = max(1.2, rect.width * 0.06)
    let calendarRect = rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.16)
    context.setLineWidth(lineWidth)
    context.setLineJoin(.round)
    context.setLineCap(.round)
    context.addPath(roundedPath(in: calendarRect, radius: rect.width * 0.06))
    context.strokePath()

    let binderWidth = max(1.2, rect.width * 0.06)
    let binderHeight = rect.height * 0.10
    let binderY = calendarRect.maxY - rect.height * 0.02
    let leftBinder = CGRect(x: calendarRect.minX + calendarRect.width * 0.2, y: binderY, width: binderWidth, height: binderHeight)
    let rightBinder = CGRect(x: calendarRect.maxX - calendarRect.width * 0.2 - binderWidth, y: binderY, width: binderWidth, height: binderHeight)
    context.addPath(roundedPath(in: leftBinder, radius: binderWidth / 2))
    context.fillPath()
    context.addPath(roundedPath(in: rightBinder, radius: binderWidth / 2))
    context.fillPath()

    let separatorY = calendarRect.maxY - calendarRect.height * 0.26
    context.move(to: CGPoint(x: calendarRect.minX + rect.width * 0.01, y: separatorY))
    context.addLine(to: CGPoint(x: calendarRect.maxX - rect.width * 0.01, y: separatorY))
    context.strokePath()
}

func writePNG(_ image: CGImage, to url: URL) throws {
    guard let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil) else {
        throw NSError(domain: "MenuBarSymbol", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG destination"])
    }
    CGImageDestinationAddImage(destination, image, nil)
    guard CGImageDestinationFinalize(destination) else {
        throw NSError(domain: "MenuBarSymbol", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize PNG output"])
    }
}

guard fileManager.fileExists(atPath: imageSetURL.path) else {
    fputs("MenuBarSymbol.imageset not found at \(imageSetURL.path)\n", stderr)
    exit(1)
}

let pngURL = imageSetURL.appendingPathComponent("menu-bar-calendar.png")
let staleAssetPNGURL = imageSetURL.appendingPathComponent("menu-bar-calendar.png")
let stalePDFURL = imageSetURL.appendingPathComponent("menu-bar-calendar.pdf")

if fileManager.fileExists(atPath: staleAssetPNGURL.path) {
    try? fileManager.removeItem(at: staleAssetPNGURL)
}

if fileManager.fileExists(atPath: stalePDFURL.path) {
    try? fileManager.removeItem(at: stalePDFURL)
}

guard let image = withBitmapContext(size: 64, draw: { context, rect in
    drawMenuBarSymbol(in: context, rect: rect, color: NSColor.black.cgColor)
}) else {
    fputs("Failed to draw MenuBarSymbol PNG\n", stderr)
    exit(2)
}

try writePNG(image, to: pngURL)

print("Generated menu-bar-calendar.png [64x64]")
print("Done: MenuBarSymbol PNG generated in \(imageSetURL.path)")
