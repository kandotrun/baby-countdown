import Foundation

/// 予定日に基づく妊娠経過の計算。
///
/// 基準: 予定日 - 280日（40週）を妊娠基準開始日とする。
/// baby.kan.run（Web版）と同じ計算ロジック。
public struct BabySchedule: Sendable, Equatable {
    public static let gestationDays = 280

    public var dueDate: Date

    public init(dueDate: Date) {
        self.dueDate = dueDate
    }

    /// デフォルト予定日: 2027-03-08 (JST)。
    public static var defaultDueDate: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return calendar.date(from: DateComponents(year: 2027, month: 3, day: 8)) ?? .now
    }

    public enum Trimester: Sendable, Equatable {
        case first
        case second
        case third

        public var label: String {
            switch self {
            case .first: return "妊娠初期"
            case .second: return "妊娠中期"
            case .third: return "妊娠後期"
            }
        }
    }

    public struct Snapshot: Sendable, Equatable {
        /// 予定日（startOfDay）
        public let dueDay: Date
        /// 予定日までの残り日数（予定日超過は負）
        public let daysRemaining: Int
        /// 妊娠基準開始日からの経過日数
        public let elapsedDays: Int
        /// 妊娠週数（経過日数 / 7）
        public let weeks: Int
        /// 週内の日数
        public let weekRemainder: Int
        /// 「N週目」表示用の週番号（weeks + 1）
        public let gestationalWeek: Int
        /// 280日に対する進捗（0...1）
        public let progress: Double
        public let trimester: Trimester

        public var isDueToday: Bool { daysRemaining == 0 }
        public var isOverdue: Bool { daysRemaining < 0 }
    }

    public func snapshot(at date: Date, calendar: Calendar) -> Snapshot {
        let today = calendar.startOfDay(for: date)
        let dueDay = calendar.startOfDay(for: dueDate)
        let baseline = calendar.date(byAdding: .day, value: -Self.gestationDays, to: dueDay) ?? dueDay

        let daysRemaining = calendar.dateComponents([.day], from: today, to: dueDay).day ?? 0
        let elapsedRaw = calendar.dateComponents([.day], from: baseline, to: today).day ?? 0
        let elapsedDays = max(elapsedRaw, 0)

        let weeks = elapsedDays / 7
        let weekRemainder = elapsedDays % 7
        let progress = min(max(Double(elapsedDays) / Double(Self.gestationDays), 0), 1)

        let trimester: Trimester
        if weeks < 14 {
            trimester = .first
        } else if weeks < 28 {
            trimester = .second
        } else {
            trimester = .third
        }

        return Snapshot(
            dueDay: dueDay,
            daysRemaining: daysRemaining,
            elapsedDays: elapsedDays,
            weeks: weeks,
            weekRemainder: weekRemainder,
            gestationalWeek: weeks + 1,
            progress: progress,
            trimester: trimester
        )
    }
}
