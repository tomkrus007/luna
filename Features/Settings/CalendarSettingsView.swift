import SwiftUI

struct CalendarSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        Form {
            Section("状态栏显示") {
                Toggle("仅显示图标", isOn: Binding(
                    get: { settingsStore.showIcon },
                    set: { newValue in
                        settingsStore.showIcon = newValue
                        // 取消仅显示图标时，若所有其他选项都未勾选，默认勾选显示日期
                        if !newValue {
                            let anyOtherOn = settingsStore.showDate
                                || settingsStore.showLunar
                                || settingsStore.showTime
                                || settingsStore.showWeekday
                            if !anyOtherOn {
                                settingsStore.showDate = true
                            }
                        }
                    }
                ))
                Toggle("显示日期", isOn: Binding(
                    get: { settingsStore.showDate },
                    set: { newValue in
                        settingsStore.showDate = newValue
                        if !newValue {
                            fallbackToIconIfAllOff()
                        }
                    }
                ))
                .disabled(settingsStore.showIcon)
                Toggle("简化日期", isOn: $settingsStore.simplifiedDate)
                    .disabled(settingsStore.showIcon || !settingsStore.showDate)
                Toggle("显示农历", isOn: Binding(
                    get: { settingsStore.showLunar },
                    set: { newValue in
                        settingsStore.showLunar = newValue
                        if !newValue {
                            fallbackToIconIfAllOff()
                        }
                    }
                ))
                .disabled(settingsStore.showIcon)
                Toggle("显示时间", isOn: Binding(
                    get: { settingsStore.showTime },
                    set: { newValue in
                        settingsStore.showTime = newValue
                        if !newValue {
                            fallbackToIconIfAllOff()
                        }
                    }
                ))
                .disabled(settingsStore.showIcon)
                Toggle("显示秒", isOn: $settingsStore.showSeconds)
                    .disabled(settingsStore.showIcon || !settingsStore.showTime)
                Toggle("显示星期", isOn: Binding(
                    get: { settingsStore.showWeekday },
                    set: { newValue in
                        settingsStore.showWeekday = newValue
                        if !newValue {
                            fallbackToIconIfAllOff()
                        }
                    }
                ))
                .disabled(settingsStore.showIcon)
            }

            Section("系统") {
                Toggle("开机自动运行", isOn: $settingsStore.launchAtLogin)
            }
        }
        .padding(20)
        .frame(width: 320)
    }

    /// 当任意非「仅显示图标」选项被取消时，若所有主要选项都未勾选，则默认勾选「仅显示图标」
    private func fallbackToIconIfAllOff() {
        let anyOn = settingsStore.showDate
            || settingsStore.showLunar
            || settingsStore.showTime
            || settingsStore.showWeekday
        if !anyOn {
            settingsStore.showIcon = true
        }
    }
}

