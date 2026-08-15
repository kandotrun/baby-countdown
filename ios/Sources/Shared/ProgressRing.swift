import SwiftUI

/// 280日の旅リング。
struct ProgressRing: View {
    var progress: Double
    var lineWidth: CGFloat = 8
    var color: Color = .accentOrange
    var trackColor: Color = .track

    var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
