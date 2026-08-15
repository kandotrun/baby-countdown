import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var dueDate: Date = DueDateStore.load()

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return calendar
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let schedule = BabySchedule(dueDate: dueDate)
            let snapshot = schedule.snapshot(at: context.date, calendar: calendar)
            ScrollView {
                VStack(spacing: 28) {
                    header(snapshot)
                    bigNumber(snapshot)
                    heartbeat
                    panel(snapshot)
                    timelineBar(snapshot)
                    settings
                    Text("すくすく、育ってますように。")
                        .font(.footnote)
                        .foregroundStyle(Color.mutedBrown.opacity(0.8))
                        .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .background(
                LinearGradient(
                    colors: [Color.white.opacity(0.6), Color.clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .background(Color.paper)
                .ignoresSafeArea()
            )
        }
    }

    // MARK: - Sections

    private func header(_ snapshot: BabySchedule.Snapshot) -> some View {
        VStack(spacing: 10) {
            Text("BABY COUNTDOWN")
                .font(.system(size: 11, weight: .bold))
                .tracking(4.5)
                .foregroundStyle(Color.mutedBrown.opacity(0.7))
            let formatted = snapshot.dueDay.formatted(
                .dateTime.year().month(.defaultDigits).day().weekday(.abbreviated)
            )
            Text("予定日 \(formatted)")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.mutedBrown)
        }
    }

    private func bigNumber(_ snapshot: BabySchedule.Snapshot) -> some View {
        VStack(spacing: 4) {
            if snapshot.isOverdue {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(abs(snapshot.daysRemaining))")
                        .font(.system(size: 120, weight: .light, design: .serif))
                        .foregroundStyle(Color.ink)
                        .monospacedDigit()
                    Text("日目")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.accentOrange)
                }
                Text("予定日をすぎて、今日で \(abs(snapshot.daysRemaining)) 日。")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.mutedBrown)
            } else if snapshot.isDueToday {
                Text("0")
                    .font(.system(size: 120, weight: .light, design: .serif))
                    .foregroundStyle(Color.ink)
                Text("今日が予定日です。まもなく、会える。")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.mutedBrown)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(snapshot.daysRemaining)")
                        .font(.system(size: 120, weight: .light, design: .serif))
                        .foregroundStyle(Color.ink)
                        .monospacedDigit()
                        .minimumScaleFactor(0.5)
                    Text("日")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.accentOrange)
                }
                Text("うまれるまで、あと")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.mutedBrown)
            }
        }
    }

    private var heartbeat: some View {
        Circle()
            .fill(Color.accentOrange)
            .frame(width: 10, height: 10)
            .shadow(color: Color.accentOrange.opacity(0.4), radius: 6)
            .accessibilityHidden(true)
    }

    private func panel(_ snapshot: BabySchedule.Snapshot) -> some View {
        HStack(spacing: 28) {
            ZStack {
                ProgressRing(progress: snapshot.progress, lineWidth: 10)
                    .frame(width: 130, height: 130)
                VStack(spacing: 2) {
                    Text("\(Int(snapshot.progress * 100))%")
                        .font(.system(size: 28, weight: .regular, design: .serif))
                        .foregroundStyle(Color.ink)
                    Text("280日の旅")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.mutedBrown)
                        .tracking(1)
                }
            }
            VStack(alignment: .leading, spacing: 14) {
                statRow("いま何週", "\(snapshot.weeks)週\(snapshot.weekRemainder)日", sub: "\(snapshot.gestationalWeek)週目")
                statRow("経過", "\(snapshot.elapsedDays)日目", sub: "/ 280日")
                Text(snapshot.trimester.label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(Color.accentOrange)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(Color.accentSoft))
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.brown.opacity(0.12), radius: 24, y: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.track.opacity(0.6))
        )
    }

    private func statRow(_ key: String, _ value: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(key)
                .font(.system(size: 10, weight: .bold))
                .tracking(2)
                .foregroundStyle(Color.mutedBrown.opacity(0.7))
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.ink)
                Text(sub)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.mutedBrown)
            }
        }
    }

    private func timelineBar(_ snapshot: BabySchedule.Snapshot) -> some View {
        VStack(spacing: 10) {
            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.track)
                        .frame(height: 8)
                    // 中期・後期の区切り
                    Capsule().fill(Color.white).frame(width: 2, height: 8).offset(x: width * 0.35)
                    Capsule().fill(Color.white).frame(width: 2, height: 8).offset(x: width * 0.70)
                    Capsule()
                        .fill(LinearGradient(colors: [Color.accentOrange.opacity(0.6), Color.accentOrange], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(width * snapshot.progress, 8), height: 8)
                    Circle()
                        .fill(Color.white)
                        .overlay(Circle().strokeBorder(Color.accentOrange, lineWidth: 3))
                        .frame(width: 16, height: 16)
                        .shadow(color: Color.accentOrange.opacity(0.35), radius: 4, y: 2)
                        .offset(x: max(width * snapshot.progress - 8, 0))
                }
            }
            .frame(height: 16)
            HStack {
                Text("初期").foregroundStyle(snapshot.weeks < 14 && !snapshot.isOverdue ? Color.accentOrange : Color.mutedBrown.opacity(0.5))
                Spacer()
                Text("中期").foregroundStyle((14..<28).contains(snapshot.weeks) ? Color.accentOrange : Color.mutedBrown.opacity(0.5))
                Spacer()
                Text("後期").foregroundStyle(snapshot.weeks >= 28 ? Color.accentOrange : Color.mutedBrown.opacity(0.5))
                Spacer()
                Text("誕生").foregroundStyle(Color.mutedBrown.opacity(0.5))
            }
            .font(.system(size: 11, weight: .bold))
            .tracking(1.5)
        }
    }

    private var settings: some View {
        VStack(alignment: .leading, spacing: 16) {
            DatePicker(
                "予定日",
                selection: $dueDate,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .environment(\.timeZone, TimeZone(identifier: "Asia/Tokyo") ?? .current)
            .font(.system(size: 14, weight: .medium))
            .onChange(of: dueDate) { _, newValue in
                DueDateStore.save(newValue)
                WidgetCenter.shared.reloadTimelines(ofKind: "CountdownWidget")
            }

            Divider().overlay(Color.track)

            widgetGuide
        }
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.brown.opacity(0.10), radius: 20, y: 12)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.track.opacity(0.6))
        )
    }

    private var widgetGuide: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("ウィジェットを追加", systemImage: "rectangle.3.group")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Color.ink)

            Text("ホーム画面またはロック画面を長押しして、「ウィジェットを追加」から「うまれるまで」を選んでください。")
                .font(.system(size: 12))
                .foregroundStyle(Color.mutedBrown.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                widgetFamilyLabel("ホーム画面", detail: "小・中")
                widgetFamilyLabel("ロック画面", detail: "円・横長・1行")
            }

            Text("表示はJST 0時に自動更新されます。アプリを毎日開く必要はありません。")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.accentOrange)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func widgetFamilyLabel(_ title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.ink)
            Text(detail)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.mutedBrown)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.accentSoft.opacity(0.65)))
    }
}

#Preview {
    ContentView()
}
