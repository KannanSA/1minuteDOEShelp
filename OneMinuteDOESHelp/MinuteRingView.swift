import SwiftUI

struct MinuteRingView: View {
    let progress: Double
    let remainingSeconds: Int
    let isComplete: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(PeachTheme.wash, lineWidth: 22)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [PeachTheme.ringSoft, PeachTheme.ring, PeachTheme.ringSoft],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 22, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: PeachTheme.ring.opacity(0.35), radius: 10, y: 4)
                .animation(.easeOut(duration: 0.12), value: progress)

            VStack(spacing: 6) {
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundStyle(PeachTheme.ink)
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(PeachTheme.muted)
                } else {
                    Text("\(remainingSeconds)")
                        .font(.system(size: 72, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(PeachTheme.ink)
                    Text("seconds")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(PeachTheme.muted)
                }
            }
        }
        .frame(width: 268, height: 268)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(isComplete ? "Minute complete" : "\(remainingSeconds) seconds remaining")
    }
}
