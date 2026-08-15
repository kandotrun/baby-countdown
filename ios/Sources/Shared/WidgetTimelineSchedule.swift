import Foundation

/// ウィジェット表示をJSTの日付境界で更新するためのタイムライン日付。
public enum WidgetTimelineSchedule {
    public static func entryDates(
        startingAt now: Date,
        days: Int,
        calendar: Calendar
    ) -> [Date] {
        guard days > 0 else { return [now] }

        let today = calendar.startOfDay(for: now)
        let futureDates = (1...days).compactMap { dayOffset -> Date? in
            guard let midnight = calendar.date(
                byAdding: .day,
                value: dayOffset,
                to: today
            ) else {
                return nil
            }
            return calendar.date(byAdding: .second, value: 1, to: midnight)
        }

        return [now] + futureDates
    }
}
