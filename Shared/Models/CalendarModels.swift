import Foundation

enum HolidayType: String, Codable, Hashable {
    case holiday
    case workday

    var badgeText: String {
        switch self {
        case .holiday: return "休"
        case .workday: return "班"
        }
    }
}

struct HolidayItem: Codable, Hashable, Identifiable {
    var id: String { dateString }
    let dateString: String
    let name: String
    let type: HolidayType
}

struct CalendarDayItem: Hashable, Identifiable {
    let date: Date
    let isCurrentMonth: Bool
    let isSelected: Bool
    let isWeekend: Bool
    let solarText: String
    let lunarText: String
    let festivalText: String?
    let holidayType: HolidayType?

    var id: String {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    var secondaryText: String {
        festivalText ?? lunarText
    }
}

struct HolidaySourceResponse: Decodable {
    let year: Int
    let papers: [String]?
    let days: [HolidaySourceDay]
}

struct HolidaySourceDay: Decodable {
    let name: String
    let date: String
    let isOffDay: Bool
}

struct HolidayCacheEnvelope: Codable {
    let year: Int
    let updatedAt: Date
    let items: [HolidayItem]
}
