import WidgetKit
import SwiftUI

struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let monthTitle: String
    let summaryDay: CalendarDayItem
    let monthGrid: [CalendarDayItem]
}

private struct SendableCompletion<T>: @unchecked Sendable {
    let call: (T) -> Void
}

struct CalendarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarWidgetEntry {
        Self.buildEntry(for: .now, holidays: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarWidgetEntry) -> Void) {
        let now = Date()
        let year = CalendarGridBuilder.calendar.component(.year, from: now)
        let cached = HolidayCacheStore.load(year: year)
        if !cached.isEmpty {
            completion(Self.buildEntry(for: now, holidays: cached))
            return
        }
        let box = SendableCompletion(call: completion)
        Task {
            let holidays = await Self.fetchHolidays(year: year)
            box.call(Self.buildEntry(for: now, holidays: holidays))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarWidgetEntry>) -> Void) {
        let now = Date()
        let nextMidnight = CalendarGridBuilder.calendar.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 1),
            matchingPolicy: .nextTimePreservingSmallerComponents
        ) ?? now.addingTimeInterval(3600)

        let box = SendableCompletion(call: completion)
        Task {
            let entry = await Self.makeEntry(for: now)
            box.call(Timeline(entries: [entry], policy: .after(nextMidnight)))
        }
    }

    private static func makeEntry(for date: Date) async -> CalendarWidgetEntry {
        let year = CalendarGridBuilder.calendar.component(.year, from: date)
        var holidays = HolidayCacheStore.load(year: year)
        if holidays.isEmpty {
            holidays = await fetchHolidays(year: year)
        }
        return buildEntry(for: date, holidays: holidays)
    }

    private static func fetchHolidays(year: Int) async -> [String: HolidayItem] {
        guard let url = URL(string: "https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/\(year).json"),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let response = try? JSONDecoder().decode(HolidaySourceResponse.self, from: data)
        else {
            return [:]
        }
        let items = response.days.map {
            HolidayItem(dateString: $0.date, name: $0.name, type: $0.isOffDay ? .holiday : .workday)
        }
        HolidayCacheStore.save(year: year, items: items)
        return Dictionary(uniqueKeysWithValues: items.map { ($0.dateString, $0) })
    }

    private static func buildEntry(for date: Date, holidays: [String: HolidayItem]) -> CalendarWidgetEntry {
        let grid = CalendarGridBuilder.makeMonthGrid(displayDate: date, selectedDate: date, holidays: holidays)
        let components = CalendarGridBuilder.calendar.dateComponents([.year, .month], from: date)
        let displayYear = components.year ?? 0
        let displayMonth = components.month ?? 0

        let todayItem = grid.first(where: { CalendarGridBuilder.calendar.isDate($0.date, inSameDayAs: date) }) ?? grid[0]

        return CalendarWidgetEntry(
            date: date,
            monthTitle: String(format: "%04d-%02d", displayYear, displayMonth),
            summaryDay: todayItem,
            monthGrid: grid
        )
    }
}
