import Foundation
import Combine

@MainActor
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    @Published var showIcon: Bool {
        didSet { defaults.set(showIcon, forKey: Keys.showIcon) }
    }

    @Published var showLunar: Bool {
        didSet { defaults.set(showLunar, forKey: Keys.showLunar) }
    }

    @Published var showTime: Bool {
        didSet { defaults.set(showTime, forKey: Keys.showTime) }
    }

    @Published var showWeekday: Bool {
        didSet { defaults.set(showWeekday, forKey: Keys.showWeekday) }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            LaunchAtLoginService.shared.syncRegistration(isEnabled: launchAtLogin)
        }
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = AppGroupSupport.userDefaults) {
        self.defaults = defaults
        self.showIcon = defaults.object(forKey: Keys.showIcon) as? Bool ?? false
        self.showLunar = defaults.object(forKey: Keys.showLunar) as? Bool ?? true
        self.showTime = defaults.object(forKey: Keys.showTime) as? Bool ?? true
        self.showWeekday = defaults.object(forKey: Keys.showWeekday) as? Bool ?? true
        self.launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
    }

    private enum Keys {
        static let showIcon = "settings.showIcon"
        static let showLunar = "settings.showLunar"
        static let showTime = "settings.showTime"
        static let showWeekday = "settings.showWeekday"
        static let launchAtLogin = "settings.launchAtLogin"
    }
}
