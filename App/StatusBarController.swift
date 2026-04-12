import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject {
    private let appModel: AppModel
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var hostingController: NSHostingController<CalendarWindowView>?
    private var settingsWindowController: NSWindowController?
    private var cancellables = Set<AnyCancellable>()
    private var tickerTask: Task<Void, Never>?

    init(appModel: AppModel) {
        self.appModel = appModel
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configurePopover()
        configureStatusItem()
        bindSettings()
        updateStatusItem()
        startTicker()
    }

    deinit {
        tickerTask?.cancel()
    }

    private func configurePopover() {
        popover.behavior = .transient
        popover.animates = true
        popover.contentSize = NSSize(width: 360, height: 420)
        hostingController = NSHostingController(
            rootView: CalendarWindowView(
                viewModel: appModel.calendarViewModel,
                settingsStore: appModel.settingsStore,
                openSettingsAction: { [weak self] in
                    self?.openSettingsWindow()
                }
            )
        )
        popover.contentViewController = hostingController
    }

    private func configureStatusItem() {
        guard let button = statusItem.button else { return }
        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp])
        button.imagePosition = .imageOnly
        button.imageScaling = .scaleProportionallyDown
    }

    private func bindSettings() {
        appModel.settingsStore.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                guard let self else { return }
                DispatchQueue.main.async {
                    self.updateStatusItem()
                    self.startTicker()
                }
            }
            .store(in: &cancellables)
    }

    private func startTicker() {
        tickerTask?.cancel()
        tickerTask = Task { [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                self.updateStatusItem()
                let interval = self.appModel.settingsStore.showIcon ? 60.0 : (self.appModel.settingsStore.showTime ? 1.0 : 60.0)
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    private func updateStatusItem() {
        guard let button = statusItem.button else { return }

        if appModel.settingsStore.showIcon {
            statusItem.length = 12
            button.title = ""
            button.attributedTitle = NSAttributedString(string: "")
            button.image = statusImage()
            button.imagePosition = .imageOnly
            button.toolTip = "LunaCalendar"
        } else {
            statusItem.length = NSStatusItem.variableLength
            button.image = nil
            button.imagePosition = .noImage
            button.title = statusText(for: Date())
            button.toolTip = nil
        }
    }

    private func statusImage() -> NSImage? {
        let image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
        image?.isTemplate = true
        image?.size = NSSize(width: 18, height: 18)
        return image
    }

    private func statusText(for date: Date) -> String {
        var parts: [String] = []

        if appModel.settingsStore.showLunar {
            parts.append(CalendarConverter.getStatusBarLunarText(for: date))
        } else {
            let calendar = CalendarGridBuilder.calendar
            let components = calendar.dateComponents([.month, .day], from: date)
            let month = components.month ?? 0
            let day = components.day ?? 0
            parts.append("\(month)月\(day)日")
        }

        if appModel.settingsStore.showTime {
            let calendar = CalendarGridBuilder.calendar
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            parts.append(String(format: "%02d:%02d:%02d", hour, minute, second))
        }

        if appModel.settingsStore.showWeekday {
            let weekday = CalendarGridBuilder.calendar.component(.weekday, from: date) - 1
            let text = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday]
            parts.append(text)
        }

        return parts.joined(separator: " ")
    }

    private func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)

        if settingsWindowController == nil {
            let hostingController = NSHostingController(
                rootView: CalendarSettingsView(settingsStore: appModel.settingsStore)
            )
            let window = NSWindow(contentViewController: hostingController)
            window.title = "LunaCalendar Settings"
            window.setContentSize(NSSize(width: 320, height: 220))
            window.styleMask = [.titled, .closable, .miniaturizable]
            window.isReleasedWhenClosed = false
            window.center()
            settingsWindowController = NSWindowController(window: window)
        }

        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    @objc private func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
