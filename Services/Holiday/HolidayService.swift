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
        let sortedItems = items.sorted { $0.dateString < $1.dateString }
        let existingItems = loadItems(year: year)

        guard existingItems != sortedItems else {
            AppGroupSupport.setLastHolidayRefresh(Date().timeIntervalSince1970, for: year)
            return
        }

        let envelope = HolidayCacheEnvelope(year: year, updatedAt: .now, items: sortedItems)
        guard let data = try? makeEncoder().encode(envelope) else { return }
        try? data.write(to: url, options: .atomic)
        AppGroupSupport.setHolidayUpdatedYear(year)
        AppGroupSupport.setLastHolidayRefresh(Date().timeIntervalSince1970, for: year)
        NotificationCenter.default.post(name: .holidayDataDidRefresh, object: nil, userInfo: ["year": year])
#if canImport(WidgetKit) && !WIDGET_EXTENSION
        WidgetCenter.shared.reloadTimelines(ofKind: "LunaCalendarWidget")
#endif
    }

    private static func loadItems(year: Int) -> [HolidayItem] {
        let url = fileURL(for: year)
        guard
            let data = try? Data(contentsOf: url),
            let envelope = try? makeDecoder().decode(HolidayCacheEnvelope.self, from: data)
        else {
            return []
        }

        return envelope.items
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

    private var loadingYears = Set<Int>()
    private var loadTasks: [Int: Task<[String: HolidayItem], Never>] = [:]
    private var refreshingYears = Set<Int>()
    private var refreshTasks: [Int: Task<Void, Never>] = [:]

    func holidays(for year: Int, triggerRefreshIfNeeded: Bool = false) async -> [String: HolidayItem] {
        let cached = HolidayCacheStore.load(year: year)
        if !cached.isEmpty {
            if triggerRefreshIfNeeded {
                scheduleRefreshIfNeeded(for: year)
            }
            return cached
        }

        if let existingTask = loadTasks[year] {
            return await existingTask.value
        }

        loadingYears.insert(year)
        let task = Task<[String: HolidayItem], Never> {
            guard !Task.isCancelled else { return [:] }

            if let remote = try? await Self.fetchRemoteHolidays(year: year) {
                guard !Task.isCancelled else { return [:] }
                HolidayCacheStore.save(year: year, items: remote)
                return Dictionary(uniqueKeysWithValues: remote.map { ($0.dateString, $0) })
            }

            return [:]
        }
        loadTasks[year] = task

        let result = await task.value
        loadTasks[year] = nil
        loadingYears.remove(year)
        return result
    }

    func preloadAround(date: Date, excluding excludedYears: Set<Int> = []) async {
        let calendar = CalendarGridBuilder.calendar
        let currentYear = calendar.component(.year, from: date)
        let years = [currentYear - 1, currentYear, currentYear + 1]

        await withTaskGroup(of: Void.self) { group in
            for year in years where (1900...2100).contains(year) && !excludedYears.contains(year) {
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

    private func scheduleRefreshIfNeeded(for year: Int) {
        guard shouldRefresh(year: year), !refreshingYears.contains(year) else { return }
        refreshingYears.insert(year)

        let task = Task { [self] in
            defer { self.finishRefresh(for: year) }
            guard !Task.isCancelled else { return }
            _ = try? await self.refreshRemote(year: year)
        }
        refreshTasks[year] = task
    }

    private func finishRefresh(for year: Int) {
        refreshTasks[year] = nil
        refreshingYears.remove(year)
    }

    func cancelRefreshes() {
        for task in loadTasks.values {
            task.cancel()
        }
        loadTasks.removeAll()
        loadingYears.removeAll()

        for task in refreshTasks.values {
            task.cancel()
        }
        refreshTasks.removeAll()
        refreshingYears.removeAll()
    }

    private func shouldRefresh(year: Int) -> Bool {
        guard let lastRefresh = AppGroupSupport.lastHolidayRefresh(for: year), lastRefresh > 0 else { return true }
        return Date().timeIntervalSince1970 - lastRefresh >= 60 * 60 * 12
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
