import Foundation

enum CalendarGridBuilder {
    private struct MonthGridCacheKey: Hashable {
        let displayMonthStart: Date
        let selectedDateID: String
        let holidaySignature: Int
    }

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 1
        return calendar
    }()

    private static let monthGridCache = MonthGridCacheStore()

    private static func makeISOFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func makeMonthGrid(displayDate: Date, selectedDate: Date, holidays: [String: HolidayItem]) -> [CalendarDayItem] {
        let calendar = calendar
        let isoFormatter = makeISOFormatter()
        let monthStart = displayDate.startOfMonth(using: calendar)
        let cacheKey = MonthGridCacheKey(
            displayMonthStart: monthStart,
            selectedDateID: dayIdentifier(for: selectedDate, using: calendar),
            holidaySignature: holidays.signatureValue
        )

        if let cached = monthGridCache.value(for: cacheKey) {
            return cached
        }

        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        let gridStart = calendar.date(byAdding: .day, value: -firstWeekday, to: monthStart) ?? monthStart
        let displayMonth = calendar.component(.month, from: monthStart)
        let displayYear = calendar.component(.year, from: monthStart)

        var items: [CalendarDayItem] = []
        items.reserveCapacity(42)

        for offset in 0..<42 {
            guard !Task.isCancelled else { return [] }
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else {
                continue
            }

            let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
            let year = components.year ?? displayYear
            let month = components.month ?? displayMonth
            let day = components.day ?? 1
            let weekday = components.weekday ?? 1
            let festivalText = CalendarConverter.getFestival(for: components) ?? CalendarConverter.getSolarTermName(for: components)
            let holiday = holidays[isoFormatter.string(from: date)]

            items.append(CalendarDayItem(
                date: date,
                isCurrentMonth: year == displayYear && month == displayMonth,
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                isWeekend: weekday == 1 || weekday == 7,
                solarText: String(day),
                lunarText: festivalText ?? CalendarConverter.getLunarCellText(for: date),
                festivalText: festivalText,
                holidayType: holiday?.type
            ))
        }

        monthGridCache.setValue(items, for: cacheKey)
        return items
    }

    static func weekdayTitles() -> [String] {
        ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    }

    private static func dayIdentifier(for date: Date, using calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }
}

private final class MonthGridCacheStore: @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [AnyHashable: [CalendarDayItem]] = [:]

    func value<Key: Hashable>(for key: Key) -> [CalendarDayItem]? {
        lock.lock()
        defer { lock.unlock() }
        return storage[AnyHashable(key)]
    }

    func setValue<Key: Hashable>(_ value: [CalendarDayItem], for key: Key) {
        lock.lock()
        storage[AnyHashable(key)] = value
        lock.unlock()
    }
}

private extension Dictionary where Key == String, Value == HolidayItem {
    var signatureValue: Int {
        let ordered = values.sorted { lhs, rhs in
            if lhs.dateString == rhs.dateString {
                return lhs.name < rhs.name
            }
            return lhs.dateString < rhs.dateString
        }

        var hasher = Hasher()
        for item in ordered {
            hasher.combine(item.dateString)
            hasher.combine(item.name)
            hasher.combine(item.type.rawValue)
        }
        return hasher.finalize()
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}
