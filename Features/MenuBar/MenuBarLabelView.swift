import SwiftUI

struct MenuBarLabelView: View {
    private struct LabelTextCacheKey: Equatable {
        let dayStart: Date
        let showLunar: Bool
        let showWeekday: Bool
    }

    @ObservedObject var settingsStore: SettingsStore
    @State private var currentDate = Date()
    @State private var cachedLabelTextKey: LabelTextCacheKey?
    @State private var cachedLabelTextPrefix = ""

    var body: some View {
        Group {
            if settingsStore.showIcon {
                menuBarIcon
            } else {
                Text(labelText(for: currentDate))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .onAppear {
            currentDate = Date()
        }
        .task(id: settingsStore.showTime) {
            while !Task.isCancelled {
                currentDate = Date()
                let interval = settingsStore.showTime ? 1.0 : 60.0
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    @ViewBuilder
    private var menuBarIcon: some View {
        Color.clear
            .frame(width: 1.5, height: 10)
            .overlay {
                if NSImage(named: "MenuBarSymbol") != nil {
                    Image("MenuBarSymbol")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 4, height: 10)
                } else {
                    Image(systemName: "calendar")
                        .font(.system(size: 9, weight: .semibold))
                }
            }
    }

    private func labelText(for date: Date) -> String {
        var parts: [String] = [cachedLabelTextPrefix(for: date)]

        if settingsStore.showTime {
            let calendar = CalendarGridBuilder.calendar
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            parts.append(String(format: "%02d:%02d:%02d", hour, minute, second))
        }

        return parts.filter { !$0.isEmpty }.joined(separator: " ")
    }

    private func cachedLabelTextPrefix(for date: Date) -> String {
        let calendar = CalendarGridBuilder.calendar
        let dayStart = calendar.startOfDay(for: date)
        let key = LabelTextCacheKey(
            dayStart: dayStart,
            showLunar: settingsStore.showLunar,
            showWeekday: settingsStore.showWeekday
        )

        if cachedLabelTextKey == key {
            return cachedLabelTextPrefix
        }

        var parts: [String] = []

        if settingsStore.showLunar {
            parts.append(CalendarConverter.getStatusBarLunarText(for: date))
        } else {
            let components = calendar.dateComponents([.month, .day], from: date)
            let month = components.month ?? 0
            let day = components.day ?? 0
            parts.append("\(month)月\(day)日")
        }

        if settingsStore.showWeekday {
            let weekday = CalendarGridBuilder.calendar.component(.weekday, from: date) - 1
            let text = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday]
            parts.append(text)
        }

        let prefix = parts.joined(separator: " ")
        cachedLabelTextKey = key
        cachedLabelTextPrefix = prefix
        return prefix
    }
}
