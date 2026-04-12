import SwiftUI

struct CalendarSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        Form {
            Section("状态栏显示") {
                Toggle("仅显示图标", isOn: $settingsStore.showIcon)
                Toggle("显示农历", isOn: $settingsStore.showLunar)
                    .disabled(settingsStore.showIcon)
                Toggle("显示时间", isOn: $settingsStore.showTime)
                    .disabled(settingsStore.showIcon)
                Toggle("显示星期", isOn: $settingsStore.showWeekday)
                    .disabled(settingsStore.showIcon)
            }

            Section("系统") {
                Toggle("开机自动运行", isOn: $settingsStore.launchAtLogin)
            }
        }
        .padding(20)
        .frame(width: 320)
    }
}
