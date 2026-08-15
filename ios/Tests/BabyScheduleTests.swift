import XCTest
@testable import BabyCountdown

final class BabyScheduleTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return calendar
    }

    private func date(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0
    ) -> Date {
        calendar.date(from: DateComponents(
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second
        ))!
    }

    func testWidgetTimelineRefreshesAtNextJSTMidnight() {
        let now = date(2026, 8, 3, hour: 21, minute: 30)
        let dates = WidgetTimelineSchedule.entryDates(
            startingAt: now,
            days: 7,
            calendar: calendar
        )

        XCTAssertEqual(dates.count, 8)
        XCTAssertEqual(dates[0], now)
        XCTAssertEqual(dates[1], date(2026, 8, 4, second: 1))
        XCTAssertEqual(dates[7], date(2026, 8, 10, second: 1))
    }

    func testDefaultDueDate() {
        let dueDate = BabySchedule.defaultDueDate
        XCTAssertEqual(calendar.component(.year, from: dueDate), 2027)
        XCTAssertEqual(calendar.component(.month, from: dueDate), 3)
        XCTAssertEqual(calendar.component(.day, from: dueDate), 8)
    }

    func testSnapshotMatchesWebVersionOn20260803() {
        // baby.kan.run と同じ日（2026-08-03）で同じ数値になること。
        let schedule = BabySchedule(dueDate: date(2027, 3, 8))
        let snapshot = schedule.snapshot(at: date(2026, 8, 3), calendar: calendar)

        XCTAssertEqual(snapshot.daysRemaining, 217)
        XCTAssertEqual(snapshot.elapsedDays, 63)
        XCTAssertEqual(snapshot.weeks, 9)
        XCTAssertEqual(snapshot.weekRemainder, 0)
        XCTAssertEqual(snapshot.gestationalWeek, 10)
        XCTAssertEqual(snapshot.trimester, .first)
        XCTAssertEqual(Int(snapshot.progress * 100), 22)
    }

    func testDueToday() {
        let schedule = BabySchedule(dueDate: date(2027, 3, 8))
        let snapshot = schedule.snapshot(at: date(2027, 3, 8), calendar: calendar)
        XCTAssertEqual(snapshot.daysRemaining, 0)
        XCTAssertTrue(snapshot.isDueToday)
        XCTAssertEqual(snapshot.progress, 1.0)
    }

    func testOverdue() {
        let schedule = BabySchedule(dueDate: date(2027, 3, 8))
        let snapshot = schedule.snapshot(at: date(2027, 3, 11), calendar: calendar)
        XCTAssertEqual(snapshot.daysRemaining, -3)
        XCTAssertTrue(snapshot.isOverdue)
        XCTAssertEqual(snapshot.progress, 1.0)
    }

    func testTrimesterBoundaries() {
        let schedule = BabySchedule(dueDate: date(2027, 3, 8))
        // 13週6日 → 初期 / 14週0日 → 中期 / 27週6日 → 中期 / 28週0日 → 後期
        let w13 = schedule.snapshot(at: date(2026, 9, 5), calendar: calendar)   // 96日 = 13週5日付近
        let w14 = date(2026, 9, 8)                                              // 99日 = 14週1日
        let s14 = schedule.snapshot(at: w14, calendar: calendar)
        let s28 = schedule.snapshot(at: date(2026, 12, 14), calendar: calendar) // 196日 = 28週0日
        XCTAssertEqual(w13.trimester, .first)
        XCTAssertEqual(s14.trimester, .second)
        XCTAssertEqual(s28.trimester, .third)
    }
}
