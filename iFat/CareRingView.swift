import SwiftUI

struct CareRingView: View {
    let completed: Int
    let total: Int

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(SageTheme.ringTrack, lineWidth: 16)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    SageTheme.sage,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.35), value: progress)

            VStack(spacing: 2) {
                Text("\(completed) of \(total)")
                    .font(.system(size: 28, weight: .semibold, design: .serif))
                    .foregroundStyle(SageTheme.ink)
                Text("daily care")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(SageTheme.muted)
            }
        }
        .frame(width: 168, height: 168)
        .accessibilityLabel("Daily care \(completed) of \(total)")
    }
}
