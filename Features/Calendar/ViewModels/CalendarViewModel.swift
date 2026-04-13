import Foundation
import Combine

@MainActor
final class CalendarViewModel: ObservableObject {
    @Published private(set) var days: [CalendarDayItem] = []
    @Published var displayDate: Date
    @Published var selectedDate: Date

    let years = Array(1900...2100)

    private var holidayMap: [String: HolidayItem] = [:]
    private var holidayRefreshTask: Task<Void, Never>?
    private var rebuildTask: Task<Void, Never>?
    private var preloadTask: Task<Void, Never>?
    private var reloadTask: Task<Void, Never>?
    private var isHandlingHolidayRefresh = false
    private var isActive = false

    init(today: Date = .now) {
        self.displayDate = today.startOfMonth(using: CalendarGridBuilder.calendar)
        self.selectedDate = today
    }

    deinit {
        holidayRefreshTask?.cancel()
        rebuildTask?.cancel()
        preloadTask?.cancel()
        reloadTask?.cancel()
    }

    func activate() {
        guard !isActive else { return }
        isActive = true
        startHolidayRefreshObservation()
    }

    func deactivate() {
        guard isActive else { return }
        isActive = false
        holidayRefreshTask?.cancel()
        holidayRefreshTask = nil
        rebuildTask?.cancel()
        preloadTask?.cancel()
        reloadTask?.cancel()
        Task {
            await HolidayService.shared.cancelRefreshes()
        }
    }

    private func startHolidayRefreshObservation() {
        guard holidayRefreshTask == nil else { return }
        holidayRefreshTask = Task { [weak self] in
            for await notification in NotificationCenter.default.notifications(named: .holidayDataDidRefresh) {
                guard let self else { return }
                guard self.isActive else { continue }
                if let refreshedYear = notification.userInfo?["year"] as? Int,
                   refreshedYear != CalendarGridBuilder.calendar.component(.year, from: self.displayDate) {
                    continue
                }
                await self.handleHolidayRefresh()
            }
            await MainActor.run {
                self?.holidayRefreshTask = nil
            }
        }
    }

    var displayYear: Int {
        CalendarGridBuilder.calendar.component(.year, from: displayDate)
    }

    var displayMonthText: String {
        let components = CalendarGridBuilder.calendar.dateComponents([.month, .day], from: selectedDate)
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%02d-%02d", month, day)
    }

    var isDisplayingToday: Bool {
        let calendar = CalendarGridBuilder.calendar
        return calendar.isDate(selectedDate, inSameDayAs: Date())
            && displayYear == calendar.component(.year, from: Date())
            && calendar.component(.month, from: displayDate) == calendar.component(.month, from: Date())
    }

    func selectYear(_ year: Int) {
        var components = CalendarGridBuilder.calendar.dateComponents([.month], from: displayDate)
        components.year = year
        components.day = 1
        if let date = CalendarGridBuilder.calendar.date(from: components) {
            var selComponents = CalendarGridBuilder.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedDate)
            selComponents.year = year
            if let newSel = CalendarGridBuilder.calendar.date(from: selComponents) {
                applyCalendarChange(displayDate: date, selectedDate: newSel, forceReload: true)
            } else {
                applyCalendarChange(displayDate: date, selectedDate: selectedDate, forceReload: true)
            }
        }
    }

    func goToPreviousMonth() {
        guard let date = CalendarGridBuilder.calendar.date(byAdding: .month, value: -1, to: displayDate) else { return }
        if let newSelected = CalendarGridBuilder.calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            applyCalendarChange(displayDate: date, selectedDate: newSelected)
        } else {
            applyCalendarChange(displayDate: date, selectedDate: selectedDate)
        }
    }

    func goToNextMonth() {
        guard let date = CalendarGridBuilder.calendar.date(byAdding: .month, value: 1, to: displayDate) else { return }
        if let newSelected = CalendarGridBuilder.calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            applyCalendarChange(displayDate: date, selectedDate: newSelected)
        } else {
            applyCalendarChange(displayDate: date, selectedDate: selectedDate)
        }
    }

    func goToToday() {
        guard !isDisplayingToday else { return }
        let today = Date()
        applyCalendarChange(displayDate: today, selectedDate: today)
    }

    func select(_ date: Date) {
        selectedDate = date
        if let url = AppRoute.url(for: date) {
            AppGroupSupport.setSelectedDateURLString(url.absoluteString)
        }
        let selectedMonth = date.startOfMonth(using: CalendarGridBuilder.calendar)
        if selectedMonth != displayDate {
            applyCalendarChange(displayDate: selectedMonth, selectedDate: date)
        } else {
            rebuildDays()
        }
    }

    func handleIncomingURL(_ url: URL) {
        guard let date = AppRoute.parseDate(from: url) else { return }
        applyCalendarChange(displayDate: date, selectedDate: date)
    }

    private func syncSelectedDateURL() {
        if let url = AppRoute.url(for: selectedDate) {
            AppGroupSupport.setSelectedDateURLString(url.absoluteString)
        }
    }

    func reload() async {
        guard isActive else { return }
        let requestedDisplayDate = displayDate
        let year = CalendarGridBuilder.calendar.component(.year, from: requestedDisplayDate)
        let holidays = await HolidayService.shared.holidays(for: year)
        guard isActive, !Task.isCancelled else { return }
        guard displayDate.startOfMonth(using: CalendarGridBuilder.calendar) == requestedDisplayDate.startOfMonth(using: CalendarGridBuilder.calendar) else { return }

        holidayMap = holidays
        rebuildDays()
    }

    func loadInitialDataIfNeeded() async {
        guard isActive else { return }
        guard days.isEmpty else { return }
        await reload()

        let dateToPreload = displayDate
        let loadedYear = CalendarGridBuilder.calendar.component(.year, from: dateToPreload)
        preloadTask?.cancel()
        preloadTask = Task {
            await HolidayService.shared.preloadAround(date: dateToPreload, excluding: [loadedYear])
        }
    }

    func preloadHolidayData() async {
        await HolidayService.shared.preloadAround(date: displayDate)
        await reload()
    }

    private func rebuildDays() {
        guard isActive else { return }
        let displayDate = displayDate
        let selectedDate = selectedDate
        let holidayMap = holidayMap

        rebuildTask?.cancel()
        rebuildTask = Task.detached(priority: .userInitiated) { [weak self, displayDate, selectedDate, holidayMap] in
            let days = CalendarGridBuilder.makeMonthGrid(displayDate: displayDate, selectedDate: selectedDate, holidays: holidayMap)
            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard let self = self else { return }
                guard self.displayDate == displayDate, self.selectedDate == selectedDate, self.holidayMap == holidayMap else { return }
                guard self.days != days else { return }
                self.days = days
            }
        }
    }

    private func handleHolidayRefresh() async {
        guard isActive else { return }
        guard !isHandlingHolidayRefresh else { return }
        isHandlingHolidayRefresh = true
        defer { isHandlingHolidayRefresh = false }

        let year = CalendarGridBuilder.calendar.component(.year, from: displayDate)
        let updatedHolidayMap = await HolidayService.shared.holidays(for: year, triggerRefreshIfNeeded: false)
        guard updatedHolidayMap != holidayMap else { return }

        holidayMap = updatedHolidayMap
        rebuildDays()
    }

    private func applyCalendarChange(displayDate newDisplayDate: Date, selectedDate newSelectedDate: Date, forceReload: Bool = false) {
        let calendar = CalendarGridBuilder.calendar
        let previousYear = calendar.component(.year, from: displayDate)
        let normalizedDisplayDate = newDisplayDate.startOfMonth(using: calendar)
        let newYear = calendar.component(.year, from: normalizedDisplayDate)

        displayDate = normalizedDisplayDate
        selectedDate = newSelectedDate
        syncSelectedDateURL()

        if forceReload || holidayMap.isEmpty || newYear != previousYear {
            scheduleReload()
        } else {
            reloadTask?.cancel()
            rebuildDays()
        }
    }

    private func scheduleReload() {
        reloadTask?.cancel()
        reloadTask = Task { [weak self] in
            await self?.reload()
        }
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}
