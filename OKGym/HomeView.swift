import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GymStore

    var body: some View {
        NavigationStack {
            ZStack {
                GymTheme.black.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    weeklyStrip
                        .padding(.top, 8)
                    headline
                        .padding(.top, 28)
                    startButton
                        .padding(.top, 28)
                    workoutList
                        .padding(.top, 32)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .navigationDestination(isPresented: $store.sessionActive) {
                WorkoutSessionView()
            }
        }
        .tint(GymTheme.volt)
    }

    private var weeklyStrip: some View {
        HStack(spacing: 0) {
            ForEach(Array(store.weekStrip().enumerated()), id: \.offset) { _, day in
                VStack(spacing: 8) {
                    Text(day.label)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(day.isToday ? GymTheme.volt : GymTheme.mute)
                    Capsule()
                        .fill(day.done ? GymTheme.volt : (day.isToday ? GymTheme.white.opacity(0.35) : GymTheme.raised))
                        .frame(width: 28, height: 6)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(GymTheme.raised))
        .accessibilityLabel("Weekly training strip")
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: -6) {
            Text("TODAY")
                .font(.system(size: 22, weight: .semibold))
                .tracking(4)
                .foregroundStyle(GymTheme.mute)
            Text("IS")
                .font(.system(size: 22, weight: .semibold))
                .tracking(4)
                .foregroundStyle(GymTheme.mute)
            Text("PUSH")
                .font(.system(size: 84, weight: .black))
                .tracking(-3)
                .foregroundStyle(GymTheme.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Today is PUSH")
    }

    private var startButton: some View {
        Button {
            store.startWorkout()
        } label: {
            Text("Start workout")
                .font(.system(size: 18, weight: .heavy))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(Capsule().fill(GymTheme.volt))
                .foregroundStyle(Color.black)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("startWorkout")
    }

    private var workoutList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WORKOUT")
                .font(.system(size: 12, weight: .bold))
                .tracking(2)
                .foregroundStyle(GymTheme.mute)
                .padding(.bottom, 12)

            ForEach(store.todayLifts) { lift in
                HStack {
                    Text(lift.name.uppercased())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(GymTheme.white)
                    Spacer()
                    Text(lift.scheme)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundStyle(GymTheme.mute)
                }
                .padding(.vertical, 14)
                Divider().overlay(Color.white.opacity(0.08))
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(GymStore())
}
