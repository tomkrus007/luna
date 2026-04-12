import Foundation

enum AppRoute {
    static let openHost = "open"

    static func url(for date: Date) -> URL? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        var components = URLComponents()
        components.scheme = "luna-calendar"
        components.host = openHost
        components.queryItems = [
            URLQueryItem(name: "date", value: formatter.string(from: date))
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

        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}
