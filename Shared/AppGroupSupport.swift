import Foundation

enum SharedContainer {
    static let appGroupIdentifier = AppGroupSupport.identifier

    static func rootDirectory() -> URL {
        let fileManager = FileManager.default

        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let target = groupURL.appendingPathComponent("HolidayCache", isDirectory: true)
            try? fileManager.createDirectory(at: target, withIntermediateDirectories: true)
            return target
        }

        let applicationSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let target = applicationSupport.appendingPathComponent("LunaCalendar/HolidayCache", isDirectory: true)
        try? fileManager.createDirectory(at: target, withIntermediateDirectories: true)
        return target
    }
}

enum AppGroupSupport {
    static let identifier = "group.luna.calendar"

    static let selectedDateURLKey = "app.selectedDateURL"
    static let holidayUpdatedYearKey = "app.holidayUpdatedYear"
    static let holidayLastRefreshPrefix = "holiday.lastRefresh."

    static func holidayRefreshKey(for year: Int) -> String {
        "\(holidayLastRefreshPrefix)\(year)"
    }

    private static var metadataURL: URL {
        SharedContainer.rootDirectory().appendingPathComponent("shared-metadata.json")
    }

    static func selectedDateURLString() -> String? {
        metadata()?.selectedDateURLString
    }

    static func setSelectedDateURLString(_ value: String?) {
        var payload = metadata() ?? SharedMetadata()
        payload.selectedDateURLString = value
        saveMetadata(payload)
    }

    static func holidayUpdatedYear() -> Int? {
        metadata()?.holidayUpdatedYear
    }

    static func setHolidayUpdatedYear(_ year: Int?) {
        var payload = metadata() ?? SharedMetadata()
        payload.holidayUpdatedYear = year
        saveMetadata(payload)
    }

    static func lastHolidayRefresh(for year: Int) -> TimeInterval? {
        metadata()?.holidayRefreshTimestamps[holidayRefreshKey(for: year)]
    }

    static func setLastHolidayRefresh(_ timestamp: TimeInterval?, for year: Int) {
        var payload = metadata() ?? SharedMetadata()
        payload.holidayRefreshTimestamps[holidayRefreshKey(for: year)] = timestamp
        saveMetadata(payload)
    }

    private static func metadata() -> SharedMetadata? {
        guard let data = try? Data(contentsOf: metadataURL) else { return nil }
        return try? JSONDecoder().decode(SharedMetadata.self, from: data)
    }

    private static func saveMetadata(_ payload: SharedMetadata) {
        guard let data = try? JSONEncoder().encode(payload) else { return }
        try? data.write(to: metadataURL, options: .atomic)
    }
}

private struct SharedMetadata: Codable {
    var selectedDateURLString: String?
    var holidayUpdatedYear: Int?
    var holidayRefreshTimestamps: [String: TimeInterval] = [:]
}

extension Notification.Name {
    static let holidayDataDidRefresh = Notification.Name("holidayDataDidRefresh")
}
