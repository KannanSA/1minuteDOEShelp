import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var streak: StreakStore
    @EnvironmentObject private var timer: MinuteTimer

    var body: some View {
        ZStack {
            PeachTheme.background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                header
                Spacer(minLength: 8)
                MinuteRingView(
                    progress: timer.isComplete ? 1 : timer.progress,
                    remainingSeconds: timer.isRunning || timer.isComplete ? timer.remainingWholeSeconds : 60,
                    isComplete: timer.isComplete
                )
                Text(streak.selectedAction.prompt)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(PeachTheme.muted)
                chips
                streakDots
                Spacer(minLength: 8)
                startButton
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 12)
        }
        .onChange(of: timer.isComplete) { _, complete in
            if complete {
                streak.markTodayComplete()
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("1 MINUTE")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(2.4)
                    .foregroundStyle(PeachTheme.muted)
                Text("DOES Help")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(PeachTheme.ink)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(streak.currentStreak())")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(PeachTheme.ink)
                Text("day streak")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(PeachTheme.muted)
            }
        }
    }

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MinuteAction.allCases) { action in
                    Button {
                        streak.selectedAction = action
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: action.symbol)
                            Text(action.rawValue)
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(streak.selectedAction == action ? PeachTheme.ink : PeachTheme.chipFill)
                        )
                        .foregroundStyle(streak.selectedAction == action ? PeachTheme.background : PeachTheme.ink)
                    }
                    .buttonStyle(.plain)
                    .disabled(timer.isRunning)
                    .accessibilityIdentifier("chip-\(action.rawValue)")
                }
            }
        }
    }

    private var streakDots: some View {
        HStack(spacing: 14) {
            ForEach(Array(streak.lastSevenDays().enumerated()), id: \.offset) { _, day in
                VStack(spacing: 8) {
                    Circle()
                        .fill(day.done ? PeachTheme.ring : Color.white.opacity(0.55))
                        .overlay(
                            Circle().stroke(PeachTheme.ring.opacity(day.done ? 0 : 0.35), lineWidth: 1.5)
                        )
                        .frame(width: 14, height: 14)
                    Text(day.label)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(PeachTheme.muted)
                }
            }
        }
        .padding(.top, 4)
        .accessibilityLabel("Weekly streak")
    }

    private var startButton: some View {
        Button(action: handlePrimary) {
            Text(buttonTitle)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Capsule().fill(PeachTheme.button))
                .foregroundStyle(Color.white)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("startOneMinute")
    }

    private var buttonTitle: String {
        if timer.isComplete { return "Do another minute" }
        if timer.isRunning { return "Stop" }
        return "Start 1 minute"
    }

    private func handlePrimary() {
        if timer.isRunning {
            timer.stop()
        } else if timer.isComplete {
            timer.acknowledgeCompletion()
            timer.start()
        } else {
            timer.start()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(StreakStore())
        .environmentObject(MinuteTimer())
}
