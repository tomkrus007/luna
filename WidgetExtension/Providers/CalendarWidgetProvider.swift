import WidgetKit
import SwiftUI

struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let monthTitle: String
    let summaryDay: CalendarDayItem
    let monthGrid: [CalendarDayItem]
}

struct CalendarWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CalendarWidgetEntry {
        makeEntry(for: .now)
    }

    func getSnapshot(in context: Context, completion: @escaping (CalendarWidgetEntry) -> Void) {
        completion(makeEntry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarWidgetEntry>) -> Void) {
        let now = Date()
        let entry = makeEntry(for: now)
        let nextMidnight = CalendarGridBuilder.calendar.nextDate(after: now, matching: DateComponents(hour: 0, minute: 1), matchingPolicy: .nextTimePreservingSmallerComponents) ?? now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    private func makeEntry(for date: Date) -> CalendarWidgetEntry {
        let year = CalendarGridBuilder.calendar.component(.year, from: date)
        let holidays = HolidayCacheStore.load(year: year)
        let grid = CalendarGridBuilder.makeMonthGrid(displayDate: date, selectedDate: date, holidays: holidays)
        let formatter = DateFormatter()
        formatter.calendar = CalendarGridBuilder.calendar
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM"

        let todayItem = grid.first(where: { CalendarGridBuilder.calendar.isDate($0.date, inSameDayAs: date) }) ?? grid[0]

        return CalendarWidgetEntry(date: date, monthTitle: formatter.string(from: date), summaryDay: todayItem, monthGrid: grid)
    }
}
