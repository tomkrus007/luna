import SwiftUI

@main
struct LunaCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var settingsStore = SettingsStore.shared
    @StateObject private var calendarViewModel = CalendarViewModel()

    var body: some Scene {
        MenuBarExtra {
            CalendarWindowView(viewModel: calendarViewModel, settingsStore: settingsStore)
        } label: {
            MenuBarLabelView(settingsStore: settingsStore)
        }
        .menuBarExtraStyle(.window)
        .handlesExternalEvents(matching: Set(arrayLiteral: "open"))

        Settings {
            CalendarSettingsView(settingsStore: settingsStore)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "settings"))
        
        WindowGroup(id: "open") {
            CalendarWindowView(viewModel: calendarViewModel, settingsStore: settingsStore)
                .onOpenURL { url in
                    calendarViewModel.handleIncomingURL(url)
                }
        }
    }
}
