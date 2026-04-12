import AppKit
import SwiftUI

@MainActor
final class CalendarWindowController: NSWindowController {
    convenience init(viewModel: CalendarViewModel, settingsStore: SettingsStore) {
        let hostingController = NSHostingController(rootView: CalendarWindowView(viewModel: viewModel, settingsStore: settingsStore))
        let window = NSWindow(contentViewController: hostingController)
        window.title = "万年历"
        window.setContentSize(NSSize(width: 360, height: 520))
        self.init(window: window)
    }
}
