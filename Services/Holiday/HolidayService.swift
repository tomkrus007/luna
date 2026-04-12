import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

enum HolidayCacheStore {
    static func load(year: Int) -> [String: HolidayItem] {
        let url = fileURL(for: year)
        guard
            let data = try? Data(contentsOf: url),
            let envelope = try? makeDecoder().decode(HolidayCacheEnvelope.self, from: data)
        else {
            return [:]
        }

        return Dictionary(uniqueKeysWithValues: envelope.items.map { ($0.dateString, $0) })
    }

    static func save(year: Int, items: [HolidayItem]) {
        let url = fileURL(for: year)
        let envelope = HolidayCacheEnvelope(year: year, updatedAt: .now, items: items.sorted { $0.dateString < $1.dateString })
        guard let data = try? makeEncoder().encode(envelope) else { return }
        try? data.write(to: url, options: .atomic)
        AppGroupSupport.setHolidayUpdatedYear(year)
        AppGroupSupport.setLastHolidayRefresh(Date().timeIntervalSince1970, for: year)
        NotificationCenter.default.post(name: .holidayDataDidRefresh, object: nil, userInfo: ["year": year])
#if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: "LunaCalendarWidget")
#endif
    }

    private static func fileURL(for year: Int) -> URL {
        SharedContainer.rootDirectory().appendingPathComponent("holiday_\(year).json")
    }

    private static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    private static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}

actor HolidayService {
    static let shared = HolidayService()

    private let refreshInterval: TimeInterval = 60 * 60 * 12

    func holidays(for year: Int) async -> [String: HolidayItem] {
        let cached = HolidayCacheStore.load(year: year)
        if !cached.isEmpty {
            if shouldRefresh(year: year) {
                Task { [self] in
                    _ = try? await self.refreshRemote(year: year)
                }
            }
            return cached
        }

        if let remote = try? await Self.fetchRemoteHolidays(year: year) {
            HolidayCacheStore.save(year: year, items: remote)
            return Dictionary(uniqueKeysWithValues: remote.map { ($0.dateString, $0) })
        }

        return [:]
    }

    func preloadAround(date: Date) async {
        let calendar = CalendarGridBuilder.calendar
        let currentYear = calendar.component(.year, from: date)
        let years = [currentYear - 1, currentYear, currentYear + 1]

        await withTaskGroup(of: Void.self) { group in
            for year in years where (1900...2100).contains(year) {
                group.addTask {
                    _ = await self.holidays(for: year)
                }
            }
        }
    }

    private func refreshRemote(year: Int) async throws -> [HolidayItem] {
        let remote = try await Self.fetchRemoteHolidays(year: year)
        HolidayCacheStore.save(year: year, items: remote)
        return remote
    }

    private func shouldRefresh(year: Int) -> Bool {
        guard let lastRefresh = AppGroupSupport.lastHolidayRefresh(for: year), lastRefresh > 0 else { return true }
        return Date().timeIntervalSince1970 - lastRefresh >= refreshInterval
    }

    private static func fetchRemoteHolidays(year: Int) async throws -> [HolidayItem] {
        let url = URL(string: "https://cdn.jsdelivr.net/gh/NateScarlet/holiday-cn@master/\(year).json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(HolidaySourceResponse.self, from: data)

        return response.days.map {
            HolidayItem(
                dateString: $0.date,
                name: $0.name,
                type: $0.isOffDay ? .holiday : .workday
            )
        }
    }
}
