import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    private static let weekdayTitles = CalendarGridBuilder.weekdayTitles()
    private static let mediumColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private static let largeColumns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
    private static let weekendForeground = Color(nsColor: .systemRed)
    private static let adjacentMonthForeground = Color.secondary.opacity(0.6)

    @Environment(\.widgetFamily) private var family
    @Environment(\.widgetRenderingMode) private var renderingMode
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
                                .foregroundStyle(badgeTextColor(for: holidayType))
                                .padding(.horizontal, 1.5)
                                .padding(.vertical, 0.5)
                                .background(badgeBackgroundColor(for: holidayType))
                                .clipShape(RoundedRectangle(cornerRadius: 1.5, style: .continuous))
                                .padding(1.5)
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
                    .overlay {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(selectionStrokeColor(for: day), lineWidth: selectionStrokeWidth(for: day))
                    }
                }
            }
        }
        .padding()
        .containerBackground(.background, for: .widget)
        .widgetURL(AppRoute.url(for: entry.summaryDay.date))
    }

    private var largeWidget: some View {
        VStack(spacing: 8) {
            LazyVGrid(columns: Self.largeColumns, spacing: 4) {
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
                                .foregroundStyle(badgeTextColor(for: holidayType))
                                .padding(.horizontal, 2)
                                .padding(.vertical, 1)
                                .background(badgeBackgroundColor(for: holidayType))
                                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                                .padding(3)
                        }

                        VStack(spacing: 0) {
                            Spacer(minLength: 4)

                            Text(day.solarText)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(primaryTextColor(for: day))

                            Text(day.secondaryText)
                                .font(.system(size: 9, weight: .regular))
                                .foregroundStyle(secondaryTextColor(for: day))
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)

                            Spacer(minLength: 3)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: 44)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(selectionStrokeColor(for: day), lineWidth: selectionStrokeWidth(for: day))
                    }
                }
            }
        }
        .padding(12)
        .containerBackground(.background, for: .widget)
        .widgetURL(AppRoute.url(for: entry.summaryDay.date))
    }

    @ViewBuilder
    private func badge(for type: HolidayType?) -> some View {
        if let type {
            Text(type.badgeText)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(badgeTextColor(for: type))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(badgeBackgroundColor(for: type))
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        }
    }

    private func badgeBackgroundColor(for type: HolidayType) -> Color {
        if renderingMode == .fullColor {
            return type == .holiday ? Color.red : Color(white: 0.6)
        }
        return type == .holiday ? Color.red : Color.primary.opacity(0.55)
    }

    private func badgeTextColor(for type: HolidayType) -> Color {
        if renderingMode == .fullColor {
            return .white
        }
        return type == .holiday ? .white : Color(nsColor: .windowBackgroundColor)
    }

    private func backgroundColor(for day: CalendarDayItem) -> Color {
        if day.isSelected {
            if usesFilledSelectionStyle {
                return Color(red: 247/255, green: 181/255, blue: 0/255)
            }
            return .clear
        }
        if day.holidayType == .holiday {
            return Color.red.opacity(0.04)
        }
        if day.holidayType == .workday {
            return Color.gray.opacity(0.05)
        }
        return .clear
    }

    private func selectionStrokeColor(for day: CalendarDayItem) -> Color {
        guard day.isSelected, !usesFilledSelectionStyle else { return .clear }
        return .primary.opacity(0.45)
    }

    private func selectionStrokeWidth(for day: CalendarDayItem) -> CGFloat {
        day.isSelected && !usesFilledSelectionStyle ? 1.25 : 0
    }

    private func primaryTextColor(for day: CalendarDayItem) -> Color {
        if day.isSelected {
            return usesFilledSelectionStyle ? .white : .primary
        }
        if !day.isCurrentMonth { return Self.adjacentMonthForeground }
        if day.isWeekend { return Self.weekendForeground }
        return .primary
    }

    private func secondaryTextColor(for day: CalendarDayItem) -> Color {
        if day.isSelected {
            return usesFilledSelectionStyle ? .white.opacity(0.9) : .secondary
        }
        if !day.isCurrentMonth { return Self.adjacentMonthForeground }
        if day.festivalText != nil { return Self.weekendForeground }
        return .secondary
    }

    private var usesFilledSelectionStyle: Bool {
        renderingMode == .fullColor
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
