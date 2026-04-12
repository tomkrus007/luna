import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        TimelineView(.periodic(from: .now, by: settingsStore.showTime ? 1 : 60)) { context in
            if settingsStore.showIcon {
                menuBarIcon
            } else {
                Text(labelText(for: context.date))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private var menuBarIcon: some View {
        if NSImage(named: "MenuBarSymbol") != nil {
            Image("MenuBarSymbol")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
        } else {
            Image(systemName: "calendar")
                .font(.system(size: 14, weight: .semibold))
        }
    }

    private func labelText(for date: Date) -> String {
        var parts: [String] = []

        if settingsStore.showLunar {
            parts.append(CalendarConverter.getStatusBarLunarText(for: date))
        } else {
            let formatter = DateFormatter()
            formatter.calendar = CalendarGridBuilder.calendar
            formatter.locale = Locale(identifier: "zh_CN")
            formatter.dateFormat = "M月d日"
            parts.append(formatter.string(from: date))
        }

        if settingsStore.showTime {
            let formatter = DateFormatter()
            formatter.calendar = CalendarGridBuilder.calendar
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm:ss"
            parts.append(formatter.string(from: date))
        }

        if settingsStore.showWeekday {
            let weekday = CalendarGridBuilder.calendar.component(.weekday, from: date) - 1
            let text = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday]
            parts.append(text)
        }

        return parts.joined(separator: " ")
    }
}
