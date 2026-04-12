import SwiftUI

struct MenuBarLabelView: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var currentDate = Date()

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
            let calendar = CalendarGridBuilder.calendar
            let components = calendar.dateComponents([.month, .day], from: date)
            let month = components.month ?? 0
            let day = components.day ?? 0
            parts.append("\(month)月\(day)日")
        }

        if settingsStore.showTime {
            let calendar = CalendarGridBuilder.calendar
            let components = calendar.dateComponents([.hour, .minute, .second], from: date)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            parts.append(String(format: "%02d:%02d:%02d", hour, minute, second))
        }

        if settingsStore.showWeekday {
            let weekday = CalendarGridBuilder.calendar.component(.weekday, from: date) - 1
            let text = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"][weekday]
            parts.append(text)
        }

        return parts.joined(separator: " ")
    }
}
