import AppKit
import SwiftUI

private let calendarWeekdayHeaderBackground = Color(nsColor: .controlBackgroundColor)
private let calendarWeekendForeground = Color(nsColor: .systemRed)
private let calendarAdjacentMonthForeground = Color.secondary.opacity(0.6)

struct CalendarWindowView: View {
    private static let weekdayTitles = CalendarGridBuilder.weekdayTitles()
    private static let headerColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private static let dayColumns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    @Environment(\.openSettings) private var openSettings
    @ObservedObject var viewModel: CalendarViewModel
    @ObservedObject var settingsStore: SettingsStore
    let openSettingsAction: (() -> Void)?
    @State private var didPreloadHolidayData = false

    init(
        viewModel: CalendarViewModel,
        settingsStore: SettingsStore,
        openSettingsAction: (() -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.settingsStore = settingsStore
        self.openSettingsAction = openSettingsAction
    }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            weekdayHeader
            calendarGrid
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: .windowBackgroundColor))
        )
        .frame(width: 360)
        .task {
            guard !didPreloadHolidayData else { return }
            didPreloadHolidayData = true
            await viewModel.loadInitialDataIfNeeded()
        }
    }

    private var toolbar: some View {
        HStack(spacing: 12) {
            Picker("年份", selection: Binding<Int>(get: { viewModel.displayYear }, set: { viewModel.selectYear($0) })) {
                ForEach(viewModel.years, id: \.self) { year in
                    Text(verbatim: String(year)).tag(year)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .colorScheme(.light)
            .frame(width: 76)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            Text(viewModel.displayMonthText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: viewModel.goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.9))

            Button(action: viewModel.goToNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.9))

            Button("今天", action: viewModel.goToToday)
                .buttonStyle(.plain)
                .font(.system(size: 12, weight: .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(viewModel.isDisplayingToday ? Color.white.opacity(0.35) : Color.white.opacity(0.92))
                .foregroundStyle(viewModel.isDisplayingToday ? Color.white.opacity(0.9) : .black)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(Color.white.opacity(viewModel.isDisplayingToday ? 0.15 : 0), lineWidth: 1)
                }
                .disabled(viewModel.isDisplayingToday)

            Button(action: openSettingsWindow) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15))
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(red: 54/255, green: 111/255, blue: 176/255))
        .foregroundStyle(.white)
    }

    private var weekdayHeader: some View {
        LazyVGrid(columns: Self.headerColumns, spacing: 0) {
            ForEach(Self.weekdayTitles.indices, id: \.self) { index in
                Text(Self.weekdayTitles[index])
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(index == 0 || index == 6 ? calendarWeekendForeground : Color.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 10)
        .background(calendarWeekdayHeaderBackground)
        .overlay(alignment: .bottom) {
            Divider().opacity(0.5)
        }
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Self.dayColumns, spacing: 4) {
            ForEach(viewModel.days) { day in
                CalendarDayCellView(day: day) {
                    viewModel.select(day.date)
                }
            }
        }
        .padding(10)
    }

    private func openSettingsWindow() {
        NSApp.activate(ignoringOtherApps: true)
        if let openSettingsAction {
            openSettingsAction()
        } else {
            openSettings()
        }
    }
}

private struct CalendarDayCellView: View {
    let day: CalendarDayItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(backgroundColor)

                if let holidayType = day.holidayType {
                    Text(holidayType.badgeText)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 2.5)
                        .padding(.vertical, 1)
                        .background(holidayType == .holiday ? Color.red : Color(white: 0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 1.5, style: .continuous))
                        .padding(2)
                }

                VStack(spacing: 0) {
                    Spacer(minLength: 4)

                    Text(day.solarText)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(primaryTextColor)

                    Text(day.secondaryText)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(secondaryTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer(minLength: 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 44)
            .contentShape(Rectangle())
            .overlay {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(day.isSelected ? Color.orange.opacity(0.25) : Color.clear, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        if day.isSelected {
            return Color(red: 247/255, green: 181/255, blue: 0/255) // #F7B500
        }
        if day.holidayType == .holiday {
            return Color.red.opacity(0.04)
        }
        if day.holidayType == .workday {
            return Color.gray.opacity(0.05)
        }
        return .clear
    }

    private var primaryTextColor: Color {
        if day.isSelected { return .white }
        if !day.isCurrentMonth { return calendarAdjacentMonthForeground }
        if day.isWeekend { return calendarWeekendForeground }
        return .primary
    }

    private var secondaryTextColor: Color {
        if day.isSelected { return .white.opacity(0.9) }
        if !day.isCurrentMonth { return calendarAdjacentMonthForeground }
        if day.festivalText != nil { return calendarWeekendForeground }
        return .secondary
    }
}
