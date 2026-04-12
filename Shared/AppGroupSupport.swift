import Foundation

enum AppGroupSupport {
    static let identifier = "group.luna.calendar"

    static var userDefaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }

    static let selectedDateURLKey = "app.selectedDateURL"
    static let holidayUpdatedYearKey = "app.holidayUpdatedYear"
    static let holidayLastRefreshPrefix = "holiday.lastRefresh."

    static func holidayRefreshKey(for year: Int) -> String {
        "\(holidayLastRefreshPrefix)\(year)"
    }
}

extension Notification.Name {
    static let holidayDataDidRefresh = Notification.Name("holidayDataDidRefresh")
}
