import Foundation

/// App Group 経由で予定日をアプリ / ウィジェット間で共有する。
public enum DueDateStore {
    public static let appGroupID = "group.com.2-38.babycountdown"
    private static let key = "dueDate"

    public static func load() -> Date {
        guard
            let defaults = UserDefaults(suiteName: appGroupID),
            let stored = defaults.object(forKey: key) as? Date
        else {
            return BabySchedule.defaultDueDate
        }
        return stored
    }

    public static func save(_ date: Date) {
        guard let defaults = UserDefaults(suiteName: appGroupID) else { return }
        defaults.set(date, forKey: key)
    }
}
