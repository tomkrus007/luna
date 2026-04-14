import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    private static let weekdayTitles = CalendarGridBuilder.weekdayTitles()
    private static let mediumColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private static let largeColumns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private static let weekendForeground = Color(nsColor: .systemRed)
    private static let adjacentMonthForeground = Color.secondary.opacity(0.6)

    @Environment(\.widgetFamily) private var family
    let entry: CalendarWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemLarge:
            largeWidget
        default:
            mediumWidget
        }
    }

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.monthTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                badge(for: entry.summaryDay.holidayType)
            }

            Text(entry.summaryDay.solarText)
                .font(.system(size: 36, weight: .bold, design: .rounded))

            Text(entry.summaryDay.secondaryText)
                .font(.subheadline)
                .lineLimit(1)

            Text(Self.weekdayTitles[CalendarGridBuilder.calendar.component(.weekday, from: entry.summaryDay.date) - 1])
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
        .containerBackground(.background, for: .widget)
        .widgetURL(AppRoute.url(for: entry.summaryDay.date))
    }

    private var mediumWidget: some View {
        VStack(spacing: 6) {
            HStack {
                Text(entry.monthTitle)
                    .font(.headline)
                Spacer()
                Text(entry.summaryDay.secondaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                badge(for: entry.summaryDay.holidayType)
            }

            LazyVGrid(columns: Self.mediumColumns, spacing: 2) {
                ForEach(Self.weekdayTitles.indices, id: \.self) { index in
                    Text(Self.weekdayTitles[index])
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(index == 0 || index == 6 ? Self.weekendForeground : Color.secondary)
                }

                ForEach(entry.monthGrid) { day in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(backgroundColor(for: day))

                        if let holidayType = day.holidayType {
                            Text(holidayType.badgeText)
                                .font(.system(size: 7, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 2)
                                .padding(.vertical, 1)
                                .background(holidayType == .holiday ? Color.red : Color(white: 0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                                .padding(2)
                        }

                        VStack(spacing: 0) {
                            Spacer(minLength: 3)

                            Text(day.solarText)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(primaryTextColor(for: day))

                            Text(day.secondaryText)
                                .font(.system(size: 7, weight: .regular))
                                .foregroundStyle(secondaryTextColor(for: day))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)

                            Spacer(minLength: 2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 24)
                }
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
        .widgetURL(AppRoute.url(for: entry.summaryDay.date))
    }

    private var largeWidget: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.monthTitle)
                        .font(.headline)

                    HStack(spacing: 6) {
                        Text(largeWeekdayText)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        badge(for: entry.summaryDay.holidayType)
                    }
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.summaryDay.solarText)
                        .font(.system(size: 42, weight: .bold, design: .rounded))

                    Text(largeHeaderLunarText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            LazyVGrid(columns: Self.largeColumns, spacing: 6) {
                ForEach(Self.weekdayTitles.indices, id: \.self) { index in
                    Text(Self.weekdayTitles[index])
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(index == 0 || index == 6 ? Self.weekendForeground : Color.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(entry.monthGrid) { day in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(backgroundColor(for: day))

                        if let holidayType = day.holidayType {
                            Text(holidayType.badgeText)
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 3)
                                .padding(.vertical, 2)
                                .background(holidayType == .holiday ? Color.red : Color(white: 0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                                .padding(4)
                        }

                        VStack(spacing: 0) {
                            Spacer(minLength: 6)

                            Text(day.solarText)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(primaryTextColor(for: day))

                            Text(day.secondaryText)
                                .font(.system(size: 10, weight: .regular))
                                .foregroundStyle(secondaryTextColor(for: day))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Spacer(minLength: 4)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 52)
                }
            }
        }
        .padding(14)
        .containerBackground(.background, for: .widget)
        .widgetURL(AppRoute.url(for: entry.summaryDay.date))
    }

    @ViewBuilder
    private func badge(for type: HolidayType?) -> some View {
        if let type {
            Text(type.badgeText)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(type == .holiday ? Color.red : Color(white: 0.6))
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        }
    }

    private func backgroundColor(for day: CalendarDayItem) -> Color {
        if day.isSelected {
            return Color(red: 247/255, green: 181/255, blue: 0/255)
        }
        if day.holidayType == .holiday {
            return Color.red.opacity(0.04)
        }
        if day.holidayType == .workday {
            return Color.gray.opacity(0.05)
        }
        return .clear
    }

    private func primaryTextColor(for day: CalendarDayItem) -> Color {
        if day.isSelected { return .white }
        if !day.isCurrentMonth { return Self.adjacentMonthForeground }
        if day.isWeekend { return Self.weekendForeground }
        return .primary
    }

    private func secondaryTextColor(for day: CalendarDayItem) -> Color {
        if day.isSelected { return .white.opacity(0.9) }
        if !day.isCurrentMonth { return Self.adjacentMonthForeground }
        if day.festivalText != nil { return Self.weekendForeground }
        return .secondary
    }

    private var largeWeekdayText: String {
        Self.weekdayTitles[CalendarGridBuilder.calendar.component(.weekday, from: entry.summaryDay.date) - 1]
    }

    private var largeHeaderLunarText: String {
        let components = CalendarGridBuilder.calendar.dateComponents([.year, .month, .day], from: entry.summaryDay.date)
        let lunarText = CalendarConverter.getLunarDate(for: components)
        return lunarText.isEmpty ? CalendarConverter.getStatusBarLunarText(for: entry.summaryDay.date) : lunarText
    }

}
