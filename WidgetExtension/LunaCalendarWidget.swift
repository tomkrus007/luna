import WidgetKit
import SwiftUI

struct LunaCalendarWidget: Widget {
    let kind = "LunaCalendarWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarWidgetProvider()) { entry in
            CalendarWidgetView(entry: entry)
        }
        .configurationDisplayName("万年历")
        .description("展示当天日期、农历和简化月历。")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
