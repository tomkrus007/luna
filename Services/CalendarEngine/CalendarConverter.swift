import Foundation

enum CalendarConverter {
    private static let chineseCalendar = Calendar(identifier: .chinese)
    private static let gregorianCalendar = Calendar(identifier: .gregorian)

    static let solarTerm = ["小寒", "大寒", "立春", "雨水", "惊蛰", "春分", "清明", "谷雨", "立夏", "小满", "芒种", "夏至", "小暑", "大暑", "立秋", "处暑", "白露", "秋分", "寒露", "霜降", "立冬", "小雪", "大雪", "冬至"]

    private static let solarTermMinutes = [0, 21208, 42467, 63836, 85337, 107014, 128867, 150921, 173149, 195551, 218072, 240693, 263343, 285989, 308563, 331033, 353350, 375494, 397447, 419210, 440795, 462224, 483532, 504758]

    private static let solarFestivals: [String: String] = [
        "1-1": "元旦",
        "2-14": "情人节",
        "3-8": "妇女节",
        "4-1": "愚人节",
        "5-1": "劳动节",
        "6-1": "儿童节",
        "9-10": "教师节",
        "10-1": "国庆节",
        "12-25": "圣诞节"
    ]

    private static let lunarFestivals: [String: String] = [
        "1-1": "春节",
        "1-15": "元宵节",
        "5-5": "端午节",
        "7-7": "七夕",
        "8-15": "中秋",
        "9-9": "重阳",
        "12-8": "腊八",
        "12-23": "小年"
    ]

    private static let lunarMonthNames = ["正", "二", "三", "四", "五", "六", "七", "八", "九", "十", "冬", "腊"]
    private static let lunarDayPrefixes = ["初", "十", "廿", "卅"]
    private static let lunarDayDigits = ["日", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]

    static func getLunarDate(for dateComponents: DateComponents) -> String {
        guard let date = gregorianCalendar.date(from: dateComponents) else {
            return ""
        }
        let lunar = chineseCalendar.dateComponents([.month, .day, .isLeapMonth], from: date)
        guard let month = lunar.month, let day = lunar.day else {
            return ""
        }

        let monthText = (lunar.isLeapMonth == true ? "闰" : "") + toChinaMonth(month)
        return "\(monthText)\(toChinaDay(day))"
    }

    static func getStatusBarLunarText(for date: Date) -> String {
        let lunar = chineseCalendar.dateComponents([.month, .day, .isLeapMonth], from: date)
        guard let month = lunar.month, let day = lunar.day else {
            return ""
        }
        let monthText = (lunar.isLeapMonth == true ? "闰" : "") + toChinaMonth(month)
        return "\(monthText)\(toChinaDay(day))"
    }

    static func getFestival(for dateComponents: DateComponents) -> String? {
        guard let date = gregorianCalendar.date(from: dateComponents) else {
            return nil
        }
        let solar = gregorianCalendar.dateComponents([.month, .day], from: date)
        if let month = solar.month, let day = solar.day, let solarFestival = solarFestivals["\(month)-\(day)"] {
            return solarFestival
        }

        let lunar = chineseCalendar.dateComponents([.month, .day], from: date)
        if let month = lunar.month, let day = lunar.day {
            return lunarFestivals["\(month)-\(day)"]
        }

        return nil
    }

    static func getPrimaryDisplayText(for date: Date) -> String {
        let components = gregorianCalendar.dateComponents([.year, .month, .day], from: date)

        if let festival = getFestival(for: components) {
            return festival
        }

        if let solarTerm = getSolarTermName(for: components) {
            return solarTerm
        }

        let lunar = chineseCalendar.dateComponents([.day], from: date)
        guard let lunarDay = lunar.day else {
            return ""
        }
        return toChinaDay(lunarDay)
    }

    static func getSolarTermName(for dateComponents: DateComponents) -> String? {
        guard let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else {
            return nil
        }

        let firstIndex = (month - 1) * 2
        let secondIndex = firstIndex + 1

        if solarTermDay(year: year, index: firstIndex) == day {
            return solarTerm[firstIndex]
        }

        if solarTermDay(year: year, index: secondIndex) == day {
            return solarTerm[secondIndex]
        }

        return nil
    }

    static func getTerm(_ year: Int, _ n: Int) -> Int {
        guard n >= 1 && n <= 24 else { return -1 }
        return solarTermDay(year: year, index: n - 1)
    }

    static func toChinaMonth(_ month: Int) -> String {
        guard (1...12).contains(month) else { return "" }
        return lunarMonthNames[month - 1] + "月"
    }

    static func toChinaDay(_ day: Int) -> String {
        guard (1...30).contains(day) else { return "" }
        switch day {
        case 10: return "初十"
        case 20: return "二十"
        case 30: return "三十"
        default:
            return lunarDayPrefixes[day / 10] + lunarDayDigits[day % 10]
        }
    }

    private static func solarTermDay(year: Int, index: Int) -> Int {
        guard (1900...2100).contains(year), solarTermMinutes.indices.contains(index) else {
            return -1
        }

        let baseUTC = DateComponents(
            calendar: gregorianCalendar,
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 1900,
            month: 1,
            day: 6,
            hour: 2,
            minute: 5
        ).date ?? .now

        let seconds = Double(year - 1900) * 31_556_925.9747 + Double(solarTermMinutes[index] * 60)
        let termDate = baseUTC.addingTimeInterval(seconds)
        return gregorianCalendar.component(.day, from: termDate)
    }
}
