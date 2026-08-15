import SwiftUI
import WidgetKit

/// ホーム画面（systemSmall / systemMedium）とロック画面
/// （accessoryCircular / accessoryInline / accessoryRectangular）のカウントダウン。
struct CountdownWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CountdownWidget", provider: CountdownProvider()) { entry in
            CountdownEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.paper
                }
        }
        .configurationDisplayName("うまれるまで")
        .description("予定日までのカウントダウンと妊娠週数を表示します。")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular,
        ])
    }
}

struct CountdownEntry: TimelineEntry {
    let date: Date
    let snapshot: BabySchedule.Snapshot
}

struct CountdownProvider: TimelineProvider {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return calendar
    }

    private func makeEntry(_ date: Date) -> CountdownEntry {
        let schedule = BabySchedule(dueDate: DueDateStore.load())
        return CountdownEntry(date: date, snapshot: schedule.snapshot(at: date, calendar: calendar))
    }

    func placeholder(in context: Context) -> CountdownEntry {
        makeEntry(.now)
    }

    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        completion(makeEntry(.now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let now = Date()
        let entries = WidgetTimelineSchedule.entryDates(
            startingAt: now,
            days: 7,
            calendar: calendar
        ).map(makeEntry)

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}
