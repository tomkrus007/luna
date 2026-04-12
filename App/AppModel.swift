import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    static let shared = AppModel()

    let settingsStore = SettingsStore.shared
    let calendarViewModel = CalendarViewModel()

    private init() {}
}
