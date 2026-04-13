import AppKit
import Combine
import SwiftUI

@MainActor
final class StatusBarController: NSObject, NSPopoverDelegate {
    private struct StatusItemContent: Equatable {
        let length: CGFloat
        let title: String
        let toolTip: String?
        let imagePosition: NSControl.ImagePosition
        let showsImage: Bool
    }

    private struct StatusTextCacheKey: Equatable {
        let dayStart: Date
        let showLunar: Bool
        let showWeekday: Bool
    }

    private let appModel: AppModel
    private let statusItem: NSStatusItem
    private let popover = NSPopover()
    private var hostingController: NSHostingController<CalendarWindowView>?
    private var settingsWindowController: NSWindowController?
    private var cancellables = Set<AnyCancellable>()
    private var tickerTask: Task<Void, Never>?
    private var pendingStatusItemContent: StatusItemContent?
    private var appliedStatusItemContent: StatusItemContent?
    private var isStatusItemUpdateScheduled = false
    private var isPopoverTransitioning = false
    private var cachedStatusTextKey: StatusTextCacheKey?
    private var cachedStatusTextPrefix = ""

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
        popover.delegate = self
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
                let interval = self.tickerInterval()
                try? await Task.sleep(for: .seconds(interval))
            }
        }
    }

    private func tickerInterval() -> TimeInterval {
        if appModel.settingsStore.showIcon || !appModel.settingsStore.showTime {
            return 60.0
        }

        return appModel.settingsStore.showSeconds ? 1.0 : 60.0
    }

    private func updateStatusItem() {
        let content: StatusItemContent

        if appModel.settingsStore.showIcon {
            content = StatusItemContent(
                length: 12,
                title: "",
                toolTip: "LunaCalendar",
                imagePosition: .imageOnly,
                showsImage: true
            )
        } else {
            content = StatusItemContent(
                length: NSStatusItem.variableLength,
                title: statusText(for: Date()),
                toolTip: nil,
                imagePosition: .noImage,
                showsImage: false
            )
        }

        guard content != appliedStatusItemContent, content != pendingStatusItemContent else { return }
        pendingStatusItemContent = content

        scheduleStatusItemUpdateIfNeeded()
    }

    private func scheduleStatusItemUpdateIfNeeded() {
        guard !isStatusItemUpdateScheduled else { return }
        isStatusItemUpdateScheduled = true

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.applyPendingStatusItemUpdate()
        }
    }

    private func applyPendingStatusItemUpdate() {
        isStatusItemUpdateScheduled = false

        guard !isPopoverTransitioning, !popover.isShown else {
            if pendingStatusItemContent != nil {
                scheduleStatusItemUpdateIfNeeded()
            }
            return
        }

        guard let button = statusItem.button, let content = pendingStatusItemContent else { return }
        pendingStatusItemContent = nil

        statusItem.length = content.length
        button.attributedTitle = content.showsImage ? NSAttributedString(string: "") : attributedStatusTitle(for: content.title)
        button.image = content.showsImage ? statusImage() : nil
        button.imagePosition = content.imagePosition
        button.toolTip = content.toolTip

        appliedStatusItemContent = content

        if let nextContent = pendingStatusItemContent, nextContent != appliedStatusItemContent {
            updateStatusItem()
        }
    }

    private func statusImage() -> NSImage? {
        let image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
        image?.isTemplate = true
        image?.size = NSSize(width: 18, height: 18)
        return image
    }

    private func attributedStatusTitle(for title: String) -> NSAttributedString {
        NSAttributedString(
            string: title,
            attributes: [
                .font: NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .medium)
            ]
        )
    }

    private func statusText(for date: Date) -> String {
        var parts: [String] = [cachedStatusTextPrefix(for: date)]

        if appModel.settingsStore.showTime {
            let calendar = CalendarGridBuilder.calendar
            let units: Set<Calendar.Component> = appModel.settingsStore.showSeconds
                ? [.hour, .minute, .second]
                : [.hour, .minute]
            let components = calendar.dateComponents(units, from: date)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            if appModel.settingsStore.showSeconds {
                let second = components.second ?? 0
                parts.append(String(format: "%02d:%02d:%02d", hour, minute, second))
            } else {
                parts.append(String(format: "%02d:%02d", hour, minute))
            }
        }

        return parts.filter { !$0.isEmpty }.joined(separator: " ")
    }

    private func cachedStatusTextPrefix(for date: Date) -> String {
        let calendar = CalendarGridBuilder.calendar
        let dayStart = calendar.startOfDay(for: date)
        let key = StatusTextCacheKey(
            dayStart: dayStart,
            showLunar: appModel.settingsStore.showLunar,
            showWeekday: appModel.settingsStore.showWeekday
        )

        if cachedStatusTextKey == key {
            return cachedStatusTextPrefix
        }

        var parts: [String] = []

        if appModel.settingsStore.showLunar {
            parts.append(CalendarConverter.getStatusBarLunarText(for: date))
        } else {
            let components = calendar.dateComponents([.month, .day], from: date)
            let month = components.month ?? 0
            let day = components.day ?? 0
            parts.append("\(month)月\(day)日")
        }

        if appModel.settingsStore.showWeekday {
            let weekday = CalendarGridBuilder.calendar.component(.weekday, from: date) - 1
            let text = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday]
            parts.append(text)
        }

        let prefix = parts.joined(separator: " ")
        cachedStatusTextKey = key
        cachedStatusTextPrefix = prefix
        return prefix
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
            isPopoverTransitioning = true
            popover.performClose(sender)
        } else {
            isPopoverTransitioning = true
            appModel.calendarViewModel.activate()
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func popoverDidShow(_ notification: Notification) {
        isPopoverTransitioning = false
    }

    func popoverDidClose(_ notification: Notification) {
        isPopoverTransitioning = false
        appModel.calendarViewModel.deactivate()
        applyPendingStatusItemUpdate()
    }
}
