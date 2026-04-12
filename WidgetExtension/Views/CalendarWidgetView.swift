import SwiftUI
import WidgetKit

struct CalendarWidgetView: View {
    private static let weekdayTitles = CalendarGridBuilder.weekdayTitles()
    private static let mediumColumns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    @Environment(\.widgetFamily) private var family
    let entry: CalendarWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
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
        VStack(spacing: 10) {
            HStack {
                Text(entry.monthTitle)
                    .font(.headline)
                Spacer()
                Text(entry.summaryDay.secondaryText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                badge(for: entry.summaryDay.holidayType)
            }

            LazyVGrid(columns: Self.mediumColumns, spacing: 4) {
                ForEach(Self.weekdayTitles.indices, id: \.self) { index in
                    Text(Self.weekdayTitles[index])
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(index == 0 || index == 6 ? Color.red : Color.secondary)
                }

                ForEach(entry.monthGrid) { day in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(day.isSelected ? Color(red: 247/255, green: 181/255, blue: 0/255) : Color.clear)

                        Text(day.solarText)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(day.isSelected ? Color.white : (!day.isCurrentMonth ? Color(white: 0.75) : (day.isWeekend ? Color.red : Color.primary)))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                    .frame(height: 18)
                }
            }
        }
        .padding()
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
}
