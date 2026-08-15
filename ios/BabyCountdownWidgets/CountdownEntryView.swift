import SwiftUI
import WidgetKit

struct CountdownEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: CountdownEntry

    var body: some View {
        switch family {
        case .systemSmall:
            HomeSmallView(entry: entry)
        case .systemMedium:
            HomeMediumView(entry: entry)
        case .accessoryCircular:
            LockCircularView(entry: entry)
        case .accessoryInline:
            LockInlineView(entry: entry)
        case .accessoryRectangular:
            LockRectangularView(entry: entry)
        default:
            EmptyView()
        }
    }
}

// MARK: - Home screen

private struct HomeSmallView: View {
    var entry: CountdownEntry

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                ProgressRing(progress: entry.snapshot.progress, lineWidth: 7, color: .accentOrange, trackColor: .track)
                VStack(spacing: 0) {
                    Text("\(entry.snapshot.daysRemaining)")
                        .font(.system(size: 44, weight: .light, design: .serif))
                        .foregroundStyle(Color.ink)
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                    Text(entry.snapshot.isOverdue ? "日目" : "日")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.accentOrange)
                }
            }
            Text(entry.snapshot.isOverdue ? "予定日すぎ" : "うまれるまで")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.mutedBrown)
        }
    }
}

private struct HomeMediumView: View {
    var entry: CountdownEntry

    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                ProgressRing(progress: entry.snapshot.progress, lineWidth: 8, color: .accentOrange, trackColor: .track)
                VStack(spacing: 0) {
                    Text("\(entry.snapshot.daysRemaining)")
                        .font(.system(size: 40, weight: .light, design: .serif))
                        .foregroundStyle(Color.ink)
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                    Text(entry.snapshot.isOverdue ? "日目" : "日")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.accentOrange)
                }
            }
            .frame(width: 104, height: 104)

            VStack(alignment: .leading, spacing: 8) {
                Text(entry.snapshot.isOverdue ? "予定日をすぎました" : "うまれるまで")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(Color.mutedBrown.opacity(0.75))
                Text("\(entry.snapshot.weeks)週\(entry.snapshot.weekRemainder)日")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.ink)
                Text(entry.snapshot.trimester.label)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color.accentOrange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Color.accentSoft))
            }
            Spacer(minLength: 0)
        }
    }
}

// MARK: - Lock screen

private struct LockCircularView: View {
    var entry: CountdownEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("\(entry.snapshot.daysRemaining)")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text("日")
                    .font(.system(size: 11, weight: .medium))
            }
        }
        .widgetLabel {
            ProgressView(
                value: entry.snapshot.progress,
                total: 1.0
            ) {
                Text("280日の旅")
            } currentValueLabel: {
                Text("\(Int(entry.snapshot.progress * 100))%")
            }
        }
    }
}

private struct LockInlineView: View {
    var entry: CountdownEntry

    var body: some View {
        if entry.snapshot.isOverdue {
            Text("予定日から \(abs(entry.snapshot.daysRemaining)) 日")
        } else if entry.snapshot.isDueToday {
            Text("今日が予定日です 🍼")
        } else {
            Text("うまれるまで あと\(entry.snapshot.daysRemaining)日")
        }
    }
}

private struct LockRectangularView: View {
    var entry: CountdownEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(entry.snapshot.daysRemaining)")
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text(entry.snapshot.isOverdue ? "日目" : "日")
                    .font(.system(size: 12, weight: .medium))
            }
            Text("\(entry.snapshot.weeks)週\(entry.snapshot.weekRemainder)日 ・ \(entry.snapshot.trimester.label)")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }
}
