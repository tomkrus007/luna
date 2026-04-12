import Foundation

enum CalendarGridBuilder {
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "zh_CN")
        calendar.firstWeekday = 1
        return calendar
    }

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
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        let gridStart = calendar.date(byAdding: .day, value: -firstWeekday, to: monthStart) ?? monthStart
        let displayMonth = calendar.component(.month, from: monthStart)
        let displayYear = calendar.component(.year, from: monthStart)

        return (0..<42).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: gridStart) else {
                return nil
            }

            let components = calendar.dateComponents([.year, .month, .day, .weekday], from: date)
            let year = components.year ?? displayYear
            let month = components.month ?? displayMonth
            let day = components.day ?? 1
            let weekday = components.weekday ?? 1
            let festivalText = CalendarConverter.getFestival(for: components) ?? CalendarConverter.getSolarTermName(for: components)
            let holiday = holidays[isoFormatter.string(from: date)]

            return CalendarDayItem(
                date: date,
                isCurrentMonth: year == displayYear && month == displayMonth,
                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                isWeekend: weekday == 1 || weekday == 7,
                solarText: String(day),
                lunarText: CalendarConverter.getPrimaryDisplayText(for: date),
                festivalText: festivalText,
                holidayType: holiday?.type
            )
        }
    }

    static func weekdayTitles() -> [String] {
        ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
}
