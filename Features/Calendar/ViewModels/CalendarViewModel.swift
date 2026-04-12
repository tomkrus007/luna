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

    init(today: Date = .now) {
        self.displayDate = today.startOfMonth(using: CalendarGridBuilder.calendar)
        self.selectedDate = today
        holidayRefreshTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: .holidayDataDidRefresh) {
                guard let self else { return }
                await self.reload()
            }
        }
    }

    deinit {
        holidayRefreshTask?.cancel()
        rebuildTask?.cancel()
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
            displayDate = date.startOfMonth(using: CalendarGridBuilder.calendar)
            var selComponents = CalendarGridBuilder.calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: selectedDate)
            selComponents.year = year
            if let newSel = CalendarGridBuilder.calendar.date(from: selComponents) {
                selectedDate = newSel
                syncSelectedDateURL()
            }
            Task { await reload() }
        }
    }

    func goToPreviousMonth() {
        guard let date = CalendarGridBuilder.calendar.date(byAdding: .month, value: -1, to: displayDate) else { return }
        displayDate = date.startOfMonth(using: CalendarGridBuilder.calendar)
        if let newSelected = CalendarGridBuilder.calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newSelected
            syncSelectedDateURL()
        }
        Task { await reload() }
    }

    func goToNextMonth() {
        guard let date = CalendarGridBuilder.calendar.date(byAdding: .month, value: 1, to: displayDate) else { return }
        displayDate = date.startOfMonth(using: CalendarGridBuilder.calendar)
        if let newSelected = CalendarGridBuilder.calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newSelected
            syncSelectedDateURL()
        }
        Task { await reload() }
    }

    func goToToday() {
        guard !isDisplayingToday else { return }
        let today = Date()
        selectedDate = today
        displayDate = today.startOfMonth(using: CalendarGridBuilder.calendar)
        syncSelectedDateURL()
        Task { await reload() }
    }

    func select(_ date: Date) {
        selectedDate = date
        if let url = AppRoute.url(for: date) {
            AppGroupSupport.setSelectedDateURLString(url.absoluteString)
        }
        let selectedMonth = date.startOfMonth(using: CalendarGridBuilder.calendar)
        if selectedMonth != displayDate {
            displayDate = selectedMonth
            Task { await reload() }
        } else {
            rebuildDays()
        }
    }

    func handleIncomingURL(_ url: URL) {
        guard let date = AppRoute.parseDate(from: url) else { return }
        selectedDate = date
        displayDate = date.startOfMonth(using: CalendarGridBuilder.calendar)
        Task { await reload() }
    }

    private func syncSelectedDateURL() {
        if let url = AppRoute.url(for: selectedDate) {
            AppGroupSupport.setSelectedDateURLString(url.absoluteString)
        }
    }

    func reload() async {
        let year = CalendarGridBuilder.calendar.component(.year, from: displayDate)
        holidayMap = await HolidayService.shared.holidays(for: year)
        rebuildDays()
    }

    func loadInitialDataIfNeeded() async {
        guard days.isEmpty else { return }
        await reload()

        let dateToPreload = displayDate
        Task {
            await HolidayService.shared.preloadAround(date: dateToPreload)
        }
    }

    func preloadHolidayData() async {
        await HolidayService.shared.preloadAround(date: displayDate)
        await reload()
    }

    private func rebuildDays() {
        let displayDate = displayDate
        let selectedDate = selectedDate
        let holidayMap = holidayMap

        rebuildTask?.cancel()
        rebuildTask = Task.detached(priority: .userInitiated) { [weak self, displayDate, selectedDate, holidayMap] in
            let days = CalendarGridBuilder.makeMonthGrid(displayDate: displayDate, selectedDate: selectedDate, holidays: holidayMap)

            await MainActor.run {
                guard let self = self else { return }
                guard self.displayDate == displayDate, self.selectedDate == selectedDate, self.holidayMap == holidayMap else { return }
                self.days = days
            }
        }
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}
