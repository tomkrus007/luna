import Foundation

enum AppRoute {
    static let openHost = "open"

    static func url(for date: Date) -> URL? {
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let year = dateComponents.year ?? 0
        let month = dateComponents.month ?? 0
        let day = dateComponents.day ?? 0
        let dateString = String(format: "%04d-%02d-%02d", year, month, day)

        var components = URLComponents()
        components.scheme = "luna-calendar"
        components.host = openHost
        components.queryItems = [
            URLQueryItem(name: "date", value: dateString)
        ]
        return components.url
    }

    static func parseDate(from url: URL) -> Date? {
        guard url.scheme == "luna-calendar", url.host == openHost else {
            return nil
        }

        let dateString = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .first(where: { $0.name == "date" })?
            .value

        guard let dateString else { return nil }

        let parts = dateString.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return dateComponents.date
    }
}
